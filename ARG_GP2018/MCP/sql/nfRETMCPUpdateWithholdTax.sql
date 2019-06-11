USE [GPX02]
GO

/****** Object:  StoredProcedure [dbo].[nfRETMCPUpdateWithholdTax]    Script Date: 5/23/2019 10:44:39 AM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER  procedure [dbo].[nfRETMCPUpdateWithholdTax] 
@iFileName char(100),
@iFileFromDate char(8),
@iFileToDate char(8),
@iFromDate  DateTime,
@iToDate DateTime,
@iFileLocation char(150),
@ProcessType smallint,
@O_SQL_Error_State int = NULL  output

as
begin
	DECLARE @TAXDTLID char(16)
	DECLARE @PubDate DateTime
	DECLARE @DefPerc   float

	begin transaction T1;

	begin
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp1')
			DROP TABLE ##nfRETMCPTemp1 
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp2')
			DROP TABLE ##nfRETMCPTemp2
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp3')
			DROP TABLE ##nfRETMCPTemp3
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp4')
			DROP TABLE ##nfRETMCPTemp4
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp5')
			DROP TABLE ##nfRETMCPTemp5
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp6')
			DROP TABLE ##nfRETMCPTemp6
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp7')
			DROP TABLE ##nfRETMCPTemp7

		CREATE TABLE ##nfRETMCPTemp5 (TaxIDCode char(11))

		IF @ProcessType=1 or @ProcessType=3 or @ProcessType=4/*Monthly Tax or Quarterly Tax*/
		BEGIN
			IF @ProcessType=1 --ARBA
					EXEC(' create table ##nfRETMCPTemp1 (Regimen char(1)
														,PubDate char(8)
														,DueDateFrm char(8)
														,DueDateTo char(8)
														,TaxIDCode char(11)
														,TypeTaxIDCode char(1)
														,StatInd char(1)
														,StatusOfChange char(1)
														,RetPer char(4)
														,RetCat int
														,Dummy char(10))')
			IF @ProcessType=3 or @ProcessType=4 --AGIP
					EXEC(' create table ##nfRETMCPTemp1 (PubDate char(8)
														,DueDateFrm char(8)
														,DueDateTo char(8)
														,TaxIDCode char(11)
														,TypeTaxIDCode char(1)
														,StatInd char(1)
														,StatusOfChange char(1)
														,PercPer char(4)
														,RetPer char(4)
														,PerCa int
														,RetCat int
														,Name char(1000))')

			EXEC('BULK INSERT dbo.##nfRETMCPTemp1 FROM '''+ @iFileLocation +''' WITH 
								(
									FIELDTERMINATOR ='';'',
									ROWTERMINATOR =''\n''
								)')
			IF @@error<>0
			BEGIN
				rollback transaction
				RETURN
			END
  
			/*Code used to avoid the dates that are not matching with the date range*/   
			INSERT INTO ##nfRETMCPTemp5 

			SELECT TaxIDCode FROM ##nfRETMCPTemp1 WHERE DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate

			DELETE FROM  ##nfRETMCPTemp1 WHERE DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate

			SET @PubDate=(	select top 1 convert(datetime,	substring(PubDate,1,2)+	'-'+
															case 
																when( substring(PubDate,3,2))='01' then 'Jan'
																when ( substring(PubDate,3,2))='02' then 'Feb'
																when ( substring(PubDate,3,2))='03' then 'Mar'
																when ( substring(PubDate,3,2))='04' then 'Apr'
																when ( substring(PubDate,3,2))='05' then 'May'
																when ( substring(PubDate,3,2))='06' then 'Jun'
																when ( substring(PubDate,3,2))='07' then 'Jul'
																when ( substring(PubDate,3,2))='08' then 'Aug'
																when ( substring(PubDate,3,2))='09' then 'Sep'
																when ( substring(PubDate,3,2))='10' then 'Oct'
																when ( substring(PubDate,3,2))='11' then 'Nov'
																when ( substring(PubDate,3,2))='12' then 'Dec'
																END
															+'-'+substring(PubDate,5,4))
								from ##nfRETMCPTemp1)
			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END
		END/*Process Type*/

		/* This is to copy all unwanted records from the Table since we are doing insertion only for the particular period 
		and before this insertion we need to remove any records that lies in this period.This copied records we are using for report display.*/
		IF @ProcessType=1 or @ProcessType=2/*Monthly Tax or Default Tax*/
		BEGIN
			SELECT * 
			INTO ##nfRETMCPTemp2 
			FROM  (	SELECT [VENDORID] ,[nfRET_Tipo_ID] ,[TII_MCP_From_Date],[TII_MCP_TO_DATE] , [nfRET_CalType] , [PRCNTAGE]  
					FROM nfRET_PM00201 
					WHERE nfRET_CalType=2 
					and nfRET_Tipo_ID in (	select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
					and VENDORID in		 (	select PM00200.VENDORID 
											from  PM00200 
											where substring(TXRGNNUM,24,2)<>'' 
											and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
											and PM00200.VENDORID=nfRET_PM00201.VENDORID)
					and (	(TII_MCP_From_Date<@iFromDate and TII_MCP_TO_DATE>=@iFromDate)  or
							( TII_MCP_From_Date>@iFromDate and TII_MCP_From_Date<@iToDate and TII_MCP_TO_DATE>@iToDate) or
							( TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate))
				  ) as t1

			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END
		END

		/*To update the End Date for the Dates like 15-Feb-01 to 15-Mar-01*/
		IF @ProcessType=1 or @ProcessType=2
		BEGIN
			UPDATE nfRET_PM00201 set TII_MCP_TO_DATE=DATEADD(day,-1,@iFromDate)
			WHERE nfRET_CalType=2 
			and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and VENDORID in(	select PM00200.VENDORID 
								from  PM00200 
								where substring(TXRGNNUM,24,2)<>'' 
								and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
								and PM00200.VENDORID=nfRET_PM00201.VENDORID) 
			and (TII_MCP_From_Date<@iFromDate and TII_MCP_TO_DATE>=@iFromDate) 

			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END

			/*To update the From Date for the Dates like 15-Mar-01 to 15-Apr-01*/
			UPDATE nfRET_PM00201 SET TII_MCP_From_Date=DATEADD(day,1,@iToDate)
			where nfRET_CalType=2 
			and nfRET_Tipo_ID in (	select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and VENDORID in		(	select PM00200.VENDORID 
									from  PM00200 
									where substring(TXRGNNUM,24,2)<>'' 
									and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
									and PM00200.VENDORID=nfRET_PM00201.VENDORID)
			and (TII_MCP_From_Date<=@iToDate and TII_MCP_TO_DATE>@iToDate) 

			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END

			/*Delete these records  since we are doing insertion for these deleted records also*/
			DELETE from nfRET_PM00201
			where  nfRET_CalType=2 
			and nfRET_Tipo_ID in(select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)
			and TII_MCP_From_Date>=@iFromDate 
			and TII_MCP_TO_DATE<=@iToDate
			and VENDORID in(	select PM00200.VENDORID 
								from  PM00200 
								where substring(TXRGNNUM,24,2)<>'' 
								and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5) 
								and PM00200.VENDORID=nfRET_PM00201.VENDORID
							)
			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END
		END/*Process Type*/

		SET @DefPerc=isnull((select PRCNTAGE from nfRET_PM00040),1.75)
		IF @ProcessType=1 or @ProcessType=2
		BEGIN
    
			DECLARE TAXDETAILS CURSOR FOR 
				SELECT TAXDTLID FROM nfRET_PM40011 where NAME=@iFileName
			OPEN TAXDETAILS 

			FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID

			WHILE (@@FETCH_STATUS=0) 
			BEGIN 
				IF @ProcessType=1 
				BEGIN
					/*To insert the records into the table with the Tax from the Imported file*/
					INSERT INTO nfRET_PM00201	(	VENDORID
													,nfRET_Tipo_ID
													,TII_MCP_From_Date
													,TII_MCP_TO_DATE
													,nfRET_CalType
													,PRCNTAGE
													,DATE1
													,HR
												)  
												SELECT
													PM00200.VENDORID
													,@TAXDTLID
													,@iFromDate
													,@iToDate
													,2
													,CAST(REPLACE(##nfRETMCPTemp1.RetPer,',','.') AS decimal(4,2))as RetPer
													,@PubDate
													,1 
												FROM	PM00200 
														inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode and substring(PM00200.TXRGNNUM,24,2)<>''
					IF @@error<>0
					BEGIN
						rollback transaction
						CLOSE TAXDETAILS 
						DEALLOCATE TAXDETAILS
						return
					END
					
					/*To insert the Default Tax if this CUIT number not in the Text file*/
					INSERT inTO nfRET_PM00201	(
													VENDORID
													,nfRET_Tipo_ID
													,TII_MCP_From_Date
													,TII_MCP_TO_DATE
													,nfRET_CalType,PRCNTAGE
												) 
												select	PM00200.VENDORID
														,@TAXDTLID
														,@iFromDate
														,@iToDate
														,2
														,@DefPerc 
												from PM00200
												where substring(TXRGNNUM,24,2)<>''
												and substring(PM00200.TXRGNNUM,1,11) not in (select ##nfRETMCPTemp1.TaxIDCode 
																							from ##nfRETMCPTemp1 
																							where ##nfRETMCPTemp1.TaxIDCode=substring(PM00200.TXRGNNUM,1,11))
												and substring(PM00200.TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
					IF @@error<>0
					BEGIN
						rollback transaction
						CLOSE TAXDETAILS 
						DEALLOCATE TAXDETAILS
						return
					END
				END

			    IF  @ProcessType=2
				BEGIN
					/*To insert the Default Tax if this CUIT number not in the Text file*/
					INSERT INTO nfRET_PM00201	(
													VENDORID
													,nfRET_Tipo_ID
													,TII_MCP_From_Date
													,TII_MCP_TO_DATE
													,nfRET_CalType
													,PRCNTAGE
												) 
												select PM00200.VENDORID
														,@TAXDTLID
														,@iFromDate
														,@iToDate
														,2
														,@DefPerc 
												from PM00200
												where substring(TXRGNNUM,24,2)<>''
					IF @@error<>0
					BEGIN
						rollback transaction
						CLOSE TAXDETAILS 
						DEALLOCATE TAXDETAILS
						return
					END
				END /*@ProcessType=2*/     
    
				FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
			END

			CLOSE TAXDETAILS 
			DEALLOCATE TAXDETAILS

			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END
		END /*@ProcessType=1 or @ProcessType=2*/

		IF @ProcessType=3 or @ProcessType=4
		BEGIN
			IF @ProcessType=4
			BEGIN
				SET @DefPerc=isnull((select PRCNTAGE from nfRET_PM00041),2.00)

				CREATE TABLE ##nfRETMCPTemp6	(VENDORID char(15)
												,nfRET_Tipo_ID char(11)
												,TII_MCP_From_Date datetime
												,TII_MCP_TO_DATE datetime
												,nfRET_CalType char(2)
												,RetPer char(9)
												,DATE1 datetime)
				CREATE TABLE ##nfRETMCPTemp7	(VENDORID char(15)
												,nfRET_Tipo_ID char(11)
												, TII_MCP_From_Date datetime
												,TII_MCP_TO_DATE datetime
												,nfRET_CalType char(2)
												,RetPer char(9)
												,DATE1 datetime)
			END
			
			CREATE TABLE ##nfRETMCPTemp3	(VENDORID char(15)
											,nfRET_Tipo_ID char(11)
											, TII_MCP_From_Date datetime
											,TII_MCP_TO_DATE datetime
											,nfRET_CalType char(2)
											,RetPer char(9)
											,DATE1 datetime)

			DECLARE TAXDETAILS CURSOR FOR 
						SELECT TAXDTLID FROM nfRET_PM40011 WHERE NAME=@iFileName
			OPEN TAXDETAILS 
			FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
    
			WHILE (@@FETCH_STATUS=0) 
			BEGIN 
				/*To insert the records into the table with the Tax from the Imported file*/
				IF @ProcessType=3
					INSERT INTO ##nfRETMCPTemp3	(VENDORID,nfRET_Tipo_ID, TII_MCP_From_Date ,TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)
												(select PM00200.VENDORID as VENDORID, @TAXDTLID as nfRET_Tipo_ID,@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,CAST(REPLACE(##nfRETMCPTemp1.RetPer,',','.') AS decimal(4,2))as RetPer,@PubDate as DATE1 
												 from PM00200 inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode) 
					
				IF @ProcessType=4
				BEGIN 
					INSERT INTO ##nfRETMCPTemp3	(VENDORID,nfRET_Tipo_ID, TII_MCP_From_Date ,TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)
												(select PM00200.VENDORID as VENDORID, @TAXDTLID as nfRET_Tipo_ID,@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,@DefPerc as RetPer,@PubDate as DATE1 
												 from	PM00200 
														inner join ##nfRETMCPTemp1 on	substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode and 
																						PM00200.VENDORID in(	select VENDORID 
																												from nfRET_PM00200 
																												where nfRET_PM00200.VENDORID=PM00200.VENDORID 
																												and nfRET_PM00200.nfRET_MonoVend=1 
																												and nfRET_plan_de_retencione IN (select nfRET_plan_de_retencione
																																				 from nfRET_GL00020 
																																				 where nfRET_Retencion_ID IN (select nfRET_Retencion_ID 
																																											  from nfRET_GL00030 
																																											  where nfRET_Tipo_ID = @TAXDTLID)
																																				)
																											))
     
					INSERT INTO ##nfRETMCPTemp6	(VENDORID,nfRET_Tipo_ID, TII_MCP_From_Date ,TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)
												(select PM00200.VENDORID as VENDORID, @TAXDTLID as nfRET_Tipo_ID,@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,@DefPerc as RetPer,@PubDate as DATE1 
												from	PM00200 
														inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode /*and PM00200.VENDORID in(select VENDORID from nfRET_PM00200 where nfRET_PM00200.VENDORID=PM00200.VENDORID and nfRET_PM00200.nfRET_MonoVend=0)*/
												)

					INSERT INTO ##nfRETMCPTemp7	(VENDORID,nfRET_Tipo_ID, TII_MCP_From_Date ,TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)
												(select PM00200.VENDORID as VENDORID,@TAXDTLID as nfRET_Tipo_ID,@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,@DefPerc as RetPer,@PubDate as DATE1 
												from PM00200 
												where PM00200.VENDORID in(	select VENDORID 
																			from nfRET_PM00200 
																			where nfRET_PM00200.nfRET_MonoVend=1 and nfRET_PM00200.nfRET_MonoHighRisk=1))
				END 

				IF @@error<>0
				BEGIN
					rollback transaction
					CLOSE TAXDETAILS 
					DEALLOCATE TAXDETAILS
					return
				END

				FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
			END
			
			CLOSE TAXDETAILS 
			DEALLOCATE TAXDETAILS

			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END

			/*Copying the existing records to be updated to display in the report*/
			SELECT  * into ##nfRETMCPTemp4 
			FROM  (	SELECT [VENDORID] ,[nfRET_Tipo_ID] ,[TII_MCP_From_Date],[TII_MCP_TO_DATE] , [nfRET_CalType] , [PRCNTAGE]  
					FROM nfRET_PM00201 
					WHERE nfRET_CalType=2 
					and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
					and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID )
					and (	(TII_MCP_From_Date<@iFromDate and TII_MCP_TO_DATE>=@iFromDate)  or
							( TII_MCP_From_Date>@iFromDate and TII_MCP_From_Date<@iToDate and TII_MCP_TO_DATE>@iToDate) or
							( TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate)))as t1
			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END

			/*To update the From Date for the Dates like 15-Feb-01 to 15-Mar-01*/
			UPDATE nfRET_PM00201 set TII_MCP_TO_DATE=DATEADD(day,-1,@iFromDate)
			WHERE nfRET_CalType=2 
			and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and nfRET_PM00201.VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)
			and (nfRET_PM00201.TII_MCP_From_Date<@iFromDate and nfRET_PM00201.TII_MCP_TO_DATE>=@iFromDate) 
   
			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END
			
			/*To update the From Date for the Dates like 15-Mar-01 to 15-Apr-01*/
			UPDATE nfRET_PM00201 set TII_MCP_From_Date=DATEADD(day,1,@iToDate)
			WHERE nfRET_CalType=2 
			and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)
			and (TII_MCP_From_Date<=@iToDate and TII_MCP_TO_DATE>@iToDate) 
   
			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END

			/*Delete these records  since we are doing insertion for these deleted records also*/
			DELETE FROM nfRET_PM00201
			WHERE  nfRET_CalType=2 
			and nfRET_Tipo_ID in(select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)
			and TII_MCP_From_Date>=@iFromDate 
			and TII_MCP_TO_DATE<=@iToDate
			and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)
   
			IF @@error<>0
			BEGIN
				rollback transaction
				return
			END

			/*To insert the records into the table with the Tax from the Imported file*/
			INSERT INTO nfRET_PM00201	(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE, nfRET_CalType,PRCNTAGE,DATE1)  
										select ##nfRETMCPTemp3.VENDORID,##nfRETMCPTemp3.nfRET_Tipo_ID,@iFromDate,@iToDate,2,RetPer,DATE1 
										from ##nfRETMCPTemp3
			
			/*RF8538*/
			IF @ProcessType=3  
			BEGIN
				update nfRET_PM00201 set HR=1  
			END 

			/*For RF7162 To Update nfRET_MonoHighRisk to 1 */
			IF @ProcessType=4 
			BEGIN
				UPDATE nfRET_PM00200 set nfRET_MonoHighRisk=0 
				whERE nfRET_PM00200.nfRET_MonoVend=1
    
				UPDATE nfRET_PM00200 set nfRET_MonoHighRisk=1 
				where nfRET_PM00200.VENDORID in (select VENDORID from ##nfRETMCPTemp3 where ##nfRETMCPTemp3.VENDORID= nfRET_PM00200.VENDORID) 
				and  nfRET_PM00200.nfRET_MonoVend=1
			END
			
			IF @@error<>0
			begin
				rollback transaction
				CLOSE TAXDETAILS 
				DEALLOCATE TAXDETAILS
				return
			end
		END /*@ProcessType=3 or @ProcessType=4*/

		IF @ProcessType=1 or @ProcessType=2
		BEGIN
			/*This Query is to insert the new Tax Percentages and the old tax percentages to display in the Report*/
			DELETE FROM nfRET_PM40012

			INSERT INTO nfRET_PM40012	(VENDORID,VENDNAME,CUIT_Pais,nfRET_Tipo_ID, nfRET_OldPercentage,PRCNTAGE,From_Date,TODATE)
										select nfRET_PM00201.VENDORID
												,VENDNAME=( select VENDNAME  
															from  PM00200 
															where substring(TXRGNNUM,24,2)<>'' 
															and PM00200.VENDORID=nfRET_PM00201.VENDORID)
												,CUIT_Pais=(select substring(TXRGNNUM,1,11)  
															from  PM00200 
															where substring(TXRGNNUM,24,2)<>'' 
															and PM00200.VENDORID=nfRET_PM00201.VENDORID)
												,nfRET_PM00201.nfRET_Tipo_ID
												, isnull(##nfRETMCPTemp2.PRCNTAGE,0)
												,nfRET_PM00201.PRCNTAGE
												,@iFromDate
												,@iToDate from nfRET_PM00201 left outer join ##nfRETMCPTemp2 on 
																				nfRET_PM00201.VENDORID=##nfRETMCPTemp2.VENDORID and 
																				nfRET_PM00201.nfRET_Tipo_ID=##nfRETMCPTemp2.nfRET_Tipo_ID and 
																				nfRET_PM00201.nfRET_CalType=##nfRETMCPTemp2.nfRET_CalType
														  where nfRET_PM00201.nfRET_CalType=2 
														  and nfRET_PM00201.nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
														  and  nfRET_PM00201.VENDORID in(select VENDORID  
																						 from  PM00200 
																						 where substring(TXRGNNUM,24,2)<>'' 
																						 and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
																						 and PM00200.VENDORID=nfRET_PM00201.VENDORID)
														  and  nfRET_PM00201.TII_MCP_From_Date=@iFromDate 
														  and nfRET_PM00201.TII_MCP_TO_DATE=@iToDate  
			IF @@error<>0
			begin
				rollback transaction
				return
			end
			
			DELETE FROM nfRET_PM40013
			
			INSERT INTO nfRET_PM40013	(VENDORID,VENDNAME,nfRET_Reason)
										select VENDORID,VENDNAME,1 from PM00200 where substring(TXRGNNUM,24,2)=''

			INSERT INTO nfRET_PM40013	(VENDORID,VENDNAME,nfRET_Reason)
										select VENDORID,VENDNAME,2 
										from PM00200 
										where substring(TXRGNNUM,24,2)<>'' 
										and substring(TXRGNNUM,1,11) in (select TaxIDCode from ##nfRETMCPTemp5)
			IF @@error<>0
			begin
				rollback transaction
				return
			end
		END /*@ProcessType=1 or @ProcessType=2*/

		IF @ProcessType=3 OR @ProcessType=4
		BEGIN
			DELETE FROM nfRET_PM40012
			DELETE FROM nfRET_PM40013

			INSERT INTO nfRET_PM40012	(VENDORID,VENDNAME,CUIT_Pais,nfRET_Tipo_ID, nfRET_OldPercentage,PRCNTAGE,From_Date,TODATE)
										select	nfRET_PM00201.VENDORID
												,VENDNAME=(	select VENDNAME  
															from  PM00200 
															where substring(TXRGNNUM,24,2)<>'' 
															and PM00200.VENDORID=nfRET_PM00201.VENDORID)
												,CUIT_Pais=(	select substring(TXRGNNUM,1,11)  
																from  PM00200 
																where substring(TXRGNNUM,24,2)<>'' 
																and PM00200.VENDORID=nfRET_PM00201.VENDORID)
												,nfRET_PM00201.nfRET_Tipo_ID
												, isnull(##nfRETMCPTemp4.PRCNTAGE,0)
												,nfRET_PM00201.PRCNTAGE
												,@iFromDate
												,@iToDate from	nfRET_PM00201 
																left outer join ##nfRETMCPTemp4 on 
																		nfRET_PM00201.VENDORID=##nfRETMCPTemp4.VENDORID and 
																		nfRET_PM00201.nfRET_Tipo_ID=##nfRETMCPTemp4.nfRET_Tipo_ID and 
																		nfRET_PM00201.nfRET_CalType=##nfRETMCPTemp4.nfRET_CalType
														  where nfRET_PM00201.nfRET_CalType=2 
														  and nfRET_PM00201.nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)
														  and nfRET_PM00201.TII_MCP_From_Date=@iFromDate 
														  and nfRET_PM00201.TII_MCP_TO_DATE=@iToDate
														  and nfRET_PM00201.VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID) 
			IF @@error<>0
			begin
				rollback transaction
				return
			end
			
			IF @ProcessType=3
			BEGIN
				INSERT INTO nfRET_PM40013	(VENDORID,VENDNAME,nfRET_Reason)
											select VENDORID,VENDNAME,2 
											from PM00200 
											where substring(TXRGNNUM,24,2)<>'' 
											and substring(TXRGNNUM,1,11) in (select TaxIDCode from ##nfRETMCPTemp5)
    
				IF @@error<>0
				BEGIN
					rollback transaction
					return
				END
			END

			IF @ProcessType=4
			BEGIN
				insert into nfRET_PM40013	(VENDORID,VENDNAME,nfRET_Reason)
											select DISTINCT(PM00200.VENDORID),VENDNAME,3 
											from PM00200, ##nfRETMCPTemp6 
											where PM00200.VENDORID = ##nfRETMCPTemp6.VENDORID 
											and ##nfRETMCPTemp6.VENDORID in (select VENDORID from nfRET_PM00200 where  nfRET_MonoVend=0) 
    
				/*insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)
				select PM00200.VENDORID,VENDNAME,3 from PM00200, ##nfRETMCPTemp6 where ##nfRETMCPTemp6.VENDORID = PM00200.VENDORID and ##nfRETMCPTemp6.VENDORID
				not in (select nfRET_PM00200.VENDORID from nfRET_PM00200/*,PM00200 where PM00200.VENDORID= nfRET_PM00200.VENDORID*/) 
				*/
				
				INSERT INTO nfRET_PM40013	(VENDORID,VENDNAME,nfRET_Reason)
											select DISTINCT(PM00200.VENDORID),VENDNAME,3 
											from PM00200, ##nfRETMCPTemp6 
											where PM00200.VENDORID = ##nfRETMCPTemp6.VENDORID 
											and  ##nfRETMCPTemp6.VENDORID not in (select VENDORID from nfRET_PM00200) 
 
				INSERT INTO nfRET_PM40013	(VENDORID,VENDNAME,nfRET_Reason)
											/*(select PM00200.VENDORID,VENDNAME,4 from PM00200,##nfRETMCPTemp7 where PM00200.VENDORID = ##nfRETMCPTemp7.VENDORID
											and PM00200.VENDORID in (select VENDORID from nfRET_PM00200 where nfRET_HighRisk=0))*/
											(select VENDORID,VENDNAME,4 
											 from PM00200 
											 where PM00200.VENDORID in (select VENDORID from nfRET_PM00200 where nfRET_MonoVend = 1 and nfRET_MonoHighRisk=0)) 
 

				IF @@error<>0
				BEGIN
					rollback transaction
					return
				END
			END
		END /*@ProcessType=3 OR @ProcessType=4*/
  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp1')
			DROP TABLE ##nfRETMCPTemp1 
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp2')
			DROP TABLE ##nfRETMCPTemp2
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp3')
			DROP TABLE ##nfRETMCPTemp3
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp4')
			DROP TABLE ##nfRETMCPTemp4
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp5')
			DROP TABLE ##nfRETMCPTemp5
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp6')
			DROP TABLE ##nfRETMCPTemp6
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp7')
			DROP TABLE ##nfRETMCPTemp7

		COMMIT TRANSACTION T1;
	END
END
GO


