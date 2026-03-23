/* 11) Build a CTE pipeline (multiple CTEs chained):
CTE1 → Aggregate customer metrics CTE2 → Calculate recency CTE3 → Create churn label
Final SELECT → return full feature table.*/
WITH CTE_1 AS 
(
	SELECT H.CustomerID,SUM(D.LineTotal) AS TotalRevenue ,
	COUNT(DISTINCT H.SalesOrderID) AS TotalOrders,
	MAX(H.OrderDate) AS LatestOrderDate,
	(SUM(D.LineTotal) * 1.0  /NULLIF(COUNT(DISTINCT H.SalesOrderID), 0)) AS AvgOrderValue
	FROM Sales.SalesOrderHeader AS H
		LEFT JOIN Sales.SalesOrderDetail AS D
	ON D.SalesOrderID = H.SalesOrderID
	GROUP BY H.CustomerID
),
CTE_2 AS
(
SELECT 
	*,
	DATEDIFF(DAY,
	A.LatestOrderDate,
	 MAX(LatestOrderDate) OVER()) AS DaysSinceLastOrder
	FROM CTE_1 AS A
),
CTE_3 AS
(
SELECT * ,
CASE WHEN  
B.DaysSinceLastOrder> 90 THEN 1
ELSE 0 END AS ChurnLabel 
FROM CTE_2 AS B
)


SELECT * FROM CTE_3
ORDER BY CustomerID



/*
Q12 (Advanced)
Create a CTE that identifies “high-value customers”:
* Top 20% by total revenue
* Then compare their average order frequency vs remaining customers...*/

WITH CTE_HVC AS
(
	SELECT H.CustomerID ,SUM(D.LineTotal)  AS TotalRevenue , 
	COUNT(DISTINCT D.SalesOrderID) AS OrderFrequency
	FROM Sales.SalesOrderHeader AS H
		LEFT JOIN Sales.SalesOrderDetail AS D
	ON H.SalesOrderID = D.SalesOrderID
	GROUP BY H.CustomerID
),
PERCENT_CALC AS (
	SELECT * , 
	NTILE(5) OVER(ORDER BY hvc.TotalRevenue DESC) AS PercentContribution
	FROM CTE_HVC AS hvc)

SELECT 
	CASE WHEN PercentContribution < 2 THEN 'HighValueCustomer'
	ELSE 'RegularCustomer'
	END AS Ranking,
	AVG(OrderFrequency) AS AverageOrderFrequency
FROM PERCENT_CALC
GROUP BY CASE WHEN PercentContribution < 2 THEN 'HighValueCustomer'
	ELSE 'RegularCustomer'
	END ;


--Identify customers contributing to the top 20% of total revenue (Pareto logic).

WITH CTE_HVC AS
(
	SELECT H.CustomerID ,SUM(D.LineTotal)  AS TotalRevenue , 
	COUNT(DISTINCT D.SalesOrderID) AS OrderFrequency
	FROM Sales.SalesOrderHeader AS H
		LEFT JOIN Sales.SalesOrderDetail AS D
	ON H.SalesOrderID = D.SalesOrderID
	GROUP BY H.CustomerID
),
Cust_TR AS
(
	SELECT * , 
	SUM(hvc.TotalRevenue) OVER(ORDER BY hvc.TotalRevenue DESC) AS CumulativeRevenue,
	SUM(hvc.TotalRevenue) OVER() AS TotalRevenueOfAllCustomers
	FROM CTE_HVC AS hvc
)

SELECT * 
FROM 
(
SELECT *,
(tr.CumulativeRevenue * 1.0 /tr.TotalRevenueOfAllCustomers) AS P_Revenue
FROM Cust_TR AS tr)t
WHERE P_Revenue <= 0.2
