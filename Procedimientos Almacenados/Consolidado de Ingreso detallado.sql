USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_ConsolidadoVentas]    Script Date: 19/12/2024 10:18:16 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** 
			PROCEDIMIENTO ALMACENADO que muestra el consolidado de ingreso a detalle, incluyendo la forma de pago: Banco, Punto de
			Venta, efectivo, muestra por vendedores y si el pago fue en Bs o en $ 
			

			Desarrollado por: Ing. Rosibel Briceño

******/

ALTER PROCEDURE [dbo].[rp_ConsolidadoVentas] 
@FechaInicial datetime,
@FechaFinal datetime

AS

SET DATEFORMAT dmy

/* AQUI INCLUYO INFOMACION DEL PUNTO DE VENTA*/
	SELECT 'Trujillo' AS Sucursal,fecha,Bpvm.CodigoBenef,Clientes.Nombre,FacturaCompra, Origen, Importe, importe2,BancosPuntoVenta.Nombre as FormaPago,
	Bancos.Nombre as Modalidad,BPVM.CodigoCaja,TPVFacturas.Vendedor,BPVM.cambio,BPVM.IdMoneda
	,' ' as Banco
	FROM   BancosPuntoVentaMovimientos BPVM
	INNER JOIN Clientes on BPVM.CodigoBenef = Clientes.CodigoCliente
	INNER JOIN BancosPuntoVenta on BPVM.CodigoPunto = BancosPuntoVenta.Codigo
	INNER JOIN TPVFacturas ON  BPVM.FacturaCompra = TPVFacturas.Numero
	INNER JOIN Bancos ON  Bancos.CodigoBanco = BancosPuntoVenta.CodigoBanco
	WHERE convert(char(8),Fecha,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
	

	UNION ALL

	SELECT 'Trujillo' AS Sucursal,fecha,BancosMovimientos.CodigoBenef,Clientes.Nombre,NumeroOrigen, Origen, Importe, importe2,'Transferencias/PagoMóvil' as FormaPago,
	Bancos.Nombre AS Modalidad,' ' as CodigoCaja,TPVFacturas.Vendedor,BancosMovimientos.cambio,BancosMovimientos.IdMoneda
	,' ' as Banco 
	FROM   BancosMovimientos
	INNER JOIN Clientes on BancosMovimientos.CodigoBenef = Clientes.CodigoCliente
	INNER JOIN TPVFacturas ON  BancosMovimientos.NumeroOrigen = TPVFacturas.Numero
	INNER JOIN Bancos on Bancos.CodigoBanco = BancosMovimientos.CodigoBanco
	WHERE convert(char(8),Fecha,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) AND Origen ='TPV'


	UNION ALL

	SELECT 'Trujillo' AS Sucursal,fecha,CajaMovimientos.CodigoBenef,Nombre,NumeroOrigen, Origen, Importe, importe2,'Efectivo' as FormaPago,
	' ' as Modalidad,CajaMovimientos.CodigoCaja,TPVFacturas.Vendedor, CajaMovimientos.cambio, CajaMovimientos.IdMoneda
	,' ' as Banco
	FROM   CajaMovimientos
	INNER JOIN Clientes on CajaMovimientos.CodigoBenef = Clientes.CodigoCliente
	INNER JOIN TPVFacturas ON  CajaMovimientos.NumeroOrigen = TPVFacturas.Numero
	WHERE convert(char(8),Fecha,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) AND Origen ='TPV'


	UNION ALL


	/*AQUI INCLUYO SOLO LO DE FACTURAS*/

	
	SELECT 'Trujillo' AS Sucursal,fecha,Bpvm.CodigoBenef,Clientes.Nombre,FacturaCompra, Origen, Importe, importe2,BancosPuntoVenta.Nombre as FormaPago,
	Bancos.Nombre as Modalidad,BPVM.CodigoCaja,Facturas.Vendedor,BPVM.cambio,BPVM.IdMoneda
	,' ' as Banco
	FROM   BancosPuntoVentaMovimientos BPVM
	INNER JOIN Clientes on BPVM.CodigoBenef = Clientes.CodigoCliente
	INNER JOIN BancosPuntoVenta on BPVM.CodigoPunto = BancosPuntoVenta.Codigo
	INNER JOIN Facturas ON  BPVM.FacturaCompra = Facturas.Numero
	INNER JOIN Bancos ON  Bancos.CodigoBanco = BancosPuntoVenta.CodigoBanco
	WHERE convert(char(8),Fecha,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) 
	

	UNION ALL

	SELECT 'Trujillo' AS Sucursal,fecha,BancosMovimientos.CodigoBenef,Clientes.Nombre,NumeroOrigen, Origen, Importe, importe2,'Transferencias/PagoMóvil' as FormaPago,
	Bancos.Nombre AS Modalidad,' ' as CodigoCaja,Facturas.Vendedor,BancosMovimientos.cambio,BancosMovimientos.IdMoneda
	,' ' as Banco 
	FROM   BancosMovimientos
	INNER JOIN Clientes on BancosMovimientos.CodigoBenef = Clientes.CodigoCliente
	INNER JOIN Bancos on Bancos.CodigoBanco = BancosMovimientos.CodigoBanco
	INNER JOIN Facturas ON  BancosMovimientos.NumeroOrigen = Facturas.Numero
	WHERE convert(char(8),Fecha,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) AND Origen ='FAC'


	UNION ALL

	SELECT 'Trujillo' AS Sucursal,fecha,CajaMovimientos.CodigoBenef,Nombre,NumeroOrigen, Origen, Importe, importe2,'Efectivo' as FormaPago,
	' ' as Modalidad,CajaMovimientos.CodigoCaja,Facturas.Vendedor, CajaMovimientos.cambio, CajaMovimientos.IdMoneda
	,' ' as Banco
	FROM   CajaMovimientos
	INNER JOIN Clientes on CajaMovimientos.CodigoBenef = Clientes.CodigoCliente
	INNER JOIN Facturas ON  CajaMovimientos.NumeroOrigen = Facturas.Numero
	WHERE convert(char(8),Fecha,112) BETWEEN convert(char(8), @FechaInicial,112) and  convert(char(8), @FechaFinal,112) AND Origen ='FAC'





	


