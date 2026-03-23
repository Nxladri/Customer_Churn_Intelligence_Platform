-- Q1: Return 10 sample orders with:
SELECT TOP 10
OH.CustomerID , OH.SalesOrderID , OH.OrderDate , OH.TotalDue

FROM Sales.SalesOrderHeader AS OH
--Q2: Return 10 sample order line items with:
SELECT TOP 10
OD.SalesOrderID,OD.ProductID,OD.OrderQty,OD.UnitPrice,OD.LineTotal
FROM Sales.SalesOrderDetail AS OD

/*3. Return 10 products with:
ProductID
Name
ListPrice
ProductSubcategoryID*/

SELECT TOP 10 P.ProductID,
P.Name,
P.ListPrice,
P.ProductSubcategoryID FROM Production.Product AS P


--4. Return all product subcategories with: subcategoryid,name,categoryid

SELECT  PS.ProductSubcategoryID,PS.Name,
PS.ProductCategoryID

FROM Production.ProductSubcategory AS PS


-- 5. Return orders with their line items: SalesOrderID
/*OrderDate,
ProductID,
OrderQty,
LineTotal*/


SELECT TOP 10 OH.OrderDate,OH.SalesOrderID,OD.ProductID,OD.OrderQty,OD.UnitPrice,OD.LineTotal FROM Sales.SalesOrderHeader AS OH
	Inner Join Sales.SalesOrderDetail AS OD
ON OH.SalesOrderID = OD.SalesOrderID



/*6 Return products sold in orders with:
SalesOrderID
ProductID
ProductName
LineTotal*/

SELECT OD.SalesOrderID,P.ProductID,P.Name,OD.LineTotal,Od.OrderQty From Production.Product AS P
	INNER JOIN Sales.SalesOrderDetail AS OD
ON P.ProductID = OD.ProductID



--7 Return customers and their orders:

SELECT OH.CustomerID,OH.SalesOrderID,OH.OrderDate,OH.TotalDue FROM Sales.SalesOrderHeader AS OH
	LEFT JOIN Sales.Customer AS C
ON OH.CustomerID= C.CustomerID

/*8 Return order details with product category info:
SalesOrderID
ProductID
ProductName
SubcategoryName
CategoryName
LineTotal*/


SELECT OD.SalesOrderID,p.ProductID,p.Name As ProductName,
			Ps.Name  As SubcategoryName,Pc.Name As CategoryName,
			OD.LineTotal From Sales.SalesOrderDetail AS OD
	Left Join Production.Product As P
On OD.ProductID = P.ProductID
	Left Join Production.ProductSubcategory AS Ps
On P.ProductSubcategoryID = Ps.ProductSubcategoryID
	Left Join Production.ProductCategory As Pc
On Ps.ProductCategoryID = Pc.ProductCategoryID


/* 9 Return total sales amount per order:
SalesOrderID
OrderDate
TotalOrderSales*/
SELECT Od.SalesOrderID,Oh.OrderDate,SUM(Od.LineTotal) As TotalOrderSales From Sales.SalesOrderDetail As Od
	Left Join Sales.SalesOrderHeader As Oh
On Od.SalesOrderID = Oh.SalesOrderID
Group By Od.SalesOrderID,Oh.OrderDate


/*10 Return total sales per customer:
CustomerID
TotalSalesAmount */

Select C.CustomerID,SUM(D.LineTotal) As TotalSalesAmount From Sales.Customer As C
	Left Join Sales.SalesOrderHeader As H
On C.CustomerID = H.CustomerID
	Left Join Sales.SalesOrderDetail As D
On H.SalesOrderID = D.SalesOrderID
Group By C.CustomerID


/* 11 Return customers who never placed an order: CustomerID*/

Select C.CustomerID From Sales.Customer As C
	Left Join Sales.SalesOrderHeader AS H
On C.CustomerID = H.CustomerID
Where H.OrderDate IS Null

/*12 Return products that were never sold:ProductID,
ProductName */

Select P.ProductID,P.Name From Production.Product P
	Left Join Sales.SalesOrderDetail Od
On P.ProductID = Od.ProductID
Where Od.SalesOrderID Is Null

/* 13 Return top 5 customers by total sales amount: CustomerID,TotalSales*/
Select  C.CustomerID,SUM(D.LineTotal) As TotalSalesAmount From Sales.Customer As C
	Left Join Sales.SalesOrderHeader As H
On C.CustomerID = H.CustomerID
	Left Join Sales.SalesOrderDetail As D
On H.SalesOrderID = D.SalesOrderID
Group By C.CustomerID
Order By SUM(D.LineTotal) DESC

/*14 Return total sales per product category:
CategoryName
TotalSales */

Select Pc.Name CategoryName, COALESCE(SUM(Od.LineTotal) , 0) TotalSales,AVG(Od.OrderQty) AvgOrder From Production.Product P
	Left Join Production.ProductSubcategory Ps
On P.ProductSubcategoryID = Ps.ProductSubcategoryID
	Left Join Production.ProductCategory Pc
On Ps.ProductCategoryID = Pc.ProductCategoryID
	Left Join Sales.SalesOrderDetail Od
On P.ProductID= Od.ProductID
Group By Pc.Name 
Order By  COALESCE(SUM(Od.LineTotal) , 0) DESC;
