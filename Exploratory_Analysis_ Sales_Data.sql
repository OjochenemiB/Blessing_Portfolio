-- Exploratory Data Analysis

--View all columns in Customer,Address, CustomerAddress tables
SELECT * FROM SalesLT.Customer;
SELECT * FROM SalesLT.Address;
SELECT * FROM SalesLT.CustomerAddress;

-- How many Customers Registered on the database? 847

SELECT COUNT(CustomerID) FROM SalesLT.Customer as No_of_customers;

-- Select phonenumers of client whose nameStart with G

Select FirstName, LastName, Phone from saleslt.Customer
where FirstName like 'G%';

-- Combine Customer table and Address table
SELECT * FROM SalesLT.Customer
INNER JOIN SalesLT.CustomerAddress ON 
SalesLT.Customer.CustomerID = SalesLT.CustomerAddress.CustomerID
INNER JOIN SalesLT.Address ON
SalesLT.Address.AddressID =SalesLT.CustomerAddress.AddressID
order by CompanyName;

-- How many customers are available in each Address Type? out of 847, only 417 can be found in the CustomerAddresss table
SELECT SalesLT.CustomerAddress.AddressType, COUNT(SalesLT.Customer.FirstName) as No_of_customers 
FROM SalesLT.Customer
JOIN SalesLT.CustomerAddress ON 
SalesLT.Customer.CustomerID = SalesLT.CustomerAddress.CustomerID
GROUP BY SalesLT.CustomerAddress.AddressType;


-- How many customers are in each region?
SELECT SalesLT.Address.CountryRegion, COUNT(SalesLT.Address.CountryRegion) as No_of_customers 
FROM SalesLT.Customer
INNER JOIN SalesLT.CustomerAddress ON 
SalesLT.Customer.CustomerID = SalesLT.CustomerAddress.CustomerID
INNER JOIN SalesLT.Address ON
SalesLT.Address.AddressID =SalesLT.CustomerAddress.AddressID
GROUP BY SalesLT.Address.CountryRegion;

-- Select all products table ## This is to know what the database contains and understand the field in the data
SELECT * FROM SalesLT.Product;
SELECT * FROM SalesLT.ProductCategory;
SELECT * FROM SalesLT.ProductDescription;
SELECT * From SalesLT.ProductModel;
SELECT * FROM SalesLT.ProductModelProductDescription;

-- join product and productcategory
select * from SalesLT.Product INNER JOIN SalesLT.ProductCategory
ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID
order by 1 DESC

--what product yields the higehest gain? Mountain Bike Socks, M

Select ProductID, Product.Name, StandardCost, ListPrice, (ListPrice - StandardCost) as Profit,((ListPrice - StandardCost)/StandardCost)*100 
as percent_Gain from SalesLT.Product INNER JOIN SalesLT.ProductCategory
ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID
WHERE Product.Name like '%Mountain%'
order by 6 DESC;

-- Select all from salesorder table ## This is to know what the database contains and understand the field in the data
SELECT * FROM SalesLT.SalesOrderDetail,SalesLT.SalesOrderHeader;

-- Total Purchase  per customer ..  out of the 847 customers on the database only 440 made some purchase
SELECT FirstName, LastName, OrderDate,SUM(UnitPrice * OrderQty) as Purchases 
FROM SalesLT.Customer,SalesLT.SalesOrderDetail,SalesLT.SalesOrderHeader
Group by OrderDate, FirstName, LastName
ORDER BY OrderDate DESC;

-- quantity ordered by products .
Select ProductID, SUM(OrderQty) as Quantity_order from SalesLT.SalesOrderDetail INNER JOIN SalesLT.SalesOrderHeader
ON SalesLT.SalesOrderDetail.SalesOrderID =SalesLT.SalesOrderHeader.SalesOrderID 
GROUP by ProductID
ORDER by ProductID Desc;

SELECT Name, Color, Sum(ListPrice) as Sales_Price, SUM((UnitPrice-UnitPricediscount) * OrderQty) as EPurchase_price,
max(Weight) as Weight 
FROM SalesLT.product, SalesLT.SalesOrderDetail
where color is not NULL
GROUP BY Name,Color
order by 3 desc;

--Probing if constant figure across purchase_price is a true reflection of the data or there is a logic error

select sum(orderqty), sum(unitprice) , sum ( unitprice * orderqty ) from SalesLT.SalesOrderDetail, Saleslt.product
where name = 'HL Road Frame - Black, 58';

select unitprice from SalesLT.SalesOrderDetail, Saleslt.product where name = 'HL Road Frame - Black, 58';
select unitprice from SalesLT.SalesOrderDetail, Saleslt.product where name = 'Mountain-100 Black, 38';

SELECT Count(Distinct Name)as Distict_Product,SUM(OrderQTY),(SUM(OrderQTY)/Count(Distinct Name)) as totalOrdered 
FROM SalesLT.SalesOrderDetail,SalesLT.Product;

Select * FROM SalesLT.Customer,SalesLT.Address,SalesLT.product, SalesLT.SalesOrderDetail;

--Which City listprice based on FirstName? Rolling over
SELECT FirstName,LastName, City,ListPrice,Sum(ListPrice)
OVER (Partition by City order by City, FirstName)  as RollingListPrice
FROM SalesLT.Customer,SalesLT.Address,SalesLT.product;

-- Using a Common Table Expression
WITH StanCostperCity(City,Name,StandardCost,RollingStandardCost,listprice,RollingListPrice)
as
(
SELECT  City,Name, StandardCost,Sum(StandardCost)
OVER (Partition by City order by City)  as RollingStandardCost,
ListPrice,Sum(ListPrice)
OVER (Partition by City order by City)  as RollingListPrice
FROM SalesLT.Address,SalesLT.product

)
Select *, ((RollingListPrice - RollingStandardCost)/RollingStandardCost)*100 as percent_Gain
From StanCostperCity ;
