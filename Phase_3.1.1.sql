--7) Create a CTE that calculates running total revenue per customer ordered by date. 
--Then select the last running total per customer.
WITH Cte_tr AS
(
 SELECT H.CustomerID,H.OrderDate,
 SUM(D.LineTotal) OVER(PARTITION BY H.CustomerID ORDER BY H.OrderDate) 
 AS TotalRevenue --Total Revenue per customer
 FROM Sales.SalesOrderDetail AS D
	LEFT JOIN Sales.SalesOrderHeader AS H
	ON D.SalesOrderID = H.SalesOrderID
),
Cte_rt AS 
(
	SELECT CustomerID,OrderDate,
	SUM(TotalRevenue) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS RunningTotalRevenue
	FROM Cte_tr
)

SELECT CustomerID
 , MAX(RunningTotalRevenue) AS LastRunningTotal --Calculates the latest running total for each custoemr
 FROM Cte_rt 
GROUP BY CustomerID; 

--8) Create a CTE that calculates number of orders in the last 90 days for each customer
--(relative to their latest order date).

WITH Recency AS
(
	SELECT H.CustomerID, H.OrderDate , H.SalesOrderID,
	MAX(H.OrderDate) OVER(PARTITION BY H.CustomerID) AS LatestOrder
	FROM Sales.SalesOrderHeader AS H
)

SELECT r.CustomerID ,
--Calculate the orders in the last 90 days for each customer
COUNT(DISTINCT r.SalesOrderID) AS OrderCount 
FROM Recency AS r
WHERE r.OrderDate >= DATEADD(DAY , -90 , LatestOrder) 
GROUP BY r.CustomerID

