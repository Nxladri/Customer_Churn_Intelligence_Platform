/*Using CTEs, build a dataset with:
* CustomerID
* TotalOrders
* TotalRevenue
* AvgOrderValue
* DaysSinceLastOrder*/

WITH Dataset AS 
(
	SELECT H.CustomerID,SUM(D.LineTotal) AS TotalRevenue ,
	COUNT(DISTINCT H.SalesOrderID) AS TotalOrders,
	MAX(H.OrderDate) AS LatestOrderDate
	FROM Sales.SalesOrderDetail AS D
		LEFT JOIN Sales.SalesOrderHeader AS H
	ON D.SalesOrderID = H.SalesOrderID
	GROUP BY H.CustomerID
)


SELECT df.CustomerID,df.TotalOrders,df.TotalRevenue,
(df.TotalRevenue * 1.0 /df.TotalOrders) AS AvgOrderValue,
DATEDIFF(DAY,df.LatestOrderDate,(SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader)) AS DaysSinceLastOrder
FROM Dataset AS df
ORDER BY df.CustomerID


/*10) Using CTEs, create a churn label:
ChurnLabel = 1 if DaysSinceLastOrder > 90 0 otherwise*/

WITH Recency AS 
(
	SELECT H.CustomerID,
	MAX(H.OrderDate) AS LatestOrderDate
	FROM Sales.SalesOrderHeader AS H
	GROUP BY H.CustomerID
)

SELECT R.CustomerID,R.LatestOrderDate,
DATEDIFF(DAY,
R.LatestOrderDate,
(SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader)) AS DaysSinceLastOrder,
CASE WHEN  
DATEDIFF(DAY,
LatestOrderDate,
(SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader)) > 90 THEN 0
ELSE 1 END AS ChurnLabel
FROM Recency AS R
ORDER BY R.CustomerID