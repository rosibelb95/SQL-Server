USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_ResumenCompras]    Script Date: 19/12/2024 10:52:19 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[rp_ResumenCompras]

@FechaInicial datetime,
@FechaFinal datetime

AS

SET DATEFORMAT dmy
BEGIN
	 SELECT Compras.Numero,Compras.CentroCosto,CR.CodigoProducto,CR.Descripcion,CR.TotalRenglon,CR.CodigoProveedor,CR.TarifaRet,
	 'Re' AS CodigoGrupo, 'RETENCIONES' AS Nombre, Compras.FechaEmision, Compras.TotalCompra, Compras.TotalCompra2,
	 CR.Cantidad,Compras.Comentarios,Proveedores.Nombre AS NombreProveedor,Compras.Referencia,CR.TotalRenglon2,
	 ContabilidadCentroCosto.Nombre AS 'CentroCostoNombre' FROM Compras
			INNER JOIN ComprasRenglones CR ON Compras.Numero= CR.Numero 
			INNER JOIN Proveedores ON Proveedores.CodigoProveedor = Compras.CodigoProveedor
			INNER JOIN ContabilidadCentroCosto ON Compras.CentroCosto = ContabilidadCentroCosto.CentroCosto
			WHERE  convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)
			AND SUBSTRING(CR.CodigoProducto,1,1)='('  -- SELECT DE RETENCIONES

	UNION ALL

			SELECT Compras.Numero,Compras.CentroCosto,LEFT(CR.CodigoProducto, 4) AS CodigoProducto, CR.Descripcion,CR.TotalRenglon,CR.CodigoProveedor,CR.TarifaRet,
			S.CodigoGrupo, SG.Nombre, Compras.FechaEmision, Compras.TotalCompra, Compras.TotalCompra2,
			CR.Cantidad,Compras.Comentarios,Proveedores.Nombre AS NombreProveedor,Compras.Referencia,CR.TotalRenglon2,
			ContabilidadCentroCosto.Nombre AS 'CentroCostoNombre' FROM Compras
			INNER JOIN ComprasRenglones CR ON Compras.Numero= CR.Numero 
			INNER JOIN Servicios S ON CR.CodigoProducto like '%'+S.Codigo+'%'   --CR.Descripcion=S.Nombre   
			INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo
			INNER JOIN Proveedores ON Proveedores.CodigoProveedor = Compras.CodigoProveedor
			INNER JOIN ContabilidadCentroCosto ON Compras.CentroCosto = ContabilidadCentroCosto.CentroCosto 
			WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
			AND SUBSTRING(CR.CodigoProducto,1,1)='/' --SELECT DE SERVICIOS
			
	UNION ALL 

	   SELECT Compras.Numero,Compras.CentroCosto,CR.CodigoProducto,CR.Descripcion,CR.TotalRenglon,CR.CodigoProveedor,CR.TarifaRet,
	   P.CodigoGrupo,PG.Nombre, Compras.FechaEmision, Compras.TotalCompra, Compras.TotalCompra2,
	   CR.Cantidad,Compras.Comentarios,Proveedores.Nombre AS NombreProveedor,Compras.Referencia,CR.TotalRenglon2,
	   ContabilidadCentroCosto.Nombre AS 'CentroCostoNombre'  FROM Compras
			INNER JOIN ComprasRenglones CR ON Compras.Numero= CR.Numero 
			INNER JOIN Productos P ON CR.CodigoProducto=P.CodigoProducto
			INNER JOIN ProductosGrupos PG  on P.CodigoGrupo=PG.CodigoGrupo 
			INNER JOIN Proveedores ON Proveedores.CodigoProveedor = Compras.CodigoProveedor
			INNER JOIN ContabilidadCentroCosto ON Compras.CentroCosto = ContabilidadCentroCosto.CentroCosto
			WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)
	order by Compras.Numero asc


END
