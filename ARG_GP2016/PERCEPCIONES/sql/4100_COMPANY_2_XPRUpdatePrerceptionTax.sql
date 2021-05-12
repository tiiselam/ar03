USE PRD01
GO

/****** Object:  StoredProcedure [dbo].[XPRUpdatePerceptionTax]    Script Date: 2/14/2020 8:38:45 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER  procedure [dbo].[XPRUpdatePerceptionTax]  @iFileName char(100), @iFileFromDate char(8), 
@iFileToDate char(8), @iFromDate DateTime, @iToDate DateTime, @iFileLocation char(256), 
@ProcessType smallint,  @O_SQL_Error_State int = NULL  output  
as 
begin  
	DECLARE @TAXDTLID char(16)  DECLARE @PubDate DateTime  DECLARE @DefPerc   float  
	begin transaction T1;  
	begin  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp1')  DROP TABLE ##XPRTemp1 
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp12')  DROP TABLE ##XPRTemp12  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp2')  DROP TABLE ##XPRTemp2  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp3')  DROP TABLE ##XPRTemp3  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp4')  DROP TABLE ##XPRTemp4  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp5')  DROP TABLE ##XPRTemp5  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp6')  DROP TABLE ##XPRTemp6  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp7')  DROP TABLE ##XPRTemp7  

		create table ##XPRTemp5(TaxIDCode char(11))  

		if @ProcessType=1 or @ProcessType=3 or @ProcessType = 5 
		BEGIN  
			create table ##XPRTemp1 
						(
						Regimen char(1), 
						PubDate char(8),
						DueDateFrm char(8),
						DueDateTo char(8),
						TaxIDCode char(11),
						TypeTaxIDCode char(1),  
						StatInd char(1),
						StatusOfChange char(1),
						PercPer char(10),
						PerCa int, 
						Dummy char(10))      
			
			if @ProcessType = 5 
			BEGIN
				DECLARE @ARCHIVO_FORMAT char(256)
				SELECT @ARCHIVO_FORMAT = SUBSTRING(RTRIM(@iFileLocation),1,LEN(RTRIM(@iFileLocation))- CHARINDEX('\',REVERSE(RTRIM(@iFileLocation)))+1)+'FormatFiles\formato_efgr116.txt';
				--INSERT log_desarrollo VALUES('2',GETDATE(),'fILE '+ REVERSE(RTRIM(@iFileLocation)) + 'LEN ' +str(LEN(@iFileLocation))+ ' Char ' +  str(CHARINDEX('\',REVERSE(RTRIM(@iFileLocation)))+1) + 'File ' +@ARCHIVO_FORMAT )
				--commit;
				create table ##XPRTemp12 (
										TaxIDCode char(11),
										StatInd char(5),
										Coef Char(8),
										DueDateFrm char(6),
										VendorName char(152),
										PercPer char(10)
										 )

				EXEC('BULK INSERT dbo.##XPRTemp12 FROM '''+ @iFileLocation +''' WITH   ( FIRSTROW=6,FORMATFILE='''+@ARCHIVO_FORMAT+''' )')  

				if @@error<>0  begin  rollback transaction  return  end    

				insert into ##XPRTemp1
					select 'P', 
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
										ELSE PercPer--convert(char(10),Convert(numeric(5,4), coef) * Convert(numeric(5,3), PercPer) * 0.50)
										end 
								END ,
							0, 
						   ' '
					FROM ##XPRTemp12

				if @@error<>0  begin  rollback transaction  return  end   						
				--update  con el Coeficiente
			END
			ELSE
			BEGIN
				EXEC('BULK INSERT dbo.##XPRTemp1 FROM '''+ @iFileLocation +''' WITH   (  FIELDTERMINATOR ='';'',  ROWTERMINATOR =''\n''  )')  
			
				if @@error<>0  begin  rollback transaction  return  end    
			END 

			insert into ##XPRTemp5 select TaxIDCode from ##XPRTemp1 where DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate  
			delete from ##XPRTemp1 where DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate  
		END  

		if @ProcessType=1 or @ProcessType=2  or @ProcessType = 5
		begin  
			select * 
			into ##XPRTemp2 
			from  (select	[CUSTNMBR] ,
							[ADRSCODE] ,
							[TAXDTLID],
							[AX_Start_Date] ,  
							[AX_Due_Date], 
							[AX_Tipo] , 
							[AX_Porcentaje] ,
							[AX_Organismo],
							[AX_Certificado_Entregado] 
					from XPR00102   
					where AX_Tipo=2 
					and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)   
					and CUSTNMBR in (	select RM00101.CUSTNMBR 
										from  RM00101 
										where substring(TXRGNNUM,24,2)<>'' 
										and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5)
										and  RM00101.CUSTNMBR=XPR00102.CUSTNMBR)  
					and ((AX_Start_Date<@iFromDate and AX_Due_Date>=@iFromDate)  or
						 ( AX_Start_Date>@iFromDate and AX_Start_Date<@iToDate and AX_Due_Date>@iToDate)  or
						 ( AX_Start_Date>=@iFromDate and AX_Due_Date<=@iToDate)
						)
					) as t1   
			
			if @@error<>0  begin  rollback transaction  return  end  
		end  
		
		if @ProcessType=1 or @ProcessType=2  or @ProcessType = 5
		begin  
			update XPR00102 
					set AX_Due_Date=DATEADD(day,-1,@iFromDate)  
					where AX_Tipo=2 
					and TAXDTLID in (	select TAXDTLID from XPR00106 where NAME=@iFileName)   
					and CUSTNMBR in (	select RM00101.CUSTNMBR 
										from  RM00101 
										where substring(TXRGNNUM,24,2)<>'' 
										and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) 
										and RM00101.CUSTNMBR=XPR00102.CUSTNMBR) 
					 and (AX_Start_Date<@iFromDate and AX_Due_Date>=@iFromDate)
					    
			if @@error<>0  begin  rollback transaction  return  end   
			
			update XPR00102 
					set AX_Start_Date=DATEADD(day,1,@iToDate)  
					where AX_Tipo=2 
					and TAXDTLID in (	select TAXDTLID from XPR00106 where NAME=@iFileName)   
					and CUSTNMBR in (	select RM00101.CUSTNMBR 
										from  RM00101 
										where substring(TXRGNNUM,24,2)<>'' 
										and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) 
										and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)  
					and (AX_Start_Date<=@iToDate and AX_Due_Date>@iToDate)   
			
			if @@error<>0  begin  rollback transaction  return  end  
			
			select * 
			into ##XPRTemp6 
			from (	SELECT DISTINCT CUSTNMBR,TXRGNNUM=(	select substring(RM00101.TXRGNNUM,1,11) 
														from RM00101 
														where RM00101.CUSTNMBR=XPR00102.CUSTNMBR),
								    ADRSCODE,TAXDTLID 
					FROM XPR00102  
					WHERE TAXDTLID in (	select TAXDTLID 
										from XPR00106 
										where NAME=@iFileName)
					and CUSTNMBR in(	select RM00101.CUSTNMBR 
										from  RM00101 
										where substring(TXRGNNUM,24,2)<>'' 
										and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) 
										and RM00101.CUSTNMBR=XPR00102.CUSTNMBR) 
				) as T1   

			insert	into ##XPRTemp6 
					select distinct CUSTNMBR,
									TXRGNNUM=(	select substring(RM00101.TXRGNNUM,1,11) 
												from RM00101 
												where RM00101.CUSTNMBR=RM00102.CUSTNMBR),
									ADRSCODE,TAXDTLID 
					from	RM00102 
							inner join TX00102 on RM00102.TAXSCHID=TX00102.TAXSCHID  
					where TX00102.TAXDTLID in  (select TAXDTLID from XPR00106 where NAME=@iFileName) 
					and RM00102.CUSTNMBR in	(	select RM00101.CUSTNMBR 
												from  RM00101 
												where substring(TXRGNNUM,24,2)<>'' 
												and substring(TXRGNNUM,1,11) not in(select TaxIDCode 
																					from ##XPRTemp5) 
												and RM00101.CUSTNMBR=RM00102.CUSTNMBR)  

			if @@error<>0  begin  rollback transaction  return  end  

			delete 
				from XPR00102  
				where  AX_Tipo=2 
				and TAXDTLID in(	select TAXDTLID from XPR00106 where NAME=@iFileName)  
				and AX_Start_Date>=@iFromDate 
				and AX_Due_Date<=@iToDate  
				and CUSTNMBR in(	select RM00101.CUSTNMBR 
									from  RM00101 
									where substring(TXRGNNUM,24,2)<>'' 
									and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) 
									and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)  
			
			if @@error<>0  begin  rollback transaction  return  end  
		end 
		 
		set @DefPerc=isnull((select PRCNTAGE from XPR00107),3)  

		if @ProcessType=1 or @ProcessType=2  or @ProcessType = 5
		BEGIN  
			if @ProcessType=1   or @ProcessType = 5
			begin  
				insert  into XPR00102(	CUSTNMBR,
										ADRSCODE,
										TAXDTLID,
										AX_Start_Date,
										AX_Due_Date,  
										AX_Tipo,AX_Porcentaje)  
					select distinct		##XPRTemp6.CUSTNMBR,  
										##XPRTemp6.ADRSCODE,
										##XPRTemp6.TAXDTLID,
										@iFromDate,
										@iToDate,2,
										CAST(REPLACE(##XPRTemp1.PercPer,',','.') AS decimal(6,4))as PercPer 
					from	##XPRTemp6 
							inner join ##XPRTemp1 on substring(##XPRTemp6.TXRGNNUM,1,11)=##XPRTemp1.TaxIDCode  

				if @@error<>0  begin  rollback transaction  return  end  

				insert into XPR00102(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date,AX_Due_Date,  AX_Tipo,AX_Porcentaje)  
					select distinct		##XPRTemp6.CUSTNMBR,  
										##XPRTemp6.ADRSCODE,
										##XPRTemp6.TAXDTLID,
										@iFromDate,
										@iToDate,
										2,
										@DefPerc 
					from ##XPRTemp6  
					where  substring(##XPRTemp6.TXRGNNUM,1,11)  not in (select ##XPRTemp1.TaxIDCode from ##XPRTemp1 where ##XPRTemp1.TaxIDCode=substring(##XPRTemp6.TXRGNNUM,1,11))  and  substring(##XPRTemp6.TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5)  
				if @@error<>0  begin  rollback transaction  return  end   
			end  
			if  @ProcessType=2  
			begin  
				insert into XPR00102(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date,AX_Due_Date,  AX_Tipo,AX_Porcentaje)  select distinct ##XPRTemp6.CUSTNMBR,  ##XPRTemp6.ADRSCODE,##XPRTemp6.TAXDTLID,@iFromDate,@iToDate,2,@DefPerc from ##XPRTemp6  
				if @@error<>0  begin  rollback transaction  return  end   
			end   
			if @@error<>0  begin  rollback transaction  return  end  
		END   
		if @ProcessType=3  
		BEGIN  
			create table ##XPRTemp3 (CUSTNMBR char(15),ADRSCODE char(15),TAXDTLID char(15), AX_Start_Date datetime,AX_Due_Date datetime,AX_Tipo char(2),AX_Porcentaje char(9))   
			select * into ##XPRTemp7 from (SELECT DISTINCT CUSTNMBR,TXRGNNUM=(select substring(RM00101.TXRGNNUM,1,11) from RM00101 where RM00101.CUSTNMBR=XPR00102.CUSTNMBR),ADRSCODE,TAXDTLID FROM XPR00102  WHERE TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)  and CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)) as T1   
			insert into ##XPRTemp7 select distinct CUSTNMBR,TXRGNNUM=(select substring(RM00101.TXRGNNUM,1,11) from RM00101 where RM00101.CUSTNMBR=RM00102.CUSTNMBR),ADRSCODE,TAXDTLID from RM00102 inner join TX00102 on RM00102.TAXSCHID=TX00102.TAXSCHID  where TX00102.TAXDTLID in  (select TAXDTLID from XPR00106 where NAME=@iFileName) and RM00102.CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=RM00102.CUSTNMBR) 	  
			insert into ##XPRTemp3(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date ,AX_Due_Date,AX_Tipo,AX_Porcentaje)  (select distinct ##XPRTemp7.CUSTNMBR ,  ADRSCODE,##XPRTemp7.TAXDTLID,@iFromDate as AX_Start_Date,@iToDate as AX_Due_Date,2 as AX_Tipo,CAST(REPLACE(##XPRTemp1.PercPer,',','.') AS decimal(4,2))as AX_Porcentaje from ##XPRTemp7 inner join ##XPRTemp1 on substring(##XPRTemp7.TXRGNNUM,1,11)=##XPRTemp1.TaxIDCode)   
			if @@error<>0  begin  rollback transaction  return  end  
			select * into ##XPRTemp4 from (select [CUSTNMBR] ,[ADRSCODE],[TAXDTLID] ,[AX_Start_Date],[AX_Due_Date] ,  [AX_Tipo] , [AX_Porcentaje]  from XPR00102   where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)   and CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)  and ((AX_Start_Date<@iFromDate and AX_Due_Date>=@iFromDate)  or( AX_Start_Date>@iFromDate and AX_Start_Date<@iToDate and AX_Due_Date>@iToDate)  or( AX_Start_Date>=@iFromDate and AX_Due_Date<=@iToDate)))as t1  
			if @@error<>0  begin  rollback transaction  return  end  
			update XPR00102 set AX_Due_Date=DATEADD(day,-1,@iFromDate)  where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)   and XPR00102.CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)  and (XPR00102.AX_Start_Date<@iFromDate and XPR00102.AX_Due_Date>=@iFromDate)   
			if @@error<>0  begin  rollback transaction  return  end   
			update XPR00102 set AX_Start_Date=DATEADD(day,1,@iToDate)  where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)   and CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)  and (AX_Start_Date<=@iToDate and AX_Due_Date>@iToDate)   
			if @@error<>0  begin  rollback transaction  return  end  
			delete from XPR00102  where  AX_Tipo=2 and TAXDTLID in(select TAXDTLID from XPR00106 where NAME=@iFileName)  and AX_Start_Date>=@iFromDate and AX_Due_Date<=@iToDate  and CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)  
			if @@error<>0  begin  rollback transaction  return  end  
			insert  into XPR00102(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date,AX_Due_Date,  AX_Tipo,AX_Porcentaje)  select ##XPRTemp3.CUSTNMBR,##XPRTemp3.ADRSCODE,  ##XPRTemp3.TAXDTLID,@iFromDate,@iToDate,2,AX_Porcentaje from ##XPRTemp3  
			if @@error<>0  begin  rollback transaction  return  end  
		END  
		if @ProcessType=1 or @ProcessType=2  or @ProcessType = 5
		Begin  
			delete from XPR00108  
			insert into XPR00108(CUSTNMBR,CUSTNAME,TXRGNNUM,ADRSCODE, TAXDTLID,XPR_OldPercentage,AX_Porcentaje,From_Date,TODATE)  select XPR00102.CUSTNMBR,CUSTNAME=(select CUSTNAME  from  RM00101 where substring(TXRGNNUM,24,2)<>''  and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),TXRGNNUM=(select substring(TXRGNNUM,1,11)  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),  XPR00102.ADRSCODE,XPR00102.TAXDTLID,  isnull(##XPRTemp2.AX_Porcentaje,0),XPR00102.AX_Porcentaje,@iFromDate,@iToDate from XPR00102 left outer join ##XPRTemp2 on   XPR00102.CUSTNMBR=##XPRTemp2.CUSTNMBR and XPR00102.ADRSCODE=##XPRTemp2.ADRSCODE and XPR00102.TAXDTLID=##XPRTemp2.TAXDTLID  and XPR00102.AX_Tipo=##XPRTemp2.AX_Tipo  where XPR00102.AX_Tipo=2  and XPR00102.CUSTNMBR in(select CUSTNMBR  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)  and  XPR00102.AX_Start_Date=@iFromDate and XPR00102.AX_Due_Date=@iToDate and   XPR00102.TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)    
			if @@error<>0  begin  rollback transaction  return  end  
			update XPR00102 set XPR00102.AX_Organismo= ##XPRTemp2.AX_Organismo,XPR00102.AX_Certificado_Entregado=##XPRTemp2.AX_Certificado_Entregado from XPR00102 inner join ##XPRTemp2 on XPR00102.CUSTNMBR=##XPRTemp2.CUSTNMBR and XPR00102.ADRSCODE=##XPRTemp2.ADRSCODE and XPR00102.TAXDTLID=##XPRTemp2.TAXDTLID  and  XPR00102.AX_Start_Date=##XPRTemp2.AX_Start_Date and XPR00102.AX_Due_Date=##XPRTemp2.AX_Due_Date and XPR00102.AX_Tipo=##XPRTemp2.AX_Tipo 
			if @@error<>0 begin rollback transaction return end 
			delete from XPR00109  
			insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)  select CUSTNMBR,CUSTNAME,1 from RM00101 where substring(TXRGNNUM,24,2)=''   
			insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)  select CUSTNMBR,CUSTNAME,2 from RM00101 where substring(TXRGNNUM,24,2)<>''  and CUSTNMBR not in(select CUSTNMBR from XPR00102 where XPR00102.CUSTNMBR=RM00101.CUSTNMBR and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName))  
			insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)  select CUSTNMBR,CUSTNAME,3 from RM00101 where substring(TXRGNNUM,24,2)<>''  and substring(TXRGNNUM,1,11)  in(select TaxIDCode from ##XPRTemp5)  
			if @@error<>0  begin  rollback transaction  return  end  
		End  
		if @ProcessType=3   
		begin 
			delete from XPR00108  
			insert into XPR00108(CUSTNMBR,CUSTNAME,TXRGNNUM,ADRSCODE,TAXDTLID, XPR_OldPercentage,AX_Porcentaje,From_Date,TODATE)  select XPR00102.CUSTNMBR,CUSTNAME=(select CUSTNAME  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),TXRGNNUM=(select substring(TXRGNNUM,1,11)  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),  XPR00102.ADRSCODE,XPR00102.TAXDTLID,  isnull(##XPRTemp4.AX_Porcentaje,0),XPR00102.AX_Porcentaje,@iFromDate,@iToDate from XPR00102 left outer join ##XPRTemp4 on   XPR00102.CUSTNMBR=##XPRTemp4.CUSTNMBR and XPR00102.ADRSCODE=##XPRTemp4.ADRSCODE and XPR00102.TAXDTLID=##XPRTemp4.TAXDTLID  and XPR00102.AX_Tipo=##XPRTemp4.AX_Tipo  where XPR00102.AX_Tipo=2 and  XPR00102.AX_Start_Date=@iFromDate and XPR00102.AX_Due_Date=@iToDate  and XPR00102.CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)   and XPR00102.TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)    
			if @@error<>0  begin  rollback transaction  return  end 
			delete from XPR00109  
			insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)  select CUSTNMBR,CUSTNAME,2 from RM00101 inner join ##XPRTemp1 on   substring(RM00101.TXRGNNUM,1,11)=##XPRTemp1.TaxIDCode  where substring(TXRGNNUM,24,2)<>''  and CUSTNMBR not in(select CUSTNMBR from XPR00102 where XPR00102.CUSTNMBR=RM00101.CUSTNMBR and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName))  
			insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)  select CUSTNMBR,CUSTNAME,3 from RM00101 where substring(TXRGNNUM,24,2)<>''  and substring(TXRGNNUM,1,11)  in(select TaxIDCode from ##XPRTemp5)  
			if @@error<>0  begin  rollback transaction  return  end  
		end  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp1')  DROP TABLE ##XPRTemp1  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp1')  DROP TABLE ##XPRTemp12
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp2')  DROP TABLE ##XPRTemp2  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp3')  DROP TABLE ##XPRTemp3  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp4')  DROP TABLE ##XPRTemp4  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp5')  DROP TABLE ##XPRTemp5  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp6')  DROP TABLE ##XPRTemp6  
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp7')  DROP TABLE ##XPRTemp7  
		commit transaction T1;  
	end 
end     


GO


