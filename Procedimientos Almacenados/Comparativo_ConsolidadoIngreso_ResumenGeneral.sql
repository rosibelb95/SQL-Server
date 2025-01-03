USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_Consolidado_ResumenGeneral]    Script Date: 19/12/2024 9:19:12 a.m. ******/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
			PROCEDIMIENTO ALMACENADO QUE REALIZA UNA SELECCION DEL CONSOLIDADO DE INGRESO Y EL RESUMEN GENERAL DE VENTAS
			Su funcion: Es comparar que esten los montos cuadrado y determinar que día tiene una diferencia.
			

			Desarrollado por: Ing. Rosibel Briceño



******/
ALTER PROCEDURE [dbo].[rp_Consolidado_ResumenGeneral] 
@FechaInicial datetime,
@FechaFinal datetime,
@moneda char(2)

AS

SET DATEFORMAT dmy

 IF @moneda='DI'




/****** Extraer los datos del consolidado de ingresos******/


SELECT  Vendedor, Fecha, TIPO,SUM(CONSOLIDADO) AS Consolidado, SUM(Resumen) as Resumen
FROM (
	SELECT 0 as Numero,CAST(FechaEmision AS DATE) as Fecha, Vendedor,  TIPO,SUM(totalbrutoC) AS CONSOLIDADO, (0) AS Resumen
	From  (
					SELECT Numero, FechaEmision, TotalBruto2 AS totalbrutoC, Vendedor,TipoPago,CodigoCaja, 'FAC' AS TIPO 
					FROM            Facturas WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)

					UNION ALL


					SELECT Numero, FechaEmision, TotalBruto2 AS totalbrutoC, Vendedor,TipoPago,CodigoCaja, 'TPV' AS TIPO 
					FROM           TPVFacturas WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)

					UNION ALL

					SELECT  Numero, Emision, TotalBruto,   Vendedor, '' AS TIPOPAGO,'' AS CODIGOCAJA, 'CXC' AS TIPO 
					FROM            ClientesMovimientos WHERE Tipo IN ('AB','CA','AA') AND  convert(char(8),emision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)
				
				) as ConsolidadoIngreso

		Group by CAST(FechaEmision AS DATE),ConsolidadoIngreso.Vendedor,  tipo


		UNION ALL



		
/****** Extraer los datos del Resumen general de Ventas******/

	SELECT  Numero,CAST(FechaEmision AS DATE) as Fecha,Vendedor,  TIPO,SUM(0) AS CONSOLIDADO, SUM(totalrenglon) as Resumen
	From  (
					SELECT F.Numero, FechaEmision, Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,	fr.TotalRenglon2 as totalrenglon
					FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
					INNER JOIN Servicios S ON FR.CodigoProducto='/'+S.Codigo
					WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
					AND SUBSTRING(fr.CodigoProducto,1,1)='/'

					UNION ALL

					SELECT F.Numero, FechaEmision,  Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,fr.TotalRenglon2 as totalrenglon
					FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
					INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
					WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
					AND SUBSTRING(fr.CodigoProducto,1,1)<>'/'
	
					UNION ALL

					SELECT F.Numero, FechaEmision, F.Vendedor,TipoPago, CodigoCaja, 'TPV' AS TIPO,fr.TotalRenglon2 as totalrenglon
					FROM TPVFacturas F INNER JOIN TPVFacturasRenglones FR ON F.Numero=FR.Numero 
					INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
					WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0

				)	AS ResumenGeneral
		Group by CAST(FechaEmision AS DATE),ResumenGeneral.Vendedor,  tipo,Numero,FechaEmision
		
) as ResumenFinal

		Group by ResumenFinal.Vendedor,  tipo, Fecha




/****** Extraer los datos del consolidado de ingresos******/
ELSE IF @moneda='BS'

SELECT  Vendedor, Fecha, TIPO,SUM(CONSOLIDADO) AS Consolidado, SUM(Resumen) as Resumen
FROM (
	SELECT 0 as Numero,CAST(FechaEmision AS DATE) as Fecha, Vendedor,  TIPO,SUM(totalbrutoC) AS CONSOLIDADO, (0) AS Resumen
	From  (
					SELECT Numero, FechaEmision, TotalBruto AS totalbrutoC, Vendedor,TipoPago,CodigoCaja, 'FAC' AS TIPO 
					FROM            Facturas WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)

					UNION ALL


					SELECT Numero, FechaEmision, TotalBruto AS totalbrutoC, Vendedor,TipoPago,CodigoCaja, 'TPV' AS TIPO 
					FROM           TPVFacturas WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)

					UNION ALL

					SELECT  Numero, Emision, TotalBruto,   Vendedor, '' AS TIPOPAGO,'' AS CODIGOCAJA, 'CXC' AS TIPO 
					FROM            ClientesMovimientos WHERE Tipo IN ('AB','CA','AA') AND  convert(char(8),emision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)
				
				) as ConsolidadoIngreso

		Group by CAST(FechaEmision AS DATE),ConsolidadoIngreso.Vendedor,  tipo


		UNION ALL


/****** Extraer los datos del Resumen general de Ventas******/

	SELECT  Numero,CAST(FechaEmision AS DATE) as Fecha,Vendedor,  TIPO,SUM(0) AS CONSOLIDADO, SUM(totalrenglon) as Resumen
	From  (
					SELECT F.Numero, FechaEmision, Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,	fr.TotalRenglon as totalrenglon
					FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
					INNER JOIN Servicios S ON FR.CodigoProducto='/'+S.Codigo
					WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
					AND SUBSTRING(fr.CodigoProducto,1,1)='/'

					UNION ALL

					SELECT F.Numero, FechaEmision,  Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,fr.TotalRenglon as totalrenglon
					FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
					INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
					WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
					AND SUBSTRING(fr.CodigoProducto,1,1)<>'/'
	
					UNION ALL

					SELECT F.Numero, FechaEmision, F.Vendedor,TipoPago, CodigoCaja, 'TPV' AS TIPO,fr.TotalRenglon as totalrenglon
					FROM TPVFacturas F INNER JOIN TPVFacturasRenglones FR ON F.Numero=FR.Numero 
					INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
					WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0

				)	AS ResumenGeneral
		Group by CAST(FechaEmision AS DATE),ResumenGeneral.Vendedor,  tipo,Numero,FechaEmision
		
) as ResumenFinal

		Group by ResumenFinal.Vendedor,  tipo, Fecha
