/*Begin_nfRETMCPUpdateWithholdTax*/
set quoted_identifier off 
go 
set ansi_nulls off 
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfRETMCPUpdateWithholdTax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfRETMCPUpdateWithholdTax]
go

create  procedure nfRETMCPUpdateWithholdTax 
 @iFileName char(100), @iFileFromDate char(8), @iFileToDate char(8), @iFromDate DateTime, 
 @iToDate DateTime, @iFileLocation char(256), @ProcessType smallint,  @O_SQL_Error_State int = NULL  output  
 as 
 begin  
 DECLARE @TAXDTLID char(16)  DECLARE @PubDate DateTime  DECLARE @DefPerc   float  
 begin transaction T1;  
 begin  
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp1') DROP TABLE ##nfRETMCPTemp1   
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp2') DROP TABLE ##nfRETMCPTemp2  
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp3') DROP TABLE ##nfRETMCPTemp3  
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp4') DROP TABLE ##nfRETMCPTemp4  
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp5') DROP TABLE ##nfRETMCPTemp5  
 create table ##nfRETMCPTemp5 (TaxIDCode char(11))  
 if @ProcessType=1 or @ProcessType=3  
 BEGIN  
	 create table ##nfRETMCPTemp1 (Regimen char(1), PubDate char(8),DueDateFrm char(8),DueDateTo char(8),
	 TaxIDCode char(11),TypeTaxIDCode char(1),  StatInd char(1),StatusOfChange char(1),
	 RetPer char(4),RetCat int, Dummy char(10))   
	EXEC('BULK INSERT dbo.##nfRETMCPTemp1 FROM '''+ @iFileLocation +''' WITH   (  FIELDTERMINATOR ='';'',  ROWTERMINATOR =''\n''  )')  
	if @@error<>0  begin  rollback transaction  return  end   
 insert into ##nfRETMCPTemp5   
 select TaxIDCode from ##nfRETMCPTemp1 where DueDateFrm<>@iFileFromDate or 
 DueDateTo<>@iFileToDate  
 delete from  ##nfRETMCPTemp1 where DueDateFrm<>@iFileFromDate or 
 DueDateTo<>@iFileToDate  
 set @PubDate=(select top 1 convert(datetime,substring(PubDate,5,4)+substring(PubDate,3,2)+substring(PubDate,1,2))  
 from ##nfRETMCPTemp1)  
 if @@error<>0  begin  rollback transaction  return  end  
 END  
 if @ProcessType=1 or @ProcessType=2  
 begin  
	 select * into ##nfRETMCPTemp2 from  
	 (select [VENDORID] ,[nfRET_Tipo_ID] ,[TII_MCP_From_Date],[TII_MCP_TO_DATE] ,  
	 [nfRET_CalType] , [PRCNTAGE]  from nfRET_PM00201   where nfRET_CalType=2 and 
	 nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
	 and VENDORID in(select PM00200.VENDORID from  PM00200 
	 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) 
	 not in(select TaxIDCode from ##nfRETMCPTemp5)  
	 and PM00200.VENDORID=nfRET_PM00201.VENDORID)  and ((TII_MCP_From_Date<@iFromDate and 
	 TII_MCP_TO_DATE>=@iFromDate)  or( TII_MCP_From_Date>@iFromDate and 
	 TII_MCP_From_Date<@iToDate and TII_MCP_TO_DATE>@iToDate)  
	 or( TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate)))as t1  
	 if @@error<>0  begin  rollback transaction  return  end  
 end  
 if @ProcessType=1 or @ProcessType=2  
 begin  
	update nfRET_PM00201 set TII_MCP_TO_DATE=DATEADD(day,-1,@iFromDate)  
	where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 
	where NAME=@iFileName)   and VENDORID in(select PM00200.VENDORID from  PM00200 
	where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) 
	not in(select TaxIDCode from ##nfRETMCPTemp5)  
	and PM00200.VENDORID=nfRET_PM00201.VENDORID) and (TII_MCP_From_Date<@iFromDate 
	and TII_MCP_TO_DATE>=@iFromDate)   
	if @@error<>0  begin  rollback transaction  return  end   
	update nfRET_PM00201 set TII_MCP_From_Date=DATEADD(day,1,@iToDate)  
	where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 
	where NAME=@iFileName)   and VENDORID in(select PM00200.VENDORID from  PM00200 
	where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not 
	in(select TaxIDCode from ##nfRETMCPTemp5)  
	and PM00200.VENDORID=nfRET_PM00201.VENDORID)and (TII_MCP_From_Date<=@iToDate 
	and TII_MCP_TO_DATE>@iToDate)   
	if @@error<>0  begin  rollback transaction  return  end  
	delete from nfRET_PM00201  where  nfRET_CalType=2 and 
	nfRET_Tipo_ID in(select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)  
	and TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate  
	and VENDORID in(select PM00200.VENDORID from  PM00200 where substring(TXRGNNUM,24,2)<>'' 
	and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5) 
	and PM00200.VENDORID=nfRET_PM00201.VENDORID)  
	if @@error<>0  begin  rollback transaction  return  end  
end  
set @DefPerc=isnull((select PRCNTAGE from nfRET_PM00040),1.75)  
if @ProcessType=1 or @ProcessType=2  
BEGIN  
	DECLARE TAXDETAILS CURSOR FOR   select TAXDTLID from nfRET_PM40011 where NAME=@iFileName  
	OPEN TAXDETAILS   FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID  WHILE (@@FETCH_STATUS=0)   
	BEGIN   
		if @ProcessType=1   
		begin  
			insert  into nfRET_PM00201(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE,  
			nfRET_CalType,PRCNTAGE,DATE1)  
			select PM00200.VENDORID,  @TAXDTLID,@iFromDate,@iToDate,2,
			CAST(REPLACE('0' + ##nfRETMCPTemp1.RetPer,',','.') AS decimal(19,5))as RetPer,@PubDate 
			from PM00200 inner join ##nfRETMCPTemp1 
			on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode 
			and substring(PM00200.TXRGNNUM,24,2)<>''  
			if @@error<>0  begin  rollback transaction  CLOSE TAXDETAILS   DEALLOCATE TAXDETAILS  return  end  
			insert into nfRET_PM00201(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE,  
			nfRET_CalType,PRCNTAGE) 
			select PM00200.VENDORID,@TAXDTLID,@iFromDate,@iToDate,2,@DefPerc from PM00200  
			where substring(TXRGNNUM,24,2)<>''and substring(PM00200.TXRGNNUM,1,11)  
			not in (select ##nfRETMCPTemp1.TaxIDCode from ##nfRETMCPTemp1 
			where ##nfRETMCPTemp1.TaxIDCode=substring(PM00200.TXRGNNUM,1,11))  
			and substring(PM00200.TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)  
			if @@error<>0  begin  rollback transaction  CLOSE TAXDETAILS   DEALLOCATE TAXDETAILS  return  end   
		end  
		if  @ProcessType=2  
		begin  
			insert into nfRET_PM00201(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE,  
			nfRET_CalType,PRCNTAGE) 
			select PM00200.VENDORID,@TAXDTLID,@iFromDate,@iToDate,2,@DefPerc from PM00200  
			where substring(TXRGNNUM,24,2)<>''  
			if @@error<>0  begin  rollback transaction  CLOSE TAXDETAILS   DEALLOCATE TAXDETAILS  return  end   
		end   
		FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID  END  
		CLOSE TAXDETAILS   
		DEALLOCATE TAXDETAILS  
		if @@error<>0  begin  rollback transaction  return  end  
	END   
	if @ProcessType=3  
	BEGIN  
		create table ##nfRETMCPTemp3 (VENDORID char(15),nfRET_Tipo_ID char(11), 
		TII_MCP_From_Date datetime,TII_MCP_TO_DATE datetime,nfRET_CalType char(2),RetPer char(9),
		DATE1 datetime)   
		DECLARE TAXDETAILS CURSOR FOR select TAXDTLID from nfRET_PM40011 where NAME=@iFileName  
		OPEN TAXDETAILS   FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID  
		WHILE (@@FETCH_STATUS=0)   
		BEGIN   
			insert into ##nfRETMCPTemp3(VENDORID,nfRET_Tipo_ID, TII_MCP_From_Date ,
			TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)  
			(select PM00200.VENDORID as VENDORID,  @TAXDTLID as nfRET_Tipo_ID,
			@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,
			CAST(REPLACE(##nfRETMCPTemp1.RetPer,',','.') AS decimal(19,5))as RetPer,@PubDate as DATE1 
			from PM00200 inner join ##nfRETMCPTemp1 
			on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode)   
			if @@error<>0  begin  rollback transaction  CLOSE TAXDETAILS   DEALLOCATE TAXDETAILS  return  end  
			FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID  
		END  
		CLOSE TAXDETAILS   
		DEALLOCATE TAXDETAILS  
		if @@error<>0  begin  rollback transaction  return  end  
		select * into ##nfRETMCPTemp4 from  (select [VENDORID] ,[nfRET_Tipo_ID] ,[TII_MCP_From_Date],
		[TII_MCP_TO_DATE] ,  [nfRET_CalType] , [PRCNTAGE]  from nfRET_PM00201   
		where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
		and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 
		where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)  and ((TII_MCP_From_Date<@iFromDate 
		and TII_MCP_TO_DATE>=@iFromDate)  or( TII_MCP_From_Date>@iFromDate and TII_MCP_From_Date<@iToDate 
		and TII_MCP_TO_DATE>@iToDate)  or( TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate)))as t1  
		if @@error<>0  begin  rollback transaction  return  end  
		update nfRET_PM00201 set TII_MCP_TO_DATE=DATEADD(day,-1,@iFromDate)  where nfRET_CalType=2 
		and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
		and nfRET_PM00201.VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 
		where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)  
		and (nfRET_PM00201.TII_MCP_From_Date<@iFromDate and nfRET_PM00201.TII_MCP_TO_DATE>=@iFromDate)   
		if @@error<>0  begin  rollback transaction  return  end   
		update nfRET_PM00201 set TII_MCP_From_Date=DATEADD(day,1,@iToDate)  where nfRET_CalType=2 
		and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
		and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 
		where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)  
		and (TII_MCP_From_Date<=@iToDate and TII_MCP_TO_DATE>@iToDate)   
		if @@error<>0  begin  rollback transaction  return  end  
		delete from nfRET_PM00201  where  nfRET_CalType=2 and nfRET_Tipo_ID 
		in(select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)  
		and TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate  and VENDORID 
		in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  
		##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)  
		if @@error<>0  begin  rollback transaction  return  end  
		insert  into nfRET_PM00201(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE,  
		nfRET_CalType,PRCNTAGE,DATE1)  select ##nfRETMCPTemp3.VENDORID,  ##nfRETMCPTemp3.nfRET_Tipo_ID,
		@iFromDate,@iToDate,2,RetPer,DATE1 from ##nfRETMCPTemp3  
		if @@error<>0  begin  rollback transaction  CLOSE TAXDETAILS   DEALLOCATE TAXDETAILS  return  end  
		END  
		if @ProcessType=1 or @ProcessType=2  
		Begin  
			delete from nfRET_PM40012  insert into nfRET_PM40012(VENDORID,VENDNAME,CUIT_Pais,nfRET_Tipo_ID, nfRET_OldPercentage,PRCNTAGE,From_Date,TODATE)  
			select nfRET_PM00201.VENDORID,VENDNAME=(select VENDNAME  from  PM00200 
			where substring(TXRGNNUM,24,2)<>'' and PM00200.VENDORID=nfRET_PM00201.VENDORID),
			CUIT_Pais=(select substring(TXRGNNUM,1,11)  from  PM00200 where substring(TXRGNNUM,24,2)<>'' 
			and PM00200.VENDORID=nfRET_PM00201.VENDORID),  nfRET_PM00201.nfRET_Tipo_ID,  
			isnull(##nfRETMCPTemp2.PRCNTAGE,0),nfRET_PM00201.PRCNTAGE,@iFromDate,@iToDate from nfRET_PM00201 
			left outer join ##nfRETMCPTemp2 
			on   nfRET_PM00201.VENDORID=##nfRETMCPTemp2.VENDORID 
			and nfRET_PM00201.nfRET_Tipo_ID=##nfRETMCPTemp2.nfRET_Tipo_ID  
			and nfRET_PM00201.nfRET_CalType=##nfRETMCPTemp2.nfRET_CalType  where nfRET_PM00201.nfRET_CalType=2 
			and nfRET_PM00201.nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)   
			and  nfRET_PM00201.VENDORID in(select VENDORID  from  PM00200 where substring(TXRGNNUM,24,2)<>'' 
			and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
			and PM00200.VENDORID=nfRET_PM00201.VENDORID)  and  nfRET_PM00201.TII_MCP_From_Date=@iFromDate 
			and nfRET_PM00201.TII_MCP_TO_DATE=@iToDate   
			if @@error<>0  begin  rollback transaction  return  end  delete from nfRET_PM40013  
			insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)  
			select VENDORID,VENDNAME,1 from PM00200 where substring(TXRGNNUM,24,2)=''   
			insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)  select VENDORID,VENDNAME,2 from PM00200 
			where substring(TXRGNNUM,24,2)<>''   and substring(TXRGNNUM,1,11) 
			in (select TaxIDCode from ##nfRETMCPTemp5)  if @@error<>0  begin  rollback transaction  return  end  
			End  
			if @ProcessType=3   
			begin  
				delete from nfRET_PM40012  delete from nfRET_PM40013  
				insert into nfRET_PM40012(VENDORID,VENDNAME,CUIT_Pais,nfRET_Tipo_ID, nfRET_OldPercentage,PRCNTAGE,
				From_Date,TODATE)  select nfRET_PM00201.VENDORID,VENDNAME=(select VENDNAME  from  PM00200 
				where substring(TXRGNNUM,24,2)<>'' and PM00200.VENDORID=nfRET_PM00201.VENDORID),
				CUIT_Pais=(select substring(TXRGNNUM,1,11)  from  PM00200 where substring(TXRGNNUM,24,2)<>'' 
				and PM00200.VENDORID=nfRET_PM00201.VENDORID),  nfRET_PM00201.nfRET_Tipo_ID,  
				isnull(##nfRETMCPTemp4.PRCNTAGE,0),nfRET_PM00201.PRCNTAGE,@iFromDate,@iToDate 
				from nfRET_PM00201 left outer join ##nfRETMCPTemp4 
				on   nfRET_PM00201.VENDORID=##nfRETMCPTemp4.VENDORID 
				and nfRET_PM00201.nfRET_Tipo_ID=##nfRETMCPTemp4.nfRET_Tipo_ID  
				and nfRET_PM00201.nfRET_CalType=##nfRETMCPTemp4.nfRET_CalType  
				where nfRET_PM00201.nfRET_CalType=2 and nfRET_PM00201.nfRET_Tipo_ID 
				in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)  
				and nfRET_PM00201.TII_MCP_From_Date=@iFromDate and nfRET_PM00201.TII_MCP_TO_DATE=@iToDate  
				and nfRET_PM00201.VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 
				where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)   
				if @@error<>0  begin  rollback transaction  return  end  
				insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)  
				select VENDORID,VENDNAME,2 from PM00200 where substring(TXRGNNUM,24,2)<>''   
				and substring(TXRGNNUM,1,11) in (select TaxIDCode from ##nfRETMCPTemp5)  
				if @@error<>0  begin  rollback transaction  return  end  
			end  
			IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp1')  
			DROP TABLE ##nfRETMCPTemp1   
			IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp2')  
			DROP TABLE ##nfRETMCPTemp2  
			IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp3')  
			DROP TABLE ##nfRETMCPTemp3  
			IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp4')  
			DROP TABLE ##nfRETMCPTemp4  IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects 
			WHERE name = '##nfRETMCPTemp5')  
			DROP TABLE ##nfRETMCPTemp5  
			PRINT 'COMMIT TRANSACTION T1'
			commit transaction T1;  
		end 
	end     
 

GO
set quoted_identifier on
go
set ansi_nulls on 
go

grant execute on [dbo].[nfRETMCPUpdateWithholdTax] to [DYNGRP] 
go 

/*End_nfRETMCPUpdateWithholdTax*/


