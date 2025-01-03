USE [EMPRESA001]
GO
/****** Object:  StoredProcedure [dbo].[rp_EstructuraCostos]    Script Date: 19/12/2024 10:40:17 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
			PROCEDIMIENTO ALMACENADO que realiza la relacion de costos-utilidad 
			Muestra las Unidades vendidas, el costo para obtener un promedio y determinar el margen de ganancia 
			
			Esta compuesto por una tabla que registra las modificaciones, Si se selecciona S  Inserta o Actualiza los datos.
			Si se selecciona N solo realiza un SELECT de los datos ya registrados
			Desarrollado por: Ing. Rosibel Briceño



******/
ALTER PROCEDURE [dbo].[rp_EstructuraCostos]
@FechaInicial datetime,
@FechaFinal datetime,
@Registrar varchar(1),
@TasaCierre money                    
AS

BEGIN
	if @Registrar = 'S' 

			BEGIN
				DECLARE @CodigoProducto varchar(10), @fstatus int,@Nombre char(100),@CodigoGrupo nchar(5), @Peso money,@NombreGrupo char(100),
				@CostoDi money,@CostoBs money, @UnidadesProducidas money , @CantidadesVendidasFac money, @CantidadesVendidastpv money, 
				@TotalFacturadoBsFac money, @TotalFacturadoDiFac money,@TotalFacturadoBsTpv money, @TotalFacturadoDiTpv money		


				--SET @Tasa = (SELECT TOP (1) CAMBIO FROM MonedasCambio WHERE IDMONEDA = '2' ORDER BY FECHA DESC)

				--SET @Tasa = (select TOP (1) cambio FROM MonedasCambio WHERE IDMONEDA = '2' and  convert(char(8),Fecha,112) =@FechaFinal ORDER BY FECHA DESC)

				DECLARE Productos CURSOR FOR select Productos.CodigoProducto,Productos.Nombre,(@TasaCierre*PrecioSugerido),PrecioSugerido,Productos.CodigoGrupo,ProductosGrupos.Nombre,Peso from [Productos]  
				INNER JOIN ProductosGrupos ON Productos.CodigoGrupo = ProductosGrupos.CodigoGrupo
				OPEN Productos
				FETCH next FROM Productos INTO @CodigoProducto,@Nombre,@CostoBs,@CostoDi,@CodigoGrupo,@NombreGrupo, @Peso
				set @fstatus=@@FETCH_STATUS

				WHILE @@FETCH_STATUS = 0

						BEGIN

				
									 IF not EXISTS (SELECT * FROM tmpCostoVentas WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas]([CodigoProducto],[Nombre],[CostoBs],[CostoDi],[CodigoGrupo],[NombreGrupo],[Peso],[FechaInicial],[FechaFinal])
												VALUES(@CodigoProducto,@Nombre,@CostoBs,@CostoDi, @CodigoGrupo,@NombreGrupo,@Peso,@FechaInicial, @FechaFinal)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas]
												SET [Nombre] = @Nombre,
												[CostoBs] = @CostoBs, [CostoDi] = @CostoDi,
												[CodigoGrupo] = @CodigoGrupo,[NombreGrupo] = @NombreGrupo,[Peso] = @Peso
												 WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


	
							FETCH next FROM Productos INTO @CodigoProducto,@Nombre,@CostoBs,@CostoDi,@CodigoGrupo,@NombreGrupo,@Peso
						END

				close Productos
				deallocate Productos

/*INICIO DE DECLARE PARA LAS ORDENES DE PRODUCCION */
				DECLARE Productos1 CURSOR FOR  select Productos.CodigoProducto, SUM(Cantidad) from [OrdenesProduccion]  
				INNER JOIN Productos on OrdenesProduccion.CodigoProducto= Productos.CodigoProducto 
				---where (CONVERT( DATETIME,FechaInicio, 121) BETWEEN CONVERT( DATETIME,@FechaInicial, 121)  and  CONVERT( DATETIME,@FechaFinal, 121) )
				where (convert(char(8),OrdenesProduccion.FechaInicio,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	 )
				group by Productos.CodigoProducto

				SET @UnidadesProducidas = 0
				OPEN Productos1
				FETCH next FROM Productos1 INTO @CodigoProducto,@UnidadesProducidas
				set @fstatus=@@FETCH_STATUS
				WHILE @@FETCH_STATUS = 0

						BEGIN

				
									 IF not EXISTS (SELECT * FROM tmpCostoVentas WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas]([UnidadesProducidas])
												VALUES( @UnidadesProducidas)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas]
												SET [UnidadesProducidas] =@UnidadesProducidas
											 WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


	
							FETCH next FROM Productos1 INTO @CodigoProducto,@UnidadesProducidas

						END

				close Productos1
				deallocate Productos1
/*FIN DE DECLARE PARA LAS ORDENES DE PRODUCCION */

/*INICIO DE DECLARE PARA LAS FACTURAS MANUALES */
				DECLARE Facturas CURSOR FOR select FacturasRenglones.CodigoProducto, SUM(FacturasRenglones.Cantidad), SUM(TotalRenglon), SUM(TotalRenglon2) from [FacturasRenglones]  
				inner join Facturas ON Facturas.Numero = FacturasRenglones.Numero 
				--WHERE (CodigoProducto = CodigoProducto and convert(char(8),Facturas.FechaEmision,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	 )
				WHERE (Descripcion <> '*** Factura Anulada ***' AND CodigoProducto NOT LIKE '/%'  and convert(char(8),Facturas.FechaEmision,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	
				/*and Vendedor  BETWEEN '001' and  '499'*/ )
				GROUP BY CodigoProducto
				

				SET @CantidadesVendidasFac = 0
				SET @TotalFacturadoBsFac = 0
				SET @TotalFacturadoDiFac = 0
				OPEN Facturas

				FETCH next FROM Facturas INTO @CodigoProducto,@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac

				set @fstatus=@@FETCH_STATUS

				WHILE @@FETCH_STATUS = 0

						BEGIN

													 IF not EXISTS (SELECT * FROM tmpCostoVentas WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas]([CantidadesVendidasFacturas],[TotalFacturadoBsFac],[TotalFacturadoDIFac])
												VALUES(@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas]
												SET [CantidadesVendidasFacturas] =@CantidadesVendidasFac,
												[TotalFacturadoBsFac] =@TotalFacturadoBsFac,
												[TotalFacturadoDiFac] =@TotalFacturadoDiFac
												WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


					FETCH next FROM Facturas INTO @CodigoProducto,@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac
			
						END

				close Facturas
				deallocate Facturas


				DECLARE Facturas1 CURSOR FOR select TPVFacturasRenglones.CodigoProducto, SUM(TPVFacturasRenglones.Cantidad), SUM(TotalRenglon), SUM(TotalRenglon2) from [TPVFacturasRenglones]  
				inner join TPVFacturas ON TPVFacturas.Numero = TPVFacturasRenglones.Numero 
				WHERE (Descripcion <> '*ANULADA*' AND CodigoProducto NOT LIKE '/%' and convert(char(8),TPVFacturas.FechaEmision,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	
				/*and TPVFacturas.Vendedor  BETWEEN '001' and  '499'*/ )
				GROUP BY CodigoProducto
				SET @CantidadesVendidastpv = 0
				SET @TotalFacturadoBsTpv = 0
				SET @TotalFacturadoDiTPV = 0


				OPEN Facturas1

				FETCH next FROM Facturas1 INTO @CodigoProducto,@CantidadesVendidastpv,@TotalFacturadoBsTPV,@TotalFacturadoDiTPV



				set @fstatus=@@FETCH_STATUS

				WHILE @@FETCH_STATUS = 0

						BEGIN

													 IF not EXISTS (SELECT * FROM tmpCostoVentas WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas]([CantidadesVendidasTPVFact],[TotalFacturadoBsTPV],[TotalFacturadoDITPV])
												VALUES(@CantidadesVendidastpv,@TotalFacturadoBsTpv,@TotalFacturadoDiTpv)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas]
												SET [CantidadesVendidasTPVFact] = @CantidadesVendidastpv,
													[TotalFacturadoBsTPV] = @TotalFacturadoBsTpv,
													[TotalFacturadoDITpv] = @TotalFacturadoDiTpv
												 WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


					FETCH next FROM Facturas1 INTO @CodigoProducto,@CantidadesVendidastpv,@TotalFacturadoBsTPV,@TotalFacturadoDiTPV
			
						END

				close Facturas1
				deallocate Facturas1
				END


select * from tmpCostoVentas 
where convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
ORDER BY CodigoProducto ASC



END


/*
BEGIN
	if @Registrar = 'S' 

			BEGIN
				DECLARE @CodigoProducto varchar(10), @fstatus int,@Nombre char(100),@CodigoGrupo nchar(5), @Peso money,@NombreGrupo char(100),
				@CostoDi money,@CostoBs money, @UnidadesProducidas money , @CantidadesVendidasFac money, @CantidadesVendidastpv money, 
				@TotalFacturadoBsFac money, @TotalFacturadoDiFac money,@TotalFacturadoBsTpv money, @TotalFacturadoDiTpv money		


				DECLARE Productos CURSOR FOR select Productos.CodigoProducto,Productos.Nombre,(@TasaCierre*PrecioSugerido),PrecioSugerido,Productos.CodigoGrupo,ProductosGrupos.Nombre,Peso from [Productos]  
				INNER JOIN ProductosGrupos ON Productos.CodigoGrupo = ProductosGrupos.CodigoGrupo
				OPEN Productos
				FETCH next FROM Productos INTO @CodigoProducto,@Nombre,@CostoBs,@CostoDi,@CodigoGrupo,@NombreGrupo, @Peso
				set @fstatus=@@FETCH_STATUS

				WHILE @@FETCH_STATUS = 0

						BEGIN

				
									 IF not EXISTS (SELECT * FROM tmpCostoVentas WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas]([CodigoProducto],[Nombre],[CostoBs],[CostoDi],[CodigoGrupo],[NombreGrupo],[Peso],[FechaInicial],[FechaFinal])
												VALUES(@CodigoProducto,@Nombre,@CostoBs,@CostoDi, @CodigoGrupo,@NombreGrupo,@Peso,@FechaInicial, @FechaFinal)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas]
												SET [Nombre] = @Nombre,
												[CostoBs] = @CostoBs, [CostoDi] = @CostoDi,
												[CodigoGrupo] = @CodigoGrupo,[NombreGrupo] = @NombreGrupo,[Peso] = @Peso
												 WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


	
							FETCH next FROM Productos INTO @CodigoProducto,@Nombre,@CostoBs,@CostoDi,@CodigoGrupo,@NombreGrupo,@Peso
						END

				close Productos
				deallocate Productos

/*INICIO DE DECLARE PARA LAS ORDENES DE PRODUCCION */

				DECLARE Productos1 CURSOR FOR  select Productos.CodigoProducto, SUM(Cantidad) from [OrdenesProduccion]  
				INNER JOIN Productos on OrdenesProduccion.CodigoProducto= Productos.CodigoProducto 
				---where (CONVERT( DATETIME,FechaInicio, 121) BETWEEN CONVERT( DATETIME,@FechaInicial, 121)  and  CONVERT( DATETIME,@FechaFinal, 121) )
				where (convert(char(8),OrdenesProduccion.FechaInicio,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	 )
				group by Productos.CodigoProducto

				SET @UnidadesProducidas = 0
				OPEN Productos1
				FETCH next FROM Productos1 INTO @CodigoProducto,@UnidadesProducidas
				set @fstatus=@@FETCH_STATUS
				WHILE @@FETCH_STATUS = 0

						BEGIN

				
									 IF not EXISTS (SELECT * FROM tmpCostoVentas WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas]([UnidadesProducidas])
												VALUES( @UnidadesProducidas)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas]
												SET [UnidadesProducidas] =@UnidadesProducidas
											 WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


	
							FETCH next FROM Productos1 INTO @CodigoProducto,@UnidadesProducidas

						END

				close Productos1
				deallocate Productos1
/*FIN DE DECLARE PARA LAS ORDENES DE PRODUCCION */

/*INICIO DE DECLARE PARA LAS FACTURAS MANUALES */
				DECLARE Facturas CURSOR FOR select FacturasRenglones.CodigoProducto, SUM(FacturasRenglones.Cantidad), SUM(TotalRenglon), SUM(TotalRenglon2) from [FacturasRenglones]  
				inner join Facturas ON Facturas.Numero = FacturasRenglones.Numero 
				--WHERE (CodigoProducto = CodigoProducto and convert(char(8),Facturas.FechaEmision,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	 )
				WHERE (Descripcion <> '*** Factura Anulada ***' AND CodigoProducto NOT LIKE '/%'  and convert(char(8),Facturas.FechaEmision,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	
				/*and Vendedor  BETWEEN '001' and  '499'*/ )
				GROUP BY CodigoProducto
				

				SET @CantidadesVendidasFac = 0
				SET @TotalFacturadoBsFac = 0
				SET @TotalFacturadoDiFac = 0
				OPEN Facturas

				FETCH next FROM Facturas INTO @CodigoProducto,@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac

				set @fstatus=@@FETCH_STATUS

				WHILE @@FETCH_STATUS = 0

						BEGIN

													 IF not EXISTS (SELECT * FROM tmpCostoVentas WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas]([CantidadesVendidasFacturas],[TotalFacturadoBsFac],[TotalFacturadoDIFac])
												VALUES(@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas]
												SET [CantidadesVendidasFacturas] =@CantidadesVendidasFac,
												[TotalFacturadoBsFac] =@TotalFacturadoBsFac,
												[TotalFacturadoDiFac] =@TotalFacturadoDiFac
												WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


					FETCH next FROM Facturas INTO @CodigoProducto,@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac
			
						END

				close Facturas
				deallocate Facturas


				DECLARE Facturas1 CURSOR FOR select TPVFacturasRenglones.CodigoProducto, SUM(TPVFacturasRenglones.Cantidad), SUM(TotalRenglon), SUM(TotalRenglon2) from [TPVFacturasRenglones]  
				inner join TPVFacturas ON TPVFacturas.Numero = TPVFacturasRenglones.Numero 
				WHERE (Descripcion <> '*ANULADA*' AND CodigoProducto NOT LIKE '/%' and convert(char(8),TPVFacturas.FechaEmision,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	
				/*and TPVFacturas.Vendedor  BETWEEN '001' and  '499'*/ )
				GROUP BY CodigoProducto
				SET @CantidadesVendidastpv = 0
				SET @TotalFacturadoBsTpv = 0
				SET @TotalFacturadoDiTPV = 0


				OPEN Facturas1

				FETCH next FROM Facturas1 INTO @CodigoProducto,@CantidadesVendidastpv,@TotalFacturadoBsTPV,@TotalFacturadoDiTPV



				set @fstatus=@@FETCH_STATUS

				WHILE @@FETCH_STATUS = 0

						BEGIN

													 IF not EXISTS (SELECT * FROM tmpCostoVentas WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas]([CantidadesVendidasTPVFact],[TotalFacturadoBsTPV],[TotalFacturadoDITPV])
												VALUES(@CantidadesVendidastpv,@TotalFacturadoBsTpv,@TotalFacturadoDiTpv)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas]
												SET [CantidadesVendidasTPVFact] = @CantidadesVendidastpv,
													[TotalFacturadoBsTPV] = @TotalFacturadoBsTpv,
													[TotalFacturadoDITpv] = @TotalFacturadoDiTpv
												 WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


					FETCH next FROM Facturas1 INTO @CodigoProducto,@CantidadesVendidastpv,@TotalFacturadoBsTPV,@TotalFacturadoDiTPV
			
						END

				close Facturas1
				deallocate Facturas1
				END
				
				
				/* AQUI LO INCLUYO LO QUE VA A GUARDAR EN PROQUIMFA     */


				DECLARE FactuProquifaTPV1 CURSOR FOR select FacturasRenglones.CodigoProducto, SUM(FacturasRenglones.Cantidad), SUM(TotalRenglon), SUM(TotalRenglon2) from [FacturasRenglones]  
				inner join Facturas ON Facturas.Numero = FacturasRenglones.Numero 
				WHERE (Descripcion <> '*ANULADA*' AND CodigoProducto NOT LIKE '/%' and convert(char(8),Facturas.FechaEmision,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	
				and Facturas.Vendedor  BETWEEN '001' and  '499' )
				GROUP BY CodigoProducto
				SET @CantidadesVendidastpv = 0
				SET @TotalFacturadoBsTpv = 0
				SET @TotalFacturadoDiTPV = 0


				OPEN FactuProquifaTPV1

				FETCH next FROM FactuProquifaTPV1 INTO @CodigoProducto,@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac



				set @fstatus=@@FETCH_STATUS

				WHILE @@FETCH_STATUS = 0

						BEGIN

													 IF not EXISTS (SELECT * FROM tmpCostoVentas_PROQUIMFA WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas_PROQUIMFA]([CantidadesVendidasFacturas],[TotalFacturadoBsFac],[TotalFacturadoDIFac])
												VALUES(@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas_PROQUIMFA]
												SET [CantidadesVendidasFacturas] = @CantidadesVendidasFac,
													[TotalFacturadoBsFac] = @TotalFacturadoBsFac,
													[TotalFacturadoDIFac] = @TotalFacturadoDiFac
												 WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


					FETCH next FROM FactuProquifaTPV1 INTO @CodigoProducto,@CantidadesVendidasFac,@TotalFacturadoBsFac,@TotalFacturadoDiFac		
					

				close FactuProquifaTPV1
				deallocate FactuProquifaTPV1
				END


				/*AQUI INCLUYO PROQUIMFA PEROLAS FACTURAS MANUALES*/

				DECLARE FactuProquifaTPV2 CURSOR FOR select TPVFacturasRenglones.CodigoProducto, SUM(TPVFacturasRenglones.Cantidad), SUM(TotalRenglon), SUM(TotalRenglon2) from [TPVFacturasRenglones]  
				inner join TPVFacturas ON TPVFacturas.Numero = TPVFacturasRenglones.Numero 
				WHERE (Descripcion <> '*ANULADA*' AND CodigoProducto NOT LIKE '/%' and convert(char(8),TpvFacturas.FechaEmision,112) BETWEEN convert(char(8),@FechaInicial ,112) and  convert(char(8),@FechaFinal,112)	
				and TPVFacturas.Vendedor  BETWEEN '001' and  '499' )
				GROUP BY CodigoProducto
				SET @CantidadesVendidastpv = 0
				SET @TotalFacturadoBsTpv = 0
				SET @TotalFacturadoDiTPV = 0


				OPEN FactuProquifaTPV2

				FETCH next FROM FactuProquifaTPV2 INTO @CodigoProducto,@CantidadesVendidastpv,@TotalFacturadoBsTPV,@TotalFacturadoDiTPV



				set @fstatus=@@FETCH_STATUS

				WHILE @@FETCH_STATUS = 0

						BEGIN

													 IF not EXISTS (SELECT * FROM tmpCostoVentas_PROQUIMFA WHERE convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) and @CodigoProducto = CodigoProducto)
									BEGIN
												INSERT INTO [tmpCostoVentas_PROQUIMFA]([CantidadesVendidasTPVFact],[TotalFacturadoBsTPV],[TotalFacturadoDITPV])
												VALUES(@CantidadesVendidastpv,@TotalFacturadoBsTpv,@TotalFacturadoDiTpv)
									END
 							 ELSE 
			 						BEGIN
												UPDATE [dbo].[tmpCostoVentas_PROQUIMFA]
												SET [CantidadesVendidasTPVFact] = @CantidadesVendidastpv,
													[TotalFacturadoBsTPV] = @TotalFacturadoBsTpv,
													[TotalFacturadoDITpv] = @TotalFacturadoDiTpv
												 WHERE @CodigoProducto = CodigoProducto and   convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
									END


					FETCH next FROM FactuProquifaTPV2 INTO @CodigoProducto,@CantidadesVendidastpv,@TotalFacturadoBsTPV,@TotalFacturadoDiTPV		
					

				close FactuProquifaTPV2
				deallocate FactuProquifaTPV2
				END

select * from tmpCostoVentas 
where convert(char(8),FechaInicial,112) = convert(char(8),@FechaInicial,112) and convert(char(8),FechaFinal,112) = convert(char(8),@FechaFinal,112) 
ORDER BY CodigoProducto ASC



END

*/