/*Count : 15 */
 
set DATEFORMAT ymd 
GO 
 
/*Begin_XDL_CAE_Export_Redisplay*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XDL_CAE_Export_Redisplay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XDL_CAE_Export_Redisplay]
go

create  procedure XDL_CAE_Export_Redisplay 
@TBName1 varchar(25),
@TBName2 varchar(25),
@FromDate   char(10),
@ToDate           char(10),
@LetterA    tinyint,
@LetterB    tinyint,
@LetterE    tinyint,
@Xml  int,
@DocInvoice tinyint,
@DocReturn  tinyint,
@PointOfSaleFrom  char(5),
@PointOfSaleTo          char(5),
@InvSiteFrom            char(11),
@InvSiteTo              char(11),
@DispCAEStatus          tinyint,
@SortBy                       tinyint,
@PackListLetter         char(31),
@InvoiceLetter          char(31),
@CreditNoteLetter char(31),
@DebitNoteLetter  char(31),

@O_SQL_Error_State int = NULL  output

as
begin
DECLARE @ExecStr  varchar(8000)
DECLARE     @CountRecords     int   
IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##XDLTemp1')
      DROP TABLE ##XDLTemp1 
EXEC('select * into ##XDLTemp1 from '+@TBName1)
EXEC('delete from '+@TBName1)
if @Xml=0
BEGIN
set @ExecStr='insert into '+@TBName1+'
select 0,SOP30200.DOCDATE,SOP30200.SOPTYPE,SOP30200.DOCID,XDL10101.XDL_Letra_Documento,XDL_GP_DocNumber,CUSTNMBR,DOCAMNT,ORDOCAMT,1,
CUSTNAME,XDL_Punto_de_venta,SITECODE,CURNCYID,CURRNIDX,SUBTOTAL,ORSUBTOT,TRDISAMT,ORTDISAM,FRTAMNT,ORFRTAMT,MISCAMNT,ORMISCAMT,TAXAMNT,ORTAXAMT,XDL_DocNumber
from SOP30200 inner join XDL10101 on SOP30200.SOPNUMBE=XDL10101.XDL_DocNumber and SOP30200.SOPTYPE=XDL10101.SOPTYPE where  
SOP30200.DOCID in (select DOCID from '+@TBName2+' where ISCHECK=1)'
if @DispCAEStatus=3 
set @ExecStr=@ExecStr+' and XDL10101.XDL_GP_DocNumber not in (select XDL_DocNumber from XDL10114 where XDL10114.XDL_DocNumber=XDL10101.XDL_GP_DocNumber and XDL10114.DOCTYPE=XDL10101.SOPTYPE and XDL_CAE_Status>3 ) '
else if @DispCAEStatus=0 
set @ExecStr=@ExecStr+' and XDL10101.XDL_GP_DocNumber not in (select XDL_DocNumber from XDL10114 where XDL10114.XDL_DocNumber=XDL10101.XDL_GP_DocNumber and XDL10114.DOCTYPE=XDL10101.SOPTYPE and XDL_CAE_Status>1) '         
else if @DispCAEStatus=1 
set @ExecStr=@ExecStr+' and XDL10101.XDL_GP_DocNumber  in (select XDL_DocNumber from XDL10114 where XDL10114.XDL_DocNumber=XDL10101.XDL_GP_DocNumber and XDL10114.DOCTYPE=XDL10101.SOPTYPE and XDL_CAE_Status=2)'
else if @DispCAEStatus=2 
set @ExecStr=@ExecStr+' and XDL10101.XDL_GP_DocNumber  in (select XDL_DocNumber from XDL10114 where XDL10114.XDL_DocNumber=XDL10101.XDL_GP_DocNumber and XDL10114.DOCTYPE=XDL10101.SOPTYPE and XDL_CAE_Status=3)'
if @FromDate>'00/00/0000'
set @ExecStr=@ExecStr+' and  SOP30200.DOCDATE >=''' + rtrim(@FromDate) + ''''
if @ToDate>'00/00/0000'
set @ExecStr=@ExecStr+' and SOP30200.DOCDATE<= ''' +rtrim(@ToDate)  + ''''
if @LetterA=1 and @LetterB=1
set @ExecStr=@ExecStr+' and (XDL10101.XDL_Letra_Documento="A" or XDL10101.XDL_Letra_Documento="B") '
else if @LetterA=1
set @ExecStr=@ExecStr+'and XDL10101.XDL_Letra_Documento="A" '
else if  @LetterB=1
set @ExecStr=@ExecStr+'and XDL10101.XDL_Letra_Documento="B" '
if @DocInvoice=1 and @DocReturn=1
set @ExecStr=@ExecStr+' and (SOP30200.SOPTYPE=3 or SOP30200.SOPTYPE=4) '
else if @DocInvoice=1
set @ExecStr=@ExecStr+' and SOP30200.SOPTYPE=3 '
else if     @DocReturn=1
set @ExecStr=@ExecStr+' and SOP30200.SOPTYPE=4 '
if @PointOfSaleFrom<>'' and @PointOfSaleTo<>''
set @ExecStr=@ExecStr+' and XDL10101.XDL_Punto_de_venta>='''+rtrim(@PointOfSaleFrom)+''' and XDL10101.XDL_Punto_de_venta<= '''+rtrim(@PointOfSaleTo)+''''
if @InvSiteFrom<>'' and @InvSiteTo<>''
set @ExecStr=@ExecStr+' and XDL10101.SITECODE>='''+rtrim(@InvSiteFrom)+''' and XDL10101.SITECODE<='''+rtrim(@InvSiteTo)+''''
set @ExecStr=@ExecStr+' and exists(select 1 from XDL00101 where XDL00101.XDL_Punto_de_venta=XDL10101.XDL_Punto_de_venta
 and( XDL00101.XDL_Tipo_Documento=XDL10101.XDL_Tipo_Documento 
or XDL00101.XDL_Tipo_Documento=(case when substring(XDL10101.XDL_GP_DocNumber,1,2)="FC" and XDL10101.XDL_Tipo_Documento='''+@PackListLetter +''' then '''+@InvoiceLetter+'''    
      when substring(XDL10101.XDL_GP_DocNumber,1,2)="ND" and XDL10101.XDL_Tipo_Documento='''+@PackListLetter+''' then '''+@DebitNoteLetter+'''
      when substring(XDL10101.XDL_GP_DocNumber,1,2)="NC" and XDL10101.XDL_Tipo_Documento='''+@PackListLetter+''' then '''+@CreditNoteLetter+'''        
       END) )
  and XDL00101.XDL_Letra_Documento=XDL10101.XDL_Letra_Documento and XDL00101.SITECODE=XDL10101.SITECODE and XDL00101.XDL_CAECODE=1) '

EXEC(@ExecStr)
EXEC('update '+ @TBName1+' set XDL_Check_Remito=##XDLTemp1.XDL_Check_Remito from '+@TBName1+' inner join ##XDLTemp1 on '+@TBName1+'.DOCNUMBR=##XDLTemp1.DOCNUMBR')
EXEC('update '+ @TBName1+' set XDL_CAE_Status=XDL10114.XDL_CAE_Status from XDL10114 where  '+@TBName1+'.DOCNUMBR = XDL10114.XDL_DocNumber and XDL10114.DOCTYPE= '+@TBName1+'.DOCTYPE')
END
ELSE  if @Xml=1
BEGIN
 set @ExecStr='insert into '+@TBName1+' 
 select 0,SOP30200.DOCDATE,SOP30200.SOPTYPE,SOP30200.DOCID,XDL10101.XDL_Letra_Documento,XDL_GP_DocNumber,CUSTNMBR,DOCAMNT,ORDOCAMT,1, 
 CUSTNAME,XDL_Punto_de_venta,SITECODE,CURNCYID,CURRNIDX,SUBTOTAL,ORSUBTOT,TRDISAMT,ORTDISAM,FRTAMNT,ORFRTAMT,MISCAMNT,ORMISCAMT,TAXAMNT,ORTAXAMT,XDL_DocNumber
 from SOP30200 
 inner join XDL10101 on SOP30200.SOPNUMBE=XDL10101.XDL_DocNumber and SOP30200.SOPTYPE=XDL10101.SOPTYPE where  
 SOP30200.DOCID in (select DOCID from '+@TBName2+' where ISCHECK=1)'
 if @DispCAEStatus=3 
 set @ExecStr=@ExecStr+' and XDL10101.XDL_GP_DocNumber not in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber=XDL10101.XDL_GP_DocNumber and XDL10115.DOCTYPE=XDL10101.SOPTYPE and XDL_CAE_Status>3 ) '
 else if @DispCAEStatus=0 
 set @ExecStr=@ExecStr+' and XDL10101.XDL_GP_DocNumber not in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber=XDL10101.XDL_GP_DocNumber and XDL10115.DOCTYPE=XDL10101.SOPTYPE and XDL_CAE_Status>1) '   
 else if @DispCAEStatus=1 
 set @ExecStr=@ExecStr+' and XDL10101.XDL_GP_DocNumber  in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber=XDL10101.XDL_GP_DocNumber and XDL10115.DOCTYPE=XDL10101.SOPTYPE and XDL_CAE_Status=2)'
 else if @DispCAEStatus=2 
 set @ExecStr=@ExecStr+' and XDL10101.XDL_GP_DocNumber  in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber=XDL10101.XDL_GP_DocNumber and XDL10115.DOCTYPE=XDL10101.SOPTYPE and XDL_CAE_Status=3)'
 if @FromDate>'00/00/0000'
 set @ExecStr=@ExecStr+' and  SOP30200.DOCDATE >=''' + rtrim(@FromDate) + ''''
 if @ToDate>'00/00/0000'
 set @ExecStr=@ExecStr+' and SOP30200.DOCDATE<= ''' +rtrim(@ToDate)  + ''''
 if @LetterA=1 and @LetterB=1
 set @ExecStr=@ExecStr+' and (XDL10101.XDL_Letra_Documento= ''A'' or XDL10101.XDL_Letra_Documento=  ''B'') '
 else if @LetterA=1
 set @ExecStr=@ExecStr+'and XDL10101.XDL_Letra_Documento=  ''A'' '
 else if  @LetterB=1
 set @ExecStr=@ExecStr+'and XDL10101.XDL_Letra_Documento= ''B'' '
 else if @LetterE=1
 set @ExecStr=@ExecStr+'and XDL10101.XDL_Letra_Documento= ''E'' '
 if @DocInvoice=1 and @DocReturn=1
 set @ExecStr=@ExecStr+' and (SOP30200.SOPTYPE=3 or SOP30200.SOPTYPE=4) '
 else if @DocInvoice=1
 set @ExecStr=@ExecStr+' and SOP30200.SOPTYPE=3 '
 else if    @DocReturn=1
 set @ExecStr=@ExecStr+' and SOP30200.SOPTYPE=4 '
 if @PointOfSaleFrom<>'' and @PointOfSaleTo<>''
 set @ExecStr=@ExecStr+' and XDL10101.XDL_Punto_de_venta>='''+rtrim(@PointOfSaleFrom)+''' and XDL10101.XDL_Punto_de_venta<= '''+rtrim(@PointOfSaleTo)+''''
 if @InvSiteFrom<>'' and @InvSiteTo<>''
 set @ExecStr=@ExecStr+' and XDL10101.SITECODE>='''+rtrim(@InvSiteFrom)+''' and XDL10101.SITECODE<='''+rtrim(@InvSiteTo)+''''
set @ExecStr=@ExecStr+' and exists(select 1 from XDL00101 where XDL00101.XDL_Punto_de_venta=XDL10101.XDL_Punto_de_venta
 and( XDL00101.XDL_Tipo_Documento=XDL10101.XDL_Tipo_Documento 
 or XDL00101.XDL_Tipo_Documento=(case when substring(XDL10101.XDL_GP_DocNumber,1,2)=''FC'' and XDL10101.XDL_Tipo_Documento='''+@PackListLetter +''' then '''+@InvoiceLetter+''' 
 when substring(XDL10101.XDL_GP_DocNumber,1,2)= ''ND'' and XDL10101.XDL_Tipo_Documento='''+@PackListLetter+''' then '''+@DebitNoteLetter+''' 
 when substring(XDL10101.XDL_GP_DocNumber,1,2)=''NC'' and XDL10101.XDL_Tipo_Documento='''+@PackListLetter+''' then '''+@CreditNoteLetter+''' 
  END) ) 
 and XDL00101.XDL_Letra_Documento=XDL10101.XDL_Letra_Documento and XDL00101.SITECODE=XDL10101.SITECODE and XDL00101.XDL_CAECODE=1) ' 
 EXEC(@ExecStr)
 EXEC('update '+ @TBName1+' set XDL_Check_Remito=##XDLTemp1.XDL_Check_Remito from '+@TBName1+' inner join ##XDLTemp1 on '+@TBName1+'.DOCNUMBR=##XDLTemp1.DOCNUMBR')
 EXEC('update '+ @TBName1+' set XDL_CAE_Status=XDL10115.XDL_CAE_Status from XDL10115 where  '+@TBName1+'.DOCNUMBR = XDL10115.XDL_DocNumber and XDL10115.DOCTYPE= '+@TBName1+'.DOCTYPE')
 set @ExecStr='insert into '+@TBName1+' 
 select 0,SOP10100.DOCDATE,SOP10100.SOPTYPE,SOP10100.DOCID,XDL10100.XDL_Letra_Documento,XDL_GP_DocNumber,SOP10100.CUSTNMBR,DOCAMNT,ORDOCAMT,1, 
 CUSTNAME,XDL_Punto_de_venta,SITECODE,CURNCYID,CURRNIDX,SUBTOTAL,ORSUBTOT,TRDISAMT,ORTDISAM,FRTAMNT,ORFRTAMT,MISCAMNT,ORMISCAMT,TAXAMNT,ORTAXAMT,XDL10100.SOPNUMBE
 from SOP10100 
 inner join XDL10100 on SOP10100.SOPNUMBE=XDL10100.SOPNUMBE and SOP10100.SOPTYPE=XDL10100.SOPTYPE where  
 SOP10100.DOCID in (select DOCID from '+@TBName2+' where ISCHECK=1)'
 if @DispCAEStatus=3 
 set @ExecStr=@ExecStr+' and XDL10100.XDL_GP_DocNumber not in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber=XDL10100.XDL_GP_DocNumber and XDL10115.DOCTYPE=XDL10100.SOPTYPE and XDL_CAE_Status>3 ) '
 else if @DispCAEStatus=0 
 set @ExecStr=@ExecStr+' and XDL10100.XDL_GP_DocNumber not in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber=XDL10100.XDL_GP_DocNumber and XDL10115.DOCTYPE=XDL10100.SOPTYPE and XDL_CAE_Status>1) '   
 else if @DispCAEStatus=1 
 set @ExecStr=@ExecStr+' and XDL10100.XDL_GP_DocNumber  in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber=XDL10100.XDL_GP_DocNumber and XDL10115.DOCTYPE=XDL10100.SOPTYPE and XDL_CAE_Status=2)'
 else if @DispCAEStatus=2 
 set @ExecStr=@ExecStr+' and XDL10100.XDL_GP_DocNumber  in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber=XDL10100.XDL_GP_DocNumber and XDL10115.DOCTYPE=XDL10100.SOPTYPE and XDL_CAE_Status=3)'
 if @FromDate>'00/00/0000'
 set @ExecStr=@ExecStr+' and  SOP10100.DOCDATE >=''' + rtrim(@FromDate) + ''''
 if @ToDate>'00/00/0000'
 set @ExecStr=@ExecStr+' and SOP10100.DOCDATE<= ''' +rtrim(@ToDate)  + ''''
 if @LetterA=1 and @LetterB=1
 set @ExecStr=@ExecStr+' and (XDL10100.XDL_Letra_Documento= ''A'' or XDL10100.XDL_Letra_Documento=  ''B'') '
 else if @LetterA=1
 set @ExecStr=@ExecStr+'and XDL10100.XDL_Letra_Documento=  ''A'' '
 else if  @LetterB=1
 set @ExecStr=@ExecStr+'and XDL10100.XDL_Letra_Documento= ''B'' '
 else if @LetterE=1
 set @ExecStr=@ExecStr+'and XDL10100.XDL_Letra_Documento= ''E'' '
 if @DocInvoice=1 and @DocReturn=1
 set @ExecStr=@ExecStr+' and (SOP10100.SOPTYPE=3 ) '
 else if @DocInvoice=1
 set @ExecStr=@ExecStr+' and SOP10100.SOPTYPE=3 '
 else if    @DocReturn=1
 set @ExecStr=@ExecStr+' and SOP10100.SOPTYPE=0 '
 if @PointOfSaleFrom<>'' and @PointOfSaleTo<>''
 set @ExecStr=@ExecStr+' and XDL10100.XDL_Punto_de_venta>='''+rtrim(@PointOfSaleFrom)+''' and XDL10100.XDL_Punto_de_venta<= '''+rtrim(@PointOfSaleTo)+''''
 if @InvSiteFrom<>'' and @InvSiteTo<>''
 set @ExecStr=@ExecStr+' and XDL10100.SITECODE>='''+rtrim(@InvSiteFrom)+''' and XDL10100.SITECODE<='''+rtrim(@InvSiteTo)+''''   
 set @ExecStr=@ExecStr+' and exists(select 1 from XDL00101 where XDL00101.XDL_Punto_de_venta=XDL10100.XDL_Punto_de_venta
 and( XDL00101.XDL_Tipo_Documento=XDL10100.XDL_Tipo_Documento 
 or XDL00101.XDL_Tipo_Documento=(case when substring(XDL10100.XDL_GP_DocNumber,1,2)=''FC'' and XDL10100.XDL_Tipo_Documento='''+@PackListLetter +''' then '''+@InvoiceLetter+''' 
 when substring(XDL10100.XDL_GP_DocNumber,1,2)= ''ND'' and XDL10100.XDL_Tipo_Documento='''+@PackListLetter+''' then '''+@DebitNoteLetter+''' 
 when substring(XDL10100.XDL_GP_DocNumber,1,2)=''NC'' and XDL10100.XDL_Tipo_Documento='''+@PackListLetter+''' then '''+@CreditNoteLetter+''' 
  END) ) 
 and XDL00101.XDL_Letra_Documento=XDL10100.XDL_Letra_Documento and XDL00101.SITECODE=XDL10100.SITECODE and XDL00101.XDL_CAECODE=1) '       
 EXEC(@ExecStr)
 EXEC('update '+ @TBName1+' set XDL_Check_Remito=##XDLTemp1.XDL_Check_Remito from '+@TBName1+' inner join ##XDLTemp1 on '+@TBName1+'.DOCNUMBR=##XDLTemp1.DOCNUMBR')
 EXEC('update '+ @TBName1+' set XDL_CAE_Status=XDL10115.XDL_CAE_Status from XDL10115 where  '+@TBName1+'.DOCNUMBR = XDL10115.XDL_DocNumber and XDL10115.DOCTYPE= '+@TBName1+'.DOCTYPE')
END
end 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XDL_CAE_Export_Redisplay] TO [DYNGRP] 
GO 

/*End_XDL_CAE_Export_Redisplay*/
/*Begin_XDL_CAE_Export_Save_Records*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XDL_CAE_Export_Save_Records]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XDL_CAE_Export_Save_Records]
GO

create  procedure XDL_CAE_Export_Save_Records 
@TBName1 varchar(25),
@Xml int,
@O_SQL_Error_State int = NULL  output

as
begin
DECLARE @ExecStr  varchar(8000)
if @Xml=0 
BEGIN
set @ExecStr='insert into XDL10114(XDL_DocNumber,DOCTYPE,XDL_Letra_Documento,XDL_Punto_de_venta,CUSTNMBR,DOCDATE,DOCAMNT,XDL_CAE_Status)
select DOCNUMBR,DOCTYPE,XDL_Letra_Documento,XDL_Punto_de_venta,CUSTNMBR,DOCDATE,DOCAMNT,XDL_CAE_Status
from '+@TBName1+' where  XDL_Check_Remito=1 and DOCNUMBR not in (select XDL_DocNumber from XDL10114 where XDL10114.XDL_DocNumber='+@TBName1+'.DOCNUMBR and XDL10114.DOCTYPE='+@TBName1+'.DOCTYPE )'
EXEC(@ExecStr)
END
ELSE if @Xml=1 
BEGIN
set @ExecStr=''
set @ExecStr='insert into XDL10115(XDL_DocNumber,DOCTYPE,XDL_Letra_Documento,XDL_Punto_de_venta,CUSTNMBR,XDL_CAE_Status,DOCDATE,DOCAMNT,XDL_Error_Msg)
select DOCNUMBR,DOCTYPE,XDL_Letra_Documento,XDL_Punto_de_venta,CUSTNMBR,XDL_CAE_Status,DOCDATE,DOCAMNT,''''
 from '+@TBName1+' where  XDL_Check_Remito=1 and DOCNUMBR not in (select XDL_DocNumber from XDL10115 where XDL10115.XDL_DocNumber='+@TBName1+'.DOCNUMBR and XDL10115.DOCTYPE='+@TBName1+'.DOCTYPE )'
 EXEC(@ExecStr)
 END  
end   
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XDL_CAE_Export_Save_Records] TO [DYNGRP] 
GO 

/*End_XDL_CAE_Export_Save_Records*/
/*Begin_XDL_CAE_Status_Report*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XDL_CAE_Status_Report]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XDL_CAE_Status_Report]
go

CREATE  procedure XDL_CAE_Status_Report
(
@TBName1 varchar(25),
@XDL_Sort smallint,
@XDL_Transaction_Status smallint,
@XDL_A tinyint,
@XDL_B tinyint,
@XDL_E tinyint,
@XDL_Invoice tinyint,
@XDL_Return tinyint,
@XDL_Await_For_CAE tinyint,
@XDL_Acceptance tinyint,
@XDL_Acceptance_With_Warn tinyint,
@XDL_Sent_To_Req_CAECode tinyint,
@XDL_Rejected tinyint,
@XDL_From_AuthCode      char(31),
@XDL_From_Cust_ID char(31),
@XDL_From_DocDate char(10),
@XDL_From_DocNo   char(31),
@XDL_From_POS     char(5),
@XDL_From_RequestNo     smallint,
@XDL_To_AuthorizationCode char(31),
@XDL_To_Cust_ID   char(31),
@XDL_To_Doc_Date  char(10),
@XDL_To_Doc_No    char(31),
@XDL_To_POS char(5),
@XDL_To_Request_No      smallint) 
as
BEGIN
DECLARE @ExecStr  VARCHAR(8000)
DECLARE @ExecStr1 VARCHAR(1000)
DECLARE @ExecStr2 VARCHAR(8000)
DECLARE @ExecStr3 VARCHAR(1000)
DECLARE @ExecStr4 VARCHAR(8000)
DECLARE @ExecStr5 VARCHAR(1000)
DECLARE @Sortby     CHAR(100)
DECLARE @FLAG       INTEGER

set @ExecStr='SELECT ISNULL(XDL10114.XDLCAEAuthorizationCode," ") AS XDLCAEAuthorizationCode,XDL10101.XDL_Punto_de_venta ,SOP30200.DOCDATE AS DOCDATE, 
XDL10101.XDL_GP_DocNumber,SOP30200.CUSTNAME ,SOP30200.CUSTNMBR AS CUSTNMBR,ISNULL(XDL10114.XDL_CAE_Status,1) AS XDL_CAE_Status,
ISNULL(XDL10114.XDL_DueDate," ") AS XDL_DueDate , ISNULL(XDL10114.XDL_Reason_Code, 0) AS XDL_Reason_Code ,SOP30200.DOCAMNT,1,ISNULL(XDL10114.XDL_Request_Number,0),0.0 from XDL10101
LEFT OUTER JOIN  XDL10114 ON (XDL10101.XDL_GP_DocNumber=XDL10114.XDL_DocNumber AND XDL10101.SOPTYPE= XDL10114.DOCTYPE)
LEFT OUTER JOIN  SOP30200 ON (XDL10101.XDL_DocNumber=SOP30200.SOPNUMBE AND XDL10101.SOPTYPE= SOP30200.SOPTYPE)'
set @ExecStr = @ExecStr +  ' WHERE '
IF @XDL_Sort = 1 
SET @Sortby= ' ORDER BY XDLCAEAuthorizationCode'
ELSE IF @XDL_Sort = 2
SET   @Sortby= ' ORDER BY CUSTNMBR'
ELSE IF @XDL_Sort = 3
SET   @Sortby= ' ORDER BY XDL10101.XDL_GP_DocNumber'
ELSE 
SET   @Sortby =' ORDER BY DOCDATE '

IF @XDL_Transaction_Status =1  
set @ExecStr = @ExecStr + 'SOP30200.VOIDSTTS=0' 
ELSE IF  @XDL_Transaction_Status =2  
set @ExecStr = @ExecStr + 'SOP30200.VOIDSTTS=1'
ELSE
set @ExecStr = @ExecStr + 'SOP30200.VOIDSTTS IN (0,1)'

IF @XDL_A = 1 AND  @XDL_B = 1 
set @ExecStr = @ExecStr + ' AND (XDL10101.XDL_Letra_Documento= "A" OR XDL10101.XDL_Letra_Documento= "B")'
ELSE IF  @XDL_A = 1 
set @ExecStr = @ExecStr + ' AND XDL10101.XDL_Letra_Documento= "A" '
ELSE IF  @XDL_B = 1
set @ExecStr = @ExecStr + ' AND XDL10101.XDL_Letra_Documento= "B" '
ELSE 
set @ExecStr = @ExecStr + ' AND XDL10101.XDL_Letra_Documento= "" '

IF @XDL_Invoice=1 AND @XDL_Return=1  
set @ExecStr=@ExecStr+' AND (SOP30200.SOPTYPE=3 OR SOP30200.SOPTYPE=4) '
ELSE IF @XDL_Invoice=1 
set @ExecStr=@ExecStr+' AND SOP30200.SOPTYPE=3 '
ELSE IF @XDL_Return=1 
set @ExecStr=@ExecStr+' AND SOP30200.SOPTYPE=4 '
ELSE
set @ExecStr=@ExecStr+' AND SOP30200.SOPTYPE=0 '

IF @XDL_From_AuthCode<> '' AND @XDL_To_AuthorizationCode <> ''
SET @ExecStr=@ExecStr + ' AND ( XDL10114.XDLCAEAuthorizationCode >= '''+rtrim(@XDL_From_AuthCode)+''' AND XDL10114.XDLCAEAuthorizationCode < = '''+rtrim(@XDL_To_AuthorizationCode)+''') '
IF @XDL_From_Cust_ID <> '' AND @XDL_To_Cust_ID <> ''
SET @ExecStr=@ExecStr + ' AND ( SOP30200.CUSTNMBR >= '''+rtrim(@XDL_From_Cust_ID)+''' AND SOP30200.CUSTNMBR < = '''+rtrim(@XDL_To_Cust_ID)+''') '
IF @XDL_From_DocDate <> '19000101' AND @XDL_To_Doc_Date <> '19000101'
SET @ExecStr=@ExecStr + ' AND ( XDL10101.XDL_Posted_Date >= '''+rtrim(@XDL_From_DocDate)+''' AND XDL10101.XDL_Posted_Date < = '''+rtrim(@XDL_To_Doc_Date)+''') '
IF @XDL_From_DocNo <> '' AND @XDL_To_Doc_No <> ''
SET @ExecStr=@ExecStr + ' AND ( XDL10101.XDL_GP_DocNumber >= '''+rtrim(@XDL_From_DocNo)+''' AND XDL10101.XDL_GP_DocNumber < = '''+rtrim(@XDL_To_Doc_No)+''') '
IF @XDL_From_POS <> '' AND @XDL_To_POS <> ''
SET @ExecStr=@ExecStr + ' AND ( XDL10101.XDL_Punto_de_venta >= '''+rtrim(@XDL_From_POS)+''' AND XDL10101.XDL_Punto_de_venta < = '''+rtrim(@XDL_To_POS)+''' ) '
IF @XDL_From_RequestNo <> 0 AND @XDL_To_Request_No <> 0
SET @ExecStr=@ExecStr + ' AND ( XDL10114.XDL_Request_Number >= '+rtrim(@XDL_From_RequestNo)+' AND XDL10114.XDL_Request_Number < = '+rtrim(@XDL_To_Request_No)+') '
IF @XDL_Await_For_CAE = 1  
SET @ExecStr1 = @ExecStr1 + ' AND (XDL10101.XDL_GP_DocNumber NOT IN (SELECT XDL_DocNumber FROM XDL10114 WHERE XDL10114.XDL_DocNumber=XDL10101.XDL_GP_DocNumber AND XDL10114.DOCTYPE=XDL10101.SOPTYPE AND XDL_CAE_Status>1)) '
IF (@XDL_Await_For_CAE = 1) AND (@XDL_Sent_To_Req_CAECode = 1 OR @XDL_Rejected = 1 OR @XDL_Acceptance_With_Warn = 1 OR @XDL_Acceptance = 1)
SET @ExecStr = @ExecStr + @ExecStr1 + ' UNION ' + @ExecStr
else
SET @ExecStr = @ExecStr + @ExecStr1
IF @XDL_Sent_To_Req_CAECode = 1 
BEGIN 
SET @ExecStr=@ExecStr+ ' AND (XDL10114.XDL_CAE_Status = 2'
SET @FLAG =1
END
IF @XDL_Rejected = 1
IF @FLAG =1
SET @ExecStr=@ExecStr+ ' OR XDL10114.XDL_CAE_Status = 3'
ELSE
BEGIN
SET @ExecStr=@ExecStr+ ' AND ( XDL10114.XDL_CAE_Status = 3'
SET @FLAG =1
END
IF @XDL_Acceptance_With_Warn = 1
IF @FLAG =1
SET @ExecStr=@ExecStr+ ' OR XDL10114.XDL_CAE_Status = 4'
ELSE
BEGIN
SET @ExecStr=@ExecStr+ ' AND ( XDL10114.XDL_CAE_Status = 4'
SET @FLAG =1
END
IF @XDL_Acceptance = 1
IF @FLAG =1
SET @ExecStr=@ExecStr+ ' OR XDL10114.XDL_CAE_Status = 5'
ELSE
BEGIN
SET @ExecStr=@ExecStr+ ' AND ( XDL10114.XDL_CAE_Status = 5'
SET @FLAG =1
END
IF @FLAG =1 
SET @ExecStr=@ExecStr+ ')'
SET @ExecStr='INSERT INTO '+@TBName1+' '+@ExecStr+ @Sortby
EXEC(@ExecStr)
IF @XDL_E = 1 
BEGIN
SET @FLAG =0
 set @ExecStr2='SELECT ISNULL(XDL10115.XDLCAEAuthorizationCode,'' '') AS XDLCAEAuthorizationCode,
 XDL10101.XDL_Punto_de_venta ,SOP30200.DOCDATE AS DOCDATE, 
 XDL10101.XDL_GP_DocNumber,SOP30200.CUSTNAME ,SOP30200.CUSTNMBR AS CUSTNMBR,ISNULL(XDL10115.XDL_CAE_Status,1) AS XDL_CAE_Status,
ISNULL(XDL10115.XDL_DueDate,'' '') AS XDL_DueDate , ISNULL(XDL10115.XDL_Reason_Code, 0) AS XDL_Reason_Code ,SOP30200.DOCAMNT,1,0,ISNULL(XDL10115.XDL_Request_Number_1,0.0) from XDL10101
 LEFT OUTER JOIN  XDL10115 ON (XDL10101.XDL_GP_DocNumber=XDL10115.XDL_DocNumber AND XDL10101.SOPTYPE= XDL10115.DOCTYPE)
 LEFT OUTER JOIN  SOP30200 ON (XDL10101.XDL_DocNumber=SOP30200.SOPNUMBE AND XDL10101.SOPTYPE= SOP30200.SOPTYPE)'
 set @ExecStr2 = @ExecStr2 +  ' WHERE '
 IF @XDL_Sort = 1 
 SET @Sortby= ' ORDER BY XDLCAEAuthorizationCode'
 ELSE IF @XDL_Sort = 2
 SET  @Sortby= ' ORDER BY CUSTNMBR'
 ELSE IF @XDL_Sort = 3
 SET  @Sortby= ' ORDER BY XDL10101.XDL_GP_DocNumber'
 ELSE 
 SET  @Sortby =' ORDER BY DOCDATE '
 IF @XDL_Transaction_Status =1  
 set @ExecStr2 = @ExecStr2 + 'SOP30200.VOIDSTTS=0' 
 ELSE IF  @XDL_Transaction_Status =2  
 set @ExecStr2 = @ExecStr2+ 'SOP30200.VOIDSTTS=1'
 ELSE
 set @ExecStr2 = @ExecStr2 + 'SOP30200.VOIDSTTS IN (0,1)'
 IF  @XDL_E = 1
 set @ExecStr2 = @ExecStr2 + ' AND XDL10101.XDL_Letra_Documento= ''E'''
 ELSE 
 set @ExecStr2 = @ExecStr2 + ' AND XDL10101.XDL_Letra_Documento=  '' '''
 IF @XDL_Invoice=1 AND @XDL_Return=1  
 set @ExecStr2=@ExecStr2+' AND (SOP30200.SOPTYPE=3 OR SOP30200.SOPTYPE=4) '
 ELSE IF @XDL_Invoice=1 
 set @ExecStr2=@ExecStr2+' AND SOP30200.SOPTYPE=3 '
 ELSE IF @XDL_Return=1 
 set @ExecStr2=@ExecStr2+' AND SOP30200.SOPTYPE=4 '
 ELSE
 set @ExecStr2=@ExecStr2+' AND SOP30200.SOPTYPE=0 '
IF @XDL_From_AuthCode<> '' AND @XDL_To_AuthorizationCode <> ''
 SET @ExecStr2=@ExecStr2 + ' AND ( XDL10115.XDLCAEAuthorizationCode >= '''+rtrim(@XDL_From_AuthCode)+''' AND XDL10115.XDLCAEAuthorizationCode < = '''+rtrim(@XDL_To_AuthorizationCode)+''') '
IF @XDL_From_Cust_ID <> '' AND @XDL_To_Cust_ID <> ''
SET @ExecStr2=@ExecStr2 + ' AND ( SOP30200.CUSTNMBR >= '''+rtrim(@XDL_From_Cust_ID)+''' AND SOP30200.CUSTNMBR < = '''+rtrim(@XDL_To_Cust_ID)+''') '
IF @XDL_From_DocDate <> '19000101' AND @XDL_To_Doc_Date <> '19000101'
SET @ExecStr2=@ExecStr2 + ' AND ( XDL10101.XDL_Posted_Date >= '''+rtrim(@XDL_From_DocDate)+''' AND XDL10101.XDL_Posted_Date < = '''+rtrim(@XDL_To_Doc_Date)+''') '
IF @XDL_From_DocNo <> '' AND @XDL_To_Doc_No <> ''
SET @ExecStr2=@ExecStr2 + ' AND ( XDL10101.XDL_GP_DocNumber >= '''+rtrim(@XDL_From_DocNo)+''' AND XDL10101.XDL_GP_DocNumber < = '''+rtrim(@XDL_To_Doc_No)+''') '
IF @XDL_From_POS <> '' AND @XDL_To_POS <> ''
SET @ExecStr2=@ExecStr2 + ' AND ( XDL10101.XDL_Punto_de_venta >= '''+rtrim(@XDL_From_POS)+''' AND XDL10101.XDL_Punto_de_venta < = '''+rtrim(@XDL_To_POS)+''' ) '
IF @XDL_From_RequestNo <> 0 AND @XDL_To_Request_No <> 0
SET @ExecStr2=@ExecStr2 + ' AND ( XDL10115.XDL_Request_Number_1 >= '+rtrim(@XDL_From_RequestNo)+' AND XDL10115.XDL_Request_Number_1 < = '+rtrim(@XDL_To_Request_No)+') '
IF @XDL_Await_For_CAE = 1  
SET @ExecStr3 = @ExecStr3 + ' AND (XDL10101.XDL_GP_DocNumber NOT IN (SELECT XDL_DocNumber FROM XDL10115 WHERE XDL10115.XDL_DocNumber=XDL10101.XDL_GP_DocNumber AND XDL10115.DOCTYPE=XDL10101.SOPTYPE AND XDL_CAE_Status>1)) '
IF (@XDL_Await_For_CAE = 1) AND (@XDL_Sent_To_Req_CAECode = 1 OR @XDL_Rejected = 1 OR @XDL_Acceptance_With_Warn = 1 OR @XDL_Acceptance = 1)
SET @ExecStr2 = @ExecStr2 + @ExecStr3 + ' UNION ' + @ExecStr2
else
SET @ExecStr2 = @ExecStr2 + @ExecStr3
IF @XDL_Sent_To_Req_CAECode = 1 
BEGIN 
SET @ExecStr2=@ExecStr2+ ' AND (XDL10115.XDL_CAE_Status = 2'
SET @FLAG =1
END
IF @XDL_Rejected = 1
IF @FLAG =1
SET @ExecStr2=@ExecStr2+ ' OR XDL10115.XDL_CAE_Status = 3'
ELSE
BEGIN
SET @ExecStr2=@ExecStr2+ ' AND ( XDL10115.XDL_CAE_Status = 3'
SET @FLAG =1
END
IF @XDL_Acceptance_With_Warn = 1
IF @FLAG =1
SET @ExecStr2=@ExecStr2+ ' OR XDL10115.XDL_CAE_Status = 4'
ELSE
BEGIN
SET @ExecStr2=@ExecStr2+ ' AND ( XDL10115.XDL_CAE_Status = 4'
SET @FLAG =1
END
IF @XDL_Acceptance = 1
IF @FLAG =1
SET @ExecStr2=@ExecStr2+ ' OR XDL10115.XDL_CAE_Status = 5'
ELSE
BEGIN
SET @ExecStr2=@ExecStr2+ ' AND ( XDL10115.XDL_CAE_Status = 5'
SET @FLAG =1
END
IF @FLAG =1 
SET @ExecStr2=@ExecStr2+ ')'
SET @ExecStr2='INSERT INTO '+@TBName1+' '+@ExecStr2+ @Sortby
EXEC(@ExecStr2)
IF @XDL_Transaction_Status <>1
BEGIN
SET @FLAG =0
set @ExecStr4='SELECT ISNULL(XDL10115.XDLCAEAuthorizationCode,'' '') AS XDLCAEAuthorizationCode,XDL10100.XDL_Punto_de_venta ,SOP10100.DOCDATE AS DOCDATE, 
XDL10100.XDL_GP_DocNumber,SOP10100.CUSTNAME ,SOP10100.CUSTNMBR AS CUSTNMBR,ISNULL(XDL10115.XDL_CAE_Status,1) AS XDL_CAE_Status,
ISNULL(XDL10115.XDL_DueDate,'' '') AS XDL_DueDate , ISNULL(XDL10115.XDL_Reason_Code, 0) AS XDL_Reason_Code ,SOP10100.DOCAMNT,1,0,ISNULL(XDL10115.XDL_Request_Number_1,0.0) from XDL10100
LEFT OUTER JOIN  XDL10115 ON (XDL10100.XDL_GP_DocNumber=XDL10115.XDL_DocNumber AND XDL10100.SOPTYPE= XDL10115.DOCTYPE)
LEFT OUTER JOIN  SOP10100 ON (XDL10100.SOPNUMBE=SOP10100.SOPNUMBE AND XDL10100.SOPTYPE= SOP10100.SOPTYPE)'
set @ExecStr4 = @ExecStr4 +  ' WHERE '
IF @XDL_Sort = 1 
SET @Sortby= ' ORDER BY XDLCAEAuthorizationCode'
ELSE IF @XDL_Sort = 2
SET   @Sortby= ' ORDER BY CUSTNMBR'
ELSE IF @XDL_Sort = 3
SET   @Sortby= ' ORDER BY XDL10100.XDL_GP_DocNumber'
ELSE 
SET   @Sortby =' ORDER BY DOCDATE '
IF @XDL_Transaction_Status =1  
set @ExecStr4 = @ExecStr4 + 'SOP10100.VOIDSTTS=0' 
ELSE IF  @XDL_Transaction_Status =2  
set @ExecStr4 = @ExecStr4 + 'SOP10100.VOIDSTTS=1'
ELSE
set @ExecStr4 = @ExecStr4 + 'SOP10100.VOIDSTTS IN (0,1)'
IF  @XDL_E = 1
set @ExecStr4 = @ExecStr4 + ' AND XDL10100.XDL_Letra_Documento= ''E'' '
ELSE 
set @ExecStr4 = @ExecStr4 + ' AND XDL10100.XDL_Letra_Documento=  '' '''
IF @XDL_Invoice=1 AND @XDL_Return=1  
set @ExecStr4=@ExecStr4+' AND (SOP10100.SOPTYPE=3 OR SOP10100.SOPTYPE=4) '
ELSE IF @XDL_Invoice=1 
set @ExecStr4=@ExecStr4+' AND SOP10100.SOPTYPE=3 '
ELSE IF @XDL_Return=1 
set @ExecStr4=@ExecStr4+' AND SOP10100.SOPTYPE=4 '
ELSE
set @ExecStr4=@ExecStr4+' AND SOP10100.SOPTYPE=0 '
IF @XDL_From_AuthCode<> '' AND @XDL_To_AuthorizationCode <> ''
SET @ExecStr4=@ExecStr4 + ' AND ( XDL10115.XDLCAEAuthorizationCode >= '''+rtrim(@XDL_From_AuthCode)+''' AND XDL10115.XDLCAEAuthorizationCode < = '''+rtrim(@XDL_To_AuthorizationCode)+''') '
IF @XDL_From_Cust_ID <> '' AND @XDL_To_Cust_ID <> ''
SET @ExecStr4=@ExecStr4 + ' AND ( SOP10100.CUSTNMBR >= '''+rtrim(@XDL_From_Cust_ID)+''' AND SOP10100.CUSTNMBR < = '''+rtrim(@XDL_To_Cust_ID)+''') '
IF @XDL_From_DocDate <> '19000101' AND @XDL_To_Doc_Date <> '19000101'
SET @ExecStr4=@ExecStr4 + ' AND ( XDL10100.XDL_Posted_Date >= '''+rtrim(@XDL_From_DocDate)+''' AND XDL10100.XDL_Posted_Date < = '''+rtrim(@XDL_To_Doc_Date)+''') '
IF @XDL_From_DocNo <> '' AND @XDL_To_Doc_No <> ''
SET @ExecStr4=@ExecStr4 + ' AND ( XDL10100.XDL_GP_DocNumber >= '''+rtrim(@XDL_From_DocNo)+''' AND XDL10100.XDL_GP_DocNumber < = '''+rtrim(@XDL_To_Doc_No)+''') '
IF @XDL_From_POS <> '' AND @XDL_To_POS <> ''
SET @ExecStr4=@ExecStr4+ ' AND ( XDL10100.XDL_Punto_de_venta >= '''+rtrim(@XDL_From_POS)+''' AND XDL10100.XDL_Punto_de_venta < = '''+rtrim(@XDL_To_POS)+''' ) '
IF @XDL_From_RequestNo <> 0 AND @XDL_To_Request_No <> 0
SET @ExecStr4=@ExecStr4 + ' AND ( XDL10115.XDL_Request_Number >= '+rtrim(@XDL_From_RequestNo)+' AND XDL10115.XDL_Request_Number < = '+rtrim(@XDL_To_Request_No)+') '
IF @XDL_Await_For_CAE = 1  
SET @ExecStr5 = @ExecStr5 + ' AND (XDL10100.XDL_GP_DocNumber NOT IN (SELECT XDL_DocNumber FROM XDL10115 WHERE XDL10115.XDL_DocNumber=XDL10100.XDL_GP_DocNumber AND XDL10115.DOCTYPE=XDL10100.SOPTYPE AND XDL_CAE_Status>1)) '
IF (@XDL_Await_For_CAE = 1) AND (@XDL_Sent_To_Req_CAECode = 1 OR @XDL_Rejected = 1 OR @XDL_Acceptance_With_Warn = 1 OR @XDL_Acceptance = 1)
SET @ExecStr4 = @ExecStr4 + @ExecStr5 + ' UNION ' + @ExecStr4
else
SET @ExecStr4 = @ExecStr4 + @ExecStr5
IF @XDL_Sent_To_Req_CAECode = 1 
BEGIN 
SET @ExecStr4=@ExecStr4+ ' AND (XDL10115.XDL_CAE_Status = 2'
SET @FLAG =1
END
IF @XDL_Rejected = 1
IF @FLAG =1
SET @ExecStr4=@ExecStr4+ ' OR XDL10115.XDL_CAE_Status = 3'
ELSE
BEGIN
SET @ExecStr4=@ExecStr4+ ' AND ( XDL10115.XDL_CAE_Status = 3'
SET @FLAG =1
END
IF @XDL_Acceptance_With_Warn = 1
IF @FLAG =1
SET @ExecStr4=@ExecStr4+ ' OR XDL10115.XDL_CAE_Status = 4'
ELSE
BEGIN
SET @ExecStr4=@ExecStr4+ ' AND ( XDL10115.XDL_CAE_Status = 4'
SET @FLAG =1
END
IF @XDL_Acceptance = 1
IF @FLAG =1
SET @ExecStr4=@ExecStr4+ ' OR XDL10115.XDL_CAE_Status = 5'
ELSE
BEGIN
SET @ExecStr4=@ExecStr4+ ' AND ( XDL10115.XDL_CAE_Status = 5'
SET @FLAG =1
END
IF @FLAG =1 
SET @ExecStr4=@ExecStr4+ ')'
SET @ExecStr4='INSERT INTO '+@TBName1+' '+@ExecStr4+ @Sortby
EXEC (@ExecStr4)
END
END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XDL_CAE_Status_Report] TO [DYNGRP] 
GO 

/*End_XDL_CAE_Status_Report*/
/*Begin_XDL_Archive_CAE_Document*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XDL_Archive_CAE_Document]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XDL_Archive_CAE_Document]
GO
CREATE PROCEDURE XDL_Archive_CAE_Document 
(
@SOPTYPE   char(2),
@DOCNUMBER char(25),
@LETTERTYPE char(1),
@ConcCount int OUTPUT,
@TotTaxAmt char(30) OUTPUT,
@VATTaxAmt char(30)OUTPUT,
@RNIAmt    char(30)OUTPUT,
@ExemptAmt char(30)OUTPUT,
@VATPerAmt char(30)OUTPUT,
@GIPerAmt  char(30)OUTPUT,
@BAPerAmt  char(30)OUTPUT,
@IntTaxAmt char(30) OUTPUT,
@VatRate   int OUTPUT
) 
AS
BEGIN
SELECT @ConcCount= COUNT(*) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND SOP10105.TAXDTLID IN(SELECT TAXDTLID FROM TX00201 WHERE TX00201.TAXDTLID=SOP10105.TAXDTLID AND TXDTLBSE=6)
SELECT @TotTaxAmt =MAX(TDTTXSLS) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND TAXDTLID IN( SELECT TAXDTLID FROM XDL00117 )

SELECT @VATTaxAmt =SUM(STAXAMNT) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND TAXDTLID IN( SELECT TAXDTLID FROM XDL00117 WHERE XDL_CAE_Tax_Type=1)
SELECT @RNIAmt    =SUM(STAXAMNT) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND TAXDTLID IN( SELECT TAXDTLID FROM XDL00117 WHERE XDL_CAE_Tax_Type=2)
SELECT @ExemptAmt =SUM(STAXAMNT) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND TAXDTLID IN( SELECT TAXDTLID FROM XDL00117 WHERE XDL_CAE_Tax_Type=3)
SELECT @VATPerAmt =SUM(STAXAMNT) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND TAXDTLID IN( SELECT TAXDTLID FROM XDL00117 WHERE XDL_CAE_Tax_Type=4)
SELECT @GIPerAmt  =SUM(STAXAMNT) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND TAXDTLID IN( SELECT TAXDTLID FROM XDL00117 WHERE XDL_CAE_Tax_Type=5)
SELECT @BAPerAmt  =SUM(STAXAMNT) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND TAXDTLID IN( SELECT TAXDTLID FROM XDL00117 WHERE XDL_CAE_Tax_Type=6)
SELECT @IntTaxAmt =SUM(STAXAMNT) FROM SOP10105 WHERE LNITMSEQ=0 AND SOPTYPE=@SOPTYPE AND SOPNUMBE=@DOCNUMBER AND TAXDTLID IN( SELECT TAXDTLID FROM XDL00117 WHERE XDL_CAE_Tax_Type=7)      
select @VatRate=count(distinct TX00201.TXDTLPCT) from SOP10105 inner join TX00201  on SOP10105.TAXDTLID=TX00201.TAXDTLID and SOP10105.SOPTYPE=@SOPTYPE AND SOP10105.SOPNUMBE=@DOCNUMBER
if @VatRate>9
begin
	set @VatRate=9
end	
if @VatRate<1
begin
	set @VatRate=1
end	

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[XDL_Archive_CAE_Document] TO [DYNGRP] 
GO 

/*End_XDL_Archive_CAE_Document*/



/*Begin_SP_XDL_To_Get_Letter*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_To_Get_Letter]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_To_Get_Letter]
go

CREATE PROCEDURE SP_XDL_To_Get_Letter
@XDL_letra  VARCHAR(40) ,
@AWLI_LETRA INTEGER OUTPUT

AS
BEGIN

      IF @XDL_letra = 'A' 
      BEGIN 
            SET @AWLI_LETRA = 1 
      END
      ELSE IF @XDL_letra = 'B'  
      BEGIN 
            SET @AWLI_LETRA = 2 
      END
      ELSE IF @XDL_letra = 'C'  
      BEGIN 
            SET @AWLI_LETRA = 3 
      END
      ELSE IF @XDL_letra = 'E'  
      BEGIN 
            SET @AWLI_LETRA = 4 
      END
      ELSE IF @XDL_letra = 'None' OR  @XDL_letra = 'Ninguno' 
      BEGIN 
            SET @AWLI_LETRA = 5 
      END
      ELSE IF @XDL_letra = 'M'  
      BEGIN 
            SET @AWLI_LETRA = 6 
      END
      ELSE IF @XDL_letra = 'R'  
      BEGIN 
            SET @AWLI_LETRA = 7 
      END
      ELSE IF @XDL_letra = 'X'  
      BEGIN 
            SET @AWLI_LETRA = 8 
      END
      ELSE IF @XDL_letra = 'Z'  
      BEGIN 
            SET @AWLI_LETRA = 9 
      END
      ELSE IF @XDL_letra = 'Y'  
      BEGIN 
            SET @AWLI_LETRA = 10 
      END

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_To_Get_Letter] TO [DYNGRP] 
GO 

/*End_SP_XDL_To_Get_Letter*/

/*Begin_SP_XDL_To_Get_Tipodocument*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_To_Get_Tipodocument]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_To_Get_Tipodocument]
go

CREATE PROCEDURE SP_XDL_To_Get_Tipodocument
@in_Soptype                   SMALLINT , 
@in_docid                     CHAR(15) ,
@in_BtchSrc                   CHAR(15) ,
@out_XDLTipoDocumento           CHAR(21) OUTPUT

AS
BEGIN
      IF EXISTS(SELECT TOP 1 1 FROM XDL00103 WHERE XDL_SOP_Type=@in_Soptype AND DOCID=@in_docid AND BCHSOURC=@in_BtchSrc)
      BEGIN
            SELECT TOP 1 @out_XDLTipoDocumento=XDL_Tipo_Documento FROM XDL00103 WHERE XDL_SOP_Type=@in_Soptype AND DOCID=@in_docid AND BCHSOURC=@in_BtchSrc
      END
      ELSE
      BEGIN
            SET @out_XDLTipoDocumento=''
      END 
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_To_Get_Tipodocument] TO [DYNGRP] 
GO 

/*End_SP_XDL_To_Get_Tipodocument*/

/*Begin_SP_XDL_To_Get_VoucherType*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_To_Get_VoucherType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_To_Get_VoucherType]
go

CREATE PROCEDURE SP_XDL_To_Get_VoucherType
@in_sTipoDocumento      VARCHAR(400) ,
@AWLI_Docnmbr           INT OUTPUT

AS
BEGIN

      IF @in_sTipoDocumento='Invoice' or @in_sTipoDocumento='Factura' 
      BEGIN 
            SET @AWLI_Docnmbr=1
      END
      ELSE IF @in_sTipoDocumento= 'Credit Note' OR @in_sTipoDocumento='Nota de crédito' 
      BEGIN 
            SET @AWLI_Docnmbr=2
      END
      ELSE IF @in_sTipoDocumento='Debit Note' OR @in_sTipoDocumento='Nota de débito'
      BEGIN 
            SET @AWLI_Docnmbr=3
      END
      ELSE IF @in_sTipoDocumento='All' OR @in_sTipoDocumento='Todo'
      BEGIN 
            SET @AWLI_Docnmbr=4
      END
      ELSE IF @in_sTipoDocumento='Packing List' OR @in_sTipoDocumento='Lista de remisión'
      BEGIN 
            SET @AWLI_Docnmbr=5
      END

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_To_Get_VoucherType] TO [DYNGRP] 
GO 

/*End_SP_XDL_To_Get_VoucherType*/

/*Begin_SP_XDL_ToValidate_CAI*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_ToValidate_CAI]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_ToValidate_CAI]
go

CREATE PROCEDURE SP_XDL_ToValidate_CAI
@in_TipoDocumento       VARCHAR(100) , 
@in_LetraDocumento      VARCHAR(100) , 
@in_DocumentDate        DATETIME , 
@l_errstatus            BIT OUTPUT , 
@in_DocNumber           VARCHAR(100) , 
@in_numerador           INT , 
@in_Xdl_PuntodeVenta    VARCHAR(100) ,
@l_CAI                  VARCHAR(100) OUTPUT ,  
@l_DueDateCAI           DATETIME  OUTPUT
AS
BEGIN

      DECLARE
      @l_SQL_Connection       INT ,
      @status               INT , 
      @l_records_count        INT , 
      @l_ok                 BIT , 
      @l_Is_Awli_Installed  BIT , 
      /*@l_SQLDatabasename      VARCHAR(100) , */
      @cQry                 nvarchar(1000) ,
      @AWLI_LETRA           INT ,
      @AWLI_Docnmbr         INT , 
      @l_PDV                VARCHAR(100) , 
      @l_NMBR               VARCHAR(100) , 
      @lFechaYYYYMMDD       VARCHAR(100) , 
      @l_Anio               VARCHAR(100) ,
      @l_Mes                VARCHAR(100) , 
      @l_Dia                VARCHAR(100) ,
      @sDocType             VARCHAR(100) , 
      @l_CAI_All            INT ,
	@l_ParmDefinition			nvarchar(500),
	  @CompID				VARCHAR(400),
	@Out_ToDt			DATETIME,
	@Out_CAI	VARCHAR(100)

SET @CompID = DB_NAME() 
      /*IF NOT EXISTS (SELECT TOP 1 1 from DYNAMICS..DU000020 WHERE PRODID = 9883 ) 
      BEGIN
            /*call XDL_Is_Awli_Installed,l_Is_Awli_Installed*/
            SET @l_errstatus = 1
            RETURN
      END*/
	if  not exists (select * from dbo.sysobjects where id = object_id(N'[AWLI_RM00103]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
      BEGIN
            SET @l_errstatus = 1
            RETURN
      END

      SET @l_errstatus=0
      SET @l_CAI=''
      SET @l_DueDateCAI = NULL
      SET @l_CAI_All = 0
      SET @sDocType = ''
      IF @in_DocNumber<>'' 
      BEGIN
            SET @l_PDV=substring(@in_DocNumber,5,4)
            SET @l_NMBR=substring(@in_DocNumber,10,8)
      END
      ELSE
      BEGIN
            SET @l_PDV=@in_Xdl_PuntodeVenta
            SET @l_NMBR=@in_numerador
      END


      SET @cQry = ''
      SET @cQry = ' USE ' + @CompID  
 /*     SET @cQry = @cQry + ' SELECT UNIQ_FORM_FCNCND From AWLI40300'*/
      EXEC(@cQry)  

      /*
            if status = 0 then
            status = SQL_GetNumRows(l_SQL_Connection, l_records_count) 
            status = SQL_FetchNext (l_SQL_Connection) 
            if status <> 31 then {If not EOF} 
                        status = SQL_GetData(l_SQL_Connection, 1, l_CAI_All)
            end if
      end if
      call 'AXDEXRec_Close', l_SQL_Connection {rsaha@partners for bug 51242}
      {Adding ends here for bug 51045}
      */
      SELECT @l_CAI_All=UNIQ_FORM_FCNCND From AWLI40300


      /*SET @l_SQLDatabasename = @CompID*/
      EXEC SP_XDL_To_Get_Letter @in_LetraDocumento,@AWLI_LETRA  OUTPUT

      IF @l_CAI_All = 0 
      BEGIN
            EXEC SP_XDL_To_Get_VoucherType @in_TipoDocumento,@AWLI_Docnmbr OUTPUT
      END
      ELSE
      BEGIN
            SET @sDocType = 'All'
            EXEC SP_XDL_To_Get_VoucherType @sDocType,@AWLI_Docnmbr OUTPUT
      END 

      SET @cQry = 'USE ' + @CompID
      SET @cQry = @cQry + ' SET DATEFORMAT dmy '

      EXEC(@cQry)

      SET @l_Anio = str(year(@in_DocumentDate))
      SET @l_Mes = str(month(@in_DocumentDate))
      SET @l_Dia = str(day(@in_DocumentDate))
      IF LEN(@l_Mes) < 2  
      BEGIN 
            SET @l_Mes = '0' + @l_Mes
      END 
      IF LEN(@l_Dia) < 2  
      BEGIN
            SET @l_Dia = '0' + @l_Dia
      END 
      SET @lFechaYYYYMMDD = @l_Dia + '/' + @l_Mes + '/' + @l_Anio

      Select @cQry = N''
      SElect @cQry = N'SELECT @Out_CAI=CAI, @Out_ToDt=TO_DT  From AWLI_RM00103  Where PDV = ''' + @l_PDV + '''
      and ''' + @lFechaYYYYMMDD + ''' between FROM_DT and TO_DT  and ''' + @l_NMBR + ''' between FROM_NMBR and TO_NMBR '
      + ' and COMP_TYPE = ' + CONVERT(VARCHAR(100),@AWLI_Docnmbr) + ' and LETRA = ' + CONVERT(VARCHAR(100),@AWLI_LETRA )

						set @l_ParmDefinition = N'@Out_CAI VARCHAR(100) output, @Out_ToDt DATETIME OUTPUT'	

						execute sp_executesql @cQry, 
							@l_ParmDefinition, 
							@Out_CAI=@l_CAI output,
							@Out_ToDt=@l_DueDateCAI  OUTPUT



      /*
      if status = 0 then {Hkumarps@partners Regf's 5025 03-Nov-08}
      status = SQL_GetNumRows(l_SQL_Connection, l_records_count); 
         status = SQL_FetchNext (l_SQL_Connection); 
         if status <> 31 then {If not EOF} 
                        status = SQL_GetData(l_SQL_Connection, 1, l_CAI);
                        status = SQL_GetData(l_SQL_Connection, 2, l_DueDateCAI);
                        l_errstatus = true;
         end if;
      end if;
      */

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_ToValidate_CAI] TO [DYNGRP] 
GO 

/*End_SP_XDL_ToValidate_CAI*/


/*Begin_SP_XDL_Return_ReasonCode_Desc*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_Return_ReasonCode_Desc]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_Return_ReasonCode_Desc]
go

CREATE PROCEDURE SP_XDL_Return_ReasonCode_Desc
@l_XDL_Docnumber        VARCHAR(100),
@l_SopType              SMALLINT,
@O_XDL_Return_ReasonCode_Desc VARCHAR(1000) OUTPUT
AS
BEGIN
      DECLARE
      @l_XDL_Reason_Code      VARCHAR(1000),
      @l_codelength           INTEGER,
      @i                      INTEGER,
      @XDL_Reason_Code          VARCHAR(100)
      

      IF EXISTS (SELECT TOP 1 1 FROM XDL10114 WHERE XDL_DocNumber = @l_XDL_Docnumber AND DOCTYPE = @l_SopType)
      BEGIN
            SELECT TOP 1 @XDL_Reason_Code=XDL_Reason_Code FROM XDL10114 WHERE XDL_DocNumber = @l_XDL_Docnumber AND DOCTYPE = @l_SopType
            SET @l_codelength=LEN(@XDL_Reason_Code)
            SET @O_XDL_Return_ReasonCode_Desc=' '
            SET @i=1
            IF @XDL_Reason_Code <> ''
            BEGIN
				WHILE @i <> @l_codelength
				BEGIN
					SET @l_XDL_Reason_Code=SUBSTRING(@XDL_Reason_Code,@i,2)
					IF    @l_XDL_Reason_Code ='01' 
					BEGIN 
						 SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The registered CUIT number does not correspond to the customer.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code ='02' 
					BEGIN  
						 SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc +'The documents for the selected CUIT number are not authorized to be submitted for electronic authorization code OR the beginning date for the authorized period is later than the CAE request date.'
					END
                        
					ELSE IF @l_XDL_Reason_Code ='03' 
					BEGIN  
						SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The CUIT number contains incorrect address information.'
					END
                        
					ELSE IF @l_XDL_Reason_Code ='04' 
					BEGIN  
						 SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The documents for this point of sale is not declared to be used for electronic submission.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code='05' 
					BEGIN  
						SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The document date cannot be prior to 5 days and later than 10 days from the current date for the Sales Service documents.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code ='06' 
					BEGIN  
						SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The CUIT number is not authorized to submit the documents with the letter class ''A''.' 
					 END
                        
					ELSE IF @l_XDL_Reason_Code ='07' 
					BEGIN  
						SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The Identification Code Type field in the text file 1 should be always ''80'' for the documents with letter class ''A''.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code ='08' 
					BEGIN  
                        SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The CUIT number in the Identification Number field is invalid.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code ='09' 
					BEGIN  
                        SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The CUIT number in the Identification Number field of the buyer does not exist in the list of taxpayers.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code ='10' 
					BEGIN  
                        SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The CUIT number in the Identification Number field of the buyer does not correspond to the RI in the VAT declaration.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code ='11' 
					BEGIN  
                        SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The document number currently submitted for this point of sale does not match with the last document number registered.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code ='12' 
					BEGIN  
                        SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The selected documents for this CUIT number, document type and point of sale is already submitted.' 
					END
                        
					ELSE IF @l_XDL_Reason_Code ='13' 
					BEGIN  
                        SET @O_XDL_Return_ReasonCode_Desc = @O_XDL_Return_ReasonCode_Desc + 'The CUIT selected is included in the regime/law established by the resolution ° 2177 and/or in the Title of Resolution I General N ° 1361 - art. 24 of the RG N ° 2177-.' 
					END
					SET @i=@i+3
				END
            END
      END
      ELSE
      BEGIN
            SET @O_XDL_Return_ReasonCode_Desc=''
      END 
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_Return_ReasonCode_Desc] TO [DYNGRP] 
GO 

/*End_SP_XDL_Return_ReasonCode_Desc*/
/*Begin_SP_XDL_Imprime_TRX*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_Imprime_TRX]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_Imprime_TRX]
go

CREATE PROCEDURE SP_XDL_Imprime_TRX
@in_sDocNum             VARCHAR(400) ,
@in_sTipoDocumento      VARCHAR(400) , 
@in_sLetraDocumento           VARCHAR(400) ,
@in_DocID               VARCHAR(400) ,
@in_Batch               VARCHAR(400) ,
@out_Error              BIT OUTPUT ,
@UserID                 VARCHAR(100) ,
@CompID                 INTEGER
 
AS
BEGIN

      DECLARE
      @status                 BIT , 
      @l_records_count          INT ,  
      @l_ok                   BIT ,
      @lTypeTrue              BIT , 
      /*@l_SQLDatabasename    VARCHAR(400) , */
      @cQry                   VARCHAR(8000) , 
      @lresp                  INT , 
      @cRuta                  VARCHAR(400) ,
      @cReporte               VARCHAR(400) , 
      @cPath                  VARCHAR(400) , 
      @lContador              INT , 
      @lNumPagina             INT , 
      @lMaxXPage              INT , 
      @i                      INT , 
      @lNumeroCopias          INT ,
      @lDsPage                VARCHAR(400) , 
      @l_DosDS                VARCHAR(400) , 
      @l_formulas             VARCHAR(400) , 
      @l_Parametros           VARCHAR(400) ,
      @lPageFmt               VARCHAR(400) ,
      @l_message              VARCHAR(400) , 
      @lTypeItem              VARCHAR(400) , 
      @lDocTypeNew            VARCHAR(400) , 
      @iRecCount              INT,
      @lNumCopies			  VARCHAR(400),
	  @Comp                   INT,
	  @SubChar				VARCHAR(100)	
  


      /*SET @l_SQLDatabasename = DB_NAME()'Intercompany ID' of globals*/

      SET @lContador = 1
      SET @lNumPagina = 1
      SET @out_Error = 1


      /* RajuSET @cQry = ''
      SET @cQry = @cQry + ' Delete XDL90100 Where USERID = ''' + @UserID + ''' '
      EXEC (@cQry)

      SET @cQry = ''
      SET @cQry = @cQry + 'Delete XDL90102 Where USERID = ''' + @UserID + ''' '
      EXEC (@cQry)


      SET @cQry = ''
      SET @cQry = @cQry + 'Delete XDL91101 Where Usuario = ''' + @UserID + ''' '
      EXEC (@cQry)*/


/*
      SET @lMaxXPage = FUNC_Get_Parameters_Documento(@in_sTipoDocumento, 'LINEPERPAGE', 0)
      IF @lMaxXPage = 0 
      BEGIN
            SET @lMaxXPage = FUNC_Get_Parameters_General( 'LINEPERPAGE', 0 )
            IF @lMaxXPage = 0 
            BEGIN
                  SET @lMaxXPage = 10
            END 
      END 

      SET @lNumeroCopias = FUNC_Get_Parameters_Documento( in_sTipoDocumento, 'PRINTCOPY', 0)

      IF @lNumeroCopias=0 
      BEGIN
            SET @lNumeroCopias = FUNC_Get_Parameters_General( 'PRINTCOPY', 0 )
            IF @lNumeroCopias=0 
            BEGIN
                  SET @lNumeroCopias = 1
            END   
      END

      SET @i = 1

      WHILE @i > @lNumeroCopias
      BEGIN
            SET @lDsPage = FUNC_Get_Parameters_General( 'PAGE' + str(@i), 0, 'PAGE')
            IF @lDsPage=0 
            BEGIN
                  SET @lDsPage = str(@i)
            END 
            IF @i = 1 
            BEGIN
                  SET @lPageFmt = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, XDL_PARAM_PAGE1, 0)                 
            END 
            IF @i = 2 
            BEGIN
                  SET @lPageFmt = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, XDL_PARAM_PAGE2, 0)                 
            END 
            IF @i = 3 
            BEGIN
                  SET @lPageFmt = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, XDL_PARAM_PAGE3, 0)                 
            END
*/

            UPDATE XDL90100 SET USERID = @UserID /*, XDLDSCFG = @lPageFmt*/ WHERE XDL_GP_DocNumber = @in_sDocNum AND XDL_Tipo_Documento = @in_sTipoDocumento /*AND XDLNUCO = @i AND XDLCPDS = @lDsPage*/
/*
      SET @i=@i+1
      END   
*/

      IF @in_Batch = 'Inventory'
      BEGIN
            SET @lDocTypeNew = 'Packing List'
      END 
      ELSE IF @in_Batch = 'Inventario'
      BEGIN
            SET @lDocTypeNew = 'Lista de remisión'
      END
            


SET @CompID=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())

      SET @cQry = ''
      SET @cQry = @cQry + 'insert into XDL90102 (TRXSORCE, DOCTYPE, DOCNUMBR, DOCDATE, ITEMNMBR, LNSEQNBR, UOFM, TRXQTY, TRXLOCTN, TRNSTLOC, CAI, Compania,
      CUITCom, CUITIIBB, DirCom, LocaCom, EstadoCom, CodPostCom, PaisCom, TelefonoCom, FaxCom, FecCpbte, Remito, NOTEINDX, XDL_GP_DocNumber, XDL_Tipo_Documento,
      DOCID, XCHGRATE, EXCHDATE, XDLNULINE, NUMRPRIN, CMPANYID, Usuario, USERID, XDLDSCFG) 
      Select Det.TRXSORCE, Det.DOCTYPE, Det.DOCNUMBR, Det.DOCDATE, Det.ITEMNMBR, Det.LNSEQNBR, Det.UOFM, Det.TRXQTY, Det.TRXLOCTN, Det.TRNSTLOC,
       case when ( Select ''C.A.I. Nro. '' + Cai.XDL_CAI + ''- Fecha de Vto. '' + convert(varchar,Cai.XDL_CAI_Due_Date)  From XDL00102 Cai 
      Where Trx.XDL_Tipo_Documento = Cai.XDL_Tipo_Documento and Trx.XDL_Letra_Documento = Cai.XDL_Letra_Documento and
      Trx.XDL_Punto_de_venta = Cai.XDL_Punto_de_venta and Cai.XDL_CAI_Due_Date in ( Select Min(Cai2.XDL_CAI_Due_Date) From XDL00102 Cai2 Where Cai2.XDL_CAI_Due_Date > Trx.XDL_Remito_Created_Date )) is null then '''' else 
      ( Select ''C.A.I. Nro. '' + Cai.XDL_CAI + '' - Fecha de Vto. '' + convert(varchar,Cai.XDL_CAI_Due_Date) From XDL00102 Cai 
      Where Trx.XDL_Tipo_Documento = Cai.XDL_Tipo_Documento and Trx.XDL_Letra_Documento = Cai.XDL_Letra_Documento and Trx.XDL_Punto_de_venta = Cai.XDL_Punto_de_venta and 
      Cai.XDL_CAI_Due_Date in ( Select Min(Cai2.XDL_CAI_Due_Date) From XDL00102 Cai2 Where Cai2.XDL_CAI_Due_Date > Trx.XDL_Remito_Created_Date )) end CAI ,
      Com.CMPNYNAM Compania, Com.TAXREGTN CUITCom, Com.UDCOSTR1 CUITIIBB, (RTRIM(Com.ADDRESS1) + RTRIM(Com.ADDRESS2) + RTRIM(Com.ADDRESS3))  DirCom,
      Com.CITY LocaCom, Com.STATE EstadoCom, Com.ZIPCODE CodPostCom, Com.CMPCNTRY PaisCom, (Com.PHONE1 + '' '' + Com.PHONE2 + '' '' + Com.PHONE3) TelefonoCom,
      Com.FAXNUMBR FaxCom, Trx.XDL_Remito_Created_Date FecCpbte, Trx.XDL_Remito_DocNumber Remito, Cab.NOTEINDX NOTEINDX, Trx.XDL_GP_DocNumber XDL_GP_DocNumber, 
       ''' + ISNULL(@in_sTipoDocumento,'') + ''' ,  Trx.DOCID DOCID, 1, Trx.XDL_Posted_Date  EXCHDATE, 1, 0, ''' + CONVERT(VARCHAR(10),@CompID) + /* + str('Company ID' of globals) +*/ ''' CMPANYID,
      ''' + ISNULL(@UserID,'') + ''' Usuario , ''' + ISNULL(@UserID,'') + ''' USERID,''''  From IV30300 Det, IV30200 Cab, XDL10101 Trx,  DYNAMICS.dbo.SY01500 Com 
      Where Det.DOCNUMBR = Trx.XDL_DocNumber and Trx.XDL_Tipo_Documento = ''' + ISNULL(@lDocTypeNew,'') + ''' and Det.HSTMODUL = ''IV'' and Det.DOCTYPE = 3 and
      Trx.XDL_GP_DocNumber = ''' + ISNULL(@in_sDocNum,'') + ''' and Det.TRXSORCE = Cab.TRXSORCE and Det.DOCNUMBR = Cab.DOCNUMBR and Det.DOCTYPE = Cab.IVDOCTYP and
      Com.CMPANYID = ''' + CONVERT(VARCHAR(10),@CompID) + /* + str('Company ID' of globals) +*/ '''  Order By Det.LNSEQNBR ' 


      EXEC (@cQry)

      IF @in_Batch = 'Inventory'
      BEGIN 
            set @lDocTypeNew = 'Packing List'
      END 
      ELSE IF @in_Batch = 'Inventario'
      BEGIN 
            set @lDocTypeNew = 'Lista de remisión'
      END 
/*
      SET @lMaxXPage = FUNC_Get_Parameters_Documento(@in_sTipoDocumento, 'LINEPERPAGE', 0)
      IF @lMaxXPage=0 
      BEGIN
            SET @lMaxXPage = FUNC_Get_Parameters_General( 'LINEPERPAGE', 0 )
            IF @lMaxXPage=0 
            BEGIN
                  SET @lMaxXPage = 10
            END 
      END 
      SELECT @iRecCount = COUNT(*) FROM XDL90102


      /*
      release table XDL_Impr_Trx
      set 'XDL Tipo Documento' of table XDL_Impr_Trx
            to @in_sTipoDocumento
      set 'XDL GP DocNumber' of table XDL_Impr_Trx
            to @in_sDocNum
      set 'Document ID' of table XDL_Impr_Trx 
            to @in_DocID
      set 'User ID' of table XDL_Impr_Trx
            to str('User ID' of globals)
      change first table XDL_Impr_Trx by XDL_Impr_Trx_Key2
      while err() = OKAY do
      */
            IF @lMaxXPage = 1 
            BEGIN
                  IF @lContador > @lMaxXPage 
                  BEGIN
                        SET @lNumPagina = @lNumPagina + 1
                  END 
            END
            ELSE
            BEGIN
                  IF 'XDL Re-Printing' of table @XDL_Impr_Trx = 1 
                  BEGIN
                        IF @lContador > @lMaxXPage 
                        BEGIN
                              SET @lContador = 1
                              SET @lNumPagina = @lNumPagina + 1
                        END
                  ELSE
                  BEGIN
                        IF @lContador > @lMaxXPage AND (@lContador > @iRecCount OR @lContador > @lNumeroCopias) 
                        BEGIN
                              SET @lContador = 1
                              SET @lNumPagina = @lNumPagina + 1
                        END
                  END         
            END 

                  IF @lNumPagina = 1 
                  BEGIN
                        SET @lPageFmt = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 1', 0)                  
                  END
                  IF @lNumPagina = 2 
                  BEGIN
                        SET @lPageFmt = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 2', 0)                  
                  END
                  IF @lNumPagina = 3 
                  BEGIN
                        SET @lPageFmt = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 3', 0)                  
                  END  */
      /*
                        SET 'XDL Config Value' OF TABLE XDL_Impr_Trx  to @lPageFmt
                        SET 'XDL Numero Linea' OF TABLE XDL_Impr_Trx  to @lNumPagina
            save table XDL_Impr_Trx
            SET @lContador = @lContador + 1

            change next table XDL_Impr_Trx by XDL_Impr_Trx_Key2    

      END */



      /*
      release table XDL_Reports_Path
      set 'Batch Source' of table XDL_Reports_Path 
            to in_Batch
      set 'Document ID' of table XDL_Reports_Path
            to ''
      set 'XDL SOP Type' of table XDL_Reports_Path 
            to {XDL_TRANSFER}1
      set 'XDL Letra Documento' of table XDL_Reports_Path 
            to in_sLetraDocumento
      get table XDL_Reports_Path
      if err() = OKAY then
      */
/*

                  SET @lNumeroCopias = value(FUNC_Get_Parameters_Documento( @in_sTipoDocumento, 'PRINTCOPY', 0))
                  IF @lNumeroCopias = 0 
                  BEGIN
                        SET @lNumeroCopias = 1
                  END 

                  SET @i = 1
                  WHILE @i > @lNumeroCopias 
                  BEGIN
                        SET @lDsPage = FUNC_Get_Parameters_General( 'PAGE' + str(@i), 0, 'PAGE')
                        IF @lDsPage=0 
                        BEGIN
                              SET @lDsPage = str(@i)
                        END */
                        UPDATE XDL90100 SET USERID=@UserID , SOPTYPE=3 WHERE XDL_GP_DocNumber = @in_sDocNum AND XDL_Tipo_Documento = @in_sTipoDocumento /*AND XDLNUCO = @i AND XDLCPDS = @lDsPage*/
                  /*END
                  SET @l_DosDS = Get_Parameters_Documento(@in_sTipoDocumento, XDL_PARAM_DOCDS, 0)
                  IF @l_DosDS = 0 
                  BEGIN
                        set @l_formulas = 'TipoCpbte = ''' + @in_sTipoDocumento + ''''
                  END 
                  
                  SET @l_Parametros = 'Usuario' + @UserID + '|Letra Documento' + str(@in_sLetraDocumento)
            */    
            /*    call X_ReporteCrystal,'XDL Ruta Reporte' of table XDL_Reports_Path, l_Parametros, l_formulas,lNumeroCopias  */
                  SET @out_Error = 0

      /*
      else
            l_message = getmsg(22013);
            substitute l_message, str( "" ), in_sLetraDocumento;
            warning( l_message );
            set out_Error to true;
            abort script;
      end if;
      */

/* Uri Baba */
		select * INTO #Temp from XDL90102
		SET @lPageFmt = ''
		SET @lNumCopies = ''
        SET @lNumeroCopias = 1
		IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PRINTCOPY')
			BEGIN
				SELECT TOP 1 @lNumCopies=isnull(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PRINTCOPY'
				SET @lNumeroCopias = convert(int,@lNumCopies)
			END
		IF LTRIM( RTRIM(@lNumCopies)) = '' OR @lNumCopies = NULL
			BEGIN
				SET @lNumeroCopias = 1
			END
		SET @i = 1		
		WHILE @i<=@lNumeroCopias 
        BEGIN
			
			IF @i = 1
			BEGIN
				SET @lPageFmt = ''
				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 1')
					BEGIN
						SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 1'
					END
				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1'
						END
					END
			END
			IF @i = 2
			BEGIN
				SET @lPageFmt = ''
				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 2')
					BEGIN
						SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 2'
					END
				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 2')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 2'
						END
					END
			END
			IF @i = 3
			BEGIN
				SET @lPageFmt = ''
				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 3')
					BEGIN
						SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 3'
					END
				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 3')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 3'
						END
					END
			END
			IF LTRIM( RTRIM(@lPageFmt)) <> '' OR @lPageFmt <> NULL
			BEGIN
				IF @i = 1
				BEGIN
					update XDL90102 set XDLDSCFG = @lPageFmt,XDLNULINE = @i
				END
				ELSE 
				BEGIN
					/*select XDLDSCFG,* from #Temp*/
					IF @i > 3
					BEGIN
						SET @SubChar = convert(VARCHAR,@i)
						SET @lPageFmt = convert(VARCHAR,@lPageFmt) + @SubChar
					END
					update #Temp set XDLDSCFG = @lPageFmt, XDLNULINE = @i

					INSERT INTO [XDL90102]  ([XDL_Tipo_Documento],[XDL_GP_DocNumber],[DOCID],[TRXSORCE] ,[DOCTYPE],[DOCNUMBR]
							   ,[DOCDATE],[ITEMNMBR],[LNSEQNBR],[UOFM],[TRXQTY] ,[TRXLOCTN],[XDLDSCFG] ,[TRNSTLOC] ,[CAI],[CodPostCom]
							   ,[Compania],[CUITCom],[CUITIIBB],[DirCom],[EstadoCom],[FaxCom],[FecCpbte],[LocaCom] ,[PaisCom],[Remito]
							   ,[TelefonoCom],[Usuario],[NOTEINDX],[XCHGRATE],[XDLNULINE],[EXCHDATE],[CMPANYID],[NUMRPRIN],[USERID])
					      
						SELECT [XDL_Tipo_Documento],[XDL_GP_DocNumber] ,[DOCID],[TRXSORCE] ,[DOCTYPE],[DOCNUMBR],[DOCDATE],[ITEMNMBR],[LNSEQNBR]
							   ,[UOFM],[TRXQTY],[TRXLOCTN],[XDLDSCFG] ,[TRNSTLOC],[CAI] ,[CodPostCom] ,[Compania] ,[CUITCom] ,[CUITIIBB]
							   ,[DirCom],[EstadoCom],[FaxCom],[FecCpbte],[LocaCom] ,[PaisCom],[Remito],[TelefonoCom] ,[Usuario],[NOTEINDX]
							   ,[XCHGRATE],[XDLNULINE],[EXCHDATE] ,[CMPANYID],[NUMRPRIN],[USERID] from #Temp
				END
			END
			SET @i = @i + 1
		END
		drop table #Temp

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_Imprime_TRX] TO [DYNGRP] 
GO 

/*End_SP_XDL_Imprime_TRX*/

/*Begin_SP_XDL_Proceso_Impresion*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_Proceso_Impresion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_Proceso_Impresion]
go

CREATE PROCEDURE SP_XDL_Proceso_Impresion
@in_sDocNumber          VARCHAR(100),
@in_sTipoDocumento      VARCHAR(100),
@in_sLetraDocumento           VARCHAR(100),
@in_l_Docdate           DATETIME,
@out_l_CAI              VARCHAR(100) OUTPUT,
@out_l_DueDateCAI       DATETIME OUTPUT

AS
BEGIN
      DECLARE
      @l_Is_Awli_Installed      BIT,
      @l_errstatus            BIT,
      @XDL_CAI                VARCHAR(400),
      @XDL_CAI_Due_Date         DATETIME
      /*IF NOT EXISTS (SELECT TOP 1 1 from DYNAMICS..DU000020 WHERE PRODID = 9883 ) RETURN*/
	if  not exists (select * from dbo.sysobjects where id = object_id(N'[AWLI_RM00103]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
      BEGIN
            RETURN
      END


        IF @in_l_Docdate=NULL BEGIN SET @in_l_Docdate='1900-01-01 00:00:00.000' END

      set @l_errstatus = 1
      set @out_l_CAI = ''
      SELECT @out_l_DueDateCAI = NULL,@XDL_CAI_Due_Date=NULL


      SELECT TOP 1 @XDL_CAI=XDL_CAI, @XDL_CAI_Due_Date=XDL_CAI_Due_Date FROM XDL10101 WHERE XDL_GP_DocNumber= @in_sDocNumber AND XDL_Tipo_Documento= @in_sTipoDocumento 


      IF @XDL_CAI='' AND @XDL_CAI_Due_Date=''
      BEGIN
            EXEC SP_XDL_ToValidate_CAI @in_sTipoDocumento, @in_sLetraDocumento, @in_l_Docdate, @l_errstatus OUTPUT, @in_sDocNumber, '', '', @out_l_CAI OUTPUT, @out_l_DueDateCAI OUTPUT
      END
      ELSE
      BEGIN
            SET @out_l_CAI = @XDL_CAI
            SET @out_l_DueDateCAI = @XDL_CAI_Due_Date
      END

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_Proceso_Impresion] TO [DYNGRP] 
GO 

/*End_SP_XDL_Proceso_Impresion*/

/*Begin_SP_XDL_Imprime_Doc*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_Imprime_Doc]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_Imprime_Doc]
go

CREATE PROCEDURE SP_XDL_Imprime_Doc
@in_sDocNumber          VARCHAR(400),
@in_sTipoDocumento            VARCHAR(400),
@in_sLetraDocumento           VARCHAR(400),
@in_DocID               VARCHAR(400),
@in_SopType             SMALLINT,
@in_Batch               VARCHAR(400),
@in_PathReport          VARCHAR(400),
@in_InvDocNumber        VARCHAR(400),
@out_Error              VARCHAR(400) OUTPUT,   /* Error */

@Oin_sLetraDocumentoExterno VARCHAR(400) OUTPUT,
@Oin_sTipoPadreRemito       VARCHAR(400) OUTPUT,

@UserID VARCHAR(400),
@CompID SMALLINT
AS
BEGIN

      DECLARE
      @l_records_count                                      INTEGER,  
      @lTypeTrue                                BIT , 
      @l_errstatus                              BIT, 
      @cQry                                     VARCHAR(4000), 
      @cSelQry                                  VARCHAR(4000), 
      @cFinal                                   VARCHAR(4000),
      @lresp                                    INTEGER, 
      @l_DocType                                INTEGER, 
      @i                                        INTEGER,
      @cRuta                                    VARCHAR(400), 
      /*@l_message                                VARCHAR(400),  */
      @l_letra                                  VARCHAR(400), 
      @cReporte                                 VARCHAR(400), 
      @lDsPage                                  VARCHAR(400), 
      @l_SQLWhere                               VARCHAR(400), 
      @l_RutaReport                             VARCHAR(400),
      @lPageFmt                                 VARCHAR(400),
      @cPath                                    VARCHAR(400), 
      @l_DocID                                  VARCHAR(400), 
      /*@l_Parametros                             VARCHAR(400), */
      @l_DocDesc                                VARCHAR(400), 
       /*@l_formulas                               VARCHAR(400),
      @l_DosDS                                  VARCHAR(400),  */
      @lFechaYYYYMMDD                           VARCHAR(400), 
      @l_Anio                                   VARCHAR(400),
      @l_Mes                                    VARCHAR(400), 
      @l_Dia                                    VARCHAR(400),
      @acum                                     INTEGER, 
      @lContador                                INTEGER, 
      @lNumPagina                               INTEGER, 
      @lMaxXPage1                               INTEGER,
	  @lMaxXPage                                VARCHAR(400),  
      @lNumeroCopias                            INTEGER, 
      @AWLI_LETRA                               INTEGER, 
      @AWLI_Docnmbr                             INTEGER,
      @l_CAI                                    VARCHAR(400),
      @l_DueDateCAI                             DATETIME,
      @sTipoDocumento_CAI                       VARCHAR(400),
      @sTipoDocumento_Pack                      VARCHAR(400),
      @l_tipo_Tal                               VARCHAR(400),
      @l_XDL_Return_ReasonCode_Desc             VARCHAR(400),
      @XDL_CAI                                  VARCHAR(4000), 
      @XDL_CAI_Due_Date                                     DATETIME,
      @SOPTYPE1                                 VARCHAR(400), 
      @XDL_Letra_Documento                                  VARCHAR(400), 
      @DOCID1                                   VARCHAR(400),
      @BCHSOURC1                                VARCHAR(400),
      @DOCDATE2                                 DATETIME,
      @SUBTOTAL2                                NUMERIC(19,5), 
      @TAXAMNT2                                 NUMERIC(19,5),
      @ORTAXAMT2                                NUMERIC(19,5),
      @DOCAMNT2                                 NUMERIC(19,5),
      @ORDOCAMT2                                NUMERIC(19,5),
      @CURNCYID2                                CHAR(15),
	  @Comp										INTEGER,
      @Cont										INTEGER,
	  @XDL_Imp									INTEGER,
      @lNumCopies								VARCHAR(400),
		@DexRow									INTEGER



      SELECT @lContador = 1, @lNumPagina = 1, @out_Error = 0,@Cont = 1	
	  	

      IF @Oin_sLetraDocumentoExterno <> '' 
      BEGIN
            SET @l_letra = @Oin_sLetraDocumentoExterno
      END
      ELSE
      BEGIN
            SET @l_letra = @in_sLetraDocumento
      END

	if  exists (select * from dbo.sysobjects where id = object_id(N'[AWLI_RM00103]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
      BEGIN
            EXEC SP_XDL_To_Get_Letter @l_letra,@AWLI_LETRA OUTPUT
            EXEC SP_XDL_To_Get_VoucherType @in_sTipoDocumento,@AWLI_Docnmbr OUTPUT
      END

/*
      SET @cQry = ''
      SET @cQry = @cQry + ' DELETE XDL91101 WHERE Usuario = ''' + @UserID + ''' '
      EXEC (@cQry)


      SET @cQry = ''
      SET @cQry = @cQry + ' DELETE XDL90100 WHERE USERID = ''' + @UserID + ''' '
      EXEC (@cQry)
*/



      SET @cQry = ''
      SET @cQry = @cQry + ' Insert into XDL91101 (Tipo, XDL_DocNumber, ERMSGTXT, NroCpbte, FecCpbte, CondPago, DirOrig, Cliente, RazSocial, Direccion,  
      Localidad, Estado, CodPost, Pais, SubTotal, Impuestos, Total, Territorio, Vendedor, CURNCYID, CURRNIDX, NOTEINDX, OrdCpra, Comentario, SHIPMTHD, 
      Linea, NroArt, DetArt, DirOrigArt, Cantidad, Unidad, Descuento, PrecUnitArt, ImpArt, TotalArt, TerritorioArt, VendedorArt, CUIT, Letra, 
      Remito, Usuario, Compania, CUITCom, CUITIIBB, DirCom, LocaCom, EstadoCom, CodPostCom, PaisCom, TelefonoCom, FaxCom, EXCHDATE, XCHGRATE, CAI, 
      XDLNULINE, SERLTNUM, SERLTQTY, ORIGNUMB, SLTSQNUM, ORUNTPRC, OXTNDPRC, ORTAXAMT) '


      SET @cSelQry = ' '
      SET @cSelQry = @cSelQry + ' SELECT distinct  Cab.SOPTYPE Tipo, ''' + ISNULL(@in_InvDocNumber,'') + ''', '
      EXEC SP_XDL_Return_ReasonCode_Desc @in_sDocNumber,@in_SopType,@l_XDL_Return_ReasonCode_Desc OUTPUT
      SET @cSelQry = @cSelQry + '''' + ISNULL(@l_XDL_Return_ReasonCode_Desc,'') + ''', Trx.XDL_GP_DocNumber, '
      IF  @in_sTipoDocumento = 'Packing List' OR @in_sTipoDocumento = 'Lista de remisión'
      BEGIN
         SET @cSelQry = @cSelQry + ' Trx.XDL_Remito_Created_Date FecCpbte, '
      END
      ELSE
      BEGIN
         SET @cSelQry = @cSelQry + ' Cab.DOCDATE FecCpbte, '
      END
      SET @cSelQry = @cSelQry + ' Cab.PYMTRMID CondPago, Cab.LOCNCODE DirOrig, Cab.CUSTNMBR Cliente, Cab.CUSTNAME RazSocial, Cab.ADDRESS1 Direccion, 
      Cab.CITY Localidad, Cab.STATE Estado, Cab.ZIPCODE CodPost, Cab.COUNTRY Pais, Cab.SUBTOTAL SubTotal, Cab.TAXAMNT Impuestos, Cab.DOCAMNT Total, 
      Cab.SALSTERR Territorio, Cab.SLPRSNID Vendedor, Cab.CURNCYID CURNCYID, Cab.CURRNIDX CURRNIDX, Cab.NOTEINDX, Cab.CSTPONBR OrdCpra, Cab.COMMNTID Comentario, 
      Cab.SHIPMTHD MetodoEnvio, Det.LNITMSEQ Linea, Det.ITEMNMBR NroArt, Det.ITEMDESC DetArt, Det.LOCNCODE DirOrigArt, Det.QUANTITY Cantidad, Det.UOFM Unidad, 
      Det.MRKDNAMT Descuento, Det.UNITPRCE PrecUnitArt, Det.TAXAMNT ImpArt, Det.XTNDPRCE TotalArt, Det.SALSTERR TerritorioArt, Det.SLPRSNID VendedorArt, 
      Cli.TXRGNNUM CUIT, ''' + ISNULL(@l_letra,'') + ''' Letra, 
      Trx.XDL_Remito_DocNumber Remito, ''' + ISNULL(@UserID,'') + ''' Usuario, Com.CMPNYNAM Compania, Com.TAXREGTN CUITCom, Com.UDCOSTR1 CUITIIBB, 
      (RTRIM(Com.ADDRESS1) + RTRIM(Com.ADDRESS2) + RTRIM(Com.ADDRESS3))  DirCom, Com.CITY LocaCom, Com.STATE EstadoCom, Com.ZIPCODE CodPostCom, 
      Com.CMPCNTRY PaisCom, (Com.PHONE1 + '' '' + Com.PHONE2 + '' '' + Com.PHONE3) TelefonoCom, Com.FAXNUMBR FaxCom, Cab.EXCHDATE EXCHDATE, 
      Cab.XCHGRATE XCHGRATE, ''N/C'',  0,isnull(LOT.SERLTNUM, ''''), isnull( (SELECT EQUOMQTY * LOT.SERLTQTY FROM IV40202 WHERE EQUIVUOM  in  
      ( SELECT UOFM FROM IV40202 WHERE UOMSCHDL = ART.UOMSCHDL and QTYBSUOM = 1.0000 and EQUOMQTY = 1.0000 and UOFM = EQUIVUOM ) AND UOFM  = Det.UOFM AND UOMSCHDL = ART.UOMSCHDL ), 0), 
       Cab.ORIGNUMB, isnull(LOT.SLTSQNUM, 0), Det.ORUNTPRC,  Det.OXTNDPRC,  Det.ORTAXAMT   
       FROM RM00101 Cli, DYNAMICS.dbo.SY01500 Com, (XDL10101  Trx inner join SOP30200 Cab on Cab.SOPNUMBE = Trx.XDL_DocNumber  
      inner join SOP30300 Det on Det.SOPTYPE = Cab.SOPTYPE and Det.CMPNTSEQ = 0  ) left outer join SOP10201 LOT on LOT.SOPTYPE =  
      Cab.SOPTYPE and LOT.SOPNUMBE = Cab.SOPNUMBE and LOT.LNITMSEQ = Det.LNITMSEQ LEFT OUTER JOIN IV00101 ART ON ART.ITEMNMBR = Det.ITEMNMBR  '


      IF @in_sDocNumber <> @in_InvDocNumber  
      BEGIN
            SET @cSelQry = @cSelQry + ' WHERE   Trx.XDL_DocNumber = ''' + @in_InvDocNumber + ''' '
      END
      ELSE
      BEGIN
            SET @cSelQry = @cSelQry + ' WHERE   Trx.XDL_DocNumber = ''' + @in_sDocNumber + ''' '
      END
      SET @cSelQry = @cSelQry + ' and Trx.XDL_Letra_Documento = ''' + @in_sLetraDocumento + ''' '
      /* IF @in_sTipoDocumento = 'Packing List'
      BEGIN
            SET @cSelQry = @cSelQry + ' and Trx.XDL_Tipo_Documento = ''' + @in_sTipoDocumento + ''' '
      END
      ELSE
      BEGIN */
            SET @cSelQry = @cSelQry + ' and Trx.XDL_Tipo_Documento = ''' + @in_sTipoDocumento + ''' '
      /*END*/
      SET @cSelQry= @cSelQry + ' and Cab.SOPTYPE = ' + CONVERT(VARCHAR(10),@in_SopType) + ' and Det.SOPNUMBE = Trx.XDL_DocNumber and Det.SOPTYPE = Cab.SOPTYPE and Cli.CUSTNMBR = Cab.CUSTNMBR  '

        SET @cSelQry= @cSelQry + ' and Com.CMPANYID = ' + CONVERT(VARCHAR(10),(SELECT ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME()))


      IF /*@lTypeTrue = 1 true and*/ @in_sTipoDocumento = 'Packing List' OR @in_sTipoDocumento ='Lista de remisión'
      BEGIN
            SET @cSelQry = @cSelQry + ' and ART.ITEMTYPE = 1 '
      END 

      EXEC (@cQry+@cSelQry)

      /*
      @lMaxXPage = FUNC_Get_Parameters_Documento(@in_sTipoDocumento, 'LINEPERPAGE', 0)
      IF NOT EXISTS (@lMaxXPage) 
            @lMaxXPage = FUNC_Get_Parameters_General( 'LINEPERPAGE', 0 )

      IF NOT EXISTS (@lMaxXPage)
      BEGIN
            @lMaxXPage = 10
      END
      */
      /*24/09/10BAAL*/
	IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'LINEPERPAGE')
		BEGIN
			SELECT TOP 1 @lMaxXPage=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'LINEPERPAGE'
			SET @lMaxXPage1 = convert(int,@lMaxXPage)
		END
	IF LTRIM( RTRIM(@lMaxXPage)) = '' OR @lMaxXPage = NULL
		BEGIN
			SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
			IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'LINEPERPAGE')
			BEGIN
				SELECT TOP 1 @lMaxXPage=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'LINEPERPAGE'
				SET @lMaxXPage1 = convert(int,@lMaxXPage)
			END
		END
	IF LTRIM( RTRIM(@lMaxXPage)) = '' OR @lMaxXPage = NULL
		BEGIN
			SET @lMaxXPage1 = 10
		END
      IF EXISTS ( SELECT TOP 1 1 From XDL91101 Where  NroCpbte = @in_sDocNumber and Tipo =  @in_SopType ) 
      BEGIN
            DECLARE CImprime CURSOR FAST_FORWARD FOR

            SELECT XDLNULINE,DEX_ROW_ID From XDL91101 Where NroCpbte = @in_sDocNumber and Tipo =  @in_SopType 

            OPEN CImprime 
                        FETCH NEXT FROM CImprime into @XDL_Imp,@DexRow
                        WHILE @@FETCH_STATUS =0
                        BEGIN
							 IF @Cont > @lMaxXPage1
                                BEGIN 
									SET  @Cont = 1
									SET @lNumPagina = @lNumPagina + 1                                     
                                END
							  UPDATE XDL91101 SET XDLNULINE= @lNumPagina WHERE NroCpbte = @in_sDocNumber and Tipo =  @in_SopType AND DEX_ROW_ID = @DexRow
                              SET  @Cont = @Cont + 1								
                        
                        FETCH NEXT FROM CImprime into @XDL_Imp,@DexRow
						END
                        CLOSE CImprime
                        DEALLOCATE CImprime
      END
	/*24/09/10*/
      SELECT TOP 1 @DOCDATE2 = DOCDATE, @SUBTOTAL2=SUBTOTAL, @TAXAMNT2=TAXAMNT,@ORTAXAMT2=ORTAXAMT,@DOCAMNT2=DOCAMNT,@ORDOCAMT2=ORDOCAMT,@CURNCYID2=CURNCYID FROM SOP30200 WHERE SOPTYPE = @in_SopType AND SOPNUMBE = @in_InvDocNumber


      SET @sTipoDocumento_CAI=@in_sTipoDocumento;
      IF (@in_sTipoDocumento = 'Packing List') and @l_letra <> 'R' 
      BEGIN
            SET @sTipoDocumento_CAI='Invoice';
      END 
      ELSE IF (@in_sTipoDocumento ='Lista de remisión') and @l_letra <> 'R' 
      BEGIN
            SET @sTipoDocumento_CAI='Factura';
      END 



      IF EXISTS (SELECT TOP 1 1 FROM XDL10101 WHERE XDL_GP_DocNumber= @in_sDocNumber AND XDL_Tipo_Documento= @in_sTipoDocumento AND XDL_Letra_Documento = @in_sLetraDocumento)
      BEGIN
            SELECT TOP 1 @XDL_CAI=XDL_CAI, @XDL_CAI_Due_Date=XDL_CAI_Due_Date,@SOPTYPE1=SOPTYPE, @DOCID1=DOCID, @BCHSOURC1=BCHSOURC
                  FROM XDL10101 WHERE XDL_GP_DocNumber= @in_sDocNumber AND XDL_Tipo_Documento= @in_sTipoDocumento AND XDL_Letra_Documento = @in_sLetraDocumento

            IF @XDL_CAI='' AND @XDL_CAI_Due_Date='' 
            BEGIN
                  IF @in_sTipoDocumento = 'Packing List' OR @in_sTipoDocumento ='Lista de remisión'
                  BEGIN
                        EXEC SP_XDL_To_Get_Tipodocument @SOPTYPE1, @DOCID1, @BCHSOURC1, @sTipoDocumento_Pack OUTPUT
                  END
                  ELSE
                  BEGIN 
                        SET @sTipoDocumento_Pack=@in_sTipoDocumento
                  END
                  EXEC SP_XDL_ToValidate_CAI @sTipoDocumento_Pack,@in_sLetraDocumento, @DOCDATE2, @l_errstatus OUTPUT,@in_sDocNumber,'' ,'' ,@l_CAI OUTPUT,@l_DueDateCAI OUTPUT
            END
            ELSE
            BEGIN
                  SET @l_CAI = @XDL_CAI
                  SET @l_DueDateCAI = @XDL_CAI_Due_Date
            END
      END
	/*24/09/10BAAL*/
		IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PRINTCOPY')
			BEGIN
				SELECT TOP 1 @lNumCopies=isnull(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PRINTCOPY'
				SET @lNumeroCopias = convert(int,@lNumCopies)
			END

		IF LTRIM( RTRIM(@lNumCopies)) = '' OR @lNumCopies = NULL
			BEGIN
				SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
				IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PRINTCOPY')
				BEGIN
					SELECT TOP 1 @lNumCopies=isnull(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PRINTCOPY'
					SET @lNumeroCopias = convert(int,@lNumCopies)
				END
			END
		IF LTRIM( RTRIM(@lNumCopies)) = '' OR @lNumCopies = NULL
			BEGIN
				SET @lNumeroCopias = 1
			END

		SET @i = 1		
		WHILE @i<=@lNumeroCopias
        BEGIN

				SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
				IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1')
				BEGIN
					SELECT TOP 1 @lDsPage=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1'
				END
				ELSE IF	EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE XDLIDCFG = 'PAGE')
				BEGIN
					SELECT TOP 1 @lDsPage=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE XDLIDCFG = 'PAGE'
				END
 
				IF LTRIM( RTRIM(@lDsPage)) = '' OR @lDsPage = NULL
				BEGIN
					SET @lDsPage = convert(VARCHAR,@i)
				END
			IF @i = 1
			BEGIN
				SET @lPageFmt = ''
				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 1')
					BEGIN
						SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 1'
					END

				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1'
						END
					END
			END
			IF @i = 2
			BEGIN
				SET @lPageFmt = ''

				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 2')
					BEGIN
						SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 2'
					END

				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 2')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 2'
						END
					END
			END
			IF @i = 3
			BEGIN
				SET @lPageFmt = ''

				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 3')
					BEGIN
						SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 3'
					END

				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 3')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 3'
						END
					END
			END
			  /*IF NOT EXISTS (SELECT TOP 1 1 FROM XDL90100 WHERE XDL_Tipo_Documento=@in_sTipoDocumento AND XDL_GP_DocNumber= @in_sDocNumber /*AND XDL_DocNumber=@in_InvDocNumber*/ AND
								XDLNUCO=@i AND XDLCPDS = @lDsPage AND USERID = @UserID)
			  BEGIN
					INSERT INTO XDL90100 (SOPTYPE,SUBTOTAL, TAXAMNT ,ORTAXAMT ,DOCAMNT,ORDOCAMT,
								FUNLCURR,CURNCYID,XDL_CAI,XDL_CAI_Due_Date,XDL_Tipo_Documento,XDL_GP_DocNumber,XDL_DocNumber,XDLNUCO,USERID,XDLCPDS)
								SELECT @in_SopType,@SUBTOTAL2,@TAXAMNT2,@ORTAXAMT2,@DOCAMNT2,@ORDOCAMT2,
								(SELECT TOP 1 Euro_Currency_ID FROM DYNAMICS.dbo.MC40400),@CURNCYID2,ISNULL(@l_CAI,''),ISNULL(@l_DueDateCAI,''),@in_sTipoDocumento,@in_sDocNumber,@in_InvDocNumber,ISNULL(@i,0),@UserID,@lDsPage
	                            

			  END
			  ELSE
			  BEGIN
				  UPDATE XDL90100 SET SOPTYPE=@in_SopType,SUBTOTAL=@SUBTOTAL2, TAXAMNT = @TAXAMNT2,ORTAXAMT = @ORTAXAMT2,DOCAMNT=@DOCAMNT2,ORDOCAMT=@ORDOCAMT2,
						FUNLCURR=(SELECT TOP 1 Euro_Currency_ID FROM MC40400),CURNCYID=@CURNCYID2,XDL_CAI=@l_CAI,XDL_CAI_Due_Date=@l_DueDateCAI
						WHERE XDL_Tipo_Documento=@in_sTipoDocumento AND XDL_GP_DocNumber= @in_sDocNumber /*AND XDL_DocNumber=@in_InvDocNumber*/ AND
						XDLNUCO=@i AND XDLCPDS = @lDsPage AND USERID = @UserID

			  END*/

					INSERT INTO XDL90100 (SOPTYPE,SUBTOTAL, TAXAMNT ,ORTAXAMT ,DOCAMNT,ORDOCAMT,
								FUNLCURR,CURNCYID,XDL_CAI,XDL_CAI_Due_Date,XDL_Tipo_Documento,XDL_GP_DocNumber,XDL_DocNumber,XDLNUCO,USERID,/*XDLCPDS,*/XDLDSCFG)
								SELECT @in_SopType,@SUBTOTAL2,@TAXAMNT2,@ORTAXAMT2,@DOCAMNT2,@ORDOCAMT2,
								ISNULL((SELECT TOP 1 Euro_Currency_ID FROM DYNAMICS.dbo.MC40400),''),@CURNCYID2,ISNULL(@l_CAI,''),ISNULL(@l_DueDateCAI,''),@in_sTipoDocumento,@in_sDocNumber,@in_InvDocNumber,@i,@UserID,/*ISNULL(@lDsPage,''),*/ISNULL(@lPageFmt,'')
			SET @i = @i + 1
		END
      /*/*24/09/10BAAL*/
      IF EXISTS(SELECT TOP 1 1 FROM XDL00107 WHERE BCHSOURC=@in_Batch AND DOCID=@in_DocID AND XDL_SOP_Type=@in_SopType AND XDL_Letra_Documento=@l_letra)
      BEGIN 
            SET @lNumeroCopias = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, 'PRINTCOPY', 0)
            if @lNumeroCopias = 0   
            BEGIN
                  SET @lNumeroCopias = FUNC_Get_Parameters_General( 'PRINTCOPY', 0 )
            END
            IF @lNumeroCopias = 0 
            BEGIN
                  SET @lNumeroCopias = 1
            END

            SET @i = 1
            WHILE @i=@lNumeroCopias 
            BEGIN
                  SET @lDsPage = FUNC_Get_Parameters_General( 'PAGE' + str(@i), 0, 'PAGE')
                  IF @lDsPage='' 
                  BEGIN
                        SET @lDsPage = str(@i)
                  END 
                  IF @i = 1 
                  BEGIN
                        SET @lPageFmt = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 1', 0)                  
                        IF @lPageFmt=0 
                        BEGIN
                              SET @lPageFmt = FUNC_Get_Parameters_General('PAGE 1', 0 )
                        END 
                  END 
                  IF @i = 2 
                  BEGIN
                        SET @lPageFmt = Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 2', 0);                 
                        IF @lPageFmt=0 
                        BEGIN
                              SET @lPageFmt = FUNC_Get_Parameters_General('PAGE 2', false ));
                        END   
                  END 
                  IF @i = 3 
                  BEGIN
                        SET @lPageFmt = Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 3', 0);                 
                        IF @lPageFmt=0 
                        BEGIN
                              SET @lPageFmt = FUNC_Get_Parameters_General('PAGE 3', 0 ));
                        END         
                  END 
      */

       /*           IF not EXISTS (SELECT TOP 1 1 FROM XDL90100 WHERE XDL_Tipo_Documento=@in_sTipoDocumento AND XDL_GP_DocNumber= @in_sDocNumber AND XDL_DocNumber=@in_InvDocNumber AND
                                    XDLNUCO=@i /*AND XDLCPDS = @lDsPage*/ AND USERID = @UserID)
                  BEGIN
                        INSERT INTO XDL90100 (SOPTYPE,SUBTOTAL, TAXAMNT ,ORTAXAMT ,DOCAMNT,ORDOCAMT,
                                    FUNLCURR,CURNCYID,XDL_CAI,XDL_CAI_Due_Date,XDL_Tipo_Documento,XDL_GP_DocNumber,XDL_DocNumber,XDLNUCO,USERID)
                                    SELECT @in_SopType,@SUBTOTAL2,@TAXAMNT2,@ORTAXAMT2,@DOCAMNT2,@ORDOCAMT2,
                                    (SELECT TOP 1 Euro_Currency_ID FROM DYNAMICS.dbo.MC40400),@CURNCYID2,ISNULL(@l_CAI,''),ISNULL(@l_DueDateCAI,''),@in_sTipoDocumento,@in_sDocNumber,@in_InvDocNumber,ISNULL(@i,0),@UserID
                                    

                  END
                  ELSE
                  BEGIN
                              UPDATE XDL90100 SET SOPTYPE=@in_SopType,SUBTOTAL=@SUBTOTAL2, TAXAMNT = @TAXAMNT2,ORTAXAMT = @ORTAXAMT2,DOCAMNT=@DOCAMNT2,ORDOCAMT=@ORDOCAMT2,
                                    FUNLCURR=(SELECT TOP 1 Euro_Currency_ID FROM MC40400),CURNCYID=@CURNCYID2,XDL_CAI=@l_CAI,XDL_CAI_Due_Date=@l_DueDateCAI
                                    WHERE XDL_Tipo_Documento=@in_sTipoDocumento AND XDL_GP_DocNumber= @in_sDocNumber AND XDL_DocNumber=@in_InvDocNumber /*AND
                                    XDLNUCO=@i*/ AND USERID = @UserID

                  END
            SET @i = @i + 1*/
            /*END*/


      /*
            @l_DosDS = FUNC_Get_Parameters_Documento(@in_sTipoDocumento, XDL_PARAM_DOCDS, 0)
            IF @l_DosDS=0 
            BEGIN
                  set @l_formulas = 'ReceiptType = ''''' + @in_sTipoDocumento + ''''
            END 
            set @l_Parametros = 'User;' +  @UserID + '|Letra Documento;' + @l_letra
            
            /*call X_ReporteCrystal,'XDL Ruta Reporte' of table XDL_Reports_Path,l_Parametros,l_formulas,lNumeroCopias;*/
            
      END
      ELSE
      BEGIN
            @l_message = @in_DocID + ' setup has not been performed.'
            /*warning( @l_message )*/
            /*set out_Error to true;
            abort script; */
      RETURN
      END
      */
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_Imprime_Doc] TO [DYNGRP] 
GO 

/*End_SP_XDL_Imprime_Doc*/

/*Begin_SP_XDL_Imprime_Doc1*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_XDL_Imprime_Doc1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_XDL_Imprime_Doc1]
go

CREATE PROCEDURE SP_XDL_Imprime_Doc1
@in_sDocNumber          VARCHAR(400),
@in_sTipoDocumento            VARCHAR(400),
@in_sLetraDocumento           VARCHAR(400),
@in_DocID               VARCHAR(400),
@in_SopType             SMALLINT,
@in_Batch               VARCHAR(400),
@in_PathReport          VARCHAR(400),
@in_InvDocNumber        VARCHAR(400),
@out_Error              VARCHAR(400) OUTPUT,   /* Error */

@Oin_sLetraDocumentoExterno VARCHAR(400) ,
@Oin_sTipoPadreRemito         VARCHAR(400),

@UserID VARCHAR(400),
@CompID INTEGER
AS
BEGIN
      DECLARE
      @l_records_count                                      INTEGER,  
      @lTypeTrue                                BIT , 
      @l_errstatus                              BIT, 
      @cQry                                     VARCHAR(4000), 
      @cSelQry                                  VARCHAR(4000), 
      @cFinal                                   VARCHAR(4000),
      @lresp                                    INTEGER, 
      @l_DocType                                INTEGER, 
      @i                                        INTEGER,
      @cRuta                                    VARCHAR(400), 
     /* @l_message                                VARCHAR(400), */
      @l_letra                                  VARCHAR(400), 
      @cReporte                                 VARCHAR(400), 
      @lDsPage                                  VARCHAR(400), 
      @l_SQLWhere                               VARCHAR(400), 
      @l_RutaReport                             VARCHAR(400),
      @lPageFmt                                 VARCHAR(400),
      @cPath                                    VARCHAR(400), 
      @l_DocID                                  VARCHAR(400), 
      /*@l_Parametros                             VARCHAR(400), */
      @l_DocDesc                                VARCHAR(400), 
      /*@l_formulas                               VARCHAR(400), 
      @l_DosDS                                  VARCHAR(400),*/ 
      @lFechaYYYYMMDD                           VARCHAR(400), 
      @l_Anio                                   VARCHAR(400),
      @l_Mes                                    VARCHAR(400), 
      @l_Dia                                    VARCHAR(400),
      @acum                                     INTEGER, 
      @lContador                                INTEGER, 
      @lNumPagina                               INTEGER, 
      @lMaxXPage1                               INTEGER,
	  @lMaxXPage                                VARCHAR(400),  
      @lNumeroCopias                            INTEGER, 
      @AWLI_LETRA                               INTEGER, 
      @AWLI_Docnmbr                             INTEGER,
      @l_CAI                                    VARCHAR(400),
      @l_DueDateCAI                             DATETIME,
      @sTipoDocumento_CAI                       VARCHAR(400),
      @sTipoDocumento_Pack                                  VARCHAR(400),
      @l_tipo_Tal                               VARCHAR(400),
      @l_XDL_Return_ReasonCode_Desc                   VARCHAR(400),
      @XDL_CAI                                  VARCHAR(4000), 
      @XDL_CAI_Due_Date                                     DATETIME,
      @SOPTYPE1                                 VARCHAR(400), 
      @XDL_Letra_Documento                                  VARCHAR(400), 
      @DOCID1                                   VARCHAR(400),
      @BCHSOURC1                                VARCHAR(400),
      @DOCDATE2                                 DATETIME,
      @SUBTOTAL2                                NUMERIC(19,5), 
      @TAXAMNT2                                 NUMERIC(19,5),
      @ORTAXAMT2                                NUMERIC(19,5),
      @DOCAMNT2                                 NUMERIC(19,5),
      @ORDOCAMT2                                NUMERIC(19,5),
      @CURNCYID2                                CHAR(15),
	  @Comp										INTEGER,
      @Cont										INTEGER,
	  @XDL_Imp									INTEGER,
      @lNumCopies								VARCHAR(400),
		@DexRow									INTEGER
      SELECT @lContador = 1, @lNumPagina = 1, @out_Error = 0,@Cont = 1	

	  IF @Oin_sLetraDocumentoExterno <> '' 
      BEGIN
            SET @l_letra = @Oin_sLetraDocumentoExterno
      END
      ELSE
      BEGIN
            SET @l_letra = @in_sLetraDocumento
      END


	if  exists (select * from dbo.sysobjects where id = object_id(N'[AWLI_RM00103]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
      BEGIN
            EXEC SP_XDL_To_Get_Letter @l_letra,@AWLI_LETRA OUTPUT
            EXEC SP_XDL_To_Get_VoucherType @in_sTipoDocumento,@AWLI_Docnmbr OUTPUT
      END

/* Raju
      SET @cQry = ''
      SET @cQry = @cQry + ' DELETE XDL91101 WHERE Usuario = ''' + @UserID + ''' '
      EXEC (@cQry)


      SET @cQry = ''
      SET @cQry = @cQry + ' DELETE XDL90100 WHERE USERID = ''' + @UserID + ''' '
      EXEC (@cQry)*/


      SET @cQry = ''
      SET @cQry = @cQry + ' INSERT INTO XDL91101 (Tipo, XDL_DocNumber, ERMSGTXT, NroCpbte, FecCpbte, CondPago, DirOrig, Cliente, RazSocial, Direccion,  
      Localidad, Estado, CodPost, Pais, SubTotal, Impuestos, Total, Territorio, Vendedor, CURNCYID, CURRNIDX, NOTEINDX, OrdCpra, Comentario, SHIPMTHD, 
      Linea, NroArt, DetArt, DirOrigArt, Cantidad, Unidad, Descuento, PrecUnitArt, ImpArt, TotalArt, TerritorioArt, VendedorArt, CUIT, Letra, 
      Remito, Usuario, Compania, CUITCom, CUITIIBB, DirCom, LocaCom, EstadoCom, CodPostCom, PaisCom, TelefonoCom, FaxCom, EXCHDATE, XCHGRATE, CAI, 
      XDLNULINE, SERLTNUM, SERLTQTY, ORIGNUMB, SLTSQNUM, ORUNTPRC, OXTNDPRC, ORTAXAMT) '


      SET @cSelQry = ' '
      SET @cSelQry = @cSelQry + ' SELECT distinct  Cab.SOPTYPE Tipo, ''' + @in_InvDocNumber + ''', '
      EXEC SP_XDL_Return_ReasonCode_Desc @in_sDocNumber,@in_SopType,@l_XDL_Return_ReasonCode_Desc OUTPUT
      SET @cSelQry = @cSelQry + '''' + @l_XDL_Return_ReasonCode_Desc + ''', Trx.XDL_GP_DocNumber, '
      IF  @in_sTipoDocumento = 'Packing List' OR @in_sTipoDocumento ='Lista de remisión'
      BEGIN
         SET @cSelQry = @cSelQry + ' Trx.XDL_Remito_Created_Date FecCpbte, '
      END
      ELSE
      BEGIN
         SET @cSelQry = @cSelQry + ' Cab.DOCDATE FecCpbte, '
      END
      SET @cSelQry = @cSelQry + ' Cab.PYMTRMID CondPago, Cab.LOCNCODE DirOrig, Cab.CUSTNMBR Cliente, Cab.CUSTNAME RazSocial, Cab.ADDRESS1 Direccion, 
      Cab.CITY Localidad, Cab.STATE Estado, Cab.ZIPCODE CodPost, Cab.COUNTRY Pais, Cab.SUBTOTAL SubTotal, Cab.TAXAMNT Impuestos, Cab.DOCAMNT Total, 
      Cab.SALSTERR Territorio, Cab.SLPRSNID Vendedor, Cab.CURNCYID CURNCYID, Cab.CURRNIDX CURRNIDX, Cab.NOTEINDX, Cab.CSTPONBR OrdCpra, Cab.COMMNTID Comentario, 
      Cab.SHIPMTHD MetodoEnvio, 0, '''''', '''''', '''''', 0,'''''', 0, 0, 0, 0, '''''', '''''', Cli.TXRGNNUM CUIT, ''' + ISNULL(@l_letra,'') + ''' Letra, 
      Trx.XDL_Remito_DocNumber Remito, ''' + ISNULL(@UserID,'') + ''' Usuario, Com.CMPNYNAM Compania, Com.TAXREGTN CUITCom, Com.UDCOSTR1 CUITIIBB, 
      (RTRIM(Com.ADDRESS1) + RTRIM(Com.ADDRESS2) + RTRIM(Com.ADDRESS3))  DirCom, Com.CITY LocaCom, Com.STATE EstadoCom, Com.ZIPCODE CodPostCom, 
      Com.CMPCNTRY PaisCom, (Com.PHONE1 + '' '' + Com.PHONE2 + '' '' + Com.PHONE3) TelefonoCom, Com.FAXNUMBR FaxCom, Cab.EXCHDATE EXCHDATE, 
      Cab.XCHGRATE XCHGRATE, ''N/C'',  0,  0,  0, Cab.ORIGNUMB, 0, 0, 0, 0  FROM RM00101 Cli, DYNAMICS.dbo.SY01500 Com, (XDL10101  
      Trx inner join SOP30200 Cab on Cab.SOPNUMBE = Trx.XDL_DocNumber) '

      IF @in_sDocNumber <> @in_InvDocNumber  
      BEGIN
            SET @cSelQry = @cSelQry + ' WHERE   Trx.XDL_DocNumber = ''' + @in_InvDocNumber + ''' '
      END
      ELSE
      BEGIN
            SET @cSelQry = @cSelQry + ' WHERE   Trx.XDL_DocNumber = ''' + @in_sDocNumber + ''' '
      END
      SET @cSelQry = @cSelQry + ' and Trx.XDL_Letra_Documento = ''' + @in_sLetraDocumento + ''' '
      IF @in_sTipoDocumento = 'Packing List' OR @in_sTipoDocumento ='Lista de remisión'
      BEGIN
            SET @cSelQry = @cSelQry + ' and Trx.XDL_Tipo_Documento = ''' + @in_sTipoDocumento + ''' '
      END
      ELSE
      BEGIN
            SET @cSelQry = @cSelQry + ' and Trx.XDL_Tipo_Documento = ''' + @in_sTipoDocumento + ''' '
      END
      SET @cSelQry= @cSelQry + ' and Cab.SOPTYPE = ' + CONVERT(VARCHAR(10),@in_SopType) + '  and Cli.CUSTNMBR = Cab.CUSTNMBR  and Com.CMPANYID = ' + CONVERT(VARCHAR(10),@CompID) 

      IF @Oin_sLetraDocumentoExterno = 'R'                  
      BEGIN
            SET @cSelQry = @cSelQry + ' and Det.DROPSHIP <> 1 '
      END


      IF /*@lTypeTrue = 1 true and*/ str(@in_sTipoDocumento) = 'Packing List' OR str(@in_sTipoDocumento) ='Lista de remisión'
      BEGIN
            SET @cSelQry = @cSelQry + ' and ART.ITEMTYPE = 1 '
      END 

      EXEC (@cQry+@cSelQry)

      /*
      SET @lMaxXPage = FUNC_Get_Parameters_Documento(@in_sTipoDocumento, 'LINEPERPAGE', 0)
      IF NOT EXISTS (@lMaxXPage) BEGIN    SET @lMaxXPage = FUNC_Get_Parameters_General( 'LINEPERPAGE', 0 ) END

      IF NOT EXISTS (@lMaxXPage)
      BEGIN
            SET @lMaxXPage = 10
      END
      *//*24/09/10BAAL*/
	IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'LINEPERPAGE')
		BEGIN
			SELECT TOP 1 @lMaxXPage=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'LINEPERPAGE'
			SET @lMaxXPage1 = convert(int,@lMaxXPage)
		END
	IF LTRIM( RTRIM(@lMaxXPage)) = '' OR @lMaxXPage = NULL
		BEGIN
			SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
			IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'LINEPERPAGE')
			BEGIN
				SELECT TOP 1 @lMaxXPage=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'LINEPERPAGE'
				SET @lMaxXPage1 = convert(int,@lMaxXPage)
			END
		END
	IF LTRIM( RTRIM(@lMaxXPage)) = '' OR @lMaxXPage = NULL
		BEGIN
			SET @lMaxXPage1 = 10
		END
	/*24/09/10*/
      IF EXISTS ( SELECT TOP 1 1 From XDL91101 Where  NroCpbte = @in_sDocNumber and Tipo =  @in_SopType ) 
      BEGIN
            DECLARE CImprime CURSOR FAST_FORWARD FOR

            SELECT XDLNULINE,DEX_ROW_ID From XDL91101 Where NroCpbte = @in_sDocNumber and Tipo =  @in_SopType 

            OPEN CImprime 
                        FETCH NEXT FROM CImprime into @XDL_Imp,@DexRow
                        WHILE @@FETCH_STATUS =0
                        BEGIN
							 IF @Cont > @lMaxXPage1
                                BEGIN 
									SET  @Cont = 1
									SET @lNumPagina = @lNumPagina + 1                                     
                                END
							  UPDATE XDL91101 SET XDLNULINE= @lNumPagina WHERE NroCpbte = @in_sDocNumber and Tipo =  @in_SopType AND DEX_ROW_ID = @DexRow
                              SET  @Cont = @Cont + 1								
                        
                        FETCH NEXT FROM CImprime into @XDL_Imp,@DexRow
						END
                        CLOSE CImprime
                        DEALLOCATE CImprime
      END
	/*24/09/10*/
      SELECT TOP 1 @DOCDATE2 = DOCDATE, @SUBTOTAL2=SUBTOTAL, @TAXAMNT2=TAXAMNT,@ORTAXAMT2=ORTAXAMT,@DOCAMNT2=DOCAMNT,@ORDOCAMT2=ORDOCAMT,@CURNCYID2=CURNCYID FROM SOP30200 WHERE SOPTYPE = @in_SopType AND SOPNUMBE = @in_InvDocNumber

      SET @sTipoDocumento_CAI=@in_sTipoDocumento;
      IF (@in_sTipoDocumento = 'Packing List') and @l_letra <> 'R' 
      BEGIN
            SET @sTipoDocumento_CAI='Invoice';
      END 
      ElSE IF (@in_sTipoDocumento = 'Lista de remisión') and @l_letra <> 'R' 
      BEGIN
            SET @sTipoDocumento_CAI='Factura';
      END 



      IF EXISTS (SELECT TOP 1 1 FROM XDL10101 WHERE XDL_GP_DocNumber= @in_sDocNumber AND XDL_Tipo_Documento= @in_sTipoDocumento AND XDL_Letra_Documento = @in_sLetraDocumento)
      BEGIN
            SELECT TOP 1 @XDL_CAI=XDL_CAI, @XDL_CAI_Due_Date=XDL_CAI_Due_Date,@SOPTYPE1=SOPTYPE, @DOCID1=DOCID, @BCHSOURC1=BCHSOURC
            FROM XDL10101 WHERE XDL_GP_DocNumber= @in_sDocNumber AND XDL_Tipo_Documento= @in_sTipoDocumento AND XDL_Letra_Documento = @in_sLetraDocumento

            IF @XDL_CAI='' AND @XDL_CAI_Due_Date='' 
            BEGIN
                  IF @in_sTipoDocumento = 'Packing List' OR @in_sTipoDocumento = 'Lista de remisión'
                  BEGIN
                        EXEC SP_XDL_To_Get_Tipodocument @SOPTYPE1, @DOCID1, @BCHSOURC1, @sTipoDocumento_Pack OUTPUT
                  END
                  ELSE
                  BEGIN 
                        SET @sTipoDocumento_Pack = @in_sTipoDocumento
                  END
                  EXEC SP_XDL_ToValidate_CAI @sTipoDocumento_Pack,@in_sLetraDocumento, @DOCDATE2 , @l_errstatus OUTPUT,@in_sDocNumber,'' ,'' ,@l_CAI OUTPUT,@l_DueDateCAI OUTPUT
            END
            ELSE
            BEGIN
                  SET @l_CAI = @XDL_CAI
                  SET @l_DueDateCAI = @XDL_CAI_Due_Date
            END
      END

		IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PRINTCOPY')
			BEGIN
				SELECT TOP 1 @lNumCopies=isnull(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PRINTCOPY'
				SET @lNumeroCopias = convert(int,@lNumCopies)
			END

		IF LTRIM( RTRIM(@lNumCopies)) = '' OR @lNumCopies = NULL
			BEGIN
				SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
				IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PRINTCOPY')
				BEGIN
					SELECT TOP 1 @lNumCopies=isnull(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PRINTCOPY'
					SET @lNumeroCopias = convert(int,@lNumCopies)
				END
			END
		IF LTRIM( RTRIM(@lNumCopies)) = '' OR @lNumCopies = NULL
			BEGIN
				SET @lNumeroCopias = 1
			END

		SET @i = 1		
		WHILE @i<=@lNumeroCopias 
        BEGIN
				SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
				IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1')
				BEGIN
					SELECT TOP 1 @lDsPage=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1'
				END
				ELSE IF	EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE XDLIDCFG = 'PAGE')
				BEGIN
					SELECT TOP 1 @lDsPage=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE XDLIDCFG = 'PAGE'
				END
 
				IF LTRIM( RTRIM(@lDsPage)) = '' OR @lDsPage = NULL

				BEGIN
					SET @lDsPage = convert(VARCHAR,@i)
				END
			IF @i = 1
			BEGIN
				SET @lPageFmt = ''

				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 1')
					BEGIN
						SELECT TOP 1 @lPageFmt=XDLDSCFG FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 1'
					END
				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 1'
						END
					END

			END
			IF @i = 2
			BEGIN
				SET @lPageFmt = ''

				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 2')
					BEGIN
						SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 2'
					END
				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 2')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 2'
						END
					END

			END
			IF @i = 3
			BEGIN
				SET @lPageFmt = ''

				IF EXISTS (SELECT TOP 1 1 FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 3')
					BEGIN
						SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM XDL00114 WHERE XDL_Tipo_Documento= @in_sTipoDocumento AND XDLIDCFG = 'PAGE 3'
					END
				IF LTRIM( RTRIM(@lPageFmt)) = '' OR @lPageFmt = NULL
					BEGIN
						SET @Comp=(select ISNULL(CMPANYID,0) from DYNAMICS.dbo.SY01500 WHERE INTERID = DB_NAME())
						IF EXISTS (SELECT TOP 1 1 FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 3')
						BEGIN
							SELECT TOP 1 @lPageFmt=ISNULL(XDLDSCFG,'') FROM DYNAMICS.dbo.XDL00115 WHERE CMPANYID= @Comp AND XDLIDCFG = 'PAGE 3'
						END
					END

			END
			  /*IF NOT EXISTS (SELECT TOP 1 1 FROM XDL90100 WHERE XDL_Tipo_Documento=@in_sTipoDocumento AND XDL_GP_DocNumber= @in_sDocNumber /*AND XDL_DocNumber=@in_InvDocNumber*/ AND
								XDLNUCO=@i AND XDLCPDS = @lDsPage AND USERID = @UserID)
			  BEGIN
					INSERT INTO XDL90100 (SOPTYPE,SUBTOTAL, TAXAMNT ,ORTAXAMT ,DOCAMNT,ORDOCAMT,
								FUNLCURR,CURNCYID,XDL_CAI,XDL_CAI_Due_Date,XDL_Tipo_Documento,XDL_GP_DocNumber,XDL_DocNumber,XDLNUCO,USERID,XDLCPDS)
								SELECT @in_SopType,@SUBTOTAL2,@TAXAMNT2,@ORTAXAMT2,@DOCAMNT2,@ORDOCAMT2,
								(SELECT TOP 1 Euro_Currency_ID FROM DYNAMICS.dbo.MC40400),@CURNCYID2,ISNULL(@l_CAI,''),ISNULL(@l_DueDateCAI,''),@in_sTipoDocumento,@in_sDocNumber,@in_InvDocNumber,ISNULL(@i,0),@UserID,@lDsPage
	                            

			  END
			  ELSE
			  BEGIN
				  UPDATE XDL90100 SET SOPTYPE=@in_SopType,SUBTOTAL=@SUBTOTAL2, TAXAMNT = @TAXAMNT2,ORTAXAMT = @ORTAXAMT2,DOCAMNT=@DOCAMNT2,ORDOCAMT=@ORDOCAMT2,
						FUNLCURR=(SELECT TOP 1 Euro_Currency_ID FROM MC40400),CURNCYID=@CURNCYID2,XDL_CAI=@l_CAI,XDL_CAI_Due_Date=@l_DueDateCAI
						WHERE XDL_Tipo_Documento=@in_sTipoDocumento AND XDL_GP_DocNumber= @in_sDocNumber /*AND XDL_DocNumber=@in_InvDocNumber*/ AND
						XDLNUCO=@i AND XDLCPDS = @lDsPage AND USERID = @UserID

			  END*/
					INSERT INTO XDL90100 (SOPTYPE,SUBTOTAL, TAXAMNT ,ORTAXAMT ,DOCAMNT,ORDOCAMT,
								FUNLCURR,CURNCYID,XDL_CAI,XDL_CAI_Due_Date,XDL_Tipo_Documento,XDL_GP_DocNumber,XDL_DocNumber,XDLNUCO,USERID,XDLCPDS,XDLDSCFG)
								SELECT @in_SopType,@SUBTOTAL2,@TAXAMNT2,@ORTAXAMT2,@DOCAMNT2,@ORDOCAMT2,
								ISNULL((SELECT TOP 1 Euro_Currency_ID FROM DYNAMICS.dbo.MC40400),''),@CURNCYID2,ISNULL(@l_CAI,''),ISNULL(@l_DueDateCAI,''),@in_sTipoDocumento,@in_sDocNumber,@in_InvDocNumber,@i,@UserID,ISNULL(@lDsPage,''),ISNULL(@lPageFmt,'')


			SET @i = @i + 1
		END

      /*IF EXISTS(SELECT TOP 1 1 FROM XDL00107 WHERE BCHSOURC=@in_Batch AND DOCID=@in_DocID AND XDL_SOP_Type=@in_SopType AND XDL_Letra_Documento=@l_letra)
      BEGIN 
            SET @lNumeroCopias = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, 'PRINTCOPY', 0)
            if @lNumeroCopias = 0   
            BEGIN
                  SET @lNumeroCopias = FUNC_Get_Parameters_General( 'PRINTCOPY', 0 )
            END
            IF @lNumeroCopias = 0 
            BEGIN
                  SET @lNumeroCopias = 1
            END

            SET @i = 1
            WHILE @i=@lNumeroCopias 
            BEGIN
                  SET @lDsPage = FUNC_Get_Parameters_General( 'PAGE' + str(@i), 0, 'PAGE')
                  IF @lDsPage='' 
                  BEGIN
                        SET @lDsPage = str(@i)
                  END 
                  IF @i = 1 
                  BEGIN
                        SET @lPageFmt = FUNC_Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 1', 0)                  
                        IF @lPageFmt=0 
                        BEGIN
                              SET @lPageFmt = FUNC_Get_Parameters_General('PAGE 1', 0 )
                        END 
                  END 
                  IF @i = 2 
                  BEGIN
                        SET @lPageFmt = Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 2', 0);                 
                        IF @lPageFmt=0 
                        BEGIN
                              SET @lPageFmt = FUNC_Get_Parameters_General('PAGE 2', false ));
                        END   
                  END 
                  IF @i = 3 
                  BEGIN
                        SET @lPageFmt = Get_Parameters_Documento( @in_sTipoDocumento, 'PAGE 3', 0);                 
                        IF @lPageFmt=0 
                        BEGIN
                              SET @lPageFmt = FUNC_Get_Parameters_General('PAGE 3', 0 ));
                        END         
                  END 

      */

                 /* IF NOT EXISTS (SELECT TOP 1 1 FROM XDL90100 WHERE XDL_Tipo_Documento=@in_sTipoDocumento AND XDL_GP_DocNumber= @in_sDocNumber AND XDL_DocNumber=@in_InvDocNumber AND
                                    XDLNUCO=@i AND USERID = @UserID)
                  BEGIN
/*
                        if 'Functional Currency' of globals = 'Currency ID' of table SOP_HDR_HIST then
                  
                              set 'XDL Total Descripcion' of table XDL_Spool_Print_HDR
                              to XDL_ToWord('Document Amount' of table SOP_HDR_HIST);
                        {CHANGED  V-RRAI as per 7.5 new source changes }
                        else
                              set 'XDL Total Descripcion' of table XDL_Spool_Print_HDR
                                    to XDL_ToWord('Originating Document Amount' of table SOP_HDR_HIST);
                        end if;
                        set 'Functional Currency' of table XDL_Spool_Print_HDR
                              to 'Functional Currency' of globals;
*/

                        INSERT INTO XDL90100 (SOPTYPE,SUBTOTAL, TAXAMNT ,ORTAXAMT ,DOCAMNT,ORDOCAMT,
                                    FUNLCURR,CURNCYID,XDL_CAI,XDL_CAI_Due_Date,XDL_Tipo_Documento,XDL_GP_DocNumber,XDL_DocNumber,XDLNUCO,USERID)
                                    SELECT @in_SopType,@SUBTOTAL2,@TAXAMNT2,@ORTAXAMT2,@DOCAMNT2,@ORDOCAMT2,
                                    (SELECT TOP 1 Euro_Currency_ID FROM DYNAMICS.dbo.MC40400),@CURNCYID2,ISNULL(@l_CAI,''),ISNULL(@l_DueDateCAI,''),@in_sTipoDocumento,@in_sDocNumber,@in_InvDocNumber,ISNULL(@i,0),@UserID
                                    
                  END
                  ELSE
                        BEGIN 
                        UPDATE XDL90100 SET SOPTYPE=@in_SopType,SUBTOTAL=@SUBTOTAL2, TAXAMNT = @TAXAMNT2,ORTAXAMT = @ORTAXAMT2,DOCAMNT=@DOCAMNT2,ORDOCAMT=@ORDOCAMT2,
                                    FUNLCURR=(SELECT TOP 1 Euro_Currency_ID FROM DYNAMICS.dbo.MC40400),CURNCYID=@CURNCYID2,XDL_CAI=@l_CAI,XDL_CAI_Due_Date=@l_DueDateCAI
                                    WHERE XDL_Tipo_Documento=@in_sTipoDocumento AND XDL_GP_DocNumber= @in_sDocNumber AND XDL_DocNumber=@in_InvDocNumber AND
                              /*XDLNUCO=@i AND XDLCPDS = @lDsPage AND*/ USERID = @UserID
                        
                  END*/



      /*
            SET @l_DosDS = FUNC_Get_Parameters_Documento(@in_sTipoDocumento, XDL_PARAM_DOCDS, 0)
            IF @l_DosDS=0 
            BEGIN
                  SET @l_formulas = 'ReceiptType = ''''' + @in_sTipoDocumento + ''''
            END 
            SET @l_Parametros = 'User;' +  @UserID + '|Letra Documento;' + @l_letra
            
            /*call X_ReporteCrystal,'XDL Ruta Reporte' of table XDL_Reports_Path,l_Parametros,l_formulas,lNumeroCopias;*/
            
      END
      ELSE
      BEGIN
            SET @l_message = @in_DocID + ' setup has not been performed.'
            /*warning( @l_message )*/
            /*set out_Error to true;
            abort script; */
      RETURN
      END
      */




END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_XDL_Imprime_Doc1] TO [DYNGRP] 
GO 

/*End_SP_XDL_Imprime_Doc1*/


/*Begin_SP_Search*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SP_Search]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SP_Search]
go

CREATE PROCEDURE SP_Search
@FromDate_Par           DATETIME,
@ToDate_Par             DATETIME,
@PointOfSale_Par        VARCHAR(4000),
@DocDraft_Par           VARCHAR(4000),
@TypeOfVoucher_Par      VARCHAR(4000),
@CustNo_Par             VARCHAR(4000),
@CustNo_ParTo           VARCHAR(4000),
@UserID_Par             VARCHAR(4000),
@DocFrom_Par            VARCHAR(4000),
@DocTo_Par              VARCHAR(4000),
@DocQuery               VARCHAR(4000)
AS
BEGIN
      DECLARE 
      @Stmt1            VARCHAR(4000),
      @WhereCondn1      VARCHAR(4000),
      @WhereCondn2      VARCHAR(4000),
      @WhereCondn3      VARCHAR(4000),
      @StmtTemp         VARCHAR(4000)


      DELETE FROM XDL91101
      DELETE FROM XDL90100
      Delete FROM XDL90102
      DELETE FROM XDL80101
      IF @FromDate_Par=NULL BEGIN SET @FromDate_Par='01-01-1900' END
      IF @ToDate_Par=NULL BEGIN SET @ToDate_Par='01-01-2999' END
      SET @Stmt1 = ''
      SELECT @WhereCondn1 = '',@WhereCondn2 = '',@WhereCondn3 = ''
      SET @Stmt1= ' INSERT INTO XDL80101 (XDL_GP_DocNumber, XDL_Check_Factura, XDL_Tipo_Documento, XDL_Letra_Documento, XDL_Punto_de_venta, SOPTYPE, XDL_DocNumber,
      DOCID, XDL_Posted_Date, XDL_Impresiones_Factura, XDL_Remito_DocNumber, XDL_Check_Remito, XDL_Remito_Created_Date, XDL_Impresiones_Remito, USERID,
      BCHSOURC, XDL_Numero_TRX, XCHGRATE, EXCHDATE) '

      SET @StmtTemp = @Stmt1

      SET @Stmt1 = @Stmt1 + ' SELECT DD.XDL_GP_DocNumber, 0, DD.XDL_Tipo_Documento, DD.XDL_Letra_Documento, DD.XDL_Punto_de_venta,DD.SOPTYPE, DD.XDL_DocNumber, 
      DD.DOCID, DD.XDL_Posted_Date, DD.XDL_Impresiones_Factura, DD.XDL_Remito_DocNumber, 0, DD.XDL_Remito_Created_Date,DD.XDL_Impresiones_Remito, ''' + @UserID_Par + ''', 
      DD.BCHSOURC, DD.XDL_Numero_TRX, DD.XCHGRATE, DD.EXCHDATE From XDL10101 DD  '

      IF ISNULL(@CustNo_Par,'') <> '' AND ISNULL(@CustNo_ParTo,'') <> ''
      BEGIN
            SET @Stmt1 = @Stmt1 +  ' , SOP30200 SHD WHERE SHD.SOPNUMBE =DD.XDL_DocNumber '
            SET @WhereCondn3 = @WhereCondn3 +  ' SHD.CUSTNMBR >= ''' + @CustNo_Par + ''' AND '
            SET @WhereCondn3 = @WhereCondn3 +  ' SHD.CUSTNMBR <= ''' + @CustNo_ParTo + ''' AND '
      END
      ELSE
      BEGIN
            SET @Stmt1 = @Stmt1 + ' Where DD.SOPTYPE >= 0 '
      END

      IF @FromDate_Par <> NULL OR @FromDate_Par<>'1900-01-01 00:00:00.000'
      BEGIN 
            SET @WhereCondn1 = @WhereCondn1 + ' DD.XDL_Posted_Date >= ''' + CONVERT(char(10),@FromDate_Par ,101) + ''' AND '
      END
      IF @ToDate_Par <> NULL OR @ToDate_Par<>'1900-01-01 00:00:00.000'
      BEGIN 
            SET @WhereCondn1 = @WhereCondn1 + ' DD.XDL_Posted_Date <= ''' + CONVERT(char(10),@ToDate_Par ,101) + ''' AND '
      END

      IF ISNULL(@PointOfSale_Par,'') <> '' 
      BEGIN 
			SET @WhereCondn1 = @WhereCondn1 + ' DD.XDL_Punto_de_venta IN (select str from SSRSMultiDDL_to_table(  ''' + @PointOfSale_Par + ''',Default)) AND '
      END
      /* Changes */
		IF @TypeOfVoucher_Par = 'P'
			BEGIN       
			IF ISNULL(@DocDraft_Par,'') <> ''
			  /*IF ISNULL(@TypeOfVoucher_Par,'') <> '' */
			  BEGIN 
					SET @WhereCondn1 = @WhereCondn1 + ' substring(DD.XDL_Remito_DocNumber,1,1) IN (select str from SSRSMultiDDL_to_table(  ''' + @DocDraft_Par + ''',Default)) AND '
					/*SET @WhereCondn2 = @WhereCondn2 + ' DD.XDL_Tipo_Documento =  ''' + @TypeOfVoucher_Par + ''' AND '*/
			  END
			ELSE
				BEGIN
					  SET @WhereCondn1 = @WhereCondn1 + ' DD.XDL_Remito_DocNumber <>  '''' AND '
				END
			END
		ELSE
			BEGIN
				IF ISNULL(@DocDraft_Par,'') <> '' /*Bug*/
				BEGIN 
						SET @WhereCondn1 = @WhereCondn1 + ' DD.XDL_Letra_Documento IN (select str from SSRSMultiDDL_to_table(  ''' + @DocDraft_Par + ''',Default)) AND '
				END
				ELSE
				BEGIN
						  SET @WhereCondn1 = @WhereCondn1 + ' DD.XDL_Letra_Documento <>  '''' AND '
				END
			END

     /* IF ISNULL(@CustNo_Par,'') <> ''
      BEGIN
            SET @WhereCondn3 = @WhereCondn3 +  ' SHD.CUSTNMBR = ''' + @CustNo_Par + ''' AND '
      END*/


      IF ISNULL(@DocFrom_Par,'') <> ''
      BEGIN 
            IF ISNULL(@DocTo_Par,'') <> '' 
            BEGIN 
                  SET @WhereCondn3 = @WhereCondn3 + ' DD.XDL_GP_DocNumber between ''' + @DocFrom_Par + ''' AND ''' + @DocTo_Par + ''' AND '
            END
            ELSE
            BEGIN 
                  SET @WhereCondn3 = @WhereCondn3 + ' DD.XDL_GP_DocNumber >= ''' + @DocFrom_Par + ''' AND '
            END
      END
      ELSE IF ISNULL(@DocTo_Par,'') <> ''
      BEGIN
            SET @WhereCondn3 = @WhereCondn3 + ' DD.XDL_GP_DocNumber <= ''' + @DocTo_Par + ''' AND '
      END



      IF @WhereCondn1<>''
      BEGIN 
            SET @Stmt1= @Stmt1 + ' AND ' + @WhereCondn3 + @WhereCondn2 + SUBSTRING(@WhereCondn1,1,LEN(@WhereCondn1)-4)
      END

      EXEC(@Stmt1)


      SET @Stmt1 = @StmtTemp
      SET @Stmt1 = @Stmt1 + ' SELECT      DD.XDL_GP_DocNumber, 0, DD.XDL_Tipo_Documento, DD.XDL_Letra_Documento, DD.XDL_Punto_de_venta, DD.SOPTYPE, DD.XDL_DocNumber,  
      DD.DOCID, DD.XDL_Posted_Date, DD.XDL_Impresiones_Factura, DD.XDL_Remito_DocNumber, 0, DD.XDL_Remito_Created_Date, DD.XDL_Impresiones_Remito, ''' + @UserID_Par + ''' , 
      DD.BCHSOURC, DD.XDL_Numero_TRX, DD.XCHGRATE, DD.EXCHDATE From  XDL10101 DD WHERE DD.BCHSOURC =''XIV_Trans'' '


      IF ISNULL(@DocFrom_Par,'') <> ''
      BEGIN 
            IF @DocTo_Par <> '' 
            BEGIN 
                  SET @DocQuery = @DocQuery + ' DD.XDL_GP_DocNumber between ''' + @DocFrom_Par + ''' AND ''' + @DocTo_Par + ''' AND '
            END
            ELSE
            BEGIN 
                  SET @DocQuery = @DocQuery + ' DD.XDL_GP_DocNumber >= ''' + @DocFrom_Par + ''' AND '
            END
      END
      ELSE IF ISNULL(@DocTo_Par,'') <> ''
      BEGIN
            SET @DocQuery = @DocQuery + ' DD.XDL_GP_DocNumber <= ''' + @DocTo_Par + ''' AND '
      END



      IF @WhereCondn1 <> ''
      BEGIN
            SET @Stmt1 = @Stmt1 + ' AND ' + @WhereCondn2 + @DocQuery + SUBSTRING(@WhereCondn1,1,LEN(@WhereCondn1)-4)
      END

    EXEC(@Stmt1)

      /*SET @Stmt1 = ' '
      SET @Stmt1 = ' DELETE FROM XDL80101 where XDL_GP_DocNumber in (select XDL_GP_DocNumber from XDL80101 inner join XDL00101 
      on  XDL80101.XDL_Punto_de_venta=XDL00101.XDL_Punto_de_venta and XDL80101.XDL_Tipo_Documento=XDL00101.XDL_Tipo_Documento 
       and  XDL80101.XDL_Letra_Documento=XDL00101.XDL_Letra_Documento and XDL00101.XDL_CAE_Req_Leg_Number=1 
       and XDL80101.XDL_GP_DocNumber not like ''FCE-%'' and XDL80101.XDL_GP_DocNumber not like ''NDE-%'' 
       and XDL80101.XDL_GP_DocNumber not like ''NCE-%'') '

      EXEC(@Stmt1)

      SET @Stmt1 = ' USERID = ''' + @UserID_Par + ''' '*/
/*EXEC SP_Search '01/01/1900','12/31/2999','','','','','sa','','',''*/

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[SP_Search] TO [DYNGRP] 
GO 
/*End_SP_Search*/

/*Begin_Proceso_Impresion*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proceso_Impresion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proceso_Impresion]
go

CREATE PROCEDURE Proceso_Impresion
@User_ID AS VARCHAR(4000),
@FromDate_Par           DATETIME,
@ToDate_Par             DATETIME,
@PointOfSale_Par        VARCHAR(4000),
@DocDraft_Par           VARCHAR(4000),
@TypeOfVoucher_Par      VARCHAR(4000),
@CustNo_Par             VARCHAR(4000),
@CustNo_ParTo           VARCHAR(4000),
@DocFrom_Par            VARCHAR(4000),
@DocTo_Par              VARCHAR(4000)
AS
BEGIN

DECLARE 
@sDocNumber       VARCHAR(100), 
@sTipoDocumento     VARCHAR(100), 
@sRemitoDocNum    VARCHAR(100), 
@sLetraDocumento  VARCHAR(100),
@sSucursalId      VARCHAR(100),
@sBachSource      VARCHAR(100), 
@lDocID           VARCHAR(100), 
@sPatchReport     VARCHAR(100),
@sInvDocNumber    VARCHAR(100),
@sDocType         VARCHAR(100),
@l_DocType        INTEGER, 
@l_tipo_Tal       VARCHAR(100), 
@l_Docdate        DATETIME,
@l_CAI            VARCHAR(100), 
@l_DueDateCAI     DATETIME,
@l_boError        VARCHAR ,
@UserID_Par       VARCHAR(100) ,
@CompID           VARCHAR(400),

      @XDL_GP_DocNumber VARCHAR(100), 
      @BCHSOURC               VARCHAR(100),
      @XDL_DocNumber          VARCHAR(100),
      @XDL_CAI                VARCHAR(100),
      @SOPTYPE1               VARCHAR(100),
      @XDL_Tipo_Documento       VARCHAR(4000),
      @SOPTYPE                VARCHAR(100),
      @XDL_Letra_Documento      VARCHAR(4000),
      @XDL_Remito_DocNumber   VARCHAR(4000),
      @DOCID                  VARCHAR(4000),
      @XDL_Posted_Date          DATETIME,
      @XDL_Punto_de_venta       VARCHAR(4000),
      @XDL_CAI_Due_Date         DATETIME,
      @DOCID1                 VARCHAR(4000),
      @BCHSOURC1              VARCHAR(4000),
      @l_errstatus            VARCHAR(4000),
      @Stmt1                  VARCHAR(4000),
      @XDL_Impresiones_Remito VARCHAR(4000),
      @XDL_Impresiones_Factura VARCHAR(4000)

      DELETE FROM XDL91101
      DELETE FROM XDL90100
      DELETE FROM XDL90102
      DELETE FROM XDL80101

EXEC SP_Search '01-01-1900','01-01-2999',@PointOfSale_Par,@DocDraft_Par,@TypeOfVoucher_Par,@CustNo_Par,@CustNo_ParTo,@User_ID,@DocFrom_Par,@DocTo_Par,''

SET @UserID_Par = @User_ID
      SET @l_DueDateCAI = NULL
      SET @Stmt1=''

      IF EXISTS ( SELECT TOP 1 1 From XDL80101 Where  XDL_Check_Factura = 0 and USERID =  @UserID_Par ) 
      BEGIN
            DECLARE CMAIN1 CURSOR FAST_FORWARD FOR

            SELECT XDL_GP_DocNumber, XDL_Tipo_Documento, XDL_Letra_Documento,  XDL_Remito_DocNumber, XDL_Punto_de_venta, BCHSOURC,
            SOPTYPE, DOCID, XDL_DocNumber, XDL_Posted_Date From XDL80101 Where      XDL_Check_Factura = 0 and USERID = @UserID_Par 

            OPEN CMAIN1 
                        FETCH NEXT FROM CMAIN1 into @XDL_GP_DocNumber, @XDL_Tipo_Documento, @XDL_Letra_Documento,  @XDL_Remito_DocNumber, 
                                                @XDL_Punto_de_venta, @BCHSOURC, @SOPTYPE, @DOCID, @XDL_DocNumber, @XDL_Posted_Date
                        WHILE @@FETCH_STATUS =0
                        BEGIN
							 IF @BCHSOURC = 'Inventory' OR @BCHSOURC = 'Inventario'
                                BEGIN 
                                      EXEC SP_XDL_Imprime_TRX @XDL_GP_DocNumber, @BCHSOURC, @XDL_Letra_Documento, @DOCID, @BCHSOURC, @l_boError OUTPUT , @UserID_Par, @CompID
                                END
							  ELSE
                              BEGIN
                                    EXEC SP_XDL_Proceso_Impresion @XDL_GP_DocNumber,@XDL_Tipo_Documento,@XDL_Letra_Documento,@XDL_Posted_Date,
                                           @l_CAI OUTPUT,@l_DueDateCAI OUTPUT

                                    IF NOT EXISTS (SELECT TOP 1 1 FROM SOP30300 WHERE SOPNUMBE=@XDL_GP_DocNumber AND SOPTYPE=@SOPTYPE)
                                    BEGIN
                                    
                                          IF NOT EXISTS (SELECT TOP 1 1 FROM SOP30300 WHERE SOPNUMBE=@XDL_DocNumber AND SOPTYPE=@SOPTYPE)
                                          BEGIN
                                                /*IF @l_CAI <> '' AND @l_DueDateCAI <> ''
                                                BEGIN*/
                                                      EXEC SP_XDL_Imprime_Doc1 @XDL_GP_DocNumber, @XDL_Tipo_Documento, @XDL_Letra_Documento, @DOCID, @SOPTYPE, 
                                                             @BCHSOURC, @sPatchReport, @XDL_DocNumber, @l_boError OUTPUT, '' , '', '', @UserID_Par, @CompID
                                                /*END*/
                                          END
                                          ELSE  
                                          BEGIN
                                                /*IF @l_CAI <> '' AND @l_DueDateCAI <> ''
                                                BEGIN*/
                                                      EXEC SP_XDL_Imprime_Doc @XDL_GP_DocNumber, @XDL_Tipo_Documento, @XDL_Letra_Documento, @DOCID, @SOPTYPE, 
                                                             @BCHSOURC, @sPatchReport, @XDL_DocNumber, @l_boError OUTPUT, '' , '',  @UserID_Par, @CompID
                                                /*END*/
                                          END
                                    END
                                    ELSE
                                    BEGIN
                                          /*IF @l_CAI <> '' AND @l_DueDateCAI <> ''
                                                BEGIN*/
                                                EXEC SP_XDL_Imprime_Doc @XDL_GP_DocNumber, @XDL_Tipo_Documento, @XDL_Letra_Documento, @DOCID, @SOPTYPE, 
                                                       @BCHSOURC, @sPatchReport, @XDL_DocNumber, @l_boError OUTPUT, '' , '',  @UserID_Par, @CompID
                                          /*END*/
                                    END
                              END
                              /*ELSE 
                              BEGIN
                                    IF @BCHSOURC = 'Inventory' OR @BCHSOURC = 'Inventario'
                                    BEGIN 
                                          EXEC SP_XDL_Imprime_TRX @XDL_GP_DocNumber, @BCHSOURC, @XDL_Letra_Documento, @DOCID, @BCHSOURC, @l_boError OUTPUT , @UserID_Par, @CompID
                                    END
                                    /*ELSE
                                    BEGIN 
                                          EXEC SP_XDL_Imprime_TRX @XDL_GP_DocNumber, @sTipoDocumento, @XDL_Letra_Documento, @DOCID, @BCHSOURC, @l_boError OUTPUT , @UserID_Par, @CompID
                                    END*/

                              END*/
                              
                              IF @l_boError =1
                              BEGIN
                                    IF EXISTS(SELECT TOP 1 1 FROM XDL10101 WHERE XDL_GP_DocNumber= @XDL_GP_DocNumber AND XDL_Tipo_Documento= @XDL_Tipo_Documento)
                                    BEGIN
                                          SELECT TOP 1 @XDL_CAI=XDL_CAI, @XDL_CAI_Due_Date=XDL_CAI_Due_Date, @SOPTYPE1=SOPTYPE, @DOCID1=DOCID, @BCHSOURC1=BCHSOURC,@XDL_Impresiones_Factura= XDL_Impresiones_Factura FROM XDL10101 WHERE XDL_GP_DocNumber= @XDL_GP_DocNumber AND XDL_Tipo_Documento= @XDL_Tipo_Documento
                                          IF @XDL_CAI='' AND @XDL_CAI_Due_Date=NULL
                                          BEGIN
                                                IF @XDL_Tipo_Documento = 'Packing List' OR @XDL_Tipo_Documento = 'Lista de remisión'
                                                BEGIN
                                                      EXEC SP_XDL_To_Get_Tipodocument @SOPTYPE1, @DOCID1, @BCHSOURC1, @sDocType OUTPUT
                                                END
                                                ELSE
                                                BEGIN 
                                                      SET @sDocType= @XDL_Tipo_Documento
                                                END
                                                      EXEC SP_XDL_ToValidate_CAI @sDocType, @XDL_Letra_Documento, @XDL_Posted_Date, @l_errstatus OUTPUT, @XDL_GP_DocNumber, '', '', @l_CAI OUTPUT, @l_DueDateCAI OUTPUT
                                          END
                                    END
                                    IF @l_errstatus = 1 
                                    BEGIN
                                          UPDATE XDL10101 SET XDL_CAI=@l_CAI , XDL_CAI_Due_Date= @l_DueDateCAI WHERE XDL_GP_DocNumber= @XDL_GP_DocNumber AND XDL_Tipo_Documento= @XDL_Tipo_Documento
                                    END
                                          UPDATE XDL10101 SET XDL_Impresiones_Factura= @XDL_Impresiones_Factura + 1 WHERE XDL_GP_DocNumber= @XDL_GP_DocNumber AND XDL_Tipo_Documento= @XDL_Tipo_Documento
                              END
                              FETCH NEXT FROM CMAIN1 into @XDL_GP_DocNumber, @XDL_Tipo_Documento, @XDL_Letra_Documento,  @XDL_Remito_DocNumber, 
                                                      @XDL_Punto_de_venta, @BCHSOURC, @SOPTYPE, @DOCID, @XDL_DocNumber, @XDL_Posted_Date
                        END
                        CLOSE CMAIN1
                        DEALLOCATE CMAIN1
      END



      IF EXISTS ( SELECT TOP 1 1 From XDL80101 Where  XDL_Check_Remito = 0 ) 
      BEGIN
            DECLARE CMAIN1 CURSOR FAST_FORWARD FOR
            SELECT XDL_GP_DocNumber Documento, XDL_Tipo_Documento TipoDoc, XDL_Letra_Documento LetraDoc, XDL_Punto_de_venta PuntodeVenta, 
                     BCHSOURC, SOPTYPE, DOCID, XDL_DocNumber, XDL_Posted_Date From XDL80101 Where XDL_Check_Remito = 0 

                        OPEN CMAIN1 

                        FETCH NEXT FROM CMAIN1 into @XDL_GP_DocNumber , @XDL_Tipo_Documento , @XDL_Letra_Documento , @XDL_Punto_de_venta , 
                      @BCHSOURC, @SOPTYPE, @DOCID, @XDL_DocNumber, @XDL_Posted_Date
                        WHILE @@FETCH_STATUS =0
                        BEGIN
                              IF @XDL_Tipo_Documento='Nota de Credito' AND @XDL_Tipo_Documento='Nota de debito'
                              BEGIN
                                    IF @BCHSOURC='Inventory' OR @BCHSOURC='Inventario'
                                    BEGIN
										IF @BCHSOURC='Inventory' 
										BEGIN 
											EXEC SP_XDL_Imprime_TRX @XDL_GP_DocNumber, 'Packing List', @XDL_Letra_Documento, @DOCID, @BCHSOURC, @l_boError OUTPUT , @UserID_Par, @CompID
										END     
										ELSE IF @BCHSOURC='Inventario' 
										BEGIN 
											EXEC SP_XDL_Imprime_TRX @XDL_GP_DocNumber, 'Lista de remisión', @XDL_Letra_Documento, @DOCID, @BCHSOURC, @l_boError OUTPUT , @UserID_Par, @CompID
										END                                 
									END
                                    ELSE
                                    BEGIN
                                          EXEC SP_XDL_Proceso_Impresion @XDL_GP_DocNumber,@XDL_Tipo_Documento,@XDL_Letra_Documento,@XDL_Posted_Date,
                                           @l_CAI OUTPUT,@l_DueDateCAI OUTPUT
                                    /*    IF @l_CAI <> '' AND @l_DueDateCAI <> ''
                                          BEGIN */
										IF @BCHSOURC='Inventory' 
										BEGIN 
											EXEC SP_XDL_Imprime_Doc @XDL_GP_DocNumber, 'Packing List', @XDL_Letra_Documento, @DOCID, @SOPTYPE, 
                                                       @BCHSOURC, @sPatchReport, @XDL_DocNumber, @l_boError OUTPUT, '', '',  @UserID_Par, @CompID
										END     
										ELSE IF @BCHSOURC='Inventario' 
										BEGIN 
											EXEC SP_XDL_Imprime_Doc @XDL_GP_DocNumber, 'Lista de remisión', @XDL_Letra_Documento, @DOCID, @SOPTYPE, 
                                                       @BCHSOURC, @sPatchReport, @XDL_DocNumber, @l_boError OUTPUT, '', '',  @UserID_Par, @CompID
										END 
                                          /*    END*/
                                    END

                                    IF @l_boError = 1
                                    BEGIN
                                          IF EXISTS(SELECT TOP 1 1 FROM XDL10101 WHERE XDL_GP_DocNumber= @XDL_GP_DocNumber AND XDL_Tipo_Documento= @XDL_Tipo_Documento AND XDL_Letra_Documento = @XDL_Letra_Documento)
                                          BEGIN
                                                SELECT TOP 1 @XDL_CAI=XDL_CAI, @XDL_CAI_Due_Date=XDL_CAI_Due_Date, @SOPTYPE1=SOPTYPE, @DOCID1=DOCID, @BCHSOURC1=BCHSOURC,
                                                            @XDL_Impresiones_Remito= XDL_Impresiones_Remito FROM XDL10101 
                                                            WHERE XDL_GP_DocNumber= @XDL_GP_DocNumber AND XDL_Tipo_Documento= @XDL_Tipo_Documento AND XDL_Letra_Documento = @XDL_Letra_Documento
                                                IF @XDL_CAI='' AND @XDL_CAI_Due_Date=NULL
                                                BEGIN
                                                      IF @XDL_Tipo_Documento = 'Packing List' OR @XDL_Tipo_Documento = 'Lista de remisión'
                                                      BEGIN
                                                            EXEC SP_XDL_To_Get_Tipodocument @SOPTYPE1, @DOCID1, @BCHSOURC1, @sDocType OUTPUT
                                                      END
                                                      ELSE
                                                      BEGIN 
                                                            SET @sDocType= @XDL_Tipo_Documento
                                                      END
                                                      EXEC SP_XDL_ToValidate_CAI @sDocType, @XDL_Letra_Documento, @XDL_Posted_Date, @l_errstatus OUTPUT, @XDL_GP_DocNumber, '', '', @l_CAI OUTPUT, @l_DueDateCAI OUTPUT
                                                      IF @l_errstatus = 1 
                                                      BEGIN
                                                            UPDATE XDL10101 SET XDL_CAI=@l_CAI , XDL_CAI_Due_Date= @l_DueDateCAI WHERE XDL_GP_DocNumber= @XDL_GP_DocNumber AND XDL_Tipo_Documento= @XDL_Tipo_Documento AND XDL_Letra_Documento = @XDL_Letra_Documento
                                                      END
                                                END
                                                UPDATE XDL10101 SET XDL_Impresiones_Remito= @XDL_Impresiones_Remito + 1 WHERE XDL_GP_DocNumber= @XDL_GP_DocNumber AND XDL_Tipo_Documento= @XDL_Tipo_Documento AND XDL_Letra_Documento = @XDL_Letra_Documento
                                          END
                                    END
                              END

                              FETCH NEXT FROM CMAIN1 into @XDL_GP_DocNumber, @XDL_Tipo_Documento, @XDL_Letra_Documento, @XDL_Punto_de_venta, 
                              @BCHSOURC, @SOPTYPE, @DOCID, @XDL_DocNumber, @XDL_Posted_Date
                        END
                        CLOSE CMAIN1
                        DEALLOCATE CMAIN1
      END



END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[Proceso_Impresion] TO [DYNGRP] 
GO 

/*End_Proceso_Impresion*/
