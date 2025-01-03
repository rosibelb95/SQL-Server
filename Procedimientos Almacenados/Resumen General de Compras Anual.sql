USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_ResumenComprasAnuales]    Script Date: 19/12/2024 10:51:18 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[rp_ResumenComprasAnuales]

@YearInicial int,
@YearFinal int,
@Mes int
AS

SET DATEFORMAT dmy
BEGIN


SELECT CentroCosto,FYear,FMes,CodigoProducto,descripcion,SUM(TOTALRENGLON) as TotalRenglon, SUM(TotalRenglon2) as TotalRenglon2,CodigoGrupo
FROM (
	 SELECT Compras.Numero,Compras.CentroCosto,CR.CodigoProducto,CR.Descripcion,CR.TotalRenglon AS TOTALRENGLON,
	 'Re' AS CodigoGrupo, 'RETENCIONES' AS Nombre, YEAR(Compras.FechaEmision) AS FYear,MONTH(Compras.FechaEmision) AS FMes,
	 CR.TotalRenglon2 AS TotalRenglon2,
	 ContabilidadCentroCosto.Nombre AS 'CentroCostoNombre' FROM Compras
			INNER JOIN ComprasRenglones CR ON Compras.Numero= CR.Numero 
			INNER JOIN ContabilidadCentroCosto ON Compras.CentroCosto = ContabilidadCentroCosto.CentroCosto
			WHERE year(FechaEmision) BETWEEN @YearInicial and   @YearFinal
			AND @Mes = MONTH(Compras.FechaEmision)
			AND SUBSTRING(CR.CodigoProducto,1,1)='(' -- SELECT DE RETENCIONES 
			
		
	UNION ALL

			SELECT Compras.Numero,Compras.CentroCosto,LEFT(CR.CodigoProducto, 4) AS CodigoProducto,CR.Descripcion,  CR.TotalRenglon AS TOTALRENGLON,
			S.CodigoGrupo, SG.Nombre, YEAR(Compras.FechaEmision) AS FYear,MONTH(Compras.FechaEmision) AS FMes,
			CR.TotalRenglon2 AS TotalRenglon2,
			ContabilidadCentroCosto.Nombre AS 'CentroCostoNombre' FROM Compras
			INNER JOIN ComprasRenglones CR ON Compras.Numero= CR.Numero 
			INNER JOIN Servicios S ON CR.CodigoProducto like '%'+S.Codigo+'%'   --CR.Descripcion=S.Nombre   
			INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo
			INNER JOIN ContabilidadCentroCosto ON Compras.CentroCosto = ContabilidadCentroCosto.CentroCosto 
			WHERE year(FechaEmision) BETWEEN @YearInicial and   @YearFinal
			AND @Mes = MONTH(Compras.FechaEmision)
			AND SUBSTRING(CR.CodigoProducto,1,1)='/' --SELECT DE SERVICIOS
			
	UNION ALL 

	   SELECT Compras.Numero,Compras.CentroCosto,CR.CodigoProducto,CR.Descripcion,CR.TotalRenglon AS TOTALRENGLON,
	   P.CodigoGrupo,PG.Nombre, YEAR(Compras.FechaEmision) AS FYear,MONTH(Compras.FechaEmision) AS FMes,
	   CR.TotalRenglon2 AS TotalRenglon2,
	   ContabilidadCentroCosto.Nombre AS 'CentroCostoNombre'  FROM Compras
			INNER JOIN ComprasRenglones CR ON Compras.Numero= CR.Numero 
			INNER JOIN Productos P ON CR.CodigoProducto=P.CodigoProducto
			INNER JOIN ProductosGrupos PG  on P.CodigoGrupo=PG.CodigoGrupo 
			INNER JOIN ContabilidadCentroCosto ON Compras.CentroCosto = ContabilidadCentroCosto.CentroCosto
			WHERE year(FechaEmision) BETWEEN @YearInicial and   @YearFinal 
			AND @Mes =	MONTH(Compras.FechaEmision)

	) as ResumenFinal

		Group by ResumenFinal.CentroCosto, FMes, FYear, CodigoProducto,CodigoGrupo,Descripcion

END
