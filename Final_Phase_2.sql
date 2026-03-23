CREATE VIEW Sales.CustomerChurnPredictionFeature AS
WITH CTE_1 AS
(
	-- Total Revenue , AvgOrderValue, most and least recent order date
	SELECT H.CustomerID,SUM(D.LineTotal) AS TotalRevenue,
	COUNT(DISTINCT D.SalesOrderID) AS OrderFrequency,
	(SUM(D.LineTotal) * 1.0 / NULLIF(COUNT(DISTINCT D.SalesOrderID),0)) AS AvgOrderValue,
	MAX(H.OrderDate) MostRecentOrderDate,
	MIN(H.OrderDate) LeastRecentOrderDate
	FROM Sales.SalesOrderDetail AS D
	LEFT JOIN Sales.SalesOrderHeader AS H
	ON D.SalesOrderID = H.SalesOrderID
	GROUP BY H.CustomerID
),
CTE_2 AS 
(
	-- recency,loyality
	SELECT * ,
	YEAR(A.MostRecentOrderDate) LastOrderYear,
	DATEDIFF(DAY,A.MostRecentOrderDate,MAX(A.MostRecentOrderDate) OVER()) AS DaysSinceLastOrder,
	DATEDIFF(DAY,A.LeastRecentOrderDate,MAX(A.MostRecentOrderDate) OVER()) AS CustomerTenure
	FROM CTE_1 AS A
),
CTE_3 AS
(
	--Variety of products,
	SELECT N.CustomerID ,COUNT(DISTINCT PS.ProductSubcategoryID) AS TotalProductSubCategories
	FROM CTE_2 AS N
	LEFT JOIN Sales.SalesOrderHeader AS H
	ON N.CustomerID = H.CustomerID
	LEFT JOIN Sales.SalesOrderDetail AS D
	ON H.SalesOrderID = D.SalesOrderID
	LEFT JOIN Production.Product AS P
	ON D.ProductID = P.ProductID
	LEFT JOIN Production.ProductSubcategory AS PS
	ON P.ProductSubcategoryID = PS.ProductSubcategoryID
	GROUP BY N.CustomerID
),
CTE_4 AS
(
	-- Count orders per customer per category:
	SELECT H.CustomerID , PC.Name,
	COUNT(DISTINCT H.SalesOrderID) AS Orders
	FROM Sales.SalesOrderHeader AS H
	LEFT JOIN Sales.SalesOrderDetail AS D
	ON H.SalesOrderID = D.SalesOrderID
	LEFT JOIN Production.Product AS P
	ON D.ProductID = P.ProductID
	LEFT JOIN Production.ProductSubcategory AS PS
	ON P.ProductSubcategoryID = PS.ProductSubcategoryID
	LEFT JOIN Production.ProductCategory AS PC
	ON PS.ProductCategoryID = PC.ProductCategoryID
	GROUP BY H.CustomerID , PC.Name
),
CTE_5 AS
	(
	SELECT * , 
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY Orders DESC) AS RowNum
	FROM CTE_4 
	),
OrderSequence AS (
   -- Days between customer last order and recent order
			SELECT H.CustomerID,H.OrderDate,H.SalesOrderID,
			LAG(H.OrderDate) OVER(PARTITION BY H.CustomerID ORDER BY H.OrderDate) AS PreviousOrder
			FROM Sales.SalesOrderHeader AS H
),
	GapCalculation AS (
	   -- Calaculate the difference
	   SELECT *,
			DATEDIFF(DAY,PreviousOrder,OrderDate) AS DaysGap
			FROM OrderSequence
),
	AvgGap AS (
	   -- Average Gap between orders for each customer
	   SELECT CustomerID, 
		AVG(DaysGap) AS AvgDaysBetweenOrders
		FROM GapCalculation
		GROUP BY CustomerID
),
LastButNotTheLeast AS
(
	SELECT C2.CustomerID,
	C2.DaysSinceLastOrder,
	C2.CustomerTenure,
	C2.AvgOrderValue,
	C2.TotalRevenue,
	C2.OrderFrequency,
	C2.LeastRecentOrderDate,
	C2.MostRecentOrderDate,
	C3.TotalProductSubCategories,
	C5.Name AS MostPurchasedCategory,
	AG.AvgDaysBetweenOrders,

	-- Recency Ratio.
	CASE 
	WHEN AG.AvgDaysBetweenOrders IS NOT NULL THEN 
	(C2.DaysSinceLastOrder * 1.0) / NULLIF(AG.AvgDaysBetweenOrders,0)
	ELSE NULL
	END AS RecencyRatio,

	--One time Buyer
	CASE 
	WHEN AG.AvgDaysBetweenOrders IS NULL THEN 1
	ELSE 0
	END AS OneTimeBuyer,

	-- Churn Label
	CASE 
	WHEN C2.DaysSinceLastOrder > 180 THEN 1
	ELSE 0
	END AS ChurnLabel

	FROM CTE_2 AS C2
	LEFT JOIN CTE_3 AS C3
	ON C2.CustomerID = C3.CustomerID
	LEFT JOIN CTE_5 AS C5
	ON C2.CustomerID = C5.CustomerID
	AND C5.RowNum = 1
	LEFT JOIN AvgGap AS AG
	ON C2.CustomerID = AG.CustomerID
)
SELECT 
    CustomerID,
    DaysSinceLastOrder,
    CustomerTenure,
    AvgOrderValue,
    TotalRevenue,
    OrderFrequency,
    LeastRecentOrderDate,
    MostRecentOrderDate,
    TotalProductSubCategories,
    MostPurchasedCategory,
    AvgDaysBetweenOrders,
    RecencyRatio,
    OneTimeBuyer,
    ChurnLabel
FROM LastButNotTheLeast;