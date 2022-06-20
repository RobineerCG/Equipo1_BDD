use AdventureWorks2019;

 --TABLAS QUE REQUIEREN FRAGMENTACION DERIVADA DE CUSTOMER
	--* SalesOrderHeader
	--	* SalesOrderDetail

-- 1.1 FRAGMENTACION HORIZONTAL DE CUSTOMER

Select * from Sales.Customer C where TerritoryID between 1 and 6; -- M1 -- REGION 1

Select * from Sales.Customer C where TerritoryID between 7 and 9; -- M2 -- REGION 2 Y 3

Select * from Sales.Customer C where TerritoryID = 10; -- M3	-- REGION 2 Y 3

Select * from Sales.Customer C where TerritoryID > 10; -- M4

-- REGION 1: North America
	--SalesTerritoryID = {1,2,3,4,5,6}
-- REGION 2: EUROPE
	--SalesTerritoryID = {7,8,10}
-- REGION 3: PACIFIC
	--SalesTerritoryID = {9}

select * from Sales.SalesTerritory;

--1.2 CONSULTAS QUE GENEREN LOS FRAGMENTOS DE CUSTOMER A PARTIR DE M

-- FRAGMENTOS HORIZONTALES DE SalesOrderHeader DERIVADOS DE CUSTOMER

	-- DERIVACION DE M1
	Select * from Sales.SalesOrderHeader SOH where exists(Select * from Sales.Customer C where TerritoryID between 1 and 6 and SOH.CustomerID = C.CustomerID); -- 33% DE COSTO
	-- SELECCIONA TODO LO DE SALESORDERHEADER SI SE CUMPLE M1^(SOH.CustomerId = C.CustomerID)

	-- DERIVACION DE M2
	select * from Sales.SalesOrderHeader SOH where exists(Select * from Sales.Customer C where TerritoryID between 7 and 9 and SOH.CustomerID = C.CustomerID);

	-- DERIVACION DE M3

	select * from Sales.SalesOrderHeader SOH where exists(Select * from Sales.Customer C where TerritoryID = 10 and SOH.CustomerID = C.CustomerID);

	-- DERIVACION DE M4
	select * from Sales.SalesOrderHeader SOH where exists(Select * from Sales.Customer C where TerritoryID > 10 and SOH.CustomerID = C.CustomerID);


-- FRAGMENTOS HORIZONTALES DE SalesOrderDetailed DERIVADOS DE CUSTOMER

-- EN ESTE CASO SE UTILIZA SalesOrderID el cual relaciona SOH y SOD

	-- DERIVACION DE M1
	select * from Sales.SalesOrderDetail SOD inner join (Select * from Sales.SalesOrderHeader SOH where exists(Select * from Sales.Customer C where C.TerritoryID between 1 and 6 and SOH.CustomerID = C.CustomerID)) M1
	on SOD.SalesOrderID = M1.SalesOrderID; -- M1 ES EL FRAGMENTO DERIVADO DE SOH

	-- DERIVACION DE M2
	select * from Sales.SalesOrderDetail SOD inner join (Select * from Sales.SalesOrderHeader SOH where exists(Select * from Sales.Customer C where C.TerritoryID between 7 and 9 and SOH.CustomerID = C.CustomerID)) M2
	on SOD.SalesOrderID = M2.SalesOrderID; -- M2 ES EL FRAGMENTO DERIVADO DE SOH

	-- DERIVACION DE M3
	select * from Sales.SalesOrderDetail SOD inner join (Select * from Sales.SalesOrderHeader SOH where exists(Select * from Sales.Customer C where C.TerritoryID = 10 and SOH.CustomerID = C.CustomerID)) M3
	on SOD.SalesOrderID = M3.SalesOrderID; -- M3 ES EL FRAGMENTO DERIVADO DE SOH

	-- DERIVACION DE M4
	select * from Sales.SalesOrderDetail SOD inner join (Select * from Sales.SalesOrderHeader SOH where exists(Select * from Sales.Customer C where C.TerritoryID > 10 and SOH.CustomerID = C.CustomerID)) M4
	on SOD.SalesOrderID = M4.SalesOrderID; -- M4 ES EL FRAGMENTO DERIVADO DE SOH

-- ASIGNACION DE FRAGMENTOS
	-- PARA EL SERVIDOR 1 EN SQL SERVER
	create database BD1;
	use BD1;
	create schema F1;
	
	-- F1.CUSTOMER  REGION 1
	select * into BD1.F1.Customer from AdventureWorks2019.Sales.Customer C where TerritoryID between 1 and 6;

	-- F1.SalesOrderHeader REGION 1
	select * into BD1.F1.SalesOrderHeader from AdventureWorks2019.Sales.SalesOrderHeader SOH where exists(Select * from AdventureWorks2019.Sales.Customer C where TerritoryID between 1 and 6 and SOH.CustomerID = C.CustomerID);

	-- F1.SalesOrderDetail REGION 1

	select * into BD1.F1.SalesOrderDetail2 from (
		select * from AdventureWorks2019.Sales.SalesOrderDetail SOD where exists(
		Select * from AdventureWorks2019.Sales.SalesOrderHeader SOH where exists(
			Select * from AdventureWorks2019.Sales.Customer C where TerritoryID between 1 and 6 and SOH.CustomerID = C.CustomerID
		and SOD.SalesOrderID = SOH.SalesOrderID))) as M1;

