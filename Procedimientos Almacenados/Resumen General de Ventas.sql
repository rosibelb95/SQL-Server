USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_ResumenVentas]    Script Date: 19/12/2024 10:52:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
			PROCEDIMIENTO ALMACENADO realizar un resumen de las ventas, seleccionando unidades vendidas y litros
			de factura y punto de ventas

			Desarrollado por: Ing. Rosibel Briceño



******/
ALTER PROCEDURE [dbo].[rp_ResumenVentas] 
@FechaInicial datetime,
@FechaFinal datetime, 
@moneda char(2)

AS

SET DATEFORMAT dmy
if @moneda='BS'

   
	SELECT F.Numero, FechaEmision, TotalBruto, TotalFactura, Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,
	 Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon, '0' AS Peso, S.CodigoGrupo, SG.Nombre 
	FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero    
	INNER JOIN Servicios S ON FR.CodigoProducto='/'+S.Codigo
	INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
	AND SUBSTRING(fr.CodigoProducto,1,1)='/'

	UNION ALL

	SELECT F.Numero, FechaEmision, TotalBruto, TotalFactura, Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,
	Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon, P.Peso, P.CodigoGrupo,PG.Nombre
	FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
	INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
	INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
	AND SUBSTRING(fr.CodigoProducto,1,1)<>'/'
	

	UNION ALL

	SELECT F.Numero, FechaEmision, TotalBruto, TotalFactura, F.Vendedor,TipoPago, CodigoCaja, 'TPV' AS TIPO,
	 F.Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon, P.Peso, P.CodigoGrupo,PG.Nombre 
	FROM           TPVFacturas F INNER JOIN TPVFacturasRenglones FR ON F.Numero=FR.Numero 
	INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
	INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0

ELSE IF @moneda='DI'

	SELECT F.Numero, FechaEmision, TotalBruto2 as totalbruto, TotalFactura2 as totalfactura, Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,
	Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon2 as totalrenglon, '0' AS Peso, S.CodigoGrupo, SG.Nombre
	FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
	INNER JOIN Servicios S ON FR.CodigoProducto='/'+S.Codigo
	INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
	AND SUBSTRING(fr.CodigoProducto,1,1)='/'

	UNION ALL

	SELECT F.Numero, FechaEmision, TotalBruto2 as totalbruto, TotalFactura2 as totalfactura, Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,
	 Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon2 as totalrenglon, P.Peso, P.CodigoGrupo,PG.Nombre
	FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
	INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
	INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
	AND SUBSTRING(fr.CodigoProducto,1,1)<>'/'
	
	UNION ALL


	SELECT F.Numero, FechaEmision, TotalBruto2 as totalbruto, TotalFactura2 as totalfactura, F.Vendedor,TipoPago, CodigoCaja, 'TPV' AS TIPO,
	 F.Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon2 as totalrenglon, P.Peso, P.CodigoGrupo,PG.Nombre 
	FROM           TPVFacturas F INNER JOIN TPVFacturasRenglones FR ON F.Numero=FR.Numero 
	INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
	INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0

/*
	SELECT F.Numero, FechaEmision, TotalBruto3 as totalbruto, TotalFactura3 as totalfactura, Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,
	Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon3 as totalrenglon, '0' AS Peso, S.CodigoGrupo, SG.Nombre
	FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
	INNER JOIN Servicios S ON FR.CodigoProducto='/'+S.Codigo
	INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
	AND SUBSTRING(fr.CodigoProducto,1,1)='/'

	UNION ALL

	SELECT F.Numero, FechaEmision, TotalBruto3 as totalbruto, TotalFactura3 as totalfactura, Vendedor, TipoPago,CodigoCaja, 'FAC' AS TIPO ,
	 Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon3 as totalrenglon, P.Peso, P.CodigoGrupo,PG.Nombre
	FROM   Facturas F INNER JOIN FacturasRenglones FR ON F.Numero=FR.Numero     
	INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
	INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char (8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0
	AND SUBSTRING(fr.CodigoProducto,1,1)<>'/'
	
	UNION ALL


	SELECT F.Numero, FechaEmision, TotalBruto3 as totalbruto, TotalFactura3 as totalfactura, F.Vendedor,TipoPago, CodigoCaja, 'TPV' AS TIPO,
	 F.Codigocliente,fr.CodigoProducto,fr.Descripcion,fr.Cantidad,fr.TotalRenglon3 as totalrenglon, P.Peso, P.CodigoGrupo,PG.Nombre 
	FROM           TPVFacturas F INNER JOIN TPVFacturasRenglones FR ON F.Numero=FR.Numero 
	INNER JOIN Productos P ON FR.CodigoProducto=P.CodigoProducto
	INNER JOIN PRODUCTOSGrupos PG on P.CodigoGrupo=PG.CodigoGrupo 
	WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) and f.TotalFactura<>0 */