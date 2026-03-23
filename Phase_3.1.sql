/* 5) Create a CTE that calculates:
CustomerID,OrderDate,Days since previous order (use LAG)
Then select customers whose gap between two consecutive orders is greater than 60 days*/

WITH CTE_CO AS 
(
	SELECT H.CustomerID,H.OrderDate FROM Sales.SalesOrderHeader AS H
)
SELECT 
* 
FROM
(SELECT * ,
LAG(co.OrderDate) OVER (PARTITION BY co.CustomerID ORDER BY co.OrderDate) PreviousOrderDay,
DATEDIFF(DAY , LAG(co.OrderDate) OVER (PARTITION BY co.CustomerID ORDER BY co.OrderDate)
, co.OrderDate) AS DaysGap
FROM CTE_CO AS co)t
WHERE DaysGap > 60
ORDER BY DaysGap

/*6) Using a CTE, calculate:
TotalOrders,TotalRevenue,AvgOrderValue For each customer. */

WITH Cus_Predc AS 
(
	SELECT H.CustomerID,COUNT(DISTINCT H.SalesOrderID) AS TotalOrders,
	SUM(D.LineTotal) AS TotalRevenue 
	FROM Sales.SalesOrderDetail AS D
		LEFT JOIN Sales.SalesOrderHeader AS H
	ON D.SalesOrderID = H.SalesOrderID
	GROUP BY H.CustomerID
)

SELECT * ,(cp.TotalRevenue * 1.0 /cp.TotalOrders) AS AvgOrderValue
FROM Cus_Predc AS cp


