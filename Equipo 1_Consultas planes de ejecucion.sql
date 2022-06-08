use covidHistorico;
select top 5 * from dbo.datoscovid;
/*Práctica de optimización de consultas
Listado de consultas a programar para analizar planes de ejecucion
1. Listar los casos positivos por entidad de residencia 
2.-Listar los casos sospechosos por entidad
3.- Listar el Top 5 de municipios por entidad con el mayor numero 
de casos reportados, indicando casos sospechosos y casos confirmados
4.- Determinar el municipio con el mayor número de defunciones en casos confirmados.
5. Determinar por entidad, si de casos sospechosos hay defunciones reportadas asociadas a neumonia.
6. Listar por entidad el total de casos sospechosos, casos confirmados, total de defunciones en los meses de marzo a agosto 2020 y de diciembre 2020 a mayo 2021.
7. Listar los 5 municipios con el mayor número de casos confirmados en niños menos de 13 años con alguna comorbilidad reportada y cuantos de esos casos fallecieron.
8. Determinar si en el año 2020 hay una mayor cantidad de defunciones menores de edad que en el año 2021 y 2022.
9. Determinar si en el año 2021 hay un pocentaje mayor al 60 de casos reportados que son confirmados por estudios de laboratorio en comparación al año 2020.
10. Determinar en que rango de edad: menor de edad, 19 a 40, 40 a 60 o mayor de 60 hay mas casos reportados que se hayan recuperado.
*/

/*Soluciones*/
--1 
select * from dbo.datoscovid where 
CLASIFICACION_FINAL between 1 and 3
order by ENTIDAD_RES;


--2
select ENTIDAD_UM, ENTIDAD_RES, count (*) total_sospechosos
from dbo.datoscovid
where CLASIFICACION_FINAL =6
group by ENTIDAD_UM, ENTIDAD_RES
order by ENTIDAD_UM;


--3
select top 5 c.CasosSC, c.MUNICIPIO_RES, c.ENTIDAD_RES from (select MUNICIPIO_RES, ENTIDAD_RES, count(CLASIFICACION_FINAL) CasosSC from dbo.datoscovid 
where CLASIFICACION_FINAL between 1 and 3 or CLASIFICACION_FINAL=6
group by ENTIDAD_RES, MUNICIPIO_RES) as c;
--Solucion 
select ENTIDAD_RES, MUNICIPIO_RES, COUNT(*) as reportados, COUNT(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
when 2 then CLASIFICACION_FINAL
when 3 then CLASIFICACION_FINAL
end) as confirmado,
count(case CLASIFICACION_FINAL when 6 then CLASIFICACION_FINAL end) as sospechoso 
from dbo.datoscovid
group by ENTIDAD_RES, MUNICIPIO_RES
order by ENTIDAD_RES, reportados desc


--4.- Determinar el municipio con el mayor número de defunciones en casos confirmados.
select TOP 1 MUNICIPIO_RES, count(FECHA_DEF) as DefuncionesCC from dbo.datoscovid 
where FECHA_DEF !='9999-99-99' and CLASIFICACION_FINAL between 1 and 3
group by MUNICIPIO_RES order by DefuncionesCC desc

--5.
select ENTIDAD_UM, ENTIDAD_RES, count (*)
from dbo.datoscovid
where CLASIFICACION_FINAL=6 and FECHA_DEF != '9999-99-99' and NEUMONIA=1
group by ENTIDAD_UM, ENTIDAD_RES

--6
select ccs.*, dma.TDefuncionesMA as 'Defunciones de Marzo a Agosto 2020', 
ddm.TDefuncionesDM as 'Defunciones de Diciembre 2021 a Mayo 2021' from
(select ENTIDAD_RES,
--Casos Confirmados
count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
when 2 then CLASIFICACION_FINAL
when 3 then CLASIFICACION_FINAL
end) as Confirmados,
--Casos Sospechosos
count(case CLASIFICACION_FINAL when 6 then CLASIFICACION_FINAL end)as sospechosos
from dbo.datoscovid group by ENTIDAD_RES) ccs
inner join
--Casos confirmados de MARZO A AGOSTO 2020
(select ENTIDAD_RES, count(FECHA_DEF) TDefuncionesMA from dbo.datoscovid where FECHA_DEF between '2020-03-01' and '2020-08-31' group by ENTIDAD_RES)
dma
on dma.ENTIDAD_RES=ccs.ENTIDAD_RES
join
--Casos confirmados de DICIEMBRE 2020 A MAYO 2021
(select ENTIDAD_RES, count(FECHA_DEF) TDefuncionesDM from dbo.datoscovid where FECHA_DEF between '2020-12-01' and '2021-05-31' group by ENTIDAD_RES) ddm
on dma.ENTIDAD_RES=ddm.ENTIDAD_RES;

--7
SELECT TOP 5
	 MUNICIPIO_RES
	,COUNT(*) AS CONFIRMADOS
	,SUM(CASE WHEN FECHA_DEF != '9999-99-99' THEN 1 ELSE 0 END) AS DEFUNCIONES
FROM dbo.datoscovid
WHERE (EDAD <= 13 AND CLASIFICACION_FINAL BETWEEN 1 AND 3)		-- Casos confirmados menores de 13
AND (	DIABETES = 1 OR											-- Comorbilidades
		EPOC = 1 OR 
		ASMA = 1 OR 
		INMUSUPR = 1 OR 
		HIPERTENSION = 1 OR 
		OTRA_COM = 1 OR 
		OBESIDAD = 1 OR 
		RENAL_CRONICA = 1)
GROUP BY MUNICIPIO_RES
ORDER BY CONFIRMADOS DESC


 
--8. Determinar si en el año 2020 hay una mayor cantidad de defunciones menores de edad que en el año 2021 y 2022
DECLARE @var1 int, @var2 int, @var3 int;
select @var1=1, @var2=1, @var3=1;
--Defunciones en menores de edad en 2020
select @var1= count(FECHA_DEF) from dbo.datoscovid where edad<18 and FECHA_DEF between '2020-01-01' and '2020-12-31'
--Defunciones en Menores de edad en 2021
select @var2= count(FECHA_DEF) from dbo.datoscovid where edad<18 and FECHA_DEF between '2021-01-01' and '2021-12-31'
--Defunciones en Menores de edad en 2022
select @var3= count(FECHA_DEF) from dbo.datoscovid where edad<18 and FECHA_DEF between '2022-01-01' and '2022-12-31'
select 'Verdadero' as 'En 2020 hay mas defunciones en -18' where @var1>@var2 and @var1>@var3;

--9. Determinar si en el año 2021 hay un pocentaje mayor al 60 de casos reportados que son confirmados por estudios de laboratorio en comparación al año 2020.

declare @var4 float, @var5 float;
select @var4=count(RESULTADO_LAB)*0.6 from dbo.datoscovid where RESULTADO_LAB =1  and FECHA_ACTUALIZACION between '2021-01-01' and '2021-12-31';

select @var5= count(RESULTADO_LAB)*0.6 from dbo.datoscovid where RESULTADO_LAB=1 and FECHA_ACTUALIZACION between '2020-01-01' and '2020-12-32';

select 'verdadero' as 'En 2021 hay mas del 60 porciento' where @var4>@var5;

--10. Determinar en que rango de edad: menor de edad, 19 a 40, 40 a 60 o mayor de 60 hay mas casos reportados que se hayan recuperado.


declare @var6 int, @var7 int, @var8 int, @var9 int,@total int; 
select @var6=count(TIPO_PACIENTE) from dbo.datoscovid where TIPO_PACIENTE=1 and EDAD < 18; 
Select @var7=count(TIPO_PACIENTE)from dbo.datoscovid where TIPO_PACIENTE=1 and EDAD between 19 and 40; 
select @var8=count(TIPO_PACIENTE)from dbo.datoscovid where TIPO_PACIENTE=1 and EDAD between 40 and 60; 
select @var9=count(TIPO_PACIENTE)from dbo.datoscovid where TIPO_PACIENTE=1 and EDAD >60; 
IF @var6>@var7 and @var6>@var8 and @var6>@var9 
begin 
print 'Casos reportados y recuperados: Menores de edad' 
end else 
if @var7>@var6 and @var7>@var8 and @var7>@var9 
begin  
print 'Casos reportados y recuperados: Entre 19 y 40 años' 
end else 
if @var8>@var6 and @var8>@var7 and @var8>@var9 
begin  
print 'Casos reportados y recuperados: entre 40 y 60 años' 
end else 
if @var9>@var6 and @var9>@var7 and @var9>@var8 
begin  
print 'Casos reportados y recuperados: Mayores de 60 años' 
end 

--consultas alternas

--1
select ENTIDAD_RES, count(*) total_Confirmado 
from dbo.datoscovid where  
CLASIFICACION_FINAL between 1 and 3 
group by ENTIDAD_RES 
order by ENTIDAD_RES; 

--2 
select ENTIDAD_UM, ENTIDAD_RES from dbo.datoscovid where CLASIFICACION_FINAL=6; 

--3
select top 5 cc.ENTIDAD_RES, cc.MUNICIPIO_RES, cc.confirmado, cs.sospechoso 
from (select ENTIDAD_RES, MUNICIPIO_RES, count(*) as sospechoso 
from dbo.datoscovid where CLASIFICACION_FINAL = 6 
group by ENTIDAD_RES, MUNICIPIO_RES 
) cs 
inner join 
(select ENTIDAD_RES, MUNICIPIO_RES, count (*) as confirmado 
from dbo.datoscovid where CLASIFICACION_FINAL between 1 and 3 
group by ENTIDAD_RES, MUNICIPIO_RES) cc 
on cc.ENTIDAD_RES = cs.ENTIDAD_RES and cs.MUNICIPIO_RES = cc.MUNICIPIO_RES 
order by cc.ENTIDAD_RES; 

--4
select top 1 MUNICIPIO_RES,count(MUNICIPIO_RES) as Muertes_Confirmadas from dbo.datoscovid where FECHA_DEF!='9999-99-99' group by MUNICIPIO_RES 

--5
select ENTIDAD_NAC, count(ENTIDAD_RES) as Defunciones from dbo.datoscovid where FECHA_DEF!='9999-99-99' 
and CLASIFICACION_FINAL=6 and NEUMONIA=1 group by ENTIDAD_NAC order by Defunciones 

--6
select a.ENTIDAD_RES, a.Sospechosos_MarzoAgosto_2020, b.Sospechosos_Diciembre2020_Marzo_2021, c.Confirmados_MarzoAgosto_2020, d.Confirmados_Diciembre2020_Marzo_2021, 
e.Defunciones_MarzoAgosto_2020, f.Defunciones_Diciembre2020_Marzo_2021 
from ( 
select ENTIDAD_RES, count (CLASIFICACION_FINAL) as Sospechosos_MarzoAgosto_2020 from dbo.datoscovid 
where CLASIFICACION_FINAL=6 and FECHA_DEF between '2020-03-01' and '2020-08-01' 
group by ENTIDAD_RES) a JOIN 
(select ENTIDAD_RES, count (CLASIFICACION_FINAL) as Sospechosos_Diciembre2020_Marzo_2021 from dbo.datoscovid 
where CLASIFICACION_FINAL=6 and FECHA_DEF between '2020-12-01' and '2021-03-01' 
group by ENTIDAD_RES) b ON 
a.ENTIDAD_RES = b.ENTIDAD_RES JOIN 
(select ENTIDAD_RES, count (CLASIFICACION_FINAL) as Confirmados_MarzoAgosto_2020 from dbo.datoscovid 
where CLASIFICACION_FINAL between 1 and 3 and FECHA_DEF between '2020-03-01' and '2020-08-01' 
group by ENTIDAD_RES) c ON 
b.ENTIDAD_RES=c.ENTIDAD_RES JOIN 
(select ENTIDAD_RES, count (CLASIFICACION_FINAL) as Confirmados_Diciembre2020_Marzo_2021 from dbo.datoscovid 
where CLASIFICACION_FINAL between 1 and 3 and FECHA_DEF between '2020-12-01' and '2021-03-01' 
group by ENTIDAD_RES) d ON 
c.ENTIDAD_RES=d.ENTIDAD_RES JOIN 
(select ENTIDAD_RES, count (FECHA_DEF) as Defunciones_MarzoAgosto_2020 from dbo.datoscovid 
where FECHA_DEF between '2020-03-01' and '2020-08-01' and FECHA_DEF!='9999-99-99' group by ENTIDAD_RES) e ON 
d.ENTIDAD_RES=e.ENTIDAD_RES JOIN 
(select ENTIDAD_RES, count (FECHA_DEF) as Defunciones_Diciembre2020_Marzo_2021 from dbo.datoscovid 
where FECHA_DEF between '2020-12-01' and '2021-03-01' and FECHA_DEF!='9999-99-99' group by ENTIDAD_RES ) f ON 
e.ENTIDAD_RES = f.ENTIDAD_RES Order by a.ENTIDAD_RES; 

--7
select MUNICIPIO_RES, count(EDAD) as Defunciones from dbo.datoscovid 
where edad<13 and FECHA_DEF!='9999-99-99' and ASMA=1 and NEUMONIA=1 group by MUNICIPIO_RES order by Defunciones desc 

--8
select /*a.Edad*/ SUM(a.Defunciones_2020) as Total2020 ,SUM( b.Defunciones_2021)as Total2021, SUM(c.Defunciones_2022) as Total2022 
from (select Edad, count(*) as Defunciones_2020 from dbo.datoscovid where FECHA_DEF like '2020%' and FECHA_DEF!='9999-99-99' group by EDAD) a 
JOIN 
(select Edad, count(*) as Defunciones_2021 from dbo.datoscovid where FECHA_DEF like '2021%' and FECHA_DEF!='9999-99-99' group by EDAD) b ON 
a.EDAD=b.EDAD 
JOIN 
(select Edad, count(*) as Defunciones_2022 from dbo.datoscovid where FECHA_DEF like '2022%' and FECHA_DEF!='9999-99-99' group by EDAD) c ONb.EDAD=c.EDAD where a.EDAD < 18 

--9
Declare @A2020 int; 
Declare @A2021 int
Declare @x     real; 
Declare @Porc1 real; 
Declare @Porc2 FLOAT; 
SET @A2020 = (select SUM(Resultado_lab) from dbo.datoscovid where CLASIFICACION_FINAL between 1 and 3 and FECHA_INGRESO like '2020%') 
SET @A2021 = (select SUM(Resultado_lab) from dbo.datoscovid where CLASIFICACION_FINAL between 1 and 3 and FECHA_INGRESO like '2021%') 
SET @x = @A2020 
SET @Porc1= @A2021/@x 
SET @Porc2= (@A2020/100)*60  
IF @Porc1 <= @Porc2 
BEGIN  
PRINT 'El porcentaje es menor al 60% del año 2020' 
END	ELSE  
BEGIN  
PRINT 'El porcentaje es Mayor al 60% del año 2020' 
END 

--10
declare @var6 int, @var7 int, @var8 int, @var9 int,@total int; 
select @var6=count(TIPO_PACIENTE) from dbo.datoscovid where TIPO_PACIENTE=1 and EDAD < 18; 
Select @var7=count(TIPO_PACIENTE)from dbo.datoscovid where TIPO_PACIENTE=1 and EDAD between 19 and 40; 
select @var8=count(TIPO_PACIENTE)from dbo.datoscovid where TIPO_PACIENTE=1 and EDAD between 40 and 60; 
select @var9=count(TIPO_PACIENTE)from dbo.datoscovid where TIPO_PACIENTE=1 and EDAD >60; 
IF @var6>@var7 and @var6>@var8 and @var6>@var9 
begin 
print 'Casos reportados y recuperados: Menores de edad' 
end else 
if @var7>@var6 and @var7>@var8 and @var7>@var9 
begin  
print 'Casos reportados y recuperados: Entre 19 y 40 años' 
end else 
if @var8>@var6 and @var8>@var7 and @var8>@var9 
begin  
print 'Casos reportados y recuperados: entre 40 y 60 años' 
end else 
if @var9>@var6 and @var9>@var7 and @var9>@var8 
begin  
print 'Casos reportados y recuperados: Mayores de 60 años' 
end 