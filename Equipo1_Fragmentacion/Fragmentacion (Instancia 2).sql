-- FAGREGACION DE REGION 2 A BD1

	create database DB1;
	use DB1;
	create schema F2;

	-- F2.Customer REGION 2 
	SELECT * INTO DB1.F2.Customer from (SELECT * FROM LINK2A1.AdventureWorks2019.Sales.Customer C where TerritoryID between 7 and 9) as S;
	-- S es elalias de la subconsulta con linked Server

	-- F2.SalesOrderHeader REGION 2
	SELECT * INTO DB1.F2.SalesOrderHeader FROM (select * from LINK2A1.AdventureWorks2019.Sales.SalesOrderHeader SOH where exists(Select * from LINK2A1.AdventureWorks2019.Sales.Customer C where C.TerritoryID between 7 and 9 and SOH.CustomerID = C.CustomerID)) AS S;

	-- F2.SalesOrderDetail REGION 2
	SELECT * INTO DB1.F2.SalesOrderDetail FROM (select * from LINK2A1.AdventureWorks2019.Sales.SalesOrderDetail SOD where exists(
		Select * from LINK2A1.AdventureWorks2019.Sales.SalesOrderHeader SOH where exists(
			Select * from LINK2A1.AdventureWorks2019.Sales.Customer C where C.TerritoryID between 7 and 9 and SOH.CustomerID = C.CustomerID
		and SOD.SalesOrderID = SOH.SalesOrderID)
	)) AS S;

-- AGREGACION DE REGION 3 A BD2
	create database DB2;
	use DB2;
	create schema F3;

	-- F3.Customer
	SELECT * INTO DB2.F3.Customer  from (SELECT * FROM LINK2A1.AdventureWorks2019.Sales.Customer C where TerritoryID = 10) as S;
	
	-- F3.SalesOrderHeader
	SELECT * INTO DB2.F3.SalesOrderHeader FROM (select * from LINK2A1.AdventureWorks2019.Sales.SalesOrderHeader SOH where exists(Select * from LINK2A1.AdventureWorks2019.Sales.Customer C where C.TerritoryID = 10 and SOH.CustomerID = C.CustomerID)) AS S;
	
	-- F3.SalesOrderDetail

	SELECT * INTO DB2.F3.SalesOrderDetail FROM (select * from LINK2A1.AdventureWorks2019.Sales.SalesOrderDetail SOD where exists(
		Select * from LINK2A1.AdventureWorks2019.Sales.SalesOrderHeader SOH where exists(
			Select * from LINK2A1.AdventureWorks2019.Sales.Customer C where C.TerritoryID = 10 and SOH.CustomerID = C.CustomerID
		and SOD.SalesOrderID = SOH.SalesOrderID)
	)) AS S;

-- REGISTRO DE TABLAS NO FRAGMENTADAS+
	use master
	create database DB_NOF; -- CONTIENE LAS TABLAS NO FRAGMENTADAS
	use DB_NOF;
	
	

	select * INTO SpecialOffer from LINK2A1.AdventureWorks2019.Sales.SpecialOffer;
	select * INTO SpecialOfferProduct from LINK2A1.AdventureWorks2019.Sales.SpecialOfferProduct;
	select * INTO SalesPerson from LINK2A1.AdventureWorks2019.Sales.SalesPerson;
	select * INTO ProductCategory from LINK2A1.AdventureWorks2019.Production.ProductCategory;
	select * INTO ProductSubcategory from LINK2A1.AdventureWorks2019.Production.ProductSubcategory;
	select * INTO Product from LINK2A1.AdventureWorks2019.Production.Product;
	-- 