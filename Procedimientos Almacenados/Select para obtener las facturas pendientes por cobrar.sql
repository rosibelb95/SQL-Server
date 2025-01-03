USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_FacturasPendientes]    Script Date: 19/12/2024 10:47:07 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[rp_FacturasPendientes] 

@Hasta datetime

AS

	SELECT ClientesMovimientos.CodigoCliente,Nombre, Numero,SUM(Importe) AS Importe,SUM(Importe2) AS Importe2, MIN(CAST(Emision AS datetime)) AS Emision,  MIN(CAST(Vencimiento AS datetime)) AS Vencimiento
   
  FROM [DONVIC600].[dbo].[ClientesMovimientos]
  INNER JOIN Clientes On ClientesMovimientos.CodigoCliente = Clientes.CodigoCliente
  GROUP BY ClientesMovimientos.CodigoCliente,Nombre, Numero