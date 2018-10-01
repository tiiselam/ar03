/*Count : 6 */

set DATEFORMAT ymd 
GO 

/*Begin_XPR_SOP_Doc_Exclution*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XPR_SOP_Doc_Exclution]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].XPR_SOP_Doc_Exclution
GO

CREATE PROCEDURE [dbo].[XPR_SOP_Doc_Exclution]   
@Docnubr as char(20),
@type as int

AS  
DECLARE
@Actindx as int,
@Taxdltid as char(20)
BEGIN
DECLARE DOC_Exclution CURSOR FOR  
select TAXDTLID from SOP10105 where SOPNUMBE=@Docnubr  
OPEN DOC_Exclution  
FETCH NEXT FROM DOC_Exclution INTO  @Taxdltid	
WHILE @@FETCH_STATUS = 0
BEGIN	
select @Actindx=ACTINDX from TX00201 where TAXDTLID=@Taxdltid

if (select count(*) from XPR00103 where TAXDTLID=@Taxdltid and XPR_Exclude_Modulo_ID=2 and XPR_Exclude_Document_Num=3)>0
BEGIN
Update SOP10105 set STAXAMNT=0.00,ORSLSTAX=0.00 where SOPNUMBE=@Docnubr and SOPTYPE=@type and TAXDTLID=@Taxdltid and ACTINDX=@Actindx 
Delete from SOP10102 where SOPNUMBE=@Docnubr and SOPTYPE=@type and ACTINDX=@Actindx 
END   
FETCH NEXT FROM DOC_Exclution INTO @Taxdltid 

END  
CLOSE DOC_Exclution  
DEALLOCATE DOC_Exclution
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XPR_SOP_Doc_Exclution] TO [DYNGRP] 
GO 
/*End_XPR_SOP_Doc_Exclution*/
/*Begin_XPRUpdatePerceptionTax*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XPRUpdatePerceptionTax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XPRUpdatePerceptionTax]
GO

create  procedure XPRUpdatePerceptionTax 
@iFileName char(100),
@iFileFromDate char(8),
@iFileToDate char(8),
@iFromDate DateTime,
@iToDate DateTime,
@iFileLocation char(256),
@ProcessType smallint,
 @O_SQL_Error_State int = NULL  output

as
begin
 DECLARE @TAXDTLID char(16)
 DECLARE @PubDate DateTime
 DECLARE @DefPerc   float
 begin transaction T1;
 begin
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp1')
 DROP TABLE ##XPRTemp1 
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp2')
 DROP TABLE ##XPRTemp2
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp3')
 DROP TABLE ##XPRTemp3
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp4')
 DROP TABLE ##XPRTemp4
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp5')
 DROP TABLE ##XPRTemp5
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp6')
 DROP TABLE ##XPRTemp6
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp7')
 DROP TABLE ##XPRTemp7
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp8')
 DROP TABLE ##XPRTemp8
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp10')
 DROP TABLE ##XPRTemp10	
 
create table ##XPRTemp5(TaxIDCode char(11))
 if @ProcessType=1 or @ProcessType=3 or @ProcessType=4
 BEGIN
 if @ProcessType=1 
 begin
 EXEC('create table ##XPRTemp1 (PubDate char(8),DueDateFrm char(8),DueDateTo char(8),TaxIDCode char(11),TypeTaxIDCode char(1),
 StatInd char(1),StatusOfChange char(1),PercPer char(4),RetPer char(4),PerCa int,RetCat int)')
 end
 if @ProcessType=3 or @ProcessType=4
 begin
 EXEC(' create table ##XPRTemp1 (PubDate char(8),DueDateFrm char(8),DueDateTo char(8),TaxIDCode char(11),TypeTaxIDCode char(1),
 StatInd char(1),StatusOfChange char(1),PercPer char(4),RetPer char(4),PerCa int,RetCat int,custName char(60))')
 end

 EXEC('BULK INSERT dbo.##XPRTemp1 FROM '''+ @iFileLocation +''' WITH 
 (
 FIELDTERMINATOR ='';'',
 ROWTERMINATOR =''\n''
 )')
 if @@error<>0
 begin
 rollback transaction
 return
 end 
 

 insert into ##XPRTemp5 
 select TaxIDCode from ##XPRTemp1 where DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate
 delete from ##XPRTemp1 where DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate
 END
 
 if @ProcessType=1 or @ProcessType=2
 begin
 select * into ##XPRTemp2 from  (select [CUSTNMBR] ,[ADRSCODE] ,[TAXDTLID],[AX_Start_Date] ,
 [AX_Due_Date], [AX_Tipo] , [AX_Porcentaje] ,[AX_Organismo],[AX_Certificado_Entregado] from XPR00102 
 where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 
 and CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5)and  RM00101.CUSTNMBR=XPR00102.CUSTNMBR)
 and ((AX_Start_Date<@iFromDate and AX_Due_Date>=@iFromDate)  or( AX_Start_Date>@iFromDate and AX_Start_Date<@iToDate and AX_Due_Date>@iToDate)
 or( AX_Start_Date>=@iFromDate and AX_Due_Date<=@iToDate)))as t1

 if @@error<>0
 begin
 rollback transaction
 return
 end
 end
 
 if @ProcessType=1 or @ProcessType=2
 begin
 update XPR00102 set AX_Due_Date=DATEADD(day,-1,@iFromDate)
 where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 
 and CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)
 and (AX_Start_Date<@iFromDate and AX_Due_Date>=@iFromDate) 
 if @@error<>0
 begin
 rollback transaction
 return
 end 
 
 update XPR00102 set AX_Start_Date=DATEADD(day,1,@iToDate)
 where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 
 and CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)
 and (AX_Start_Date<=@iToDate and AX_Due_Date>@iToDate) 
 if @@error<>0
 begin
 rollback transaction
 return
 end
 
 select * into ##XPRTemp6 from (SELECT DISTINCT CUSTNMBR,TXRGNNUM=(select substring(RM00101.TXRGNNUM,1,11) from RM00101 where RM00101.CUSTNMBR=XPR00102.CUSTNMBR),ADRSCODE,TAXDTLID FROM XPR00102  WHERE TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)and CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=XPR00102.CUSTNMBR) ) as T1 
 insert into ##XPRTemp6 select distinct CUSTNMBR,TXRGNNUM=(select substring(RM00101.TXRGNNUM,1,11) from RM00101 where RM00101.CUSTNMBR=RM00102.CUSTNMBR),ADRSCODE,TAXDTLID from RM00102 inner join TX00102 on RM00102.TAXSCHID=TX00102.TAXSCHID  where TX00102.TAXDTLID in  (select TAXDTLID from XPR00106 where NAME=@iFileName) and RM00102.CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=RM00102.CUSTNMBR)
 if @@error<>0
 begin
 rollback transaction
 return
 end
 
 delete from XPR00102
 where  AX_Tipo=2 and TAXDTLID in(select TAXDTLID from XPR00106 where NAME=@iFileName)
 and AX_Start_Date>=@iFromDate and AX_Due_Date<=@iToDate
 and CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)
 if @@error<>0
 begin
 rollback transaction
 return
 end
 end
 set @DefPerc=isnull((select PRCNTAGE from XPR00107),3)
 if @ProcessType=1 or @ProcessType=2
 BEGIN
 
 if @ProcessType=1 
 begin
 
 insert  into XPR00102(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date,AX_Due_Date,
 AX_Tipo,AX_Porcentaje)  select distinct ##XPRTemp6.CUSTNMBR,
 ##XPRTemp6.ADRSCODE,##XPRTemp6.TAXDTLID,@iFromDate,@iToDate,2,CAST(REPLACE(##XPRTemp1.PercPer,',','.') AS decimal(4,2))as PercPer from ##XPRTemp6 inner join ##XPRTemp1 on substring(##XPRTemp6.TXRGNNUM,1,11)=##XPRTemp1.TaxIDCode
 if @@error<>0
 begin
 rollback transaction
 return
 end
 
 insert into XPR00102(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date,AX_Due_Date,
 AX_Tipo,AX_Porcentaje)  select distinct ##XPRTemp6.CUSTNMBR,
 ##XPRTemp6.ADRSCODE,##XPRTemp6.TAXDTLID,@iFromDate,@iToDate,2,@DefPerc from ##XPRTemp6
 where  substring(##XPRTemp6.TXRGNNUM,1,11)
 not in (select ##XPRTemp1.TaxIDCode from ##XPRTemp1 where ##XPRTemp1.TaxIDCode=substring(##XPRTemp6.TXRGNNUM,1,11))
 and  substring(##XPRTemp6.TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5)
 if @@error<>0
 begin
 rollback transaction
 return
 end 
 end
 if  @ProcessType=2
 begin
 
 insert into XPR00102(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date,AX_Due_Date,
 AX_Tipo,AX_Porcentaje)  select distinct ##XPRTemp6.CUSTNMBR,
 ##XPRTemp6.ADRSCODE,##XPRTemp6.TAXDTLID,@iFromDate,@iToDate,2,@DefPerc from ##XPRTemp6
 if @@error<>0
 begin
 rollback transaction
 return
 end 
 end 
 
 if @@error<>0
 begin
 rollback transaction
 return
 end
 END

if @ProcessType=4
	BEGIN
		set @DefPerc=isnull((select PRCNTAGE from XPR00113),2)
	END

 if @ProcessType=3 or @ProcessType=4
 BEGIN
 create table ##XPRTemp3 (CUSTNMBR char(15),ADRSCODE char(15),TAXDTLID char(15), AX_Start_Date datetime,AX_Due_Date datetime,AX_Tipo char(2),AX_Porcentaje char(9))
 if @ProcessType=3
 begin
	select * into ##XPRTemp7 from (SELECT DISTINCT CUSTNMBR,TXRGNNUM=(select substring(RM00101.TXRGNNUM,1,11) from RM00101 where RM00101.CUSTNMBR=XPR00102.CUSTNMBR),ADRSCODE,TAXDTLID FROM XPR00102  WHERE TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)
	and CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)) as T1 
 
	 insert into ##XPRTemp7 select distinct CUSTNMBR,TXRGNNUM=(select substring(RM00101.TXRGNNUM,1,11) from RM00101 where RM00101.CUSTNMBR=RM00102.CUSTNMBR),ADRSCODE,TAXDTLID from RM00102 inner join TX00102 on RM00102.TAXSCHID=TX00102.TAXSCHID  where TX00102.TAXDTLID in  (select TAXDTLID from XPR00106 where NAME=@iFileName) and RM00102.CUSTNMBR in(select RM00101.CUSTNMBR from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=RM00102.CUSTNMBR)
	
	 insert into ##XPRTemp3(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date ,AX_Due_Date,AX_Tipo,AX_Porcentaje)
	 (select distinct ##XPRTemp7.CUSTNMBR ,
	 ADRSCODE,##XPRTemp7.TAXDTLID,@iFromDate as AX_Start_Date,@iToDate as AX_Due_Date,2 as AX_Tipo,CAST(REPLACE(##XPRTemp1.PercPer,',','.') AS decimal(4,2))as AX_Porcentaje from ##XPRTemp7 inner join ##XPRTemp1 on substring(##XPRTemp7.TXRGNNUM,1,11)=##XPRTemp1.TaxIDCode) 
 
	 if @@error<>0
	 begin
	 rollback transaction
	 return
	 end
 end
if @ProcessType=4
begin
	create table ##XPRTemp10 (CUSTNMBR char(15),ADRSCODE char(15),TAXDTLID char(15),	AX_Start_Date datetime,AX_Due_Date datetime,AX_Tipo char(2),AX_Porcentaje char(9))
	DECLARE TAXDETAILS CURSOR FOR 
	select TAXDTLID from XPR00106 where NAME=@iFileName
	OPEN TAXDETAILS 
	FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
	WHILE (@@FETCH_STATUS=0) 
	BEGIN 
		insert into ##XPRTemp3(CUSTNMBR,ADRSCODE,TAXDTLID, AX_Start_Date,AX_Due_Date,AX_Tipo,AX_Porcentaje)
		(select RM00101.CUSTNMBR as CUSTNUM,ADRSCODE,
		@TAXDTLID as TAXDTLID,@iFromDate as AX_Start_Date,@iToDate as AX_Due_Date,
		2,@DefPerc as AX_Tipo from RM00101 inner join ##XPRTemp1 on
		substring(RM00101.TXRGNNUM,1,11)=##XPRTemp1.TaxIDCode and RM00101.CUSTNMBR in(SELECT CUSTNMBR from RM00101 where TAXSCHID in 
	(select TAXSCHID from TX00102 where TAXDTLID = @TAXDTLID)))
		
		insert into ##XPRTemp10(CUSTNMBR,ADRSCODE,TAXDTLID, AX_Start_Date,AX_Due_Date,AX_Tipo,AX_Porcentaje)
		(select RM00101.CUSTNMBR as CUSTNUM,ADRSCODE,
		@TAXDTLID as TAXDTLID,@iFromDate as AX_Start_Date,@iToDate as AX_Due_Date,
		2,@DefPerc as AX_Tipo from RM00101 inner join ##XPRTemp1 on
		substring(RM00101.TXRGNNUM,1,11)=##XPRTemp1.TaxIDCode)
		if @@error<>0
			begin
			rollback transaction
			return
		end

	FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
	END
	CLOSE TAXDETAILS 
	DEALLOCATE TAXDETAILS
end
 select * into ##XPRTemp4 from (select [CUSTNMBR] ,[ADRSCODE],[TAXDTLID] ,[AX_Start_Date],[AX_Due_Date] ,
 [AX_Tipo] , [AX_Porcentaje]  from XPR00102 
 where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 
 and CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)
 and ((AX_Start_Date<@iFromDate and AX_Due_Date>=@iFromDate)  or( AX_Start_Date>@iFromDate and AX_Start_Date<@iToDate and AX_Due_Date>@iToDate)
 or( AX_Start_Date>=@iFromDate and AX_Due_Date<=@iToDate)))as t1
 
 if @@error<>0
 begin
 rollback transaction
 return
 end
 
 update XPR00102 set AX_Due_Date=DATEADD(day,-1,@iFromDate)
 where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 
 and XPR00102.CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)
 and (XPR00102.AX_Start_Date<@iFromDate and XPR00102.AX_Due_Date>=@iFromDate) 
 if @@error<>0
 begin
 rollback transaction
 return
 end 
 
 update XPR00102 set AX_Start_Date=DATEADD(day,1,@iToDate)
 where AX_Tipo=2 and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 
 and CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)
 and (AX_Start_Date<=@iToDate and AX_Due_Date>@iToDate) 
 if @@error<>0
 begin
 rollback transaction
 return
 end
 
 delete from XPR00102
 where  AX_Tipo=2 and TAXDTLID in(select TAXDTLID from XPR00106 where NAME=@iFileName)
 and AX_Start_Date>=@iFromDate and AX_Due_Date<=@iToDate
 and CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR)
 if @@error<>0
 begin
 rollback transaction
 return
 end
 if @ProcessType=3
 begin
	 insert  into XPR00102(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date,AX_Due_Date,
	 AX_Tipo,AX_Porcentaje,HR)  select ##XPRTemp3.CUSTNMBR,##XPRTemp3.ADRSCODE,
	 ##XPRTemp3.TAXDTLID,@iFromDate,@iToDate,2,AX_Porcentaje,1 from ##XPRTemp3
	 if @@error<>0
	 begin
	 rollback transaction
	 return
	 end
 end
if @ProcessType=4
begin
	insert into XPR00102(CUSTNMBR,ADRSCODE,TAXDTLID,AX_Start_Date,AX_Due_Date,AX_Tipo,AX_Porcentaje) 
	(select DISTINCT(##XPRTemp3.CUSTNMBR),##XPRTemp3.ADRSCODE,##XPRTemp3.TAXDTLID,@iFromDate,@iToDate,2,@DefPerc from ##XPRTemp3 where ##XPRTemp3.CUSTNMBR in
	(SELECT CUSTNMBR from RM00101 where TAXSCHID in 
	(select TAXSCHID from TX00102 where TAXDTLID in
	(select TAXDTLID from XPR00106 where NAME=@iFileName))))
	 if @@error<>0
	 begin
	 rollback transaction
	 return
	 end
	 delete from XPR00114
	 insert into XPR00114 (CUSTNMBR,XPR_MonoHighRisk,CUSTNAME)
	(select distinct(##XPRTemp3.CUSTNMBR),1,RM00101.CUSTNAME from ##XPRTemp3,RM00101 where ##XPRTemp3.CUSTNMBR=RM00101.CUSTNMBR)/* and XPR00102.CUSTNMBR not in (select CUSTNMBR from XPR00114))*/
     
if @@error<>0
	 begin
	 rollback transaction
	 return
	 end
end
END
 if @ProcessType=1 or @ProcessType=2
 Begin
 
 delete from XPR00108
 insert into XPR00108(CUSTNMBR,CUSTNAME,TXRGNNUM,ADRSCODE, TAXDTLID,XPR_OldPercentage,AX_Porcentaje,From_Date,TODATE)
 select XPR00102.CUSTNMBR,CUSTNAME=(select CUSTNAME  from  RM00101 where substring(TXRGNNUM,24,2)<>''  and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),TXRGNNUM=(select substring(TXRGNNUM,1,11)  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),
 XPR00102.ADRSCODE,XPR00102.TAXDTLID,
 isnull(##XPRTemp2.AX_Porcentaje,0),XPR00102.AX_Porcentaje,@iFromDate,@iToDate from XPR00102 left outer join ##XPRTemp2 on 
 XPR00102.CUSTNMBR=##XPRTemp2.CUSTNMBR and XPR00102.ADRSCODE=##XPRTemp2.ADRSCODE and XPR00102.TAXDTLID=##XPRTemp2.TAXDTLID
 and XPR00102.AX_Tipo=##XPRTemp2.AX_Tipo
 where XPR00102.AX_Tipo=2  and XPR00102.CUSTNMBR in(select CUSTNMBR  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##XPRTemp5) and RM00101.CUSTNMBR=XPR00102.CUSTNMBR)
 and  XPR00102.AX_Start_Date=@iFromDate and XPR00102.AX_Due_Date=@iToDate and 
 XPR00102.TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 

 if @@error<>0
 begin
 rollback transaction
 return
 end
 update XPR00102 set XPR00102.AX_Organismo= ##XPRTemp2.AX_Organismo,XPR00102.AX_Certificado_Entregado=##XPRTemp2.AX_Certificado_Entregado
from XPR00102 inner join ##XPRTemp2 on XPR00102.CUSTNMBR=##XPRTemp2.CUSTNMBR and XPR00102.ADRSCODE=##XPRTemp2.ADRSCODE and XPR00102.TAXDTLID=##XPRTemp2.TAXDTLID 
and  XPR00102.AX_Start_Date=##XPRTemp2.AX_Start_Date and XPR00102.AX_Due_Date=##XPRTemp2.AX_Due_Date and XPR00102.AX_Tipo=##XPRTemp2.AX_Tipo
if @@error<>0
begin
rollback transaction
return
end
delete from XPR00109
 insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)
 select CUSTNMBR,CUSTNAME,1 from RM00101 where substring(TXRGNNUM,24,2)=''

 insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)
 select CUSTNMBR,CUSTNAME,2 from RM00101 where substring(TXRGNNUM,24,2)<>''
 and CUSTNMBR not in(select CUSTNMBR from XPR00102 where XPR00102.CUSTNMBR=RM00101.CUSTNMBR and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName))
 
 insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)
 select CUSTNMBR,CUSTNAME,3 from RM00101 where substring(TXRGNNUM,24,2)<>''
 and substring(TXRGNNUM,1,11)  in(select TaxIDCode from ##XPRTemp5)
 
 if @@error<>0
 begin
 rollback transaction
 return
 end
 End
 if @ProcessType=3 
 begin
delete from XPR00108
 insert into XPR00108(CUSTNMBR,CUSTNAME,TXRGNNUM,ADRSCODE,TAXDTLID, XPR_OldPercentage,AX_Porcentaje,From_Date,TODATE)
 select XPR00102.CUSTNMBR,CUSTNAME=(select CUSTNAME  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),TXRGNNUM=(select substring(TXRGNNUM,1,11)  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),
 XPR00102.ADRSCODE,XPR00102.TAXDTLID,
 isnull(##XPRTemp4.AX_Porcentaje,0),XPR00102.AX_Porcentaje,@iFromDate,@iToDate from XPR00102 left outer join ##XPRTemp4 on 
 XPR00102.CUSTNMBR=##XPRTemp4.CUSTNMBR and XPR00102.ADRSCODE=##XPRTemp4.ADRSCODE and XPR00102.TAXDTLID=##XPRTemp4.TAXDTLID
 and XPR00102.AX_Tipo=##XPRTemp4.AX_Tipo
 where XPR00102.AX_Tipo=2 and  XPR00102.AX_Start_Date=@iFromDate and XPR00102.AX_Due_Date=@iToDate
 and XPR00102.CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR) 
 and XPR00102.TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 

 if @@error<>0
 begin
 rollback transaction
 return
 end
delete from XPR00109
 insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)
 select CUSTNMBR,RM00101.CUSTNAME,2 from RM00101 inner join ##XPRTemp1 on   substring(RM00101.TXRGNNUM,1,11)=##XPRTemp1.TaxIDCode
 where substring(TXRGNNUM,24,2)<>''
 and CUSTNMBR not in(select CUSTNMBR from XPR00102 where XPR00102.CUSTNMBR=RM00101.CUSTNMBR and TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName))
 
 insert into XPR00109(CUSTNMBR,CUSTNAME,XPR_Reason)
 select CUSTNMBR,CUSTNAME,3 from RM00101 where substring(TXRGNNUM,24,2)<>''
 and substring(TXRGNNUM,1,11)  in(select TaxIDCode from ##XPRTemp5)
 
 if @@error<>0
 begin
 rollback transaction
 return
 end
 end

if @ProcessType=4
begin
	delete from XPR00108
	insert into XPR00108(CUSTNMBR,CUSTNAME,TXRGNNUM,ADRSCODE,TAXDTLID, XPR_OldPercentage,AX_Porcentaje,From_Date,TODATE)
	select XPR00102.CUSTNMBR,CUSTNAME=(select CUSTNAME  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),TXRGNNUM=(select substring(TXRGNNUM,1,11)  from  RM00101 where substring(TXRGNNUM,24,2)<>'' and RM00101.CUSTNMBR=XPR00102.CUSTNMBR),
	XPR00102.ADRSCODE,XPR00102.TAXDTLID,
	isnull(##XPRTemp4.AX_Porcentaje,0),XPR00102.AX_Porcentaje,@iFromDate,@iToDate from XPR00102 left outer join ##XPRTemp4 on 
	XPR00102.CUSTNMBR=##XPRTemp4.CUSTNMBR and XPR00102.ADRSCODE=##XPRTemp4.ADRSCODE and XPR00102.TAXDTLID=##XPRTemp4.TAXDTLID
	and XPR00102.AX_Tipo=##XPRTemp4.AX_Tipo
	where XPR00102.AX_Tipo=2 and  XPR00102.AX_Start_Date=@iFromDate and XPR00102.AX_Due_Date=@iToDate
	and XPR00102.CUSTNMBR in(select ##XPRTemp3.CUSTNMBR from  ##XPRTemp3 where  ##XPRTemp3.CUSTNMBR=XPR00102.CUSTNMBR) 
	and XPR00102.TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName) 

	if @@error<>0
	 begin
	 rollback transaction
	 return
	 end
	delete from XPR00109
	create table ##XPRTemp8(CUSTNMBR char(15),CUSTNAME char(60),TAXSCHID char(15))
	insert into ##XPRTemp8(CUSTNMBR,CUSTNAME,TAXSCHID)
	(select CUSTNMBR,CUSTNAME,TAXSCHID from RM00101 where TAXSCHID in(select  TAXSCHID from TX00102 where TAXDTLID in (select TAXDTLID from XPR00106 where NAME=@iFileName)))
  	insert into XPR00109 (CUSTNMBR,CUSTNAME,XPR_Reason)
	(select distinct (RM00101.CUSTNMBR),RM00101.CUSTNAME,4 from RM00101,##XPRTemp10 where ##XPRTemp10.CUSTNMBR=RM00101.CUSTNMBR and ##XPRTemp10.CUSTNMBR not in (select CUSTNMBR from ##XPRTemp3) 
	)
	insert into XPR00109 (CUSTNMBR,CUSTNAME,XPR_Reason)
	(select distinct(CUSTNMBR), CUSTNAME,5 from ##XPRTemp8 where CUSTNMBR  not in (select CUSTNMBR from XPR00108))
	if @@error<>0
	 begin
	 rollback transaction
	 return
	 end
	/*update XPR00114 set XPR_MonoHighRisk=0 where CUSTNMBR not in (select CUSTNMBR from XPR00108)*/
	if @@error<>0
	begin
	rollback transaction
	return
	end
end

 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp1')
 DROP TABLE ##XPRTemp1 
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp2')
 DROP TABLE ##XPRTemp2
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp3')
 DROP TABLE ##XPRTemp3
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp4')
 DROP TABLE ##XPRTemp4
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp5')
 DROP TABLE ##XPRTemp5
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp6')
 DROP TABLE ##XPRTemp6
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp8')
 DROP TABLE ##XPRTemp8
 IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XPRTemp10')
 DROP TABLE ##XPRTemp10

 commit transaction T1;
 end
end 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XPRUpdatePerceptionTax] TO [DYNGRP] 
GO 

/*End_XPRUpdatePerceptionTax*/
/*Begin_XPR_Check_Unit_Price_Threshold*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XPR_Check_Unit_Price_Threshold]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].XPR_Check_Unit_Price_Threshold
GO

CREATE PROCEDURE [dbo].[XPR_Check_Unit_Price_Threshold]   
@Taxdltid   char(20),
@TaxSchID	char(20),
@UnitPrice   float,
@O_IsThreshTax	tinyint	output
as
declare @ThreshUnitPrice float
declare @ExcludeTax   tinyint
declare @TaxDetailBase smallint
declare @ExcludeUnitPrice float
declare	@SumTxDtlPct	float
BEGIN
if (select count(*) from XPR00111 where TAXDTLID=@Taxdltid )<=0
begin
set	@O_IsThreshTax=0
return	
end
select @ThreshUnitPrice=XPR_Thresh_UnitPrice,@ExcludeTax=XPR_Exclude_Tax from XPR00110 where XPR_ThresholdID in (select XPR_ThresholdID from XPR00111 where TAXDTLID=@Taxdltid)
if @UnitPrice<@ThreshUnitPrice
begin
set	@O_IsThreshTax=0
return
end
else
begin
if @ExcludeTax=1
begin
select @SumTxDtlPct=sum(TXDTLPCT)from TX00201 where TXDTLBSE=1 and TAXDTLID in (select TAXDTLID from TX00102 where TAXSCHID=@TaxSchID)
if @SumTxDtlPct>0
begin
set @ExcludeUnitPrice=@UnitPrice*100/(@SumTxDtlPct+100)
if @ExcludeUnitPrice>=@ThreshUnitPrice
begin
set	@O_IsThreshTax=1
return
end
else
begin
set	@O_IsThreshTax=0
return
end
end
end		
set	@O_IsThreshTax=1
return 
end					
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XPR_Check_Unit_Price_Threshold] TO [DYNGRP] 
GO 
/*End_XPR_Check_Unit_Price_Threshold*/
/*Begin_XPR_Calc_Perc_Exclude_Tax*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XPR_Calc_Perc_Exclude_Tax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].XPR_Calc_Perc_Exclude_Tax
GO

CREATE PROCEDURE [dbo].[XPR_Calc_Perc_Exclude_Tax]   
@Taxdltid   char(20),
@DocDate	datetime,
@DocNumber	char(21),
@CustNumber	char(16),
@SalesAmt	float,
@TradeDiscAmt float,
@FreightAmt float,
@MiscAmt	float,
@TaxAmt		float,
@O_IsThreshTax	tinyint	output
as
declare @ThresholdAmt float
declare @ThresholdID  char(21)
declare @ThreshPeriodType smallint, @ThreshPeriodDur  smallint
declare	@IncludeCurrentMonth tinyint,@InclCurrInv tinyint ,@CalcTaxOn	tinyint,@InclSales tinyint,@InclTradeDisc tinyint,@InclFreight tinyint,@InclTax tinyint,@InclMisc tinyint
declare   @StartDate datetime,@EndDate  datetime
declare @Exclude_PrevMonth tinyint, @Exclude_Months smallint
BEGIN
if (select count(*) from XPR00111 where TAXDTLID=@Taxdltid )<=0
begin
set	@O_IsThreshTax=0
return	
end
set @ThresholdID=(select XPR_ThresholdID from XPR00111  where TAXDTLID =@Taxdltid)
select @Exclude_Months = XPR_Exclude_Months, @Exclude_PrevMonth = XPR_Exclude_PrevMonth, @CalcTaxOn=XPR_Calc_Tax_On,@ThreshPeriodType=XPR_Thresh_Period_Type,@ThreshPeriodDur=XPR_Thresh_Period_Dur,@IncludeCurrentMonth=XPR_Current_Month,@InclCurrInv=XPR_Incl_Curr_Inv,@InclSales=XPR_Include_Sales,@InclTradeDisc=XPR_Include_TradeDisc,@InclFreight=XPR_Include_Freight,@InclTax=XPR_Include_Taxes,@InclMisc=XPR_Include_Misc from XPR00110 where XPR_ThresholdID=@ThresholdID
if @CalcTaxOn=1
begin
set	@O_IsThreshTax=1
return
end
if @ThreshPeriodType=1 
	begin
	if @IncludeCurrentMonth=1
		begin
		set @StartDate=(select DATEADD(month,-(@ThreshPeriodDur-1),@DocDate)-(select day(@DocDate))+1)
		set @EndDate=@DocDate
		end
	else if @Exclude_PrevMonth = 1
		begin
		set @StartDate=(select DATEADD(month,-(@ThreshPeriodDur+@Exclude_Months),@DocDate)-(select day(@DocDate))+1)  
		set @EndDate= (select DATEADD(month,-@Exclude_Months,@DocDate)-(select day(@DocDate)))
		end
	else
		begin
		set @StartDate=(select DATEADD(month,-@ThreshPeriodDur,@DocDate)-(select day(@DocDate))+1)
		set @EndDate=(@DocDate-(select day(@DocDate)))
		end
	end
else
	begin
	if @IncludeCurrentMonth=1
		begin
		set @StartDate=(@DocDate-(@ThreshPeriodDur)+1)
		set @EndDate=@DocDate
		end
	else if @Exclude_PrevMonth = 1
		begin
		set @StartDate=(@DocDate-(@ThreshPeriodDur+@Exclude_Months+1))
		set @EndDate=(@DocDate-(@Exclude_Months+1))
		end
	else
		begin
		set @StartDate=(@DocDate-(@ThreshPeriodDur))
		set @EndDate=(@DocDate-1)
		end
	end
if (@InclSales)>0
begin
set @ThresholdAmt=isnull((select SUM(SLSAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(SLSAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(SLSAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(SLSAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@SalesAmt
end
if (@InclTradeDisc)>0
begin
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TRDISAMT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TRDISAMT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TRDISAMT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TRDISAMT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt-@TradeDiscAmt
end
if (@InclFreight)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(FRTAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(FRTAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(FRTAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(FRTAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@FreightAmt
end
if (@InclTax)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TAXAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TAXAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TAXAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TAXAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@TaxAmt
end
if (@InclMisc)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(MISCAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(MISCAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(MISCAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(MISCAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@MiscAmt
end

if @ThresholdAmt>=(select  XPR_Thresh_Amt from XPR00110 where XPR_ThresholdID =@ThresholdID)
set @O_IsThreshTax=0
else
set @O_IsThreshTax=1	

END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XPR_Calc_Perc_Exclude_Tax] TO [DYNGRP] 
GO 
/*End_XPR_Calc_Perc_Exclude_Tax*/
/*Begin_XPRFindThreshTaxes*/

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XPRFindThreshTaxes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XPRFindThreshTaxes]
go

create  procedure XPRFindThreshTaxes 
@SOPNum		char(21),
@SOPType	smallint,
@TaxSchID	char(15),
@DocDate	datetime,
@GLPostDate	datetime,
@CustNumber	char(16),
@SalesAmt	float,
@TradeDiscAmt float,
@FreightAmt float,
@MiscAmt	float,
@TaxAmt		float,
@IsRMorSOP   tinyint,
@O_IsThreshTax	tinyint	output,
@O_SQL_Error_State int = NULL  output

as
declare @ThresholdAmt  float
declare @ThresholdID  char(21)
declare @ThreshPeriodType smallint, @ThreshPeriodDur  smallint
declare	@IncludeCurrentMonth tinyint,@InclCurrInv tinyint, @CalcTaxOn	tinyint,@InclSales tinyint,@InclTradeDisc tinyint,@InclFreight tinyint,@InclTax tinyint,@InclMisc tinyint
declare @StartDate datetime,@EndDate datetime
declare @Exclude_PrevMonth tinyint, @Exclude_Months smallint
begin
if(select count(*) from TX00102 where TAXSCHID=@TaxSchID and TX00102.TAXDTLID in (select TAXDTLID from XPR00111 where TAXDTLID=TX00102.TAXDTLID))<=0 
begin
set @O_IsThreshTax=0
return
end
set @ThresholdID=(select XPR_ThresholdID from XPR00110 where XPR_ThresholdID in (select TOP 1 XPR_ThresholdID from XPR00111 where TAXDTLID in(select TAXDTLID from TX00102 where TAXSCHID=@TaxSchID )))
select @Exclude_Months = XPR_Exclude_Months, @Exclude_PrevMonth = XPR_Exclude_PrevMonth, @CalcTaxOn=XPR_Calc_Tax_On,@ThreshPeriodType=XPR_Thresh_Period_Type,@ThreshPeriodDur=XPR_Thresh_Period_Dur,@IncludeCurrentMonth=XPR_Current_Month,@InclCurrInv=XPR_Incl_Curr_Inv,@InclSales=XPR_Include_Sales,@InclTradeDisc=XPR_Include_TradeDisc,@InclFreight=XPR_Include_Freight,@InclTax=XPR_Include_Taxes,@InclMisc=XPR_Include_Misc from XPR00110 where XPR_ThresholdID=@ThresholdID
if @CalcTaxOn = 0
	begin
	if @ThreshPeriodType=1   
		begin  
		if @IncludeCurrentMonth=1  
			begin  
			set @StartDate=(select DATEADD(month,-(@ThreshPeriodDur-1),@DocDate)-(select day(@DocDate))+1)  
			set @EndDate=@DocDate  
			end  
		else if @Exclude_PrevMonth = 1
			begin
			set @StartDate=(select DATEADD(month,-(@ThreshPeriodDur+@Exclude_Months),@DocDate)-(select day(@DocDate))+1)  
			set @EndDate= (select DATEADD(month,-@Exclude_Months,@DocDate)-(select day(@DocDate)))
			end
		else  
			begin  
			set @StartDate=(select DATEADD(month,-@ThreshPeriodDur,@DocDate)-(select day(@DocDate))+1)  
			set @EndDate=(@DocDate-(select day(@DocDate)))  
			end  
		end  
	else  
		begin  
		if @IncludeCurrentMonth=1  
			begin  
			set @StartDate=(@DocDate-(@ThreshPeriodDur)+1)  
			set @EndDate=@DocDate  
			end  
		else if @Exclude_PrevMonth = 1
			begin
			set @StartDate=(@DocDate-(@ThreshPeriodDur+@Exclude_Months+1))  
			set @EndDate=(@DocDate-(@Exclude_Months+1))  
			end
		else  
			begin  
			set @StartDate=(@DocDate-(@ThreshPeriodDur))  
			set @EndDate=(@DocDate-1)  
			end  
		end  
	end
else if @CalcTaxOn = 1
begin 
	if @ThreshPeriodType=1   
	begin  
		if @IncludeCurrentMonth=1  
		begin  
		set @StartDate=(select DATEADD(month,-(@ThreshPeriodDur-1),@GLPostDate)-(select day(@GLPostDate))+1)  
		set @EndDate=@GLPostDate  
		end  
	else if @Exclude_PrevMonth = 1
		begin
		set @StartDate=(select DATEADD(month,-(@ThreshPeriodDur+@Exclude_Months),@GLPostDate)-(select day(@GLPostDate))+1)  
		set @EndDate= (select DATEADD(month,-@Exclude_Months,@GLPostDate)-(select day(@GLPostDate)))
		end
	else  
		begin  
		set @StartDate=(select DATEADD(month,-@ThreshPeriodDur,@GLPostDate)-(select day(@GLPostDate))+1)  
		set @EndDate=(@GLPostDate-(select day(@GLPostDate)))  
		end  
	end  
	else  
	begin  
	if @IncludeCurrentMonth=1  
		begin  
		set @StartDate=(@GLPostDate-(@ThreshPeriodDur)+1)  
		set @EndDate=@GLPostDate  
		end  
	else if @Exclude_PrevMonth = 1
		begin
		set @StartDate=(@GLPostDate-(@ThreshPeriodDur+@Exclude_Months+1))  
		set @EndDate=(@GLPostDate-(@Exclude_Months+1))
		end
	else  
		begin  
		set @StartDate=(@GLPostDate-(@ThreshPeriodDur))  
		set @EndDate=(@GLPostDate-1)  
		end  
	end  
end
if @CalcTaxOn=0
begin
if (@InclSales)>0
begin
set @ThresholdAmt=isnull((select SUM(SLSAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(SLSAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(SLSAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(SLSAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@SalesAmt
end
if (@InclTradeDisc)>0
begin
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TRDISAMT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TRDISAMT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TRDISAMT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TRDISAMT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt-@TradeDiscAmt
end
if (@InclFreight)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(FRTAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(FRTAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(FRTAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(FRTAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@FreightAmt
end
if (@InclTax)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TAXAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TAXAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TAXAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TAXAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@TaxAmt
end
if (@InclMisc)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(MISCAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(MISCAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(MISCAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(MISCAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and DOCDATE BETWEEN @StartDate and @EndDate ),0)

if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@MiscAmt
end
end
else if @CalcTaxOn=1
begin
if (@InclSales)>0
begin
set @ThresholdAmt=isnull((select SUM(SLSAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(SLSAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(SLSAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(SLSAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@SalesAmt
end
if (@InclTradeDisc)>0
begin
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TRDISAMT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TRDISAMT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TRDISAMT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TRDISAMT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt-@TradeDiscAmt
end
if (@InclFreight)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(FRTAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(FRTAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(FRTAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(FRTAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@FreightAmt
end
if (@InclTax)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TAXAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(TAXAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TAXAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(TAXAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@TaxAmt
end
if (@InclMisc)>0
begin
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(MISCAMNT) from RM20101 where CUSTNMBR=@CustNumber	and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt+isnull((select SUM(MISCAMNT) from RM30101 where CUSTNMBR=@CustNumber and RMDTYPAL<=5 and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(MISCAMNT) from RM20101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
set @ThresholdAmt=@ThresholdAmt-isnull((select SUM(MISCAMNT) from RM30101 where CUSTNMBR=@CustNumber and (RMDTYPAL=7 or RMDTYPAL=8 ) and VOIDSTTS=0 and GLPOSTDT BETWEEN @StartDate and @EndDate ),0)
if @InclCurrInv>0 
set @ThresholdAmt=@ThresholdAmt+@MiscAmt
end
end
set @ThresholdAmt=isnull(@ThresholdAmt,0)
if @ThresholdAmt>=(select  XPR_Thresh_Amt from XPR00110 where XPR_ThresholdID =@ThresholdID)
begin
set @O_IsThreshTax=1
return
end
else
begin
if (@IsRMorSOP=1)
begin
if(select count(*)from RM10601 where RMDTYPAL=@SOPType and DOCNUMBR=@SOPNum and TAXAMNT<>0 and  TAXDTLID in (select TAXDTLID from XPR00111 where XPR_ThresholdID=@ThresholdID))>0
begin
set @O_IsThreshTax=2
return
end	
end		
else if(@IsRMorSOP=2)
begin
if(select count(*)from SOP10105 where SOPTYPE=@SOPType and SOPNUMBE=@SOPNum and STAXAMNT>0 and  TAXDTLID in (select TAXDTLID from XPR00111 where XPR_ThresholdID=@ThresholdID))>0
begin
set @O_IsThreshTax=2
return
end
end				
set @O_IsThreshTax=0
end	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XPRFindThreshTaxes] TO [DYNGRP] 
GO
 		
/*End_XPRFindThreshTaxes*/
/*Begin_XPR_Check_Is_MonoContributor*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XPR_Check_Is_MonoContributor]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].XPR_Check_Is_MonoContributor
GO

CREATE PROCEDURE [dbo].[XPR_Check_Is_MonoContributor]   
@TaxSchID	char(20),
@SalesSchID char(20),
@IsAddnl	tinyint,
@O_IsMonoContributor	tinyint	output
as
BEGIN
if @IsAddnl=1
BEGIN
if (select count(*) from TX00102 where TAXSCHID=@TaxSchID and TX00102.TAXDTLID in (select XPR00111.TAXDTLID from XPR00111 where XPR00111.TAXDTLID=TX00102.TAXDTLID))>0
if (select count(*) from TX00102 where TAXSCHID=@SalesSchID and TX00102.TAXDTLID in (select XPR00111.TAXDTLID from XPR00111 where XPR00111.TAXDTLID=TX00102.TAXDTLID ))>0
set @O_IsMonoContributor=1
END
ELSE
BEGIN
if (select count(*) from TX00102 where TAXSCHID=@TaxSchID and TX00102.TAXDTLID in (select XPR00111.TAXDTLID from XPR00111 where XPR00111.TAXDTLID=TX00102.TAXDTLID and XPR00111.XPR_ThresholdID in(select XPR00110.XPR_ThresholdID from XPR00110 where XPR00110.XPR_ThresholdID=XPR00111.XPR_ThresholdID and XPR_Disp_Unit_Price=1)))>0
if (select count(*) from TX00102 where TAXSCHID=@SalesSchID and TX00102.TAXDTLID in (select XPR00111.TAXDTLID from XPR00111 where XPR00111.TAXDTLID=TX00102.TAXDTLID and XPR00111.XPR_ThresholdID in(select XPR00110.XPR_ThresholdID from XPR00110 where XPR00110.XPR_ThresholdID=XPR00111.XPR_ThresholdID and XPR_Disp_Unit_Price=1)))>0
set @O_IsMonoContributor=1
END
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XPR_Check_Is_MonoContributor] TO [DYNGRP] 
GO 
/*End_XPR_Check_Is_MonoContributor*/

