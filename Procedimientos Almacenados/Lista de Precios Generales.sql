USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_ListadePreciosDonvic]    Script Date: 19/12/2024 10:50:02 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
			PROCEDIMIENTO ALMACENADO para obtener los precios y agruparlos por a tarifa

			(Realizar un reporte de las listas de Precio)

			Desarrollado por: Ing. Rosibel Briceño



******/
ALTER PROCEDURE [dbo].[rp_ListadePreciosDonvic] 
@moneda char(2),
@Familia char(50)

AS

SET DATEFORMAT dmy

begin 


declare @tasa money
 
set @tasa=(select  top 1 Cambio from DONVIC600.dbo.MonedasCambio where MonedasCambio.Fecha=MonedasCambio.Fecha AND IdMoneda = '2' order by fecha desc)

if @moneda='BS'
		if @familia='GRANEL'
				SELECT * FROM 
				(
							SELECT  Productos.CodigoProducto,Nombre,Referencia,@tasa as Tasa,Tarifa, PrecioMoneda AS PRECIO				
							FROM Productos
							INNER JOIN ProductosPrecios ON Productos.CodigoProducto = ProductosPrecios.CodigoProducto
							where Referencia ='ULTRA CLEAN' or Referencia = 'PROMOCIÓN' or Referencia = 'PREMIUM' 
							or Referencia = 'USO PERSONAL'  OR Referencia = 'BASES ULTRA CLEAN' 
							or Referencia = 'BASES PREMIUM' OR Referencia = 'ENVASES' OR Referencia = 'AUTOMOTRIZ'
							OR Referencia = 'MATERIAPQ' OR Referencia = 'MATERIAPF' OR Referencia = 'MATERIAPC'
							OR Referencia = 'MATERIAPE' OR Referencia = 'MINI KIT PREMIUM' OR Referencia = 'MINI KIT ULTRA CLEAN'
							OR Referencia = 'COMBOS ULTRA' OR Referencia = 'COMBOS PREMIUM'
							OR Referencia = 'NEGOCIO ULTRA' OR Referencia = 'NEGOCIO PREMIUM' OR Referencia = 'AGRICOLA'
							and Precio <> 0 
				) AS ProductTarifa
				PIVOT (SUM(PRECIO)
				FOR Tarifa IN ([A],[B],[C],[D],[E],[F],[G],[H],[I],[J],[K],[L],[M]))
				as Product

if @moneda='DI'
if @familia='GRANEL'
						SELECT * FROM 
				(
							SELECT  Productos.CodigoProducto,Nombre,Referencia,@tasa as Tasa,Tarifa, PrecioMoneda AS PRECIO					
							FROM Productos
							INNER JOIN ProductosPrecios ON Productos.CodigoProducto = ProductosPrecios.CodigoProducto
							where Referencia ='ULTRA CLEAN' or Referencia = 'PROMOCIÓN' or Referencia = 'PREMIUM' 
							or Referencia = 'USO PERSONAL'  OR Referencia = 'BASES ULTRA CLEAN' 
							or Referencia = 'BASES PREMIUM' OR Referencia = 'ENVASES' OR Referencia = 'AUTOMOTRIZ'
							OR Referencia = 'MATERIAPQ' OR Referencia = 'MATERIAPF' OR Referencia = 'MATERIAPC'
							OR Referencia = 'MATERIAPE'  OR Referencia = 'MINI KIT PREMIUM' OR Referencia = 'MINI KIT ULTRA CLEAN'
							OR Referencia = 'COMBOS ULTRA' OR Referencia = 'COMBOS PREMIUM'
							OR Referencia = 'NEGOCIO ULTRA' OR Referencia = 'NEGOCIO PREMIUM' OR Referencia = 'AGRICOLA'
							and Precio <> 0  
				) AS ProductTarifa
				PIVOT (SUM(PRECIO)
				FOR Tarifa IN ([A],[B],[C],[D],[E],[F],[G],[H],[I],[J],[K],[L],[M]))
				as Product


			



	end 