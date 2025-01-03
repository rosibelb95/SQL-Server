USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[DistribucionDonvicTotal]    Script Date: 19/12/2024 11:00:59 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DistribucionDonvicTotal] 

@FechaInicial datetime,
@FechaFinal datetime

AS

SET DATEFORMAT dmy

BEGIN



SELECT Distri.CentroCosto, Distri.CodigoProducto, Distri.Descripcion, SUM(TotalRenglon) AS TotalRenglon, sum(totalrenglon2) AS TotalRenglon2, CodigoGrupo,
Nombre

FROM (
		SELECT C.Numero, C.FechaEmision, CR.Descripcion, CR.CodigoProducto,CR.TotalRenglon,CR.CodigoProveedor,
			C.Referencia,C.Comentarios, C.CentroCosto,CR.TotalRenglon2,'Re' AS CodigoGrupo,'RETENCIONES' AS Nombre											
			FROM   Compras C
			INNER JOIN ComprasRenglones CR ON C.Numero=CR.Numero  
			WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
			and C.CentroCosto ='001' AND SUBSTRING(CR.CodigoProducto,1,1)='(' -- SELECT DE RETENCIONES
			and CR.TotalRenglon > 0
UNION ALL 

            SELECT C.Numero, C.FechaEmision, CR.Descripcion, CR.CodigoProducto,CR.TotalRenglon,CR.CodigoProveedor,
			C.Referencia,C.Comentarios, C.CentroCosto,CR.TotalRenglon2,S.CodigoGrupo,SG.Nombre											
			FROM   Compras C										
			INNER JOIN ComprasRenglones CR ON C.Numero= CR.Numero 
			INNER JOIN Servicios S ON CR.CodigoProducto like '%'+S.Codigo+'%'   --CR.Descripcion=S.Nombre   
			INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo
			WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
			and Recepcion IS NULL and  C.CentroCosto ='001' and CodigoProducto NOT LIKE '1024%' AND CodigoProducto NOT LIKE '1412%'
			and CR.TotalRenglon > 0


UNION ALL 

            SELECT C.Numero, C.FechaEmision, CR.Descripcion, CR.CodigoProducto,CR.TotalRenglon,CR.CodigoProveedor,
			C.Referencia,C.Comentarios, C.CentroCosto,CR.TotalRenglon2,S.CodigoGrupo,SG.Nombre											
			FROM   Compras C										
			INNER JOIN ComprasRenglones CR ON C.Numero= CR.Numero 
			INNER JOIN Servicios S ON CR.CodigoProducto like '%'+S.Codigo+'%'   --CR.Descripcion=S.Nombre   
			INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo
			WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
			and C.CentroCosto ='010' 
			and CR.TotalRenglon > 0

			
UNION ALL 

            SELECT C.Numero, C.FechaEmision, CR.Descripcion, CR.CodigoProducto,CR.TotalRenglon,CR.CodigoProveedor,
			C.Referencia,C.Comentarios, C.CentroCosto,CR.TotalRenglon2,S.CodigoGrupo,SG.Nombre											
			FROM   Compras C										
			INNER JOIN ComprasRenglones CR ON C.Numero= CR.Numero 
			INNER JOIN Servicios S ON CR.CodigoProducto like '%'+S.Codigo+'%'   --CR.Descripcion=S.Nombre   
			INNER JOIN ServiciosGrupos SG on S.CodigoGrupo=SG.CodigoGrupo
			WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
			and C.CentroCosto ='011' 
			and CR.TotalRenglon > 0


/*UNION ALL

		    SELECT C.Numero, C.FechaEmision, CR.Descripcion, CR.CodigoProducto,CR.TotalRenglon,CR.CodigoProveedor,
			C.Referencia,C.Comentarios, C.CentroCosto,CR.TotalRenglon2,'0',PG.Nombre											
			FROM   Compras C										
			INNER JOIN ComprasRenglones CR ON C.Numero= CR.Numero 
			INNER JOIN Productos P ON CR.CodigoProducto=P.CodigoProducto
			INNER JOIN ProductosGrupos PG  on P.CodigoGrupo=PG.CodigoGrupo 
			WHERE convert(char(8),Fechaemision,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112)
			and CR.TotalRenglon > 0*/

		) Distri
					   	
		GROUP BY Distri.CentroCosto, Distri.CodigoProducto,Distri.Descripcion, Distri.CodigoGrupo,Distri.Nombre
END
