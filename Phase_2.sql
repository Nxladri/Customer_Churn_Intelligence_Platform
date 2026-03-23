/*1.For each customer, show: ,CustomerID,TotalSales
% contribution of that customer to overall sales */

Select * ,
  ROUND( (TotalSales * 100) / SUM(TotalSales) OVER (), 1) AS Percent_Contribution
From
(Select C.CustomerID,COALESCE(SUM(D.LineTotal) , 0)As TotalSales ,
Cume_Dist() Over(Order By SUM(D.LineTotal) Desc) Relative_Contribution
From Sales.Customer As C
	Left Join Sales.SalesOrderHeader As H
On C.CustomerID = H.CustomerID
	Left Join Sales.SalesOrderDetail As D
On H.SalesOrderID = D.SalesOrderID
Group By C.CustomerID)t


/*2.Rank products by total sales amount within their product subcategory.
Output:
ProductID
ProductSubcategoryID
TotalSales
Rank */

Select ProductID ,ProductSubcategoryID,TotalSales,
DENSE_RANK() Over( Partition By ProductSubcategoryID Order By TotalSales DESC) RankCustomers  
From(
Select P.ProductID,Ps.ProductSubcategoryID,

		Sum(Od.LineTotal) TotalSales 
			From Production.Product As P
	Left Join Production.ProductSubcategory As Ps
On P.ProductSubcategoryID = Ps.ProductSubcategoryID
	Left Join Sales.SalesOrderDetail As Od
On P.ProductID = Od.ProductID
Group By P.ProductID,Ps.ProductSubcategoryID
) AS Subquery


/*3.For each order, show:
SalesOrderID
OrderDate
TotalOrderSales
Average order value across all orders
Difference between this order and the average */


Select * ,
(TotalOrderSales - AvgOrderValue) DiffInOrder
From(Select h.SalesOrderID,h.OrderDate,AVG(d.OrderQty) OVER() AvgOrderValue,
SUM(d.LineTotal) OVER(Partition By h.SalesOrderID) TotalOrderSales
From Sales.SalesOrderHeader As h
	Left Join Sales.SalesOrderDetail As d
On h.SalesOrderID = d.SalesOrderID)t



/*🔹 Q4. Customer Purchase Trend Question: 
For each customer’s orders: CustomerID,SalesOrderID,OrderDate,TotalDue ,
Previous order’s TotalDue, Change from previous order */

SELECT * ,
ABS(PreviousTotalDue - CurrentTotalDue) As ChangeFromPreviousOrder
FROM
(SELECT * ,
LAG(CurrentTotalDue) OVER(PARTITION BY CustomerID ORDER BY OrderDate) PreviousTotalDue

FROM(
Select c.CustomerID,h.SalesOrderID,h.OrderDate,
h.TotalDue CurrentTotalDue
From Sales.Customer AS c
	Inner Join Sales.SalesOrderHeader AS h
On c.CustomerID = h.CustomerID
)AS Subquery
)AS Subquery



/*5.Question: 
Find the top 5 customers by total sales, and show all their orders with: 
OrderDate,TotalDue,Running total of their spending */


SELECT TOP 5 RunningTotalOfSpending , *  FROM(
SELECT C.CustomerID,H.OrderDate, H.TotalDue,
--Running total of the customers spending
SUM(D.LineTotal) OVER (ORDER BY H.OrderDate) RunningTotalOfSpending,
DENSE_RANK() OVER(ORDER BY H.OrderDate DESC) RankingCustomers
FROM Sales.Customer AS C
	INNER JOIN Sales.SalesOrderHeader AS H
ON C.CustomerID = H.CustomerID
	LEFT JOIN Sales.SalesOrderDetail AS D
ON H.SalesOrderID = D.SalesOrderID
) AS SubQuery



/*6 For each product category: 
CategoryName,TotalSales,Rank categories by TotalSales */

SELECT * , 
DENSE_RANK() OVER(ORDER BY TotalSales DESC) As RankCategories
FROM (

SELECT Pc.Name As CategoryName,
		SUM(OD.LineTotal) AS TotalSales
	From Sales.SalesOrderDetail AS OD
	Left Join Production.Product As P
On OD.ProductID = P.ProductID
	Left Join Production.ProductSubcategory AS Ps
On P.ProductSubcategoryID = Ps.ProductSubcategoryID
	Left Join Production.ProductCategory As Pc
On Ps.ProductCategoryID = Pc.ProductCategoryID
GROUP BY Pc.Name
) AS SubQuery


/* 7. For each product: 
ProductID,TotalSales,Average sales per order,Rank by Average sales per order*/

SELECT *, 
DENSE_RANK() OVER(ORDER BY AverageSales) As RankCategories
FROM (

SELECT P.ProductID ,
	SUM(OD.LineTotal) AS TotalSales ,
		AVG(OD.LineTotal) AS AverageSales
	From Sales.SalesOrderDetail AS OD
	Left Join Production.Product As P
On OD.ProductID = P.ProductID
GROUP BY P.ProductID
) AS SubQuery
