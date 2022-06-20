--1. La información de los clientes se debe almacenarse por región, considerando las regiones 
--de acuerdo con el atributo group de salesterritory.
select * from F1.Customer union select * from LINK1A2.DB1.F2.Customer union select * from LINK1A2.DB2.F3.Customer order by TerritoryID desc;
--2. Listar datos del empleado que atendió más ordenes por territorio.

select *,S.Total AS 'TOTAL DE VENTAS' from [AdventureWorks2019].HumanResources.Employee E inner join (select TOP 1 SalesPersonID, count(SalesPersonID) 'Total' from F1.SalesOrderHeader where TerritoryID=1 group by SalesPersonID order by Total desc) as S on S.SalesPersonID = E.BusinessEntityID 
UNION
select *,S.Total AS 'TOTAL DE VENTAS' from [AdventureWorks2019].HumanResources.Employee E inner join (select TOP 1 SalesPersonID, count(SalesPersonID) 'Total' from F1.SalesOrderHeader where TerritoryID=2 group by SalesPersonID order by Total desc) as S on S.SalesPersonID = E.BusinessEntityID
UNION
select *,S.Total AS 'TOTAL DE VENTAS' from [AdventureWorks2019].HumanResources.Employee E inner join (select TOP 1 SalesPersonID, count(SalesPersonID) 'Total' from F1.SalesOrderHeader where TerritoryID=3 group by SalesPersonID order by Total desc) as S on S.SalesPersonID = E.BusinessEntityID
UNION
select *,S.Total AS 'TOTAL DE VENTAS' from [AdventureWorks2019].HumanResources.Employee E inner join (select TOP 1 SalesPersonID, count(SalesPersonID) 'Total' from F1.SalesOrderHeader where TerritoryID=4 group by SalesPersonID order by Total desc) as S on S.SalesPersonID = E.BusinessEntityID
UNION
select *,S.Total AS 'TOTAL DE VENTAS' from [AdventureWorks2019].HumanResources.Employee E inner join (select TOP 1 SalesPersonID, count(SalesPersonID) 'Total' from F1.SalesOrderHeader where TerritoryID=5 group by SalesPersonID order by Total desc) as S on S.SalesPersonID = E.BusinessEntityID
UNION
select *,S.Total AS 'TOTAL DE VENTAS' from [AdventureWorks2019].HumanResources.Employee E inner join (select TOP 1 SalesPersonID, count(SalesPersonID) 'Total' from F1.SalesOrderHeader where TerritoryID=6 group by SalesPersonID order by Total desc) as S on S.SalesPersonID = E.BusinessEntityID
;

--3. Listar los datos del cliente con más ordenes solicitadas en la región “North America”.

	SELECT C1.*, S1.ordenes 'Ordenes' FROM [AdventureWorks2019].Sales.Customer C1 INNER JOIN
	(
		SELECT C.CustomerID ,COUNT(SOH.SalesOrderID) ordenes  FROM [AdventureWorks2019].Sales.SalesOrderHeader SOH INNER JOIN [AdventureWorks2019].Sales.Customer C ON  SOH.CustomerID = C.CustomerID
		WHERE SOH.TerritoryID IN (1,2,3,4,5,6) GROUP BY C.CustomerID
	) S1 ON C1.CustomerID = S1.CustomerID 
	INNER JOIN
	(
		SELECT MAX(S1.ordenes) MX FROM (
		SELECT C.CustomerID ,COUNT(SOH.SalesOrderID) ordenes  FROM [AdventureWorks2019].Sales.SalesOrderHeader SOH INNER JOIN [AdventureWorks2019].Sales.Customer C ON  SOH.CustomerID = C.CustomerID
		WHERE SOH.TerritoryID IN (1,2,3,4,5,6) GROUP BY C.CustomerID
		) S1
	) S2 ON S1.ordenes = S2.MX;

--4. Listar el producto más solicitado en la región “Europe”.
	-- INSTANCIA 2 -- usar master
	select * from (
		select * from [DB_NOF].dbo.Product) b
		inner join
		(select TOP 1 ProductID, count(ProductID) as CantidadP from [DB1].F2.SalesOrderDetail group by ProductID order by CantidadP desc) a
		on a.ProductID = b.ProductID
	;

--5. Listar las ofertas que tienen los productos de la categoría “Bikes”
	select * from(
	select * from DB_NOF.dbo.SpecialOfferProduct) c
	inner join
	(
	select a.ProductID, b.ProductCategoryID from(
	select * from DB_NOF.dbo.Product) a
	inner join
	(
	select * from DB_NOF.dbo.ProductSubcategory where ProductCategoryID=1) b
	on a.ProductSubcategoryID=b.ProductSubcategoryID) d on d.ProductID=c.ProductID;

--6. Listar los 3 productos menos solicitados en la región “Pacific”
	select * from (
	select * from [DB_NOF].dbo.Product) b
	inner join
	(
	select TOP 3 ProductID,count(ProductID) as CantidadP from DB2.F3.SalesOrderDetail group by ProductID order by CantidadP) a
	on a.ProductID=b.ProductID;

--7. Actualizar la subcategoría de los productos con productId del 1 al 4 a la subcategoría valida 
--para el tipo de producto.

--8. Listar los productos que no estén disponibles a la venta.


--9. Listar los clientes del territorio 1 y 4 que no tengan asociado un valor en personId

	select * from (select * from BD1.F1.Customer)a
	inner join
	(
	select * from BD1.F1.SalesOrderHeader where TerritoryID=4 or TerritoryID=1) b
	on b.CustomerID=a.CustomerID where PersonID is null

--10. Listar los clientes del territorio 1 que tengan ordenes en otro territorio