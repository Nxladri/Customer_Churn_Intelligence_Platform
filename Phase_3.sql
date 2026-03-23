/* 1) Using a CTE, calculate total revenue per customer and then select only 
customers whose total revenue is greater than the average revenue of all customers.*/
WITH CTE_TR AS 
(
	SELECT C.CustomerID,SUM(D.LineTotal) AS TotalRevenue 
	FROM Sales.SalesOrderDetail AS D
		LEFT JOIN Sales.SalesOrderHeader AS H
	ON D.SalesOrderID = H.SalesOrderID
		LEFT JOIN Sales.Customer AS C
	ON C.CustomerID = H.CustomerID
	GROUP BY C.CustomerID
)

SELECT *
FROM CTE_TR AS tr
WHERE tr.TotalRevenue > (SELECT AVG(TotalRevenue) 
						FROM CTE_TR)


--2) Using a CTE, find customers who placed more than 5 orders.
WITH CTE_CO AS 
(	SELECT C.CustomerID , COUNT(H.SalesOrderID) AS TotalNoOrders 
	FROM Sales.SalesOrderHeader AS H
		LEFT JOIN Sales.Customer AS C
	ON C.CustomerID = H.CustomerID
	GROUP BY C.CustomerID
)

SELECT * FROM CTE_CO  AS co
WHERE co.TotalNoOrders > 5


--3) Create a CTE that calculates total orders per year. 
--Then in the outer query, calculate year-over-year growth.

WITH CTE_TO AS
(
	
	SELECT YEAR(H.OrderDate) AS YearLevel,
	SUM(D.LineTotal) AS TotalRevenue,
	COUNT(DISTINCT H.SalesOrderID)  TotalOrders FROM Sales.SalesOrderHeader AS H
		LEFT JOIN Sales.SalesOrderDetail AS D
	ON H.SalesOrderID = D.SalesOrderID
	GROUP BY YEAR(H.OrderDate)

)

SELECT * ,
LAG(co.TotalRevenue) OVER(ORDER BY co.YearLevel) AS PreviousOrderRevenue ,
COALESCE(co.TotalRevenue - LAG(co.TotalRevenue) OVER(ORDER BY co.YearLevel) , 0) AS RevDifference,
((co.TotalRevenue - LAG(co.TotalRevenue) OVER(ORDER BY co.YearLevel)) * 100 )
/ LAG(co.TotalRevenue) OVER(ORDER BY co.YearLevel) AS YoYGrowth
FROM CTE_TO AS co


--4) Using a CTE, calculate average order value per customer.
--Then return only the top 10 customers by average order value.

WITH CTE_OVC AS 
(
	SELECT D.SalesOrderID,SUM(D.LineTotal) AS EachOrderValue FROM Sales.SalesOrderDetail as D
	GROUP BY D.SalesOrderID
) 
SELECT TOP 10 H.CustomerID,
AVG(ovc.EachOrderValue) AS AvgOrderPerCustomer
FROM CTE_OVC AS ovc 
	LEFT JOIN Sales.SalesOrderHeader AS H
ON ovc.SalesOrderID = H.SalesOrderID
GROUP BY H.CustomerID 
ORDER BY AvgOrderPerCustomer DESC
