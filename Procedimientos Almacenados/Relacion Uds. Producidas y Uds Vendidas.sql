USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_CostosVentas]    Script Date: 19/12/2024 10:36:21 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
			PROCEDIMIENTO ALMACENADO para mostrar Unidades vendidas, producidas, el costo y los litros en una fecha determinada
			La función es: Poder determinar las cantidades vendidas y producidas
			

			Desarrollado por: Ing. Rosibel Briceño

******/
ALTER PROCEDURE [dbo].[rp_CostosVentas]
@FechaInicial datetime,
@FechaFinal datetime,
@moneda char(2)
AS

SET DATEFORMAT dmy
BEGIN

 
if @moneda='BS'



SELECT FactDesc.CodigoProducto, FactDesc.Nombre,Sum(FactDesc.UnidadesProducidas) as UnidadesProducidas,FactDesc.Costo, 
Sum(FactDesc.Cantidad) as CantidadesVendidas, Sum (FactDesc.TotalRenglon) as TotalFacturado,CodigoGrupo, NombreGrupo, 0 as LitrosVendidos
	From  (


	SELECT fr.CodigoProducto, fr.Descripcion, 0 as UnidadesProducidas, '0' as Costo,
		fr.Cantidad, fr.totalrenglon, 0 as TotalFacturado, S.Nombre, SG.Nombre as NombreGrupo, SG.CodigoGrupo AS CodigoGrupo
				FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
				INNER JOIN Servicios S ON FR.CodigoProducto='/'+S.Codigo
				INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo 
				WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
				AND SUBSTRING(fr.CodigoProducto,1,1)='/'

	) as FactDesc

	Group by FactDesc.CodigoProducto,FactDesc.Nombre,FactDesc.Costo,FactDesc.CodigoGrupo, FactDesc.NombreGrupo


	UNION ALL

SELECT Fact.CodigoProducto, P.Nombre,Sum(Fact.UnidadesProducidas) as UnidadesProducidas,P.PrecioSugerido as Costo, 
Sum(Fact.Cantidad) as CantidadesVendidas, Sum (Fact.TotalRenglon) as TotalFacturado,Fact.CodigoGrupo, NombreGrupo, P.Peso
	From  (


				SELECT F.Numero, FechaEmision, TotalBruto, TotalFactura,  'FAC' AS TIPO ,
				fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon,  P.CodigoGrupo as CodigoGrupo,PG.Nombre as NombreGrupo, 0 as UnidadesProducidas
				FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
				INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
				INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
				WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
				AND SUBSTRING(fr.CodigoProducto,1,1)<>'/'

					UNION ALL

				SELECT F.Numero, FechaEmision, TotalBruto, TotalFactura,  'TPV' AS TIPO,
				fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon, P.CodigoGrupo as CodigoGrupo,PG.Nombre as NombreGrupo, 0 as UnidadesProducidas
				FROM TPVFacturas F INNER JOIN TPVFacturasRenglones FR ON F.Numero=FR.Numero 
				INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
				INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
				WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0	  			 


					UNION ALL

				SELECT Numero, FechaInicio, 0 AS TotalBruto,0 AS TotalFactura, 'PRODUCCION' AS TIPO,
				OrdenesProduccion.CodigoProducto,'0' AS Descripcion,0 AS Cantidad, 0 AS TotalRenglon, 
				P.CodigoGrupo as CodigoGrupo, PG.Nombre as NombreGrupo, OrdenesProduccion.Cantidad as UnidadesProducidas
				FROM OrdenesProduccion 
				INNER JOIN Productos P ON OrdenesProduccion.CodigoProducto=P.CodigoProducto
				INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
				WHERE convert(char(8),FechaInicio,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
) as Fact
	
	INNER JOIN Productos P ON Fact.CodigoProducto=P.CodigoProducto
	WHERE convert(char(8),@FechaInicial,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)	
	
Group by Fact.CodigoProducto,P.Nombre,P.PrecioSugerido, Fact.CodigoGrupo, Fact.NombreGrupo,P.Peso
				


ELSE IF @moneda='DI'


SELECT FactDesc.CodigoProducto, FactDesc.Nombre,Sum(FactDesc.UnidadesProducidas) as UnidadesProducidas,FactDesc.Costo, 
Sum(FactDesc.Cantidad) as CantidadesVendidas, Sum (FactDesc.TotalRenglon) as TotalFacturado,CodigoGrupo , NombreGrupo, 0 as LitrosVendidos
	From  (


	SELECT fr.CodigoProducto, fr.Descripcion, 0 as UnidadesProducidas, '0' as Costo,
		fr.Cantidad, fr.totalrenglon2 as TotalRenglon, 0 as TotalFacturado, S.Nombre, SG.Nombre as NombreGrupo, SG.CodigoGrupo AS CodigoGrupo
				FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
				INNER JOIN Servicios S ON FR.CodigoProducto='/'+S.Codigo
				INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo 
				WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
				AND SUBSTRING(fr.CodigoProducto,1,1)='/'

	) as FactDesc

	Group by FactDesc.CodigoProducto,FactDesc.Nombre,FactDesc.Costo,FactDesc.CodigoGrupo, FactDesc.NombreGrupo


	UNION ALL

SELECT Fact.CodigoProducto, P.Nombre,Sum(Fact.UnidadesProducidas) as UnidadesProducidas,P.PrecioSugerido as Costo, 
Sum(Fact.Cantidad) as CantidadesVendidas, Sum (Fact.TotalRenglon) as TotalFacturado,Fact.CodigoGrupo, NombreGrupo, P.Peso
	From  (


				SELECT F.Numero, FechaEmision, TotalBruto, TotalFactura,  'FAC' AS TIPO ,
				fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon2 as TotalRenglon,  P.CodigoGrupo as CodigoGrupo,PG.Nombre as NombreGrupo, 0 as UnidadesProducidas
				FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
				INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
				INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
				WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
				AND SUBSTRING(fr.CodigoProducto,1,1)<>'/'

					UNION ALL

				SELECT F.Numero, FechaEmision, TotalBruto, TotalFactura,  'TPV' AS TIPO,
				fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon2 as TotalRenglon, P.CodigoGrupo as CodigoGrupo,PG.Nombre as NombreGrupo, 0 as UnidadesProducidas
				FROM TPVFacturas F INNER JOIN TPVFacturasRenglones FR ON F.Numero=FR.Numero 
				INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
				INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
				WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0	  			 


					UNION ALL

				SELECT Numero, FechaInicio, 0 AS TotalBruto,0 AS TotalFactura, 'PRODUCCION' AS TIPO,
				OrdenesProduccion.CodigoProducto,'0' AS Descripcion,0 AS Cantidad, 0 AS TotalRenglon, 
				P.CodigoGrupo as CodigoGrupo, PG.Nombre as NombreGrupo, OrdenesProduccion.Cantidad as UnidadesProducidas
				FROM OrdenesProduccion 
				INNER JOIN Productos P ON OrdenesProduccion.CodigoProducto=P.CodigoProducto
				INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
				WHERE convert(char(8),FechaInicio,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
) as Fact
	
	INNER JOIN Productos P ON Fact.CodigoProducto=P.CodigoProducto
	WHERE convert(char(8),@FechaInicial,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)	
	
Group by Fact.CodigoProducto,P.Nombre,P.PrecioSugerido, Fact.CodigoGrupo, Fact.NombreGrupo, P.Peso
				


	END

