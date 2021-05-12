USE PRD01
GO

/****** Object:  StoredProcedure [dbo].[nfRETMCPUpdateWithholdTax]    Script Date: 2/14/2020 11:03:13 AM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

begin  
	DECLARE  @iFileName char(100) 
	DECLARE  @iFileFromDate char(8)
	DECLARE  @iFileToDate char(8)
	DECLARE  @iFromDate DateTime 
	DECLARE  @iToDate DateTime
	DECLARE  @iFileLocation char(256) 
	DECLARE  @ProcessType smallint  

	SELECT  @iFileName='Retenciones', --Nombre de archivo INPUT
			@iFileFromDate='01022020', --Fecha Desde modo caracter
			@iFileToDate  ='29022020', -- Fecha Hasta modo Caracter
			@iFromDate=convert(datetime,'20200201',112), --Fecha Desde modo Date
			@iToDate=convert(datetime,'20200229',112), -- fecha Hasta modo Date
			@iFileLocation='\\wibd01dev\ARBA\archivocoefrg116.txt', --Nombre del archivo
			@ProcessType=5 --Aca va 6 para el padrin acreditan, 5 para el coef116
 
 
	DECLARE @TAXDTLID char(16)  DECLARE @PubDate DateTime  DECLARE @DefPerc   float  
	DECLARE @ARCHIVO_FORMAT char(256)
	begin transaction T1;  

	begin  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp1') DROP TABLE ##nfRETMCPTemp1   
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp12') DROP TABLE ##nfRETMCPTemp12
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp13') DROP TABLE ##nfRETMCPTemp13      
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp2') DROP TABLE ##nfRETMCPTemp2  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp3') DROP TABLE ##nfRETMCPTemp3  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp4') DROP TABLE ##nfRETMCPTemp4  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp5') DROP TABLE ##nfRETMCPTemp5  

		create table ##nfRETMCPTemp5 (TaxIDCode char(11))  

		if @ProcessType=1 or @ProcessType=3  or @ProcessType = 5 or @ProcessType = 6
		BEGIN  
			create table ##nfRETMCPTemp1(
											Regimen char(1), 
											PubDate char(8),
											DueDateFrm char(8),
											DueDateTo char(8),
											TaxIDCode char(11),
											TypeTaxIDCode char(1),  
											StatInd char(1),
											StatusOfChange char(1),
											RetPer char(10),
											RetCat int, 
											Dummy char(10)
										)
			if @ProcessType = 5 
			BEGIN
				SELECT @ARCHIVO_FORMAT = SUBSTRING(RTRIM(@iFileLocation),1,LEN(RTRIM(@iFileLocation))- CHARINDEX('\',REVERSE(RTRIM(@iFileLocation)))+1)+'FormatFiles\formato_efgr116.txt';
				--INSERT log_desarrollo VALUES('2',GETDATE(),'fILE '+ REVERSE(RTRIM(@iFileLocation)) + 'LEN ' +str(LEN(@iFileLocation))+ ' Char ' +  str(CHARINDEX('\',REVERSE(RTRIM(@iFileLocation)))+1) + 'File ' +@ARCHIVO_FORMAT )
				--commit;
				create table ##nfRETMCPTemp12 (
											TaxIDCode char(11),
											StatInd char(5),
											Coef Char(8),
											DueDateFrm char(6),
											VendorName char(152),
											PercPer char(10)
										 )

				EXEC('BULK INSERT dbo.##nfRETMCPTemp12 FROM '''+ @iFileLocation +''' WITH   ( FIRSTROW=6,FORMATFILE='''+@ARCHIVO_FORMAT+''' )')  

				if @@error<>0  begin  rollback transaction  return  end    

				insert into ##nfRETMCPTemp1 
					select 'R', 
							'01'+SUBSTRING(RTRIM(DueDateFrm) ,5,2)+ SUBSTRINg(RTRIM(DueDateFrm),1,4),
							'01'+SUBSTRING(RTRIM(DueDateFrm) ,5,2)+ SUBSTRINg(RTRIM(DueDateFrm),1,4),
						    replace(CONVERT(varchar,EOMONTH(CONVERT(Datetime, RTRIM(DueDateFrm) + '01', 112)) ,105),'-',''),
							TaxIDCode ,
							' ',  
							LTRIM(RTRIM(StatInd)) ,
							' ',
							CASE LTRIM(RTRIM(StatInd ))
								WHEN 'E' then '0' 
								ELSE CASE coef 
										WHEN '0.0000' then LTRIM(RTRIM(PercPer))
										ELSE convert(numeric(6,4),convert(numeric(6,4),Coef) * convert(numeric(6,4),LTRIM(RTRIM(PercPer))) * 0.50)
										end 
								END ,
							0, 
						   ' '
					FROM ##nfRETMCPTemp12

				if @@error<>0  begin  rollback transaction  return  end   						
				
				--Update el coeficiente a 3 decimales redondeando para arriba
				update ##nfRETMCPTemp1 set RetPer = convert(numeric(6,3),CEILING(convert(numeric(6,4),RetPer)*1000)/1000)

				if @@error<>0  begin  rollback transaction  return  end   						
				--update  con el Coeficiente
			END
			ELSE IF	 @ProcessType = 6 
			BEGIN
				SELECT @ARCHIVO_FORMAT = SUBSTRING(RTRIM(@iFileLocation),1,LEN(RTRIM(@iFileLocation))- CHARINDEX('\',REVERSE(RTRIM(@iFileLocation)))+1)+'FormatFiles\formato_contribuyente.txt';
				--INSERT log_desarrollo VALUES('2',GETDATE(),'fILE '+ REVERSE(RTRIM(@iFileLocation)) + 'LEN ' +str(LEN(@iFileLocation))+ ' Char ' +  str(CHARINDEX('\',REVERSE(RTRIM(@iFileLocation)))+1) + 'File ' +@ARCHIVO_FORMAT )
				--commit;
				create table ##nfRETMCPTemp13 (
										TaxIDCode char(11),
										StatInd char(5),
										Convenio char(4),
										DueDateFrm char(10),
										DueDateTo  char(10),
										VendorName char(152),
										PercPer char(10)
										 )

				EXEC('BULK INSERT dbo.##nfRETMCPTemp13 FROM '''+ @iFileLocation +''' WITH   ( FIRSTROW=8,FORMATFILE='''+@ARCHIVO_FORMAT+''' )')  

				if @@error<>0  begin  rollback transaction  return  end    

				insert into ##nfRETMCPTemp1 
					select 'R', 
							SUBSTRING(RTRIM(DueDateFrm) ,7,2)+SUBSTRING(RTRIM(DueDateFrm) ,5,2)+ SUBSTRINg(RTRIM(DueDateFrm),1,4),
							SUBSTRING(RTRIM(DueDateFrm) ,7,2)+SUBSTRING(RTRIM(DueDateFrm) ,5,2)+ SUBSTRINg(RTRIM(DueDateFrm),1,4),
							SUBSTRING(RTRIM(DueDateTo) ,7,2)+SUBSTRING(RTRIM(DueDateTo) ,5,2)+ SUBSTRINg(RTRIM(DueDateTo),1,4),
						    TaxIDCode ,
							' ',  
							LTRIM(RTRIM(StatInd)) ,
							' ',
							CASE LTRIM(RTRIM(StatInd ))
								WHEN 'E' then '0' 
								ELSE CASE LTRIM(RTRIM(Convenio))
										WHEN 'CL' then LTRIM(RTRIM(PercPer))
										WHEN 'CM' then Convert(char(10),Convert(numeric(9,3), LTRIM(RTRIM(PercPer)))*0.50)
										end
								END  ,
							0, 
							' '
					FROM ##nfRETMCPTemp13

				if @@error<>0  begin  rollback transaction  return  end   						
			END
			ELSE
			BEGIN							
				EXEC('BULK INSERT dbo.##nfRETMCPTemp1 FROM '''+ @iFileLocation +''' WITH   (  FIELDTERMINATOR ='';'',  ROWTERMINATOR =''\n''  )')  
				if @@error<>0  begin  rollback transaction  return  end   
			END

			insert into ##nfRETMCPTemp5   
			select TaxIDCode 
			from ##nfRETMCPTemp1 
			where DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate  

			delete from  ##nfRETMCPTemp1 
			where DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate  
			--	commit transaction  
			--return
			set @PubDate=(  select top 1 convert(datetime,substring(PubDate,5,4)+substring(PubDate,3,2)+substring(PubDate,1,2))  
							from ##nfRETMCPTemp1)  

			if @@error<>0  begin  rollback transaction  return  end  
		END  
		if @ProcessType=1 or @ProcessType=2  or @ProcessType = 5 or @ProcessType = 6
		begin  
			select * 
			into ##nfRETMCPTemp2 
			from	(	select	[VENDORID] ,
								[nfRET_Tipo_ID] ,
								[TII_MCP_From_Date],
								[TII_MCP_TO_DATE] ,  
								[nfRET_CalType] , 
								[PRCNTAGE]  
						from nfRET_PM00201   
						where nfRET_CalType=2 
						and  nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
						and  VENDORID in(	select PM00200.VENDORID 
											from  PM00200 
											where substring(TXRGNNUM,24,2)<>'' 
											and substring(TXRGNNUM,1,11)  not in(select TaxIDCode from ##nfRETMCPTemp5)  
											and PM00200.VENDORID=nfRET_PM00201.VENDORID)  
						and (	(TII_MCP_From_Date<@iFromDate and TII_MCP_TO_DATE>=@iFromDate)  or
								( TII_MCP_From_Date>@iFromDate and TII_MCP_From_Date<@iToDate and TII_MCP_TO_DATE>@iToDate)  or
								( TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate)))as t1  

			if @@error<>0  begin  rollback transaction  return  end  
		end  

		if @ProcessType=1 or @ProcessType=2  or @ProcessType = 5 or @ProcessType = 6
		begin  
			update nfRET_PM00201 
			set TII_MCP_TO_DATE=DATEADD(day,-1,@iFromDate)  
			where nfRET_CalType=2 
			and nfRET_Tipo_ID in (	select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
			and VENDORID in(	select PM00200.VENDORID 
								from  PM00200 
								where substring(TXRGNNUM,24,2)<>'' 
								and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)  
								and PM00200.VENDORID=nfRET_PM00201.VENDORID) 
			and (TII_MCP_From_Date<@iFromDate 	and TII_MCP_TO_DATE>=@iFromDate)   

			if @@error<>0  begin  rollback transaction  return  end   

			update nfRET_PM00201 
			set TII_MCP_From_Date=DATEADD(day,1,@iToDate)  
			where nfRET_CalType=2 
			and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
			and VENDORID in(	select PM00200.VENDORID 
								from  PM00200 
								where substring(TXRGNNUM,24,2)<>'' 
								and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)  
								and PM00200.VENDORID=nfRET_PM00201.VENDORID) 
			and (TII_MCP_From_Date<=@iToDate and TII_MCP_TO_DATE>@iToDate)   

			if @@error<>0  begin  rollback transaction  return  end  

			delete from nfRET_PM00201  
			where  nfRET_CalType=2 
			and nfRET_Tipo_ID in(select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)  
			and TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate  
			and VENDORID in(	select PM00200.VENDORID 
								from  PM00200 
								where substring(TXRGNNUM,24,2)<>'' 
								and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5) 
								and PM00200.VENDORID=nfRET_PM00201.VENDORID)  

			if @@error<>0  begin  rollback transaction  return  end  

		end  

		set @DefPerc=isnull((select PRCNTAGE from nfRET_PM00040),1.75)  

		if @ProcessType=1 or @ProcessType=2  or @ProcessType = 5 or @ProcessType = 6
		BEGIN  
			DECLARE TAXDETAILS CURSOR FOR   select TAXDTLID from nfRET_PM40011 where NAME=@iFileName  
			OPEN TAXDETAILS   
			FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID  
			WHILE (@@FETCH_STATUS=0)   
			BEGIN   
				if @ProcessType=1  or @ProcessType = 5 or @ProcessType = 6
				begin  
					insert into nfRET_PM00201(
												VENDORID,
												nfRET_Tipo_ID,
												TII_MCP_From_Date,
												TII_MCP_TO_DATE,  
												nfRET_CalType,PRCNTAGE,DATE1
											)  
									select		PM00200.VENDORID,  
												@TAXDTLID,
												@iFromDate,
												@iToDate,
												2,
												CAST(REPLACE('0' + ##nfRETMCPTemp1.RetPer,',','.') AS decimal(19,5))as RetPer,
												@PubDate 
									from	PM00200 
											inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode 
																			and substring(PM00200.TXRGNNUM,24,2)<>''  

					if @@error<>0  begin  rollback transaction  
					
					CLOSE TAXDETAILS   
					DEALLOCATE TAXDETAILS  
					return  
				end  
				
				insert into nfRET_PM00201(
											VENDORID,
											nfRET_Tipo_ID,
											TII_MCP_From_Date,
											TII_MCP_TO_DATE,  
											nfRET_CalType,PRCNTAGE
										) 
									select	PM00200.VENDORID,
											@TAXDTLID,
											@iFromDate,
											@iToDate,
											2,
											@DefPerc 
									from PM00200  
									where substring(TXRGNNUM,24,2)<>''
									and substring(PM00200.TXRGNNUM,1,11) not in(select ##nfRETMCPTemp1.TaxIDCode 
																				from ##nfRETMCPTemp1 
																				where ##nfRETMCPTemp1.TaxIDCode=substring(PM00200.TXRGNNUM,1,11))  
									and substring(PM00200.TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)  
			
				if @@error<>0  begin  
					rollback transaction  
					CLOSE TAXDETAILS   
					DEALLOCATE TAXDETAILS  
					return  
				end   
			end  
			if  @ProcessType=2  
			begin  
				insert into nfRET_PM00201(
										VENDORID,
										nfRET_Tipo_ID,
										TII_MCP_From_Date,
										TII_MCP_TO_DATE,  
										nfRET_CalType,PRCNTAGE
									) 
								select	PM00200.VENDORID,
										@TAXDTLID,
										@iFromDate,
										@iToDate,
										2,
										@DefPerc 
								from PM00200  
								where substring(TXRGNNUM,24,2)<>''  
				if @@error<>0  
				begin  
					rollback transaction  
					CLOSE TAXDETAILS   
					DEALLOCATE TAXDETAILS  
					return  
				end   
			end   
			FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID  
		END  
		CLOSE TAXDETAILS   
		DEALLOCATE TAXDETAILS  
		if @@error<>0  begin  rollback transaction  return  end  
	END 
	  
	if @ProcessType=3  
	BEGIN  
		create table ##nfRETMCPTemp3 (
										VENDORID char(15),
										nfRET_Tipo_ID char(11), 
										TII_MCP_From_Date datetime,
										TII_MCP_TO_DATE datetime,
										nfRET_CalType char(2),
										RetPer char(9),
										DATE1 datetime
									)   
		
		DECLARE TAXDETAILS CURSOR FOR select TAXDTLID from nfRET_PM40011 where NAME=@iFileName  
		OPEN TAXDETAILS   
		FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID  
		WHILE (@@FETCH_STATUS=0)   
		BEGIN   
			insert into ##nfRETMCPTemp3(
										VENDORID,
										nfRET_Tipo_ID, 
										TII_MCP_From_Date ,
										TII_MCP_TO_DATE,
										nfRET_CalType,RetPer,DATE1
									    )  
								(select PM00200.VENDORID as VENDORID,  
										@TAXDTLID as nfRET_Tipo_ID,
										@iFromDate as TII_MCP_From_Date,
										@iToDate as TII_MCP_TO_DATE,
										2 as nfRET_CalType,
										CAST(REPLACE(##nfRETMCPTemp1.RetPer,',','.') AS decimal(19,5))as RetPer,
										@PubDate as DATE1 
								from	PM00200 
										inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode)   
			if @@error<>0  
			begin  
				rollback transaction  
				CLOSE TAXDETAILS   
				DEALLOCATE TAXDETAILS  
				return  
			end  
			FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID  
		END  
		CLOSE TAXDETAILS   
		DEALLOCATE TAXDETAILS  

		if @@error<>0  begin  rollback transaction  return  end  
		
		select * 
		into ##nfRETMCPTemp4 
		from  (	select	[VENDORID] ,[nfRET_Tipo_ID] ,[TII_MCP_From_Date],
						[TII_MCP_TO_DATE] ,  [nfRET_CalType] , [PRCNTAGE]  
				from nfRET_PM00201   
				where nfRET_CalType=2 
				and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
				and VENDORID in(	select ##nfRETMCPTemp3.VENDORID 
									from  ##nfRETMCPTemp3 
									where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)  
				and (	(TII_MCP_From_Date<@iFromDate and TII_MCP_TO_DATE>=@iFromDate)  or
						( TII_MCP_From_Date>@iFromDate and TII_MCP_From_Date<@iToDate and TII_MCP_TO_DATE>@iToDate) or
						( TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate)))as t1  

		if @@error<>0  begin  rollback transaction  return  end  

		update nfRET_PM00201 
		set TII_MCP_TO_DATE=DATEADD(day,-1,@iFromDate)  
		where nfRET_CalType=2 
		and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
		and nfRET_PM00201.VENDORID in(	select ##nfRETMCPTemp3.VENDORID 
										from  ##nfRETMCPTemp3 
										where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)  
		and (nfRET_PM00201.TII_MCP_From_Date<@iFromDate and nfRET_PM00201.TII_MCP_TO_DATE>=@iFromDate)   
		
		if @@error<>0  begin  rollback transaction  return  end   

		update nfRET_PM00201 
		set TII_MCP_From_Date=DATEADD(day,1,@iToDate)  
		where nfRET_CalType=2 
		and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
		and VENDORID in(select ##nfRETMCPTemp3.VENDORID 
						from  ##nfRETMCPTemp3 
						where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)  
		and (TII_MCP_From_Date<=@iToDate and TII_MCP_TO_DATE>@iToDate)   
		
		if @@error<>0  begin  rollback transaction  return  end  

		delete from nfRET_PM00201  
		where  nfRET_CalType=2 
		and nfRET_Tipo_ID in(	select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)  
		and TII_MCP_From_Date>=@iFromDate 
		and TII_MCP_TO_DATE<=@iToDate  
		and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)  

		if @@error<>0  begin  rollback transaction  return  end  

		insert into nfRET_PM00201(
									VENDORID,
									nfRET_Tipo_ID,
									TII_MCP_From_Date,
									TII_MCP_TO_DATE,  
									nfRET_CalType,PRCNTAGE,DATE1
								)  
							select	##nfRETMCPTemp3.VENDORID,  
									##nfRETMCPTemp3.nfRET_Tipo_ID,
									@iFromDate,
									@iToDate,
									2,
									RetPer,
									DATE1 
							from ##nfRETMCPTemp3  
		if @@error<>0  
		begin  
			rollback transaction  
			CLOSE TAXDETAILS   
			DEALLOCATE TAXDETAILS  
			return  
		end  
	END  
	if @ProcessType=1 or @ProcessType=2  or @ProcessType = 5 or @ProcessType = 6
	Begin  
		delete from nfRET_PM40012  
			
		insert into nfRET_PM40012(	VENDORID,
										VENDNAME,
										CUIT_Pais,
										nfRET_Tipo_ID, 
										nfRET_OldPercentage,
										PRCNTAGE,
										From_Date,
										TODATE)  
								select	nfRET_PM00201.VENDORID,
										VENDNAME=(	select VENDNAME  
													from  PM00200 
													where substring(TXRGNNUM,24,2)<>'' 
													and PM00200.VENDORID=nfRET_PM00201.VENDORID),
										CUIT_Pais=(	select substring(TXRGNNUM,1,11)  
													from  PM00200 
													where substring(TXRGNNUM,24,2)<>'' 
													and PM00200.VENDORID=nfRET_PM00201.VENDORID),  
										nfRET_PM00201.nfRET_Tipo_ID,  
										isnull(##nfRETMCPTemp2.PRCNTAGE,0),
										nfRET_PM00201.PRCNTAGE,
										@iFromDate,
										@iToDate 
								from nfRET_PM00201 
									left outer join ##nfRETMCPTemp2 on  nfRET_PM00201.VENDORID=##nfRETMCPTemp2.VENDORID and 
																		nfRET_PM00201.nfRET_Tipo_ID=##nfRETMCPTemp2.nfRET_Tipo_ID  and 
																		nfRET_PM00201.nfRET_CalType=##nfRETMCPTemp2.nfRET_CalType  
								where nfRET_PM00201.nfRET_CalType=2 
								and nfRET_PM00201.nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
								and  nfRET_PM00201.VENDORID in(	select VENDORID  
																from  PM00200 
																where substring(TXRGNNUM,24,2)<>'' 
																and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
																and PM00200.VENDORID=nfRET_PM00201.VENDORID)  
								and  nfRET_PM00201.TII_MCP_From_Date=@iFromDate 
								and nfRET_PM00201.TII_MCP_TO_DATE=@iToDate   

		if @@error<>0  begin  rollback transaction  return  end  
			
		delete from nfRET_PM40013  

		insert 
		into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)  
		select VENDORID,VENDNAME,1 from PM00200 where substring(TXRGNNUM,24,2)=''   

		insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)  
		select VENDORID,VENDNAME,2 
		from PM00200 
		where substring(TXRGNNUM,24,2)<>''   
		and substring(TXRGNNUM,1,11) in (select TaxIDCode from ##nfRETMCPTemp5)  
			
		if @@error<>0  begin  rollback transaction  return  end  
	End  
	
	if @ProcessType=3   
	begin  
		delete from nfRET_PM40012  
		
		delete from nfRET_PM40013  

		insert into nfRET_PM40012(	VENDORID,
									VENDNAME,
									CUIT_Pais,
									nfRET_Tipo_ID, 
									nfRET_OldPercentage,
									PRCNTAGE,
									From_Date,TODATE)  
							select	nfRET_PM00201.VENDORID,
									VENDNAME=(	select VENDNAME  
												from  PM00200 
												where substring(TXRGNNUM,24,2)<>'' and PM00200.VENDORID=nfRET_PM00201.VENDORID),
									CUIT_Pais=(	select substring(TXRGNNUM,1,11)  
												from  PM00200 
												where substring(TXRGNNUM,24,2)<>'' 
												and PM00200.VENDORID=nfRET_PM00201.VENDORID),  
									nfRET_PM00201.nfRET_Tipo_ID,  
									isnull(##nfRETMCPTemp4.PRCNTAGE,0),
									nfRET_PM00201.PRCNTAGE,
									@iFromDate,
									@iToDate 
							from nfRET_PM00201 
								left outer join ##nfRETMCPTemp4 on   nfRET_PM00201.VENDORID=##nfRETMCPTemp4.VENDORID 
																and nfRET_PM00201.nfRET_Tipo_ID=##nfRETMCPTemp4.nfRET_Tipo_ID  
																and nfRET_PM00201.nfRET_CalType=##nfRETMCPTemp4.nfRET_CalType  
							where nfRET_PM00201.nfRET_CalType=2 
							and nfRET_PM00201.nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)  
							and nfRET_PM00201.TII_MCP_From_Date=@iFromDate 
							and nfRET_PM00201.TII_MCP_TO_DATE=@iToDate  
							and nfRET_PM00201.VENDORID in(	select ##nfRETMCPTemp3.VENDORID 
															from  ##nfRETMCPTemp3 
															where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)   

		if @@error<>0  begin  rollback transaction  return  end  
		
		insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)  
		select VENDORID,VENDNAME,2 from PM00200 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) in (select TaxIDCode from ##nfRETMCPTemp5)  
				
		if @@error<>0  begin  rollback transaction  return  end  
	end  
	/*IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp1')	DROP TABLE ##nfRETMCPTemp1  
	IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp12') DROP TABLE ##nfRETMCPTemp12
	IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp13') DROP TABLE ##nfRETMCPTemp13      
	IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp2')   DROP TABLE ##nfRETMCPTemp2  
	IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp3')  	DROP TABLE ##nfRETMCPTemp3  
	IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp4')  	DROP TABLE ##nfRETMCPTemp4  
	IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp5')  	DROP TABLE ##nfRETMCPTemp5  */
	PRINT 'COMMIT TRANSACTION T1'
	commit transaction T1;  
end 
end     
 

GO


