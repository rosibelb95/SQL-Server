USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_ListadePreciosMateriaPDonvic]    Script Date: 19/12/2024 10:49:45 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
			PROCEDIMIENTO ALMACENADO para obtener los precios y agruparlos por a tarifa

			(Realizar un reporte de las listas de Precio solo por MATERIA PRIMA)

			Desarrollado por: Ing. Rosibel Briceño



******/
ALTER PROCEDURE [dbo].[rp_ListadePreciosMateriaPDonvic] 
@moneda char(2)

AS

SET DATEFORMAT dmy

begin 


declare @tasa money
 
set @tasa=(select  top 1 Cambio from DONVIC600.dbo.MonedasCambio where MonedasCambio.Fecha=MonedasCambio.Fecha AND IdMoneda = '2' order by fecha desc)


if @moneda='BS'
					SELECT * FROM 
				(
							SELECT  Productos.CodigoProducto,Nombre,Referencia,Peso,@tasa as Tasa,Tarifa, ((PrecioMoneda)*@tasa) AS PRECIO				
							,ProductosCodigoAlterno.CodigoAlterno
							
							FROM ProductosCodigoAlterno
							INNER JOIN ProductosPrecios ON ProductosCodigoAlterno.CodigoAlterno = ProductosPrecios.CodigoProducto
							INNER JOIN Productos ON Productos.CodigoProducto = ProductosCodigoAlterno.CodigoProducto
							where Referencia = 'MATERIAPQ' OR Referencia = 'MATERIAPF' OR Referencia = 'MATERIAPC'
							OR Referencia = 'MATERIAPE'
							and Precio <> 0 


							UNION ALL


						SELECT  Productos.CodigoProducto,Nombre,Referencia,Peso,@tasa as Tasa,Tarifa, (PrecioMoneda*@tasa) AS PRECIO				
							,Productos.CodigoProducto AS CodigoAlterno
							FROM Productos
							INNER JOIN ProductosPrecios ON Productos.CodigoProducto = ProductosPrecios.CodigoProducto
							where Referencia = 'MATERIAPQ' OR Referencia = 'MATERIAPF' OR Referencia = 'MATERIAPC'
							OR Referencia = 'MATERIAPE'
							and Precio <> 0 


				) AS ProductTarifa
				PIVOT (SUM(PRECIO)
				FOR Tarifa IN ([A],[B],[C],[D],[E],[F],[G],[H],[I],[J],[K],[L],[M]))
				as Product

			
if @moneda='DI'

			SELECT * FROM 
				(
							SELECT  Productos.CodigoProducto,Nombre,Referencia,Peso,@tasa as Tasa,Tarifa, (PrecioMoneda) AS PRECIO				
							,ProductosCodigoAlterno.CodigoAlterno
							
							FROM ProductosCodigoAlterno
							INNER JOIN ProductosPrecios ON ProductosCodigoAlterno.CodigoAlterno = ProductosPrecios.CodigoProducto
							INNER JOIN Productos ON Productos.CodigoProducto = ProductosCodigoAlterno.CodigoProducto
							where Referencia = 'MATERIAPQ' OR Referencia = 'MATERIAPF' OR Referencia = 'MATERIAPC'
							OR Referencia = 'MATERIAPE'
							and Precio <> 0 


							UNION ALL


						SELECT  Productos.CodigoProducto,Nombre,Referencia,Peso,@tasa as Tasa,Tarifa, (PrecioMoneda) AS PRECIO				
							,Productos.CodigoProducto AS CodigoAlterno
							FROM Productos
							INNER JOIN ProductosPrecios ON Productos.CodigoProducto = ProductosPrecios.CodigoProducto
							where Referencia = 'MATERIAPQ' OR Referencia = 'MATERIAPF' OR Referencia = 'MATERIAPC'
							OR Referencia = 'MATERIAPE'
							and Precio <> 0 


				) AS ProductTarifa
				PIVOT (SUM(PRECIO)
				FOR Tarifa IN ([A],[B],[C],[D],[E],[F],[G],[H],[I],[J],[K],[L],[M]))
				as Product

				ORDER BY nombre ASC
end