/*Count : 55 */ 
 
set DATEFORMAT ymd 
GO 

/*Begin_TLRS_FormatCuit*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TLRS_FormatCuit' and type = 'FN')
DROP FUNCTION TLRS_FormatCuit
GO

CREATE FUNCTION dbo.TLRS_FormatCuit (@INCuit CHAR(10))  
RETURNS CHAR(15)  
AS   
BEGIN   
 DECLARE @CuitNew CHAR(14)  
 IF @INCuit = ''
	SET @INCuit = '00000-0000'
 
 set @CuitNew = '0' + Substring(@INCuit,1,1) + '-' + Substring(@INCuit,2,8) + '-' + Substring(@INCuit,10,1)   
RETURN (@CuitNew)  
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TLRS_FormatCuit]  TO [DYNGRP]
GO

/*End_TLRS_FormatCuit*/
/*Begin_TL_RS_Citi_Sales_DocFrmt*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_Citi_Sales_DocFrmt' and type = 'FN')
DROP FUNCTION TL_RS_Citi_Sales_DocFrmt
GO


create function TL_RS_Citi_Sales_DocFrmt(        
 @INDocNumbr char(21),        
 @INDocType int,        
 @INFindDocType int,        
 @INType int)        
 returns int        
 begin    
 declare  @result int,        
    @valueset int,        
    @Letra varchar(10),        
    @PosLetra int,        
    @INDocTypeRet int  ,  
 @Let_IntValue int      
     
 if @INFindDocType=0        
  begin         
   if @INType=2        
    select  @valueset =  LETRA,@PosLetra=Pos_Letra from AWLI40380 where SOPTYPE=@INDocType        
   else         
   begin        
       
    select  @PosLetra = Pos_Letra from AWLI40300     
   
 set @Letra =  SUBSTRING(@INDocNumbr, @PosLetra, 1)    
 if  @Letra='A'  
  set @Let_IntValue=1  
 else if  @Letra='B'  
  set @Let_IntValue=2  
 else if  @Letra='C'  
  set @Let_IntValue=3  
 else if  @Letra='D'  
  set @Let_IntValue=4  
 else if  @Letra='E'  
  set @Let_IntValue=5  
 else if  @Letra='M'  
  set @Let_IntValue=6  
   
 select  @valueset =  LETRA from AWLI40370 where RMDTYPAL=@INDocType  and LETRA=@Let_IntValue     
   end        
            
  if @valueset=0        
   return 0        
  set @Letra =  SUBSTRING(@INDocNumbr, @PosLetra, 1)          
  if @valueset=1        
   begin        
   if @Letra<>'A'        
   return 0        
   end      
  else if @valueset=2        
   begin      
   if @Letra<>'B'        
   return 0      
   end        
  else if @valueset=3        
   begin      
   if @Letra<>'C'        
   return 0        
   end      
  else if @valueset=4        
   begin       
   if @Letra<>'E'        
   return 0      
   end        
  else if @valueset=6        
   if @Letra<>'M'        
   return 0        
              
           
  if SUBSTRING(@INDocNumbr, @PosLetra+1, 1)<>'-'        
   return 0         
  return 1        
 end        
 else        
    if @INType=2        
  select @INDocTypeRet = convert(int,COD_COMP) FROM AWLI40380 where SOPTYPE=@INDocType        
 else   
	begin
	  select  @PosLetra = Pos_Letra from AWLI40300     
   
 set @Letra =  SUBSTRING(@INDocNumbr, @PosLetra, 1)    
 if  @Letra='A'  
  set @Let_IntValue=1  
 else if  @Letra='B'  
  set @Let_IntValue=2  
 else if  @Letra='C'  
  set @Let_IntValue=3  
 else if  @Letra='D'  
  set @Let_IntValue=4  
 else if  @Letra='E'  
  set @Let_IntValue=5  
 else if  @Letra='M'  
  set @Let_IntValue=6  
   
	select  @valueset =  LETRA from AWLI40370 where RMDTYPAL=@INDocType  and LETRA=@Let_IntValue     
  
  select @INDocTypeRet = convert(int,COD_COMP) FROM AWLI40370 where RMDTYPAL=@INDocType  and LETRA=@valueset       
  end
    
	return isnull(@INDocTypeRet,0)        
        
end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_Citi_Sales_DocFrmt]  TO [DYNGRP]
GO

/*End_TL_RS_Citi_Sales_DocFrmt*/
/*Begin_TL_RS_Citi_SalesTaxAmnt*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_Citi_SalesTaxAmnt' and type = 'FN')
DROP FUNCTION TL_RS_Citi_SalesTaxAmnt
GO

CREATE function  TL_RS_Citi_SalesTaxAmnt(      
 @INDocNumr char(21),    
 @INPosition int,    
 @INReportID char(15),    
 @INColumnNo int,    
 @INTaxDtlId char(15),    
 @INType int  )       
 returns numeric(19,5)      
 as      
 begin      
 declare @TotAmnt numeric(19,5),    
   @IDTAXOP char(21),    
   @TIPOIMP smallint,    
   @TaxDtlId char(15),    
   @TaxAmnt numeric(19,5),      
   @TaxSalesAmnt numeric(19,5),    
   @TotSalesAmnt numeric(19,5)    
 set @TotAmnt=0    
 if @INPosition=1    
  begin    
  if @INType=1     
   select @TotAmnt= sum(TAXAMNT) FROM         RM10601 INNER JOIN    
                      nfRFC_TX00201 ON RM10601.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and RM10601.DOCNUMBR=@INDocNumr     
  else if @INType=2    
   select @TotAmnt= sum(STAXAMNT) FROM         SOP10105 INNER JOIN    
                      nfRFC_TX00201 ON SOP10105.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and SOP10105.SOPNUMBE=@INDocNumr     
   AND (SOP10105.LNITMSEQ = 0)    
  else if @INType=3    
   select @TotAmnt=sum(TAXAMNT) FROM         TX30000 INNER JOIN    
                      nfRFC_TX00201 ON TX30000.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and TX30000.DOCNUMBR=@INDocNumr     
  if @INType=3    
   if @TotAmnt<0    
   set @TotAmnt= @TotAmnt* -1    
  return @TotAmnt    
        
  end     
 else if @INPosition=2    
  begin    
     if @INType=1    
  declare c cursor fast_forward for select  RM10601.TAXDTLID,    
   RM10601.TAXAMNT,RM10601.TDTTXSLS,RM10601.TAXDTSLS    
   FROM         RM10601 INNER JOIN    
                      nfRFC_TX00201 ON RM10601.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and RM10601.DOCNUMBR=@INDocNumr     
  else if @INType=2    
  declare c cursor fast_forward for select  SOP10105.TAXDTLID,    
  SOP10105.STAXAMNT,SOP10105.TDTTXSLS,SOP10105.TAXDTSLS    
  FROM         SOP10105 INNER JOIN    
                      nfRFC_TX00201 ON SOP10105.TAXDTLID = nfRFC_TX00201.TAXDTLID    
  where nfRFC_TX00201.CLASS=1 and SOP10105.SOPNUMBE=@INDocNumr     
  AND (SOP10105.LNITMSEQ = 0)    
  else if @INType=3    
  declare c cursor fast_forward for select  TX30000.TAXDTLID,    
  TX30000.TAXAMNT,TX30000.Taxable_Amount,TX30000.DOCAMNT    
  FROM         TX30000 INNER JOIN    
                      nfRFC_TX00201 ON TX30000.TAXDTLID = nfRFC_TX00201.TAXDTLID    
  where nfRFC_TX00201.CLASS=1 and TX30000.DOCNUMBR=@INDocNumr     
         
  open c    
  fetch next from c into @TaxDtlId,@TaxAmnt,@TaxSalesAmnt, @TotSalesAmnt    
  while @@fetch_status=0  
  begin    
   SELECT    @TIPOIMP=AWLI40102.TIPOIMP    
   FROM         TLRS10203 INNER JOIN    
                      AWLI40102 ON TLRS10203.IDTAXOP = AWLI40102.IDTAXOP    
   WHERE     (TLRS10203.RPTID = @INReportID) AND (TLRS10203.NRORDCOL = @INColumnNo)    
   and AWLI40102.TAXDTLID=@TaxDtlId    
   if @TIPOIMP=1     
    set @TotAmnt = @TotAmnt + @TaxAmnt    
   else if @TIPOIMP=2     
    set @TotAmnt = @TotAmnt + @TaxSalesAmnt    
   else if @TIPOIMP=3    
    set @TotAmnt = @TotAmnt + @TotSalesAmnt    
    set @TIPOIMP=0   
   fetch next from c into @TaxDtlId,@TaxAmnt,@TaxSalesAmnt, @TotSalesAmnt    
        end    
     close c    
  deallocate c    
  if @INType=3    
  if @TotAmnt<0    
  set @TotAmnt= @TotAmnt* -1    
  return @TotAmnt    
      
    end    
 else if @INPosition=3    
 begin    
  if @INType=1     
   select  @TaxAmnt=RM10601.TAXAMNT,@TaxSalesAmnt=RM10601.TDTTXSLS,@TotSalesAmnt=RM10601.TAXDTSLS    
   FROM         RM10601 INNER JOIN    
   nfRFC_TX00201 ON RM10601.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and RM10601.DOCNUMBR=@INDocNumr     
   and RM10601.TAXDTLID = @INTaxDtlId    
  else if @INType=2    
   select  @TaxAmnt=SOP10105.STAXAMNT,@TaxSalesAmnt=SOP10105.TDTTXSLS,@TotSalesAmnt=SOP10105.TAXDTSLS    
   FROM         SOP10105 INNER JOIN    
               nfRFC_TX00201 ON SOP10105.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and SOP10105.SOPNUMBE=@INDocNumr     
   and SOP10105.TAXDTLID = @INTaxDtlId AND (SOP10105.LNITMSEQ = 0)    
  else if @INType=3    
   select @TaxAmnt=TX30000.TAXAMNT,@TaxSalesAmnt=TX30000.Taxable_Amount,@TotSalesAmnt=TX30000.DOCAMNT    
   FROM         TX30000 INNER JOIN    
                      nfRFC_TX00201 ON TX30000.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and TX30000.DOCNUMBR=@INDocNumr     
   and TX30000.TAXDTLID = @INTaxDtlId    
    
   SELECT    @TIPOIMP=AWLI40102.TIPOIMP    
   FROM         TLRS10203 INNER JOIN    
   AWLI40102 ON TLRS10203.IDTAXOP = AWLI40102.IDTAXOP    
   WHERE     (TLRS10203.RPTID = @INReportID) AND (TLRS10203.NRORDCOL = @INColumnNo)    
   and AWLI40102.TAXDTLID=@INTaxDtlId    
    
   if @TIPOIMP=1     
    set @TotAmnt = @TaxAmnt    
   else if @TIPOIMP=2     
    set @TotAmnt = @TaxSalesAmnt    
   else if @TIPOIMP=3    
    set @TotAmnt = @TotSalesAmnt    
   if @INType=3    
    if @TotAmnt<0    
    set @TotAmnt= @TotAmnt* -1    
   return @TotAmnt    
 end    
    else if @INPosition=4    
 begin    
  if @INType=1    
   select  @TotAmnt= count(*)    
   FROM         RM10601 INNER JOIN    
                      nfRFC_TX00201 ON RM10601.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and RM10601.DOCNUMBR=@INDocNumr     
  else if @INType=2    
   select  @TotAmnt= count(*)    
   FROM         SOP10105 INNER JOIN    
                      nfRFC_TX00201 ON SOP10105.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and SOP10105.SOPNUMBE=@INDocNumr     
   AND (SOP10105.LNITMSEQ = 0)    
  else if @INType=3    
   select  @TotAmnt= count(*)    
   FROM         TX30000 INNER JOIN    
                      nfRFC_TX00201 ON TX30000.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=1 and TX30000.DOCNUMBR=@INDocNumr     
     
     
  return @TotAmnt    
   end      
  return @TotAmnt    
 end    

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_Citi_SalesTaxAmnt]  TO [DYNGRP]
GO
/*End_TL_RS_Citi_SalesTaxAmnt*/
/*Begin_TL_RS_ReporteImpuestos_SM*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_ReporteImpuestos_SM' and type = 'TF')
DROP FUNCTION TL_RS_ReporteImpuestos_SM
GO

create function [dbo].[TL_RS_ReporteImpuestos_SM]       
(      
@Report_Type int,    
@USERID AS CHAR(15),      
@TaxValidation AS VARCHAR(15) = NULL       
)    
returns @TempTable table    
(    
PrimKey  bigint identity(1,1),  
RPTNAME    char(30),    
RPTID    char(15),    
TipoReporte   smallint,    
NumeroDeOrden  smallint,    
IDGRIMP    char(15),    
DSCRIPTN   char(31),    
AWLI_DOCUMENT_STATE char(5),    
DOCTYPE    smallint,    
DOCNUMBR   char(21),    
VCHRNMBR   char(21),    
DOCDATE    datetime,    
GLPOSTDT   datetime,    
CUSTVNDR   char(15),    
CUSTNAME   char(65),    
TXRGNNUM   char(25),    
SLSAMNT    numeric(19,5),    
TRDISAMT   numeric(19,5),    
FRTAMNT    numeric(19,5),    
MISCAMNT   numeric(19,5),    
TAXAMNT    numeric(19,5),    
DOCAMNT    numeric(19,5),    
Void    tinyint,    
DOCID    char(15),    
AWLI_DOCTYPEDESC char(7),    
VOIDDATE   datetime,    
CURNCYID   char(15),    
OPERATION   smallint,    
COL01    NUMERIC(19,5),       
COL02    NUMERIC(19,5),       
COL03    NUMERIC(19,5),        
COL04  NUMERIC(19,5),        
COL05  NUMERIC(19,5),        
COL06  NUMERIC(19,5),        
COL07  NUMERIC(19,5),       
COL08  NUMERIC(19,5),       
COL09  NUMERIC(19,5),       
COL10  NUMERIC(19,5),       
COL11  NUMERIC(19,5),       
COL12  NUMERIC(19,5),       
COL13  NUMERIC(19,5),       
COL14  NUMERIC(19,5),       
COL15  NUMERIC(19,5),       
COL16  NUMERIC(19,5),       
COL17  NUMERIC(19,5),       
COL18  NUMERIC(19,5),       
COL19  NUMERIC(19,5),       
COL20  NUMERIC(19,5)    
)    
begin      
         
     
DECLARE @TipoReporte as SMALLINT, @HISTORY as TINYINT, @UNPSTTRX as TINYINT, @OPENTRX as TINYINT, @SORTBY1 as SMALLINT      
DECLARE @AWFiltraXDocumentDate as TINYINT, @STTDOCDT as DATETIME, @ENDDOCDT as DATETIME, @AWFiltraXPostDate as TINYINT      
DECLARE @STTPSTDT as DATETIME, @ENDPSTDT as DATETIME, @TipoCorteControl as smallint      
DECLARE @RM_SALESINV as tinyint, @RM_DEBITMEM as tinyint, @RM_FINCHRGS as tinyint, @RM_SERVNREP as tinyint, @RM_WARRANTY as tinyint      
DECLARE @RM_CREDMEMO as tinyint, @RM_RETURNS as tinyint, @PM_INVOICE as tinyint, @PM_FINCHR as tinyint, @PM_MISCHARG AS tinyint, @PM_RETURN as tinyint      
DECLARE @PM_CRDMEM as tinyint, @FiltraSOPDOC as tinyint     
declare @ReportName char(30),@IDReporte char(15)     
      
      
      
DECLARE @D_TYPE AS INT, @D_STATE AS VARCHAR(4), @D_DOCTYPE AS INT, @D_DOCNUMBR AS CHAR(21), @D_VCHRNMBR AS CHAR(21), @D_DOCDATE AS DATETIME      
DECLARE @D_GLPOSTDT AS DATETIME, @D_CUSTVENDID AS CHAR(15), @D_CUSTVENDNAME AS CHAR(65), @D_TXRGNNUM AS CHAR(25)      
DECLARE @D_SALESPURCHAMNT AS NUMERIC(19,5), @D_TRDISAMT AS NUMERIC(19,5), @D_FRTAMNT AS NUMERIC(19,5), @D_MISCAMNT AS NUMERIC(19,5)      
DECLARE @D_TAXAMNT AS NUMERIC(19,5), @D_DOCAMNT AS NUMERIC(19,5), @D_VOIDED AS INT, @D_DOCID AS CHAR(15), @D_DOCTYPEDESC AS VARCHAR(7), @D_VOIDDATE AS DATETIME, @D_CURNCYID AS CHAR(15)      
      
DECLARE @T_TYPE AS INT, @T_DOCTYPE AS INT, @T_VCHRNMBR AS CHAR(21), @T_TAXDTLID AS CHAR(15), @T_TAXAMNT AS NUMERIC(19,5)      
DECLARE @T_TAXDTAMT AS NUMERIC(19,5), @T_TDTTXAMT AS NUMERIC(19,5)      
DECLARE @NumeroDeOrden as SMALLINT, @IDGRUPOIMP as CHAR(15), @DESCGRUPOIMP AS CHAR(31)      
      
DECLARE @COL01 AS NUMERIC(19,5), @COL02 AS NUMERIC(19,5), @COL03 AS NUMERIC(19,5), @COL04 AS NUMERIC(19,5), @COL05 AS NUMERIC(19,5)      
DECLARE @COL06 AS NUMERIC(19,5), @COL07 AS NUMERIC(19,5), @COL08 AS NUMERIC(19,5), @COL09 AS NUMERIC(19,5), @COL10 AS NUMERIC(19,5)      
DECLARE @COL11 AS NUMERIC(19,5), @COL12 AS NUMERIC(19,5), @COL13 AS NUMERIC(19,5), @COL14 AS NUMERIC(19,5), @COL15 AS NUMERIC(19,5)      
DECLARE @COL16 AS NUMERIC(19,5), @COL17 AS NUMERIC(19,5), @COL18 AS NUMERIC(19,5), @COL19 AS NUMERIC(19,5), @COL20 AS NUMERIC(19,5)      
DECLARE @MONTO AS NUMERIC(19,5), @OPERACION AS INTEGER      
DECLARE @T_COL01 AS NUMERIC(19,5), @T_COL02 AS NUMERIC(19,5), @T_COL03 AS NUMERIC(19,5), @T_COL04 AS NUMERIC(19,5), @T_COL05 AS NUMERIC(19,5)      
DECLARE @T_COL06 AS NUMERIC(19,5), @T_COL07 AS NUMERIC(19,5), @T_COL08 AS NUMERIC(19,5), @T_COL09 AS NUMERIC(19,5), @T_COL10 AS NUMERIC(19,5)      
DECLARE @T_COL11 AS NUMERIC(19,5), @T_COL12 AS NUMERIC(19,5), @T_COL13 AS NUMERIC(19,5), @T_COL14 AS NUMERIC(19,5), @T_COL15 AS NUMERIC(19,5)      
DECLARE @T_COL16 AS NUMERIC(19,5), @T_COL17 AS NUMERIC(19,5), @T_COL18 AS NUMERIC(19,5), @T_COL19 AS NUMERIC(19,5), @T_COL20 AS NUMERIC(19,5)      
DECLARE @NROGRUPO AS SMALLINT, @IDGRUPO as CHAR(15), @DESCGRUPO AS CHAR(31)      
      
DECLARE @COL_NROORDCOL AS INTEGER, @COL_TIPOIMP AS INTEGER, @COL_OPVTAX AS INTEGER, @COL_TAXDTLID AS CHAR(15)      
    declare @Col_2 numeric(19,5), @IncludeCol2  int
if @Report_Type=1 
 declare TLRS_Setup cursor fast_forward for select RPRTNAME,IDReporteSales from TLIV10102 where PerSales=1    
else if @Report_Type=2 
 declare TLRS_Setup cursor fast_forward for select RPRTNAME,IDReportePurchase from TLIV10102 where PerPurchase=1    
else if @Report_Type = 3  
 declare TLRS_Setup cursor fast_forward for select RPRTNAME, RPTID from TLSIC10100 where Percepciones=1    
else if @Report_Type=4 
 declare TLRS_Setup cursor fast_forward for select '' as RPRTNAME, TLRG10101.RPTID FROM         TLRG10101 INNER JOIN    
                      TLRS10101 ON TLRG10101.RPTID = TLRS10101.RPTID and TLRS10101.TipoReporte=2  and  TLRG10101.TLRG1361=1  
else if @Report_Type=5 
 declare TLRS_Setup cursor fast_forward for select '' as RPRTNAME, TLRG10101.RPTID FROM         TLRG10101 INNER JOIN    
                      TLRS10101 ON TLRG10101.RPTID = TLRS10101.RPTID and TLRS10101.TipoReporte=1 and TLRG10101.TLRG1361=1    
else if @Report_Type = 6  
 declare TLRS_Setup cursor fast_forward for select RPRTNAME, REPCOMPRAS from TLCP10101    
else if @Report_Type = 7  
 declare TLRS_Setup cursor fast_forward for select RPRTNAME, REPVTAS from TLCP10101   
else if @Report_Type=10 
 declare TLRS_Setup cursor fast_forward for select RPRTNAME,RPTID from TLST10102 where Percepciones=1 
else if @Report_Type=11 
 declare TLRS_Setup cursor fast_forward for select RPRTNAME,IDReporteSales from TLIV10102 where PerSales=1 
else if @Report_Type=12 
 declare TLRS_Setup cursor fast_forward for select RPRTNAME,IDReportePurchase from TLIV10102 where PerPurchase=1 
else if @Report_Type=13 
 declare TLRS_Setup cursor fast_forward for     
      SELECT A.RPRTNAME, B.IDReportePurchase     
      FROM TLRS10100 A INNER JOIN TLSF10100 B ON A.RPRTNAME = B.RPRTNAME     
      WHERE A.RPTID = 'SIFERE' AND A.RPRTNAME <> 'XYZ123'
else    
 return    
open TLRS_Setup  
fetch next from TLRS_Setup into @ReportName,@IDReporte  

while @@fetch_status=0  
begin  
SELECT @TipoReporte=TipoReporte, @HISTORY=HISTORY, @UNPSTTRX=UNPSTTRX, @OPENTRX=OpenTRX, @SORTBY1=SORTBY1,     
 @AWFiltraXDocumentDate=AWFiltraXDocumentDate, @STTDOCDT=STTDOCDT, @ENDDOCDT=ENDDOCDT,  @AWFiltraXPostDate=AWFiltraXPostDate,     
 @STTPSTDT=STTPSTDT, @ENDPSTDT=ENDPSTDT, @TipoCorteControl=TipoCorteControl,    
 @RM_SALESINV=SALESINV, @RM_DEBITMEM=DEBITMEM, @RM_FINCHRGS=FINCHRGS, @RM_SERVNREP=SERVNREP, @RM_WARRANTY=WARRANTY,    
 @RM_CREDMEMO=CREDMEMO, @RM_RETURNS=RETURNS, @PM_INVOICE=PMINVOIC, @PM_FINCHR=PMFINCHR, @PM_MISCHARG=MISCHARG,    
 @PM_RETURN=PMRETURN, @PM_CRDMEM=PMCRDMEM, @FiltraSOPDOC=AWLI_Filtra_SOP_Doc    
FROM TLRS10101 WHERE @IDReporte=RPTID  
  
 If @TipoReporte=1 AND @SORTBY1=1     
  DECLARE DOCUMENTOS CURSOR FOR SELECT * FROM AWLI_DOCUMENTOS_SM     
  WHERE  TYPE=1 AND  ((DOCTYPE=1 AND @PM_INVOICE=1) OR  (DOCTYPE=2 AND @PM_FINCHR=1) OR  (DOCTYPE=3 AND @PM_MISCHARG=1) OR     
   (DOCTYPE=4 AND @PM_RETURN=1) OR (DOCTYPE=5 AND @PM_CRDMEM=1))  AND ((STATE='WORK' AND @UNPSTTRX=1) OR     
   (STATE='OPEN' AND @OPENTRX=1) OR (STATE='HIST' AND @HISTORY=1)) AND (NOT @AWFiltraXDocumentDate=1 OR     
  (DOCDATE >=@STTDOCDT AND DOCDATE<=@ENDDOCDT)) AND (NOT @AWFiltraXPostDate=1 OR (GLPOSTDT >=@STTPSTDT AND     
  GLPOSTDT<=@ENDPSTDT))    
  ORDER BY DOCDATE,DOCNUMBR     
 else If @TipoReporte=1 AND @SORTBY1=2      
  DECLARE DOCUMENTOS CURSOR FOR SELECT * FROM AWLI_DOCUMENTOS_SM     
  WHERE TYPE=1 AND ((DOCTYPE=1 AND @PM_INVOICE=1) OR (DOCTYPE=2 AND @PM_FINCHR=1) OR (DOCTYPE=3 AND @PM_MISCHARG=1) OR     
  (DOCTYPE=4 AND @PM_RETURN=1) OR (DOCTYPE=5 AND @PM_CRDMEM=1)) AND ((STATE='WORK' AND @UNPSTTRX=1) OR     
   (STATE='OPEN' AND @OPENTRX=1) OR (STATE='HIST' AND @HISTORY=1)) AND (NOT @AWFiltraXDocumentDate=1 OR     
  (DOCDATE >=@STTDOCDT AND DOCDATE<=@ENDDOCDT)) AND (NOT @AWFiltraXPostDate=1 OR (GLPOSTDT >=@STTPSTDT AND     
  GLPOSTDT<=@ENDPSTDT))     
  ORDER BY DOCDATE,CUSTVENDID, DOCNUMBR     
 else if @TipoReporte=2 AND @SORTBY1=1       
  DECLARE DOCUMENTOS CURSOR FOR SELECT * FROM AWLI_DOCUMENTOS_SM     
  WHERE TYPE=2 AND ((DOCTYPE=1 AND @RM_SALESINV=1) OR (DOCTYPE=3 AND @RM_DEBITMEM=1) OR (DOCTYPE=4 AND @RM_FINCHRGS=1) OR     
  (DOCTYPE=5 AND @RM_SERVNREP=1) OR (DOCTYPE=6 AND @RM_WARRANTY=1) OR  (DOCTYPE=7 AND @RM_CREDMEMO=1) OR     
   (DOCTYPE=8 AND @RM_RETURNS=1) ) AND ((STATE='WORK' AND @UNPSTTRX=1) OR (STATE='OPEN' AND @OPENTRX=1) OR     
   (STATE='HIST' AND @HISTORY=1)) AND (NOT @AWFiltraXDocumentDate=1 OR (DOCDATE >=@STTDOCDT AND DOCDATE<=@ENDDOCDT)) AND     
  (NOT @AWFiltraXPostDate=1 OR (GLPOSTDT >=@STTPSTDT AND GLPOSTDT<=@ENDPSTDT)) AND ((DOCID = '') OR     
   NOT EXISTS  (SELECT  *  FROM TLRS10202  WHERE  AWLI_DOCUMENTOS_SM.DOCID = TLRS10202.DOCID AND RPTID = @IDReporte) OR     
  NOT (@FiltraSOPDOC = 1))     
  ORDER BY DOCDATE,DOCNUMBR     
 else if @TipoReporte=2 AND @SORTBY1=2       
  DECLARE DOCUMENTOS CURSOR FOR SELECT * FROM AWLI_DOCUMENTOS_SM     
  WHERE TYPE=2 AND ((DOCTYPE=1 AND @RM_SALESINV=1) OR (DOCTYPE=3 AND @RM_DEBITMEM=1) OR (DOCTYPE=4 AND @RM_FINCHRGS=1) OR     
   (DOCTYPE=5 AND @RM_SERVNREP=1) OR (DOCTYPE=6 AND @RM_WARRANTY=1) OR (DOCTYPE=7 AND @RM_CREDMEMO=1) OR     
   (DOCTYPE=8 AND @RM_RETURNS=1) ) AND ((STATE='WORK' AND @UNPSTTRX=1) OR (STATE='OPEN' AND @OPENTRX=1) OR     
   (STATE='HIST' AND @HISTORY=1)) AND (NOT @AWFiltraXDocumentDate=1 OR (DOCDATE >=@STTDOCDT AND DOCDATE<=@ENDDOCDT)) AND     
  (NOT @AWFiltraXPostDate=1 OR (GLPOSTDT >=@STTPSTDT AND GLPOSTDT<=@ENDPSTDT)) AND ((DOCID = '') OR     
  NOT EXISTS  (SELECT  *  FROM TLRS10202  WHERE  AWLI_DOCUMENTOS_SM.DOCID = TLRS10202.DOCID AND RPTID = @IDReporte) OR     
  NOT (@FiltraSOPDOC = 1))     
  ORDER BY DOCDATE,CUSTVENDID, DOCNUMBR     
 else return     
     
    
 OPEN  DOCUMENTOS    
 FETCH NEXT FROM DOCUMENTOS INTO @D_TYPE, @D_STATE, @D_DOCTYPE, @D_DOCNUMBR, @D_VCHRNMBR, @D_DOCDATE,@D_GLPOSTDT, @D_CUSTVENDID,    
    @D_CUSTVENDNAME,  @D_TXRGNNUM, @D_SALESPURCHAMNT, @D_TRDISAMT, @D_FRTAMNT, @D_MISCAMNT, @D_TAXAMNT,    
   @D_DOCAMNT, @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID    
    
    
 WHILE (@@FETCH_STATUS=0)        
   BEGIN     
      
   SELECT @COL01=0, @COL02=0, @COL03=0, @COL04=0, @COL05=0, @COL06=0, @COL07=0, @COL08=0, @COL09=0, @COL10=0, @COL11=0, @COL12=0, @COL13=0, @COL14=0, @COL15=0, @COL16=0, @COL17=0, @COL18=0, @COL19=0, @COL20=0    
      
 select @COL01=COL01,@COL02=COL02,@COL03=COL03,@COL04=COL04,@COL05=COL05,@COL06=COL06,  
     @COL07=COL07,@COL08=COL08,@COL09=COL09,@COL10=COL10,@COL11=COL11,@COL12=COL12,  
     @COL13=COL13,@COL14=COL14,@COL15=COL15,@COL16=COL16,@COL17=COL17,@COL18=COL18,  
     @COL19=COL19,@COL20=COL20    
 from TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaTotales(@IDReporte,@USERID,@D_SALESPURCHAMNT,@D_TRDISAMT,@D_FRTAMNT,@D_MISCAMNT,@D_TAXAMNT,@D_DOCAMNT,    
    @COL01,@COL02,@COL03,@COL04,@COL05,@COL06,@COL07,@COL08,@COL09,@COL10,@COL11,@COL12,@COL13,@COL14,@COL15,@COL16,@COL17,@COL18,@COL19,@COL20)  
   
      
 DECLARE DOC_IMPUESTOS CURSOR FOR     
 SELECT    AWLI_IMPUESTOS_SM.*, ISNULL(GRUPOIMP.NumeroDeOrden, 0) AS NumeroDeOrden, ISNULL(GRUPOIMP.IDGRIMP, '')  AS IDGRUPOIMP, ISNULL(GRUPOIMP.DSCRIPTN, '') AS DSCRIPTN     
 FROM        AWLI_IMPUESTOS_SM LEFT OUTER JOIN     
         (SELECT     AWLI40202.TAXDTLID, TLRS10201.RPTID, TLRS10201.NumeroDeOrden, AWLI40202.IDGRIMP, TLRS10201.DSCRIPTN     
        FROM          TLRS10201 INNER JOIN     
                AWLI40202 ON TLRS10201.IDGRIMP = AWLI40202.IDGRIMP     
        WHERE      (TLRS10201.RPTID = @IDReporte)) GRUPOIMP ON GRUPOIMP.TAXDTLID = dbo.AWLI_IMPUESTOS_SM.TAXDTLID     
 WHERE     (TYPE=@D_TYPE AND DOCTYPE=@D_DOCTYPE AND VCHRNMBR=@D_VCHRNMBR) AND     
           
   (  NOT EXISTS  (SELECT     TipoCorteControl FROM TLRS10101 WHERE      TLRS10101.RPTID = @IDReporte AND TipoCorteControl = 2) OR     
  NOT  (GRUPOIMP.NumeroDeOrden IS NULL)  )     
 ORDER BY GRUPOIMP.NumeroDeOrden, dbo.AWLI_IMPUESTOS_SM.TAXDTLID     
 OPEN DOC_IMPUESTOS    
       
 FETCH NEXT FROM DOC_IMPUESTOS INTO @T_TYPE, @T_DOCTYPE, @T_VCHRNMBR, @T_TAXDTLID, @T_TAXAMNT, @T_TAXDTAMT,    
    @T_TDTTXAMT, @NumeroDeOrden, @IDGRUPOIMP,@DESCGRUPOIMP     
       
 IF @TipoCorteControl=1    
   BEGIN select @NumeroDeOrden=0, @IDGRUPOIMP='', @DESCGRUPOIMP='' END    
       
 IF (@@FETCH_STATUS=0)         
   BEGIN     
         
   SELECT @NROGRUPO=@NumeroDeOrden, @IDGRUPO= @IDGRUPOIMP, @DESCGRUPO=@DESCGRUPOIMP    
   SELECT @T_COL01=@COL01, @T_COL02=@COL02, @T_COL03=@COL03, @T_COL04=@COL04, @T_COL05=@COL05, @T_COL06=@COL06, @T_COL07=@COL07, @T_COL08=@COL08,    
  @T_COL09=@COL09, @T_COL10=@COL10, @T_COL11=@COL11, @T_COL12=@COL12, @T_COL13=@COL13, @T_COL14=@COL14, @T_COL15=@COL15,     
  @T_COL16=@COL16, @T_COL17=@COL17, @T_COL18=@COL18, @T_COL19=@COL19, @T_COL20=@COL20     
         
   WHILE (@@FETCH_STATUS=0)    
     BEGIN      
   select @T_COL01=COL01,@T_COL02=COL02,@T_COL03=COL03,@T_COL04=COL04,@T_COL05=COL05,@T_COL06=COL06,  
     @T_COL07=COL07,@T_COL08=COL08,@T_COL09=COL09,@T_COL10=COL10,@T_COL11=COL11,@T_COL12=COL12,  
     @T_COL13=COL13,@T_COL14=COL14,@T_COL15=COL15,@T_COL16=COL16,@T_COL17=COL17,@T_COL18=COL18,  
     @T_COL19=COL19,@T_COL20=COL20   
   from TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaImpuestos(@IDReporte, @USERID, @T_TAXDTLID, @T_TAXAMNT,@T_TAXDTAMT,@T_TDTTXAMT, @T_COL01,@T_COL02,@T_COL03,@T_COL04,@T_COL05,@T_COL06,@T_COL07,    
      @T_COL08,@T_COL09,@T_COL10,@T_COL11,@T_COL12,@T_COL13,@T_COL14,@T_COL15,@T_COL16,@T_COL17,@T_COL18,@T_COL19,@T_COL20)  
          
  FETCH NEXT FROM DOC_IMPUESTOS INTO @T_TYPE, @T_DOCTYPE, @T_VCHRNMBR, @T_TAXDTLID, @T_TAXAMNT, @T_TAXDTAMT, @T_TDTTXAMT, @NumeroDeOrden, @IDGRUPOIMP,@DESCGRUPOIMP    
           
  IF @TipoCorteControl=1     
    BEGIN      
   select @NumeroDeOrden=0, @IDGRUPOIMP='', @DESCGRUPOIMP=''     
    END     
           
  IF (@@FETCH_STATUS=0)    
    BEGIN     
   IF @NROGRUPO<>@NumeroDeOrden      
     BEGIN     
    IF (@D_TYPE=1 AND (@D_DOCTYPE=4 OR @D_DOCTYPE=5)) OR (@D_TYPE=2 AND (@D_DOCTYPE=7 OR @D_DOCTYPE=8))     
      BEGIN  
    set @OPERACION=-1  
    if exists(select Col_2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))  
     begin
	 	select @Col_2=Col_2,@IncludeCol2=IncludeCol2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02)
		if @IncludeCol2=0
			set @Col_2=@T_COL02
			
     INSERT INTO @TempTable        
      (RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,       
      DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,              
      SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,  
      COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,  
      COL15,COL16,COL17,COL18,COL19,COL20)     
     VALUES     
       (@ReportName, @IDReporte, @D_TYPE,   @NROGRUPO, @IDGRUPO, @DESCGRUPO, @D_STATE,     
        @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,      
        @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,     
        @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,  
      @T_COL01*@OPERACION,@Col_2*@OPERACION,@T_COL03*@OPERACION,@T_COL04*@OPERACION,  
      @T_COL05*@OPERACION,@T_COL06*@OPERACION,@T_COL07*@OPERACION,@T_COL08*@OPERACION,  
      @T_COL09*@OPERACION,@T_COL10*@OPERACION,@T_COL11*@OPERACION,@T_COL12*@OPERACION,  
      @T_COL13*@OPERACION,@T_COL14*@OPERACION,@T_COL15*@OPERACION,@T_COL16*@OPERACION,  
      @T_COL17*@OPERACION,@T_COL18*@OPERACION,@T_COL19*@OPERACION,@T_COL20*@OPERACION)  
     end  
    END    
    ELSE     
    BEGIN    
    set @OPERACION=1  
    if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))  
    begin  
		select @Col_2=Col_2,@IncludeCol2=IncludeCol2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02)
		if @IncludeCol2=0
			set @Col_2=@T_COL02
    INSERT INTO @TempTable        
     (RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,       
     DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,              
     SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,  
     COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,  
     COL15,COL16,COL17,COL18,COL19,COL20)     
    VALUES     
      (@ReportName, @IDReporte, @D_TYPE,   @NROGRUPO, @IDGRUPO, @DESCGRUPO, @D_STATE,     
       @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,      
       @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,     
       @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,  
     @T_COL01,@Col_2,@T_COL03,@T_COL04,@T_COL05,@T_COL06,@T_COL07,@T_COL08, @T_COL09,@T_COL10,@T_COL11,@T_COL12,@T_COL13,@T_COL14,@T_COL15,@T_COL16,@T_COL17,@T_COL18,@T_COL19,@T_COL20)  
    end  
     END     
              
    SELECT @NROGRUPO=@NumeroDeOrden, @IDGRUPO= @IDGRUPOIMP, @DESCGRUPO=@DESCGRUPOIMP     
    SELECT @T_COL01=@COL01, @T_COL02=@COL02, @T_COL03=@COL03, @T_COL04=@COL04, @T_COL05=@COL05, @T_COL06=@COL06, @T_COL07=@COL07, @T_COL08=@COL08,     
   @T_COL09=@COL09, @T_COL10=@COL10, @T_COL11=@COL11, @T_COL12=@COL12, @T_COL13=@COL13, @T_COL14=@COL14, @T_COL15=@COL15, @T_COL16=@COL16, @T_COL17=@COL17, @T_COL18=@COL18, @T_COL19=@COL19, @T_COL20=@COL20     
     END     
    END      
  ELSE       
    BEGIN     
   IF (@D_TYPE=1 AND (@D_DOCTYPE=4 OR @D_DOCTYPE=5)) OR (@D_TYPE=2 AND (@D_DOCTYPE=7 OR @D_DOCTYPE=8))     
     BEGIN   
      set @OPERACION=-1  
    if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))  
    begin  
		select @Col_2=Col_2,@IncludeCol2=IncludeCol2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02)
		if @IncludeCol2=0
			set @Col_2=@T_COL02
    INSERT INTO @TempTable        
     (RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,       
     DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,              
     SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,  
     COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,  
     COL15,COL16,COL17,COL18,COL19,COL20)     
    VALUES     
      (@ReportName, @IDReporte, @D_TYPE,   @NROGRUPO, @IDGRUPO, @DESCGRUPO, @D_STATE,     
       @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,      
       @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,     
       @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,  
       @T_COL01*@OPERACION,@Col_2*@OPERACION,@T_COL03*@OPERACION,@T_COL04*@OPERACION,  
     @T_COL05*@OPERACION,@T_COL06*@OPERACION,@T_COL07*@OPERACION,@T_COL08*@OPERACION,  
     @T_COL09*@OPERACION,@T_COL10*@OPERACION,@T_COL11*@OPERACION,@T_COL12*@OPERACION,  
     @T_COL13*@OPERACION,@T_COL14*@OPERACION,@T_COL15*@OPERACION,@T_COL16*@OPERACION,  
     @T_COL17*@OPERACION,@T_COL18*@OPERACION,@T_COL19*@OPERACION,@T_COL20*@OPERACION)  
    end  
    END     
   ELSE     
     BEGIN   
    set @OPERACION=1  
    if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))  
    begin  
		select @Col_2=Col_2,@IncludeCol2=IncludeCol2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02)
		if @IncludeCol2=0
			set @Col_2=@T_COL02
    INSERT INTO @TempTable        
     (RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,       
     DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,              
     SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,  
     COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,  
     COL15,COL16,COL17,COL18,COL19,COL20)     
    VALUES     
      (@ReportName, @IDReporte, @D_TYPE,   @NROGRUPO, @IDGRUPO, @DESCGRUPO, @D_STATE,     
       @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,      
       @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,     
       @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,  
     @T_COL01,@Col_2,@T_COL03,@T_COL04,@T_COL05,@T_COL06,@T_COL07,@T_COL08, @T_COL09,@T_COL10,@T_COL11,@T_COL12,@T_COL13,@T_COL14,@T_COL15,@T_COL16,@T_COL17,@T_COL18,@T_COL19,@T_COL20)  
    end  
    END     
    END     
     END         
   END     
 ELSE             
   BEGIN     
  IF @TipoCorteControl=1       
    BEGIN     
   IF (@D_TYPE=1 AND (@D_DOCTYPE=4 OR @D_DOCTYPE=5)) OR (@D_TYPE=2 AND (@D_DOCTYPE=7 OR @D_DOCTYPE=8))     
     BEGIN   
   set @OPERACION=-1  
    if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))  
    begin  
		select @Col_2=Col_2,@IncludeCol2=IncludeCol2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@COL02)
		if @IncludeCol2=0
			set @Col_2=@COL02
    INSERT INTO @TempTable        
     (RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,       
     DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,              
     SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,  
     COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,  
     COL15,COL16,COL17,COL18,COL19,COL20)     
    VALUES     
      (@ReportName, @IDReporte, @D_TYPE,   0, '', '', @D_STATE,     
       @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,      
       @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,     
       @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,  
     @COL01*@OPERACION,@Col_2*@OPERACION,@COL03*@OPERACION,@COL04*@OPERACION,  
     @COL05*@OPERACION,@COL06*@OPERACION,@COL07*@OPERACION,@COL08*@OPERACION,  
     @COL09*@OPERACION,@COL10*@OPERACION,@COL11*@OPERACION,@COL12*@OPERACION,  
     @COL13*@OPERACION,@COL14*@OPERACION,@COL15*@OPERACION,@COL16*@OPERACION,  
     @COL17*@OPERACION,@COL18*@OPERACION,@COL19*@OPERACION,@COL20*@OPERACION)  
    end  
    END     
   ELSE     
     BEGIN   
   set @OPERACION=1  
    if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))  
    begin  
		select @Col_2=Col_2,@IncludeCol2=IncludeCol2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@COL02)
		if @IncludeCol2=0
			set @Col_2=@COL02
    INSERT INTO @TempTable        
     (RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,       
     DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,              
     SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,  
     COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,  
     COL15,COL16,COL17,COL18,COL19,COL20)     
    VALUES     
      (@ReportName, @IDReporte, @D_TYPE,   0, '', '', @D_STATE,     
       @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,      
       @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,     
       @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,  
     @COL01,@Col_2,@COL03,@COL04,@COL05,@COL06,@COL07,@COL08, @COL09,@COL10,@COL11,@COL12,@COL13,@COL14,@COL15,@COL16,@COL17,@COL18,@COL19,@COL20)  
    end  
    END     
    END     
  ELSE IF @TipoCorteControl=2       
    BEGIN     
   DECLARE CORTE_CONTROL CURSOR FOR     
   SELECT NumeroDeOrden, IDGRIMP,DSCRIPTN FROM TLRS10201      
   WHERE RPTID=@IDReporte AND INCZERO=1     
   ORDER BY NumeroDeOrden, IDGRIMP     
   OPEN CORTE_CONTROL     
   FETCH NEXT FROM CORTE_CONTROL INTO @NumeroDeOrden, @IDGRUPOIMP,@DESCGRUPO     
   IF (@@FETCH_STATUS<>0)     
     BEGIN SELECT @NumeroDeOrden=0, @IDGRUPO= '', @DESCGRUPO='' END     
   CLOSE CORTE_CONTROL     
   DEALLOCATE CORTE_CONTROL     
   IF (@D_TYPE=1 AND (@D_DOCTYPE=4 OR @D_DOCTYPE=5)) OR (@D_TYPE=2 AND (@D_DOCTYPE=7 OR @D_DOCTYPE=8))     
     BEGIN set @OPERACION=-1  
    if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))  
    begin  
		select @Col_2=Col_2,@IncludeCol2=IncludeCol2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@COL02)
		if @IncludeCol2=0
			set @Col_2=@COL02
    INSERT INTO @TempTable        
     (RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,       
     DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,              
     SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,  
     COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,  
     COL15,COL16,COL17,COL18,COL19,COL20)     
    VALUES     
      (@ReportName, @IDReporte, @D_TYPE,   0, '', '', @D_STATE,     
       @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,      
       @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,     
       @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,  
     @COL01*@OPERACION,@Col_2*@OPERACION,@COL03*@OPERACION,@COL04*@OPERACION,  
     @COL05*@OPERACION,@COL06*@OPERACION,@COL07*@OPERACION,@COL08*@OPERACION,  
     @COL09*@OPERACION,@COL10*@OPERACION,@COL11*@OPERACION,@COL12*@OPERACION,  
     @COL13*@OPERACION,@COL14*@OPERACION,@COL15*@OPERACION,@COL16*@OPERACION,  
     @COL17*@OPERACION,@COL18*@OPERACION,@COL19*@OPERACION,@COL20*@OPERACION)  
    end  
    END     
   ELSE     
     BEGIN set @OPERACION=1  
    if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))  
    begin  
		select @Col_2=Col_2,@IncludeCol2=IncludeCol2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@COL02)
		if @IncludeCol2=0
			set @Col_2=@COL02
    INSERT INTO @TempTable        
     (RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,       
     DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,              
     SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,  
     COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,  
     COL15,COL16,COL17,COL18,COL19,COL20)     
    VALUES     
      (@ReportName, @IDReporte, @D_TYPE,   0, '', '', @D_STATE,     
       @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,      
       @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,     
       @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,  
     @COL01,@Col_2,@COL03,@COL04,@COL05,@COL06,@COL07,@COL08, @COL09,@COL10,@COL11,@COL12,@COL13,@COL14,@COL15,@COL16,@COL17,@COL18,@COL19,@COL20)  
    end  
     END     
    END     
   END     
        
 CLOSE  DOC_IMPUESTOS     
 DEALLOCATE DOC_IMPUESTOS     
        
   FETCH NEXT FROM DOCUMENTOS INTO @D_TYPE, @D_STATE, @D_DOCTYPE, @D_DOCNUMBR, @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT,@D_CUSTVENDID, @D_CUSTVENDNAME,       
     @D_TXRGNNUM, @D_SALESPURCHAMNT, @D_TRDISAMT, @D_FRTAMNT, @D_MISCAMNT, @D_TAXAMNT, @D_DOCAMNT, @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE,@D_CURNCYID     
   END        
      
     
 CLOSE DOCUMENTOS     
 DEALLOCATE DOCUMENTOS  
 fetch next from TLRS_Setup into @ReportName,@IDReporte   
end     
 CLOSE TLRS_Setup     
 DEALLOCATE TLRS_Setup   
return  
end  


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_ReporteImpuestos_SM]  TO [DYNGRP]
GO

/*End_TL_RS_ReporteImpuestos_SM*/
/*Begin_TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaImpuestos*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaImpuestos' and type = 'TF')
DROP FUNCTION TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaImpuestos
GO


CREATE function [dbo].[TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaImpuestos] (   
@IDReporte AS CHAR(15),  
@USERID AS CHAR(15),   
@T_TAXDTLID AS CHAR(15),   
@T_TAXAMNT AS NUMERIC(19,5),   
@T_TAXDTAMT AS NUMERIC(19,5),   
@T_TDTTXAMT AS NUMERIC(19,5),   
@COL01_IN AS NUMERIC(19,5),   
@COL02_IN AS NUMERIC(19,5),   
@COL03_IN AS NUMERIC(19,5),    
@COL04_IN AS NUMERIC(19,5),    
@COL05_IN AS NUMERIC(19,5),    
@COL06_IN AS NUMERIC(19,5),    
@COL07_IN AS NUMERIC(19,5),   
@COL08_IN AS NUMERIC(19,5),   
@COL09_IN AS NUMERIC(19,5),   
@COL10_IN AS NUMERIC(19,5),   
@COL11_IN AS NUMERIC(19,5),   
@COL12_IN AS NUMERIC(19,5),   
@COL13_IN AS NUMERIC(19,5),   
@COL14_IN AS NUMERIC(19,5),   
@COL15_IN AS NUMERIC(19,5),   
@COL16_IN AS NUMERIC(19,5),   
@COL17_IN AS NUMERIC(19,5),   
@COL18_IN AS NUMERIC(19,5),   
@COL19_IN AS NUMERIC(19,5),   
@COL20_IN AS NUMERIC(19,5)
)
returns @TEMPTABLECOLM table
(
COL01  NUMERIC(19,5),   
COL02  NUMERIC(19,5),   
COL03  NUMERIC(19,5),    
COL04  NUMERIC(19,5),    
COL05  NUMERIC(19,5),    
COL06  NUMERIC(19,5),    
COL07  NUMERIC(19,5),   
COL08  NUMERIC(19,5),   
COL09  NUMERIC(19,5),   
COL10  NUMERIC(19,5),   
COL11  NUMERIC(19,5),   
COL12  NUMERIC(19,5),   
COL13  NUMERIC(19,5),   
COL14  NUMERIC(19,5),   
COL15  NUMERIC(19,5),   
COL16  NUMERIC(19,5),   
COL17  NUMERIC(19,5),   
COL18  NUMERIC(19,5),   
COL19  NUMERIC(19,5),   
COL20  NUMERIC(19,5)
)
begin
  declare @COL01 AS NUMERIC(19,5),   
		@COL02 AS NUMERIC(19,5),   
		@COL03 AS NUMERIC(19,5),    
		@COL04 AS NUMERIC(19,5),    
		@COL05 AS NUMERIC(19,5),    
		@COL06 AS NUMERIC(19,5),    
		@COL07 AS NUMERIC(19,5),   
		@COL08 AS NUMERIC(19,5),   
		@COL09 AS NUMERIC(19,5),   
		@COL10 AS NUMERIC(19,5),   
		@COL11 AS NUMERIC(19,5),   
		@COL12 AS NUMERIC(19,5),   
		@COL13 AS NUMERIC(19,5),   
		@COL14 AS NUMERIC(19,5),   
		@COL15 AS NUMERIC(19,5),   
		@COL16 AS NUMERIC(19,5),   
		@COL17 AS NUMERIC(19,5),   
		@COL18 AS NUMERIC(19,5),   
		@COL19 AS NUMERIC(19,5),   
		@COL20 AS NUMERIC(19,5)  
   
   
SELECT @COL01=@COL01_IN, @COL02=@COL02_IN, @COL03=@COL03_IN, @COL04=@COL04_IN, @COL05=@COL05_IN, @COL06=@COL06_IN, @COL07=@COL07_IN, @COL08=@COL08_IN,   
 @COL09=@COL09_IN, @COL10=@COL10_IN, @COL11=@COL11_IN, @COL12=@COL12_IN, @COL13=@COL13_IN, @COL14=@COL14_IN, @COL15=@COL15_IN,   
 @COL16=@COL16_IN, @COL17=@COL17_IN, @COL18=@COL18_IN, @COL19=@COL19_IN, @COL20=@COL20_IN   
   
DECLARE @MONTO AS NUMERIC(19,5)   
DECLARE @OPERACION AS INTEGER   
   
   
DECLARE @COL_NROORDCOL AS INTEGER, @COL_TIPOIMP AS INTEGER, @COL_OPVTAX AS INTEGER, @COL_TAXDTLID AS CHAR(15)   
   
   
 DECLARE COL_IMPUESTOS CURSOR FOR   
 SELECT    TLRS10203.NRORDCOL, AWLI40102.TIPOIMP, AWLI40102.OPOVTAX, AWLI40102.TAXDTLID   
 FROM         AWLI40102 INNER JOIN   
                       TLRS10203 ON AWLI40102.IDTAXOP = TLRS10203.IDTAXOP   
 WHERE     (TLRS10203.RPTID = @IDReporte AND AWLI40102.TIPOIMP <4 AND AWLI40102.TIPOIMP >=1 AND AWLI40102.TAXDTLID=@T_TAXDTLID )         
 ORDER BY TLRS10203.RPTID, TLRS10203.NRORDCOL, AWLI40102.TIPOIMP, AWLI40102.TAXDTLID   
 OPEN COL_IMPUESTOS   
   
   
   
 FETCH NEXT FROM COL_IMPUESTOS INTO @COL_NROORDCOL, @COL_TIPOIMP, @COL_OPVTAX, @COL_TAXDTLID   
 WHILE (@@FETCH_STATUS=0)   
      BEGIN   
  SELECT @MONTO=0   
   
     
  IF  @COL_OPVTAX=1    
   SELECT @OPERACION=1     
  ELSE IF @COL_OPVTAX=2    
   SELECT @OPERACION=-1    
  ELSE     
   SELECT @OPERACION=0     
   
     
  IF @COL_TIPOIMP=1 SELECT @MONTO=@OPERACION * @T_TAXAMNT   
  IF @COL_TIPOIMP=2 SELECT @MONTO=@OPERACION * @T_TDTTXAMT   
  IF @COL_TIPOIMP=3 SELECT @MONTO=@OPERACION * @T_TAXDTAMT   
   
       
  IF @COL_NROORDCOL = 1 SELECT @COL01=@COL01+@MONTO   
  ELSE IF @COL_NROORDCOL = 2    SELECT @COL02=@COL02+@MONTO   
  ELSE IF @COL_NROORDCOL = 3    SELECT @COL03=@COL03+@MONTO   
  ELSE IF @COL_NROORDCOL = 4    SELECT @COL04=@COL04+@MONTO   
  ELSE IF @COL_NROORDCOL = 5    SELECT @COL05=@COL05+@MONTO   
  ELSE IF @COL_NROORDCOL = 6    SELECT @COL06=@COL06+@MONTO   
  ELSE IF @COL_NROORDCOL = 7    SELECT @COL07=@COL07+@MONTO   
  ELSE IF @COL_NROORDCOL = 8    SELECT @COL08=@COL08+@MONTO   
  ELSE IF @COL_NROORDCOL = 9    SELECT @COL09=@COL09+@MONTO   
  ELSE IF @COL_NROORDCOL = 10  SELECT @COL10=@COL10+@MONTO   
  ELSE IF @COL_NROORDCOL = 11  SELECT @COL11=@COL11+@MONTO   
  ELSE IF @COL_NROORDCOL = 12  SELECT @COL12=@COL12+@MONTO   
  ELSE IF @COL_NROORDCOL = 13  SELECT @COL13=@COL13+@MONTO   
  ELSE IF @COL_NROORDCOL = 14  SELECT @COL14=@COL14+@MONTO   
  ELSE IF @COL_NROORDCOL = 15  SELECT @COL15=@COL15+@MONTO   
  ELSE IF @COL_NROORDCOL = 16  SELECT @COL16=@COL16+@MONTO   
  ELSE IF @COL_NROORDCOL = 17  SELECT @COL17=@COL17+@MONTO   
  ELSE IF @COL_NROORDCOL = 18  SELECT @COL18=@COL18+@MONTO   
  ELSE IF @COL_NROORDCOL = 19  SELECT @COL19=@COL19+@MONTO   
  ELSE IF @COL_NROORDCOL = 20  SELECT @COL20=@COL20+@MONTO   
   
     
  FETCH NEXT FROM COL_IMPUESTOS INTO @COL_NROORDCOL, @COL_TIPOIMP, @COL_OPVTAX, @COL_TAXDTLID    
      END   
   
       
 CLOSE COL_IMPUESTOS   
 DEALLOCATE COL_IMPUESTOS  
 insert into @TEMPTABLECOLM values(@COL01,@COL02,@COL03,@COL04,@COL05,@COL06,@COL07,@COL08,
		@COL09,@COL10,@COL11,@COL12,@COL13,@COL14,@COL15,@COL16,@COL17,@COL18,@COL19,@COL20)
return
end
 
 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaImpuestos]  TO [DYNGRP]
GO

/*End_TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaImpuestos*/
/*Begin_TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaTotales*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaTotales' and type = 'TF')
DROP FUNCTION TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaTotales
GO

CREATE function [dbo].[TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaTotales]    
(
@IDReporte AS CHAR(15),  
@USERID AS CHAR(15),   
@D_SALESPURCHAMNT AS NUMERIC(19,5),   
@D_TRDISAMT AS NUMERIC(19,5),   
@D_FRTAMNT AS NUMERIC(19,5),   
@D_MISCAMNT AS NUMERIC(19,5),   
@D_TAXAMNT AS NUMERIC(19,5),   
@D_DOCAMNT AS NUMERIC(19,5),   
@COL01_IN AS NUMERIC(19,5),   
@COL02_IN AS NUMERIC(19,5),   
@COL03_IN AS NUMERIC(19,5),    
@COL04_IN AS NUMERIC(19,5),    
@COL05_IN AS NUMERIC(19,5),    
@COL06_IN AS NUMERIC(19,5),    
@COL07_IN AS NUMERIC(19,5),   
@COL08_IN AS NUMERIC(19,5),   
@COL09_IN AS NUMERIC(19,5),   
@COL10_IN AS NUMERIC(19,5),   
@COL11_IN AS NUMERIC(19,5),   
@COL12_IN AS NUMERIC(19,5),   
@COL13_IN AS NUMERIC(19,5),   
@COL14_IN AS NUMERIC(19,5),   
@COL15_IN AS NUMERIC(19,5),   
@COL16_IN AS NUMERIC(19,5),   
@COL17_IN AS NUMERIC(19,5),   
@COL18_IN AS NUMERIC(19,5),   
@COL19_IN AS NUMERIC(19,5),   
@COL20_IN AS NUMERIC(19,5)
)
returns @TEMPTABLECOL table
(
COL01  NUMERIC(19,5),   
COL02  NUMERIC(19,5),   
COL03  NUMERIC(19,5),    
COL04  NUMERIC(19,5),    
COL05  NUMERIC(19,5),    
COL06  NUMERIC(19,5),    
COL07  NUMERIC(19,5),   
COL08  NUMERIC(19,5),   
COL09  NUMERIC(19,5),   
COL10  NUMERIC(19,5),   
COL11  NUMERIC(19,5),   
COL12  NUMERIC(19,5),   
COL13  NUMERIC(19,5),   
COL14  NUMERIC(19,5),   
COL15  NUMERIC(19,5),   
COL16  NUMERIC(19,5),   
COL17  NUMERIC(19,5),   
COL18  NUMERIC(19,5),   
COL19  NUMERIC(19,5),   
COL20  NUMERIC(19,5)
)
begin
   

   
DECLARE @MONTO AS NUMERIC(19,5)   
DECLARE @OPERACION AS INTEGER   
declare @COL01 AS NUMERIC(19,5),   
		@COL02 AS NUMERIC(19,5),   
		@COL03 AS NUMERIC(19,5),    
		@COL04 AS NUMERIC(19,5),    
		@COL05 AS NUMERIC(19,5),    
		@COL06 AS NUMERIC(19,5),    
		@COL07 AS NUMERIC(19,5),   
		@COL08 AS NUMERIC(19,5),   
		@COL09 AS NUMERIC(19,5),   
		@COL10 AS NUMERIC(19,5),   
		@COL11 AS NUMERIC(19,5),   
		@COL12 AS NUMERIC(19,5),   
		@COL13 AS NUMERIC(19,5),   
		@COL14 AS NUMERIC(19,5),   
		@COL15 AS NUMERIC(19,5),   
		@COL16 AS NUMERIC(19,5),   
		@COL17 AS NUMERIC(19,5),   
		@COL18 AS NUMERIC(19,5),   
		@COL19 AS NUMERIC(19,5),   
		@COL20 AS NUMERIC(19,5)
   
SELECT @COL01=@COL01_IN, @COL02=@COL02_IN, @COL03=@COL03_IN, @COL04=@COL04_IN, @COL05=@COL05_IN, @COL06=@COL06_IN, @COL07=@COL07_IN, @COL08=@COL08_IN,   
 @COL09=@COL09_IN, @COL10=@COL10_IN, @COL11=@COL11_IN, @COL12=@COL12_IN, @COL13=@COL13_IN, @COL14=@COL14_IN, @COL15=@COL15_IN,   
 @COL16=@COL16_IN, @COL17=@COL17_IN, @COL18=@COL18_IN, @COL19=@COL19_IN, @COL20=@COL20_IN   
   
   
   
DECLARE @COL_NROORDCOL AS INTEGER, @COL_TIPOIMP AS INTEGER, @COL_OPVTAX AS INTEGER, @COL_TAXDTLID AS CHAR(15)   
   
   
 DECLARE COL_IMPUESTOS CURSOR FOR   
 SELECT    TLRS10203.NRORDCOL, AWLI40102.TIPOIMP, AWLI40102.OPOVTAX, AWLI40102.TAXDTLID   
 FROM         AWLI40102 INNER JOIN   
                       TLRS10203 ON AWLI40102.IDTAXOP = TLRS10203.IDTAXOP   
 WHERE     (TLRS10203.RPTID = @IDReporte AND AWLI40102.TIPOIMP >=4)   
 ORDER BY TLRS10203.RPTID, TLRS10203.NRORDCOL, AWLI40102.TIPOIMP, AWLI40102.TAXDTLID   
   
 OPEN COL_IMPUESTOS   
   
   
 FETCH NEXT FROM COL_IMPUESTOS INTO @COL_NROORDCOL, @COL_TIPOIMP, @COL_OPVTAX, @COL_TAXDTLID   
 WHILE (@@FETCH_STATUS=0)   
      BEGIN   
     
  SELECT @MONTO=0   
   
     
  IF  @COL_OPVTAX=1    
   SELECT @OPERACION=1     
  ELSE IF @COL_OPVTAX=2    
   SELECT @OPERACION=-1    
  ELSE     
   SELECT @OPERACION=0     
   
     
  IF @COL_TIPOIMP=4 SELECT @MONTO=@OPERACION * @D_SALESPURCHAMNT   
  IF @COL_TIPOIMP=5 SELECT @MONTO=@OPERACION *@D_TRDISAMT   
  IF @COL_TIPOIMP=6 SELECT @MONTO=@OPERACION *@D_FRTAMNT   
  IF @COL_TIPOIMP=7 SELECT @MONTO=@OPERACION *@D_MISCAMNT   
  IF @COL_TIPOIMP=8 SELECT @MONTO=@OPERACION *@D_TAXAMNT   
  IF @COL_TIPOIMP=9 SELECT @MONTO=@OPERACION *@D_DOCAMNT   
   
       
  IF @COL_NROORDCOL = 1 SELECT @COL01=@COL01+@MONTO   
  ELSE IF @COL_NROORDCOL = 2    SELECT @COL02=@COL02+@MONTO   
  ELSE IF @COL_NROORDCOL = 3    SELECT @COL03=@COL03+@MONTO   
  ELSE IF @COL_NROORDCOL = 4    SELECT @COL04=@COL04+@MONTO   
  ELSE IF @COL_NROORDCOL = 5    SELECT @COL05=@COL05+@MONTO   
  ELSE IF @COL_NROORDCOL = 6    SELECT @COL06=@COL06+@MONTO   
  ELSE IF @COL_NROORDCOL = 7    SELECT @COL07=@COL07+@MONTO   
  ELSE IF @COL_NROORDCOL = 8    SELECT @COL08=@COL08+@MONTO   
  ELSE IF @COL_NROORDCOL = 9    SELECT @COL09=@COL09+@MONTO   
  ELSE IF @COL_NROORDCOL = 10  SELECT @COL10=@COL10+@MONTO   
  ELSE IF @COL_NROORDCOL = 11  SELECT @COL11=@COL11+@MONTO   
  ELSE IF @COL_NROORDCOL = 12  SELECT @COL12=@COL12+@MONTO   
  ELSE IF @COL_NROORDCOL = 13  SELECT @COL13=@COL13+@MONTO   
  ELSE IF @COL_NROORDCOL = 14  SELECT @COL14=@COL14+@MONTO   
  ELSE IF @COL_NROORDCOL = 15  SELECT @COL15=@COL15+@MONTO   
  ELSE IF @COL_NROORDCOL = 16  SELECT @COL16=@COL16+@MONTO   
  ELSE IF @COL_NROORDCOL = 17  SELECT @COL17=@COL17+@MONTO   
  ELSE IF @COL_NROORDCOL = 18  SELECT @COL18=@COL18+@MONTO   
  ELSE IF @COL_NROORDCOL = 19  SELECT @COL19=@COL19+@MONTO   
  ELSE IF @COL_NROORDCOL = 20  SELECT @COL20=@COL20+@MONTO   
   
     
  FETCH NEXT FROM COL_IMPUESTOS INTO @COL_NROORDCOL, @COL_TIPOIMP, @COL_OPVTAX, @COL_TAXDTLID   
      END   
   
       
 CLOSE COL_IMPUESTOS   
 DEALLOCATE COL_IMPUESTOS   
 
insert into @TEMPTABLECOL values(@COL01,@COL02,@COL03,@COL04,@COL05,@COL06,@COL07,@COL08,
		@COL09,@COL10,@COL11,@COL12,@COL13,@COL14,@COL15,@COL16,@COL17,@COL18,@COL19,@COL20)
return
end

 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaTotales]  TO [DYNGRP]
GO

/*End_TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaTotales*/
/*Begin_dbo.TL_RS_CITIPurchase_ValoresLibros_PURCH*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CITIPurchase_ValoresLibros_PURCH' and type = 'FN')
DROP FUNCTION dbo.TL_RS_CITIPurchase_ValoresLibros_PURCH
GO

CREATE function [dbo].[TL_RS_CITIPurchase_ValoresLibros_PURCH](  
@IN_CurrID  char(15),
@IN_DOCDATE	datetime,  
@IN_VCRNMBR char(21),
@IN_DOCTYPE	smallint,
@IN_VENDORID char(15),
@IN_DocNumber	char(21) ,
@IN_Void	int 
)  
returns int  
begin    
 declare @remove int,  
   @Exists int,  
   @AWLI_DocNumber char(21),  
   @Letra char(1),  
   @val_letra int,  
   @CHECK_CAI tinyint,  
   @FROM_NMBR char(9),  
   @TO_NMBR char(9),  
   @FROM_DT datetime,  
   @TO_DT  datetime,  
   @FORMAT_DOC tinyint  
 set @remove=1    
  
 if len(@IN_DocNumber) <> 17     
 and (substring(@IN_DocNumber, 3,1) <> ' ' or substring(@IN_DocNumber, 3,1) = '')    
 and (substring(@IN_DocNumber, 9,1) <> '-' or substring(@IN_DocNumber, 9,1) = '')     
  set @remove=0  
else  
 begin  
  if exists(select top 1 DOCTYPE from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and     
   DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4)  
  begin  
   select top 1 @AWLI_DocNumber=AWLI_DocNumber from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and     
   DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4    
  
   set @Letra = substring(@AWLI_DocNumber,4,1)        
   if @Letra ='A'        
    set @val_letra =1        
   else if @Letra ='B'        
    set @val_letra =2        
   else if @Letra ='C'        
    set @val_letra =3        
   else if @Letra ='E'        
    set @val_letra =4        
   else if @Letra =' '        
    set @val_letra =5        
   else if @Letra ='M'        
    set @val_letra =6      
  
   if exists(SELECT  top 1 AWLI_PM00400.DOCTYPE     
   FROM         AWLI_PM00201   
   INNER JOIN AWLI_PM00400 ON AWLI_PM00201.VENDORID = AWLI_PM00400.VENDORID AND   
      AWLI_PM00201.COMP_TYPE = AWLI_PM00400.DOCTYPE    
   where AWLI_PM00400.DOCTYPE=@IN_DOCTYPE and   
     AWLI_PM00400.VENDORID=@IN_VENDORID and   
     AWLI_PM00400.VCHRNMBR=@IN_VCRNMBR and  
     AWLI_PM00400.OP_ORIGIN<>4 and   
     AWLI_PM00201.PDV=substring(AWLI_PM00400.AWLI_DocNumber,5,4) and  
     substring(AWLI_PM00400.AWLI_DocNumber,10,8)>=AWLI_PM00201.FROM_NMBR and  
     substring(AWLI_PM00400.AWLI_DocNumber,10,8)<=AWLI_PM00201.TO_NMBR and   
     @IN_DOCDATE between AWLI_PM00201.FROM_DT and AWLI_PM00201.TO_DT and    
     AWLI_PM00201.LETRA=@val_letra   
   ORDER BY AWLI_PM00400.VENDORID ASC, AWLI_PM00400.VCHRNMBR ASC, AWLI_PM00400.DOCTYPE ASC,    
   AWLI_PM00201.PDV ASC ,AWLI_PM00201.COMP_TYPE ASC)  
  
   begin    
    if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'')     
     if not exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)        
      set @remove=0      
   end  
  end  
 end  
  
 if @IN_Void=1    
  set @remove=0     
 return @remove      
        
end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_CITIPurchase_ValoresLibros_PURCH]  TO [DYNGRP]
GO
/*End_TL_RS_CITIPurchase_ValoresLibros_PURCH*/
/*Begin_dbo.TL_RS_CitiPurchaseReqValues*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiPurchaseReqValues' and type = 'TF')
DROP FUNCTION dbo.TL_RS_CitiPurchaseReqValues
GO

CREATE function [dbo].[TL_RS_CitiPurchaseReqValues](  
@IN_Type int 
)  
returns @TempTablePVals table
(
	Letra char(1),
	Letra_Value	int,
	PDV	char(10),	
	From_No	char(21),
	To_No	char(21),
	COD_COMP	char(3),
	CUST_CODE	char(3),
	DEST_CODE	char(5),
	NRO_DESP	char(7),
	DIGVERIF_NRODESP	char(1),
	CAI	char(31),
	TO_DT	datetime,
	CURR_CODE	char(3),
	T_CAMBIO	numeric(19,7),
	RESP_TYPE	char(3),
	CNTRLLR	tinyint,
	OP_ORIGIN	smallint,
	primkey bigint
	
) 
begin    
 declare @remove int,  
   @Exists int,  
   @AWLI_DocNumber char(21),  
   @Letra char(1),  
   @val_letra int,  
   @CHECK_CAI tinyint,  
   @FROM_NMBR char(9),  
   @TO_NMBR char(9),  
   @FROM_DT datetime,  
   @TO_DT  datetime,  
   @FORMAT_DOC tinyint,  
   @IN_CurrID  char(15),  
  @IN_DOCDATE datetime,    
  @IN_VCRNMBR char(21),  
  @IN_DOCTYPE smallint,  
  @IN_VENDORID char(15),  
  @IN_DocNumber char(21) ,  
  @IN_Void int,  
  @PrimKey bigint,  
  @PDV char(10),  
  @COD_COMP char(3),  
  @CUST_CODE char(3),  
  @DEST_CODE char(5),  
  @NRO_DESP char(7),  
  @DIGVERIF_NRODESP char(1),  
  @CAI char(31),  
  @ATO_DT datetime,  
  @CURR_CODE char(3),  
  @CURR_CODE_MC char(3),  
  @T_CAMBIO numeric(19,7),  
  @RESP_TYPE char(3),  
  @CNTRLLR tinyint,  
  @OP_ORIGIN smallint,  
  @XCHGRATE numeric(19,7)  
 set @remove=1    
 if @IN_Type=1  
 declare TL_Purch_Vals cursor  fast_forward  
  for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void FROM TL_RS_CitiPurchase_PURCH  
 else  
 return  
 OPEN TL_Purch_Vals  
 FETCH NEXT FROM TL_Purch_Vals INTO @PrimKey,@IN_CurrID,@IN_DOCDATE,@IN_VCRNMBR,@IN_DOCTYPE,@IN_VENDORID,  
  @IN_DocNumber,@IN_Void  
 WHILE @@fetch_status=0  
 begin   
 set @PDV =''  
 set @FORMAT_DOC=0  
 set @COD_COMP =''  
 set @CUST_CODE =''  
 set @DEST_CODE =''  
 set @NRO_DESP =''  
 set @DIGVERIF_NRODESP=''  
 set @CAI=''  
 set @ATO_DT =0  
 set @CURR_CODE=''  
 set @T_CAMBIO=0  
 set @RESP_TYPE=''  
 set @CNTRLLR=0  
 set @OP_ORIGIN=0  
 set @remove=1  
	if len(@IN_DocNumber) <> 17   
	and (substring(@IN_DocNumber, 3,1) <> ' ' or substring(@IN_DocNumber, 3,1) = '')  
	and (substring(@IN_DocNumber, 9,1) <> '-' or substring(@IN_DocNumber, 9,1) = '')  
		set @remove=0   
	else
	begin 
		if exists(select top 1 DOCTYPE from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and   
		DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4)  
		begin  
			select top 1 @AWLI_DocNumber=AWLI_DocNumber from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and   
			DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4  
			set @Letra = substring(@AWLI_DocNumber,4,1)  
	    
			if @Letra ='A'      
			set @val_letra =1      
			else if @Letra ='B'      
			set @val_letra =2      
			else if @Letra ='C'      
			set @val_letra =3      
			else if @Letra ='E'      
			set @val_letra =4      
			else if @Letra =' '      
			set @val_letra =5      
			else if @Letra ='M'      
			set @val_letra =6

			if exists
			(SELECT  top 1 AWLI_PM00400.DOCTYPE   
			FROM AWLI_PM00201 INNER JOIN  
			AWLI_PM00400 ON AWLI_PM00201.VENDORID = AWLI_PM00400.VENDORID AND 
							AWLI_PM00201.COMP_TYPE = AWLI_PM00400.DOCTYPE  
			where AWLI_PM00400.DOCTYPE=@IN_DOCTYPE and 
			AWLI_PM00400.VENDORID=@IN_VENDORID and 
			AWLI_PM00400.VCHRNMBR=@IN_VCRNMBR and 
			AWLI_PM00400.OP_ORIGIN<>4 and 
			AWLI_PM00201.PDV=substring(AWLI_PM00400.AWLI_DocNumber,5,4) and 
			substring(AWLI_PM00400.AWLI_DocNumber,10,8)>=AWLI_PM00201.FROM_NMBR and
			substring(AWLI_PM00400.AWLI_DocNumber,10,8)<=AWLI_PM00201.TO_NMBR and
			@IN_DOCDATE between AWLI_PM00201.FROM_DT and AWLI_PM00201.TO_DT and  
			AWLI_PM00201.LETRA=@val_letra 
			ORDER BY AWLI_PM00400.VENDORID ASC, AWLI_PM00400.VCHRNMBR ASC, AWLI_PM00400.DOCTYPE ASC,  
			AWLI_PM00201.PDV ASC ,AWLI_PM00201.COMP_TYPE ASC)  
			begin  
				SELECT  top 1 @FROM_NMBR=AWLI_PM00201.FROM_NMBR,@TO_NMBR=AWLI_PM00201.TO_NMBR,  
				@FROM_DT=AWLI_PM00201.FROM_DT,@TO_DT=AWLI_PM00201.TO_DT,@FORMAT_DOC=AWLI_PM00400.FORMAT_DOC   
				FROM AWLI_PM00201 INNER JOIN  
				AWLI_PM00400 ON AWLI_PM00201.VENDORID = AWLI_PM00400.VENDORID AND 
								AWLI_PM00201.COMP_TYPE = AWLI_PM00400.DOCTYPE  
				where AWLI_PM00400.DOCTYPE=@IN_DOCTYPE and 
				AWLI_PM00400.VENDORID=@IN_VENDORID and 
				AWLI_PM00400.VCHRNMBR=@IN_VCRNMBR and 
				AWLI_PM00400.OP_ORIGIN<>4 and 
				AWLI_PM00201.PDV=substring(AWLI_PM00400.AWLI_DocNumber,5,4) and 
				substring(AWLI_PM00400.AWLI_DocNumber,10,8)>=AWLI_PM00201.FROM_NMBR and
				substring(AWLI_PM00400.AWLI_DocNumber,10,8)<=AWLI_PM00201.TO_NMBR and
				@IN_DOCDATE between AWLI_PM00201.FROM_DT and AWLI_PM00201.TO_DT and  
				AWLI_PM00201.LETRA=@val_letra 
				ORDER BY AWLI_PM00400.VENDORID ASC, AWLI_PM00400.VCHRNMBR ASC, AWLI_PM00400.DOCTYPE ASC,  
				AWLI_PM00201.PDV ASC ,AWLI_PM00201.COMP_TYPE ASC

				if @FORMAT_DOC=1  
				begin  
					set @PDV=substring(@AWLI_DocNumber,5,4)  
					set @FROM_NMBR=substring(@AWLI_DocNumber,10,8)  
					set @TO_NMBR=substring(@AWLI_DocNumber,10,8)  
				end  
				else  
				begin
					set @PDV='0000'  
					set @FROM_NMBR =dbo.[TLRS_GetDocNumber_Purchase](@AWLI_DocNumber,0)  
					set @TO_NMBR=@FROM_NMBR  
				end

				if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'')   
				begin  
					if exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)      
					begin  
						select @CURR_CODE_MC=CURR_CODE from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID  
						set @CURR_CODE=@CURR_CODE_MC
						if @CURR_CODE='PES'
							set @T_CAMBIO=1
						else
						begin
							if exists(select XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR    
							 and DOCTYPE=@IN_DOCTYPE)
							begin
							 select @XCHGRATE=XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR
							 and DOCTYPE=@IN_DOCTYPE
							 set @T_CAMBIO=@XCHGRATE
							end
						end
					end
					else
						set @remove=0
				end  
				else  
				begin  
					set @CURR_CODE='PES'
					set @T_CAMBIO=1   
				end
			end
		end
	end
	if @PDV='' 
		begin
		set @PDV=substring(@IN_DocNumber,5,4)  
		set @FROM_NMBR=substring(@IN_DocNumber,10,8)  
		set @TO_NMBR=substring(@IN_DocNumber,10,8)
		end
	select	@COD_COMP=COD_COMP, 
			@CUST_CODE=CUST_CODE, 
			@DEST_CODE=DEST_CODE,  
			@NRO_DESP=NRO_DESP,
			@DIGVERIF_NRODESP=DIGVERIF_NRODESP,
			@CAI=CAI,  
			@ATO_DT=TO_DT,
			@CURR_CODE=CURR_CODE,
			@T_CAMBIO=T_CAMBIO,
			@RESP_TYPE=RESP_TYPE,  
			@CNTRLLR=CNTRLLR,
			@OP_ORIGIN=OP_ORIGIN  
	from AWLI_PM00400 
	where VENDORID=@IN_VENDORID and 
	VCHRNMBR=@IN_VCRNMBR and 
	DOCTYPE=@IN_DOCTYPE
  if @remove=1  
	begin
	insert into @TempTablePVals values(@Letra,@val_letra,@PDV,@FROM_NMBR,@TO_NMBR,  
	@COD_COMP,@CUST_CODE,@DEST_CODE,@NRO_DESP,@DIGVERIF_NRODESP,@CAI,@ATO_DT,@CURR_CODE,  
	@T_CAMBIO,@RESP_TYPE,@CNTRLLR,@OP_ORIGIN,@PrimKey)  
	end
  FETCH NEXT FROM TL_Purch_Vals INTO @PrimKey,@IN_CurrID,@IN_DOCDATE,@IN_VCRNMBR,@IN_DOCTYPE,@IN_VENDORID,  
  @IN_DocNumber,@IN_Void  
   
 end
 close TL_Purch_Vals  
 deallocate TL_Purch_Vals  
 return    
      
end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_CitiPurchaseReqValues]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_CitiPurchaseReqValues*/
/*Begin_dbo.TL_RS_TaxValidationInfo*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_TaxValidationInfo' and type = 'TF')
DROP FUNCTION dbo.TL_RS_TaxValidationInfo
GO

CREATE function TL_RS_TaxValidationInfo(
@IDReporte	CHAR(15),
@D_VCHRNMBR CHAR(21),
@D_TAXAMNT	numeric(19,5),
@TaxValidation VARCHAR(15),
@COL02		numeric(19,5)
)
returns @TempTableTax table 
(
	Col_2	numeric(19,5),
	IncludeCol2	int
)
begin
	DECLARE @TX_COUNT1 as int, @TX_COUNT2 as int , @TX_PCT as NUMERIC(19,5), @COL02_1 AS NUMERIC(19,5), @INCTax as INTEGER 
	SELECT   @TX_COUNT1 = 0   
	SELECT @COL02_1 = @COL02   
	IF @TaxValidation = 'SIRFT'   
	BEGIN   
		SELECT @TX_PCT = TXDTLPCT FROM TX00201 WHERE TAXDTLID IN ( select TAXDTLID from AWLI40102   
		INNER JOIN TLRS10203 ON AWLI40102.IDTAXOP = TLRS10203.IDTAXOP   
		WHERE TLRS10203.RPTID = @IDReporte)   
		  
	END   
	ELSE   
	BEGIN   
		if len(@TaxValidation) > 0  
		BEGIN   
			SELECT   @TX_COUNT1 = count(1)   
			FROM AWLI40102 INNER JOIN TLRS10203 ON AWLI40102.IDTAXOP = TLRS10203.IDTAXOP  
			WHERE TLRS10203.RPTID = @IDReporte AND len(AWLI40102.TAXDTLID) > 0   
	    END   
	END   
   
if @TX_COUNT1 > 0 
	BEGIN 
	if @TX_COUNT2 > 0 
		BEGIN 
		insert into @TempTableTax (Col_2,IncludeCol2) values(@COL02_1,0)  
		END 
	ELSE
	SELECT @INCTax = TL_WITHOUT_TAX FROM AWLI40001 WHERE RPTID = @IDReporte
	IF @INCTax = 1 
		BEGIN 
		insert into @TempTableTax (Col_2,IncludeCol2) values(@COL02_1,0)  
		END 
	END 
ELSE 
	BEGIN 
	insert into @TempTableTax (Col_2,IncludeCol2) values(@COL02_1,1)  
	END 

	return 
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_TaxValidationInfo]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_TaxValidationInfo*/
/*Begin_dbo.TL_RS_EliminateSalesRecs*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_EliminateSalesRecs' and type = 'FN')
DROP FUNCTION TL_RS_EliminateSalesRecs
GO

create function [dbo].[TL_RS_EliminateSalesRecs]
(    
 @IN_DocNumbr char(21),    
 @IN_DocType  int,    
 @IN_CUSTVNDR char(15),    
 @IN_DOCID  char(15),    
 @IN_CurrID  char(15),    
 @DOCDATE  datetime,    
 @Void   tinyint  
)  
returns int    
as    
begin    
 declare @SopType  int,    
   @PRSTADCD  char(15),    
   @COD_COMP  char(3),    
   @Pos_Letra  smallint,    
   @Pos_PDV  smallint,    
   @Pos_NRO  smallint,    
   @Letra   char(1),    
   @val_letra  int,    
   @PDV   char(5),    
   @FROM_NMBR  char(9),    
   @TO_NMBR  char(9),    
   @RM_FIN_CHRG_AS smallint,    
   @RM_SRVC_AS  smallint,    
   @DocType  int,    
   @UNIQ_FORM_FCNCND tinyint,    
   @remove   int ,
   @OP_ORIGIN int   
 
  set @remove=1    
   
 if exists(select OP_ORIGIN from AWLI_RM00101 where CUSTNMBR=@IN_CUSTVNDR)
	begin
		select @OP_ORIGIN =OP_ORIGIN from AWLI_RM00101 where CUSTNMBR=@IN_CUSTVNDR
	    if @OP_ORIGIN=4
			return 0
	end
 else
	return 0
 
 if @IN_DocType=1    
  set @SopType=3    
 else    
  set @SopType=4    
 if @IN_DOCID <> ''    
  begin    
  if exists(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)    
   begin    
   if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)    
    set @remove=0 
   end    
  else    
   if exists(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)    
    begin    
     if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)    
     set @remove=0 
    end    
    else    
     set @remove=0    
  if exists (select COD_COMP from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType)    
   begin    
    select @COD_COMP=isnull(COD_COMP,'') from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType   
    if @COD_COMP=''    
     set @remove=0    
    else    
     select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType    
   end    
   else    
    set @remove=0     
       
      
  end    
      
  else /*DOCID = ''*/    
   select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40300    
  set @Letra = substring(@IN_DocNumbr,@Pos_Letra,1)    
  if @Letra ='A'    
   set @val_letra =1    
  else if @Letra ='B'    
   set @val_letra =2    
  else if @Letra ='C'    
   set @val_letra =3    
  else if @Letra ='E'    
   set @val_letra =4    
  else if @Letra =' '    
   set @val_letra =5    
  else if @Letra ='M'    
   set @val_letra =6    
      
      
  if @IN_DOCID = ''    
   if not exists(select TipoReporte from AWLI40370 where TipoReporte=2 and RMDTYPAL=@IN_DocType and LETRA=@val_letra)    
    set @remove=0    
  if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'') 
   if not exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)    
    set @remove=0    
    
      
  set @PDV = substring(@IN_DocNumbr,@Pos_PDV,4)    
  set @FROM_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)    
  set @TO_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)    
  select @RM_FIN_CHRG_AS =RM_FIN_CHRG_AS,@RM_SRVC_AS=RM_SRVC_AS,@UNIQ_FORM_FCNCND=UNIQ_FORM_FCNCND from AWLI40300    
  set @DocType=@IN_DocType     
  if @IN_DocType =4    
   begin    
   if @RM_FIN_CHRG_AS=1    
    set @DocType=1    
   else    
    set @DocType=3    
   end    
  else if @IN_DocType =5    
   begin    
   if @RM_SRVC_AS=1    
    set @DocType=1    
   else    
    set @DocType=3    
   end    
  else if (@IN_DocType =7) or (@IN_DocType =8)    
   set @DocType=2    
      
  if (@COD_COMP='02') or (@COD_COMP='07') or (@COD_COMP='12') or (@COD_COMP='20') or (@COD_COMP='37')    
   or (@COD_COMP='86')    
   set @DocType=3    
      
  if @UNIQ_FORM_FCNCND=1    
   set @DocType=4    
      
  if not exists (select top 1 COMP_TYPE from AWLI_RM00103 where PDV=@PDV and    
    LETRA=@val_letra and @FROM_NMBR >=FROM_NMBR and @FROM_NMBR<=TO_NMBR and @DOCDATE between FROM_DT and TO_DT and COMP_TYPE = @DocType)    
   set @remove=0    
  
     
  if (@remove=0) and (@Void=0)    
   return 0    
      
  return 1    
end  
  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_EliminateSalesRecs]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_EliminateSalesRecs*/
/*Begin_dbo.TL_RS_TaxNumber*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_TaxNumber' and type = 'FN')
DROP FUNCTION dbo.TL_RS_TaxNumber;
GO

CREATE FUNCTION TL_RS_TaxNumber (@TAXNO CHAR(25))
RETURNS CHAR(25)
AS
BEGIN
	IF (SELECT TAXREGTN FROM DYNAMICS..SY01500 WHERE INTERID = (SELECT DB_NAME())) IS NOT NULL
		RETURN (SELECT SUBSTRING (TAXREGTN, 1, 11) FROM DYNAMICS..SY01500 WHERE INTERID = (SELECT DB_NAME()))

	RETURN (SELECT SUBSTRING (@TAXNO, 1, 11))
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_TaxNumber]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_TaxNumber*/
/*Begin_dbo.TL_RS_GetSalesReqValues*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_GetSalesReqValues' and type = 'TF')
DROP FUNCTION dbo.TL_RS_GetSalesReqValues;
GO

create function [dbo].[TL_RS_GetSalesReqValues]
(    
 @IN_Type	int 
)  
returns @TempTableSalesVals table
(
	Letra char(1),
	Letra_Value	int,
	PDV	char(10),	
	From_No	char(21),
	To_No	char(21),
	COD_COMP	char(3),
	CUST_CODE	char(3),
	DEST_CODE	char(5),
	NRO_DESP	char(7),
	DIGVERIF_NRODESP	char(1),
	CAI	char(31),
	TO_DT	datetime,
	CURR_CODE	char(3),
	T_CAMBIO	numeric(19,7),
	RESP_TYPE	char(3),
	CNTRLLR	tinyint,
	OP_ORIGIN	smallint,
	primkey bigint
	
)  
begin    
 declare @SopType  int,    
   @PRSTADCD  char(15),    
   @COD_COMP  char(3),    
	@Pos_Letra  smallint,    
   @Pos_PDV  smallint,    
   @Pos_NRO  smallint,    
   @Letra   char(1),    
   @val_letra  int,    
   @PDV   char(5),    
   @FROM_NMBR  char(9),    
   @TO_NMBR  char(9),    
   @RM_FIN_CHRG_AS smallint,    
   @RM_SRVC_AS  smallint,    
   @DocType  int,    
   @UNIQ_FORM_FCNCND tinyint,    
   @remove   int ,
   @OP_ORIGIN int ,
   @PrimKey	bigint,
	@TO_DT	datetime,
	@CUST_CODE	char(3),
	@DEST_CODE	char(5),
	@NRO_DESP	char(7),
	@DIGVERIF_NRODESP	char(1),
	@CAI	char(31),
	@ATO_DT	datetime,
	@CURR_CODE	char(3),
	@CURR_CODE_MC	char(3),
	@T_CAMBIO	numeric(19,7),
	@RESP_TYPE	char(3),
	@CNTRLLR	tinyint,
	@XCHGRATE	numeric(19,7),
	@IN_DocNumbr char(21),    
	@IN_DocType  int,    
	@IN_CUSTVNDR char(15),    
	@IN_VCRNMBR char(21),
	@IN_DOCID  char(15),    
	@IN_CurrID  char(15),    
	@DOCDATE  datetime,    
	@Void   tinyint,
	@CAE char(31)

 
 if @IN_Type=1
	 declare TL_Sales_Vals cursor  fast_forward
		for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void,DOCID 
			FROM TL_RS_CitiPurchase_SALES

 else if @IN_Type = 2
	 declare TL_Sales_Vals cursor  fast_forward  
		for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void,DOCID   
			FROM TL_RS_RG1361_SalesView  
 else if @IN_Type = 3
	 declare TL_Sales_Vals cursor  fast_forward  
		for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void,DOCID   
		from TL_RS_Sirft_Rev_Whold_View
else if @IN_Type = 4
	declare TL_Sales_Vals cursor  fast_forward  
		for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void,DOCID   
		from TL_RS_IVA_Sales_View
 else
	return
 
 OPEN TL_Sales_Vals
 FETCH NEXT FROM TL_Sales_Vals INTO @PrimKey,@IN_CurrID,@DOCDATE,@IN_VCRNMBR,@IN_DocType,@IN_CUSTVNDR,
		@IN_DocNumbr,@Void,@IN_DOCID
 WHILE @@fetch_status=0
 begin	
	
	set @Letra=''
	set @val_letra=0
	set @PDV=''
	set @FROM_NMBR=''
	set @TO_NMBR=''
	set	@COD_COMP=''
    set @CUST_CODE=''
    set @DEST_CODE=''
    set @NRO_DESP=''
    set @DIGVERIF_NRODESP=''
    set @CAI=''
    set @ATO_DT=0
	set @CURR_CODE=''
	set	@T_CAMBIO=0
    set @RESP_TYPE=''
    set @CNTRLLR=0
    set @OP_ORIGIN=0
	set @remove=1    
 if exists(select OP_ORIGIN from AWLI_RM00101 where CUSTNMBR=@IN_CUSTVNDR)
	begin
		select @OP_ORIGIN =OP_ORIGIN,@RESP_TYPE=RESP_TYPE from AWLI_RM00101 where CUSTNMBR=@IN_CUSTVNDR
	    if @OP_ORIGIN=4
			begin
			 return 
			end
	end
 else
	return 
 
 if @IN_DocType=1    
  set @SopType=3    
 else    
  set @SopType=4    
 if @IN_DOCID <> ''    
  begin    
  if exists(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)    
   begin    
   if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)    
    set @remove=0 
   end    
  else    
   if exists(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)    
    begin    
     if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)    
		set @remove=0 
	 else
		select @OP_ORIGIN=OP_ORIGIN from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN<>4		
    end    
    else    
     set @remove=0    
  if exists (select TOP 1 COD_COMP from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType ORDER BY SOPTYPE,DOCID,LETRA,COD_COMP)    
   begin    
    select TOP 1 @COD_COMP=isnull(COD_COMP,''),@CNTRLLR=CNTRLLR from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType ORDER BY SOPTYPE,DOCID,LETRA,COD_COMP  
    if @COD_COMP=''    
     set @remove=0
    else
		begin
			select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType    
		end
   end    
   else    
    set @remove=0     
       
      
  end    
      
  else 
   select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40300    
  set @Letra = substring(@IN_DocNumbr,@Pos_Letra,1)    
  if @Letra ='A'    
   set @val_letra =1    
  else if @Letra ='B'    
   set @val_letra =2    
  else if @Letra ='C'    
   set @val_letra =3    
  else if @Letra ='E'    
   set @val_letra =4    
  else if @Letra =' '    
   set @val_letra =5    
  else if @Letra ='M'    
   set @val_letra =6    
      
      
  if @IN_DOCID = ''    
   if not exists(select TipoReporte from AWLI40370 where TipoReporte=2 and RMDTYPAL=@IN_DocType and LETRA=@val_letra)    
    set @remove=0    
  if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'') /*MULTICURRENCY ENABLED*/    
   if not exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)    
    set @remove=0    
    
      
  set @PDV = substring(@IN_DocNumbr,@Pos_PDV,4)    
  set @FROM_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)    
  set @TO_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)    
  select @RM_FIN_CHRG_AS =RM_FIN_CHRG_AS,@RM_SRVC_AS=RM_SRVC_AS,@UNIQ_FORM_FCNCND=UNIQ_FORM_FCNCND from AWLI40300    
  set @DocType=@IN_DocType     
  if @IN_DocType =4    
   begin    
   if @RM_FIN_CHRG_AS=1    
    set @DocType=1    
   else    
    set @DocType=3    
   end    
  else if @IN_DocType =4    
   begin    
   if @RM_SRVC_AS=1    
    set @DocType=1    
   else    
    set @DocType=3    
   end    
  else if (@IN_DocType =7) or (@IN_DocType =8)    
   set @DocType=2    
      
  if (@COD_COMP='02') or (@COD_COMP='07') or (@COD_COMP='12') or (@COD_COMP='20') or (@COD_COMP='37')    
   or (@COD_COMP='86')    
   set @DocType=3    
      
  if @UNIQ_FORM_FCNCND=1    
   set @DocType=4    
      
  if not exists (select top 1 COMP_TYPE from AWLI_RM00103 where PDV=@PDV and LETRA=@val_letra and @FROM_NMBR >=FROM_NMBR and @FROM_NMBR<=TO_NMBR and @DOCDATE between FROM_DT and TO_DT and COMP_TYPE = @DocType and LETRA = @val_letra and PDV = @PDV)    
   set @remove=0    
	else
		begin
		select top 1 @TO_DT=TO_DT,@CAI=CAI from AWLI_RM00103 where PDV=@PDV and LETRA=@val_letra and @FROM_NMBR >=FROM_NMBR and @FROM_NMBR<=TO_NMBR and @DOCDATE between FROM_DT and TO_DT and COMP_TYPE = @DocType and LETRA = @val_letra and PDV = @PDV
		order by CAI desc, PDV desc, LETRA desc, COMP_TYPE desc
		
		end
  
  if @IN_DOCID = '' 
	if exists(select top 1 COD_COMP from AWLI40370  where TipoReporte=2 and  RMDTYPAL=@IN_DocType and LETRA=@val_letra and COD_COMP<>'')
		begin
			select top 1 @COD_COMP=COD_COMP,@CNTRLLR=CNTRLLR from AWLI40370  where TipoReporte=2 and  RMDTYPAL=@IN_DocType and LETRA=@val_letra and COD_COMP<>''
		end
   
	if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'') 
		begin
			if exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)    
			begin
				select @CURR_CODE_MC=CURR_CODE from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID
				set @CURR_CODE=@CURR_CODE_MC
				if @CURR_CODE='PES'
					set @T_CAMBIO=1
				else
				begin
				if exists(select XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR  
					and DOCTYPE=@IN_DocType)
					begin
					select @XCHGRATE=XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR  
					and DOCTYPE=@IN_DocType
					set @T_CAMBIO=@XCHGRATE
					end
				end
			
			end
			
		end
		else
		begin
			
			set @CURR_CODE='PES'
			set @T_CAMBIO=1		  
		end	
		set @ATO_DT=@TO_DT

		if exists (select * from dbo.sysobjects where id = object_id(N'[XDL10114]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) and   
		  exists (SELECT XDLCAEAuthorizationCode From XDL10114 Where XDL_DocNumber = @IN_DocNumbr)  
		   begin  
		   SELECT @CAE  = XDLCAEAuthorizationCode From XDL10114 Where XDL_DocNumber = @IN_DocNumbr  
		   IF @CAE <> ''
			SET @CAI = @CAE
		   end 
		 else 
			if exists (select * from dbo.sysobjects where id = object_id(N'[XDL10115]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) and   
			  exists (SELECT XDLCAEAuthorizationCode From XDL10115 Where XDL_DocNumber = @IN_DocNumbr)  
			   begin  
				SELECT @CAE  = XDLCAEAuthorizationCode From XDL10115 Where XDL_DocNumber = @IN_DocNumbr  
			   IF @CAE <> ''
				SET @CAI = @CAE
			   end  
		 insert into @TempTableSalesVals values(@Letra,@val_letra,@PDV,@FROM_NMBR,@TO_NMBR,
		@COD_COMP,@CUST_CODE,@DEST_CODE,@NRO_DESP,@DIGVERIF_NRODESP,@CAI,@ATO_DT,@CURR_CODE,
		@T_CAMBIO,@RESP_TYPE,@CNTRLLR,@OP_ORIGIN,@PrimKey)
		 FETCH NEXT FROM TL_Sales_Vals INTO @PrimKey,@IN_CurrID,@DOCDATE,@IN_VCRNMBR,@IN_DocType,@IN_CUSTVNDR,
		@IN_DocNumbr,@Void,@IN_DOCID	     
  end  
	close   TL_Sales_Vals
	deallocate TL_Sales_Vals  
  return     
end  
  
  GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_GetSalesReqValues]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_GetSalesReqValues*/
/*Begin_dbo.TL_RS_FormatCuit*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_FormatCuit' and type = 'FN')
DROP FUNCTION dbo.TL_RS_FormatCuit;
GO


CREATE FUNCTION dbo.TL_RS_FormatCuit (@INCuit CHAR(11))
RETURNS CHAR(15)
AS 
BEGIN 
	DECLARE @CuitNew CHAR(14)
	SET @CuitNew = Substring(@INCuit,1,2) + '-' + Substring(@INCuit,3,8) + '-' + Substring(@INCuit,11,1)	
RETURN (@CuitNew)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_FormatCuit]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_FormatCuit*/
/*Begin_dbo.TL_RS_Set_Field_Format*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_Set_Field_Format' and type = 'FN')
DROP FUNCTION dbo.TL_RS_Set_Field_Format;
GO

CREATE FUNCTION dbo.TL_RS_Set_Field_Format 
(@IN_Field VARCHAR(30), @IN_Align VARCHAR(5), @IN_Fill CHAR(1), @IN_Final_Length INT)
RETURNS VARCHAR(30)
AS
BEGIN
	DECLARE @OUT_Field VARCHAR(30), @IN_Length INT

	SET @IN_Field = RTRIM(@IN_Field)
	SET @IN_Field = LTRIM(@IN_Field)
	IF LEN(@IN_Field) >=  @IN_Final_Length
		BEGIN	
			IF LEN(@IN_Field) = @IN_Final_Length
				BEGIN
				SET @OUT_Field = @IN_Field
				GOTO RETURN_END
				END
			IF LEN(@IN_Field) > @IN_Final_Length
				BEGIN
				SET @OUT_Field = LEFT(@IN_Field,@IN_Final_Length)
				GOTO RETURN_END
				END
		END
	ELSE
		BEGIN
			IF @IN_Align = 'LEFT'
				IF ASCII(@IN_Fill) = 32
					BEGIN
					SET @OUT_Field = @IN_Field + SPACE(@IN_Final_Length - LEN(@IN_Field))
					GOTO RETURN_END
					END
				ELSE
					BEGIN
					SET @OUT_Field = @IN_Field + REPLICATE(@IN_Fill, @IN_Final_Length - LEN(@IN_Field))
					GOTO RETURN_END
					END
			IF @IN_Align = 'RIGHT'
				SET @IN_Field = REVERSE(@IN_Field)
				IF ASCII(@IN_Fill) = 32
					BEGIN
					SET @OUT_Field = @IN_Field + SPACE(@IN_Final_Length - LEN(@IN_Field))
					SET @OUT_Field = REVERSE(@OUT_Field)
					GOTO RETURN_END
					END
				ELSE
					BEGIN
					SET @OUT_Field = @IN_Field + REPLICATE(@IN_Fill, @IN_Final_Length - LEN(@IN_Field))
					SET @OUT_Field = REVERSE(@OUT_Field)
					GOTO RETURN_END
					END
		END
		
	RETURN_END:
	RETURN (@OUT_Field)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_Set_Field_Format]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_Set_Field_Format*/
/*Begin_dbo.TL_RS_SICOAR_REPORT*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SICOAR_REPORT' and type = 'TF')
DROP FUNCTION dbo.TL_RS_SICOAR_REPORT;
GO

CREATE FUNCTION TL_RS_SICOAR_REPORT()      
RETURNS @SICOAR TABLE       
(      
RPRTNAME CHAR(31),       
RPTID CHAR(15),       
[Report Type] VARCHAR(20),      
DOCNUMBR CHAR(21),       
SICOAR_CODE CHAR(3),       
DOCDATE DATETIME,       
CUSTVNDR CHAR(15),      
ISIB VARCHAR(10),      
[Taxpayer ID] VARCHAR(15),      
AMOUNT NUMERIC(19, 5),
IDENTIFICATION INT,      
PRIM_KEY INT IDENTITY (1,1)      
)      
AS      
BEGIN
Declare @TII_HGHRISK char(3)
Declare @DOCNUMBR varchar(21)
Declare @SICOAR_CODE char(3)
Declare @DOCDATE as datetime
Declare @CUSTVNDR as varchar(20)
Declare @HR as int 
Declare @nfRET_Retencion char(21)    
 INSERT @SICOAR (RPRTNAME, RPTID, [Report Type], DOCNUMBR, SICOAR_CODE, DOCDATE,       
     CUSTVNDR, ISIB, [Taxpayer ID], AMOUNT, IDENTIFICATION)      
 (SELECT     RPRTNAME, RPTID, [Report Type], DOCNUMBR, SICOAR_CODE, DOCDATE, CUSTVNDR, ISIB, [Taxpayer ID], AMOUNT, IDENTIFICATION  
 FROM         dbo.TL_RS_SICOAR_REPORT_TL_WITH_TAX() AS TL_RS_SICOAR_REPORT_1  
 WHERE     (AMOUNT <> 0)  
 UNION   
 SELECT     RPRTNAME, RPTID, [Report Type], DOCNUMBR, SICOAR_CODE, DOCDATE, CUSTVNDR, ISIB, [Taxpayer ID], AMOUNT , IDENTIFICATION 
 FROM         dbo.TL_RS_SICOAR_REPORT_TL_WITHOUT_TAX() AS TL_RS_SICOAR_REPORT_1)  
 
 /*Change for RF8538*/
	DECLARE HighRisk CURSOR FOR   
    SELECT DOCNUMBR,SICOAR_CODE,DOCDATE,CUSTVNDR from @SICOAR   
    OPEN HighRisk   
    FETCH NEXT FROM HighRisk INTO @DOCNUMBR,@SICOAR_CODE,@DOCDATE,@CUSTVNDR  
    WHILE (@@FETCH_STATUS=0)   
    BEGIN
		set @HR=0
		select @HR=HR from nfRET_PM00201 where VENDORID=@CUSTVNDR and nfRET_Tipo_ID in (
			select nfRET_Tipo_ID from nfRET_GL00030 where nfRET_Retencion_ID in (
			select nfRET_Retencion_ID from nfRET_GL10020 where DOCNUMBR=@DOCNUMBR and VENDORID=@CUSTVNDR and nfRET_Fec_Retencion=@DOCDATE))
		and TII_MCP_From_Date <=@DOCDATE and TII_MCP_TO_DATE>=@DOCDATE
		if @HR=1
		BEGIN
			select @TII_HGHRISK=TII_HGHRISK from TII_SICOAR00100 where ID_Retencion in(select nfRET_Retencion_ID from nfRET_GL10020 where DOCNUMBR=@DOCNUMBR and VENDORID=@CUSTVNDR and nfRET_Fec_Retencion=@DOCDATE  )
			UPDATE @SICOAR set SICOAR_CODE	=@TII_HGHRISK where DOCNUMBR=@DOCNUMBR and CUSTVNDR=@CUSTVNDR and @DOCDATE=@DOCDATE
		END
	FETCH NEXT FROM HighRisk INTO @DOCNUMBR,@SICOAR_CODE,@DOCDATE,@CUSTVNDR 
   END  
   CLOSE HighRisk   
   DEALLOCATE HighRisk  
 /*END*/   	   
RETURN      
END   

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_SICOAR_REPORT]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_SICOAR_REPORT*/
/*Begin_dbo.TLRS_Sirft_WithHoldings*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TLRS_Sirft_WithHoldings' and type = 'TF')
DROP FUNCTION dbo.TLRS_Sirft_WithHoldings;
GO


create function TLRS_Sirft_WithHoldings()
RETURNS  @TEMPTABLE TABLE
	(
  	    TXRGNNUM				char(25),
		nfRET_Fec_Retencion		datetime,
		nfMCP_Printing_Number	char(15),
		nfRET_Importe_Retencion	numeric(19,5),
		VENDORID				char(15),
		DOCTYPE					smallint,
		DSCRIPTN				char(31),
		ID_Retencion			char(21),
		PDV						char(5),
		RPRTNAME				char(31),
		PrimKey int identity(1,1)
	
	)		
begin
	declare	@TXRGNNUM					char(25),
			@nfRET_Fec_Retencion		datetime,
			@nfMCP_Printing_Number		char(15),
			@nfRET_Importe_Retencion	numeric(19,5),
			@VENDORID					char(15),
			@DOCTYPE					smallint,
			@DSCRIPTN					char(31),
			@ID_Retencion				char(21),
			@PDV						char(5),
			@RPRTNAME					char(31),
			@Len						int,
			@Print_Numb					varchar(25),
			@Count						int,
			@Test_Asc					varchar(5)
				
	declare sirft_rwh_cur cursor fast_forward for 
	SELECT     PM00200.TXRGNNUM, nfRET_GL10020.nfRET_Fec_Retencion, nfRET_GL10020.nfMCP_Printing_Number, nfRET_GL10020.nfRET_Importe_Retencion, 
                      PM00200.VENDORID, nfRET_GL10020.DOCTYPE, TLST10201.DSCRIPTN, TLST10201.ID_Retencion, TLST10101.PDV, TLST10201.RPRTNAME
	FROM         TLST10201 INNER JOIN
                      nfRET_GL10020 ON TLST10201.ID_Retencion = nfRET_GL10020.nfRET_Retencion_ID INNER JOIN
                      PM00200 ON nfRET_GL10020.VENDORID = PM00200.VENDORID INNER JOIN
                      TLST10101 ON TLST10201.RPRTNAME = TLST10101.RPRTNAME AND nfRET_GL10020.nfRET_Fec_Retencion >= TLST10101.STRTDATE AND 
                      nfRET_GL10020.nfRET_Fec_Retencion <= TLST10101.ENDDATE and TLST10101.Retenciones<>0
	WHERE     (nfRET_GL10020.nfRET_Importe_Retencion <> 0)
	open sirft_rwh_cur
	
	fetch next from sirft_rwh_cur into @TXRGNNUM,@nfRET_Fec_Retencion,@nfMCP_Printing_Number,
			@nfRET_Importe_Retencion,@VENDORID,@DOCTYPE,@DSCRIPTN,@ID_Retencion,@PDV,@RPRTNAME
	
	WHILE @@FETCH_STATUS=0
		begin
			set @Print_Numb=''
			set @Count=0
			set @Len	=len(@nfMCP_Printing_Number)
			if @Len=0
				begin
				set	@nfMCP_Printing_Number='00000000'
				end
			else
				begin
					set	@nfMCP_Printing_Number= @nfMCP_Printing_Number
					while @Count<@Len
						begin
							set @Test_Asc=substring(@nfMCP_Printing_Number,@Count+1,1)
							if (ascii(@Test_Asc)>=48) and (ascii(@Test_Asc)<=57)
								set @Print_Numb = @Print_Numb  + '' + @Test_Asc
							set @Count = @Count+1
						end
					set @Print_Numb = '00000000' + @Print_Numb
					set @nfMCP_Printing_Number=substring(@Print_Numb,len(@Print_Numb)-8+1,len(@Print_Numb))
				end
			set @TXRGNNUM = @TXRGNNUM + '00000000000'
			set @TXRGNNUM = substring(@TXRGNNUM,1, 2) + '-' + substring(@TXRGNNUM, 3, 8) + '-' + substring(@TXRGNNUM, 11, 1)
			insert into @TEMPTABLE values(@TXRGNNUM,@nfRET_Fec_Retencion,@nfMCP_Printing_Number,@nfRET_Importe_Retencion,@VENDORID,@DOCTYPE,@DSCRIPTN,@ID_Retencion,@PDV,@RPRTNAME)
			fetch next from sirft_rwh_cur into @TXRGNNUM,@nfRET_Fec_Retencion,@nfMCP_Printing_Number,@nfRET_Importe_Retencion,@VENDORID,@DOCTYPE,@DSCRIPTN,@ID_Retencion,@PDV,@RPRTNAME
		end
		close sirft_rwh_cur
		deallocate sirft_rwh_cur        
	return


end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TLRS_Sirft_WithHoldings]  TO [DYNGRP]
GO
/*End_dbo.TLRS_Sirft_WithHoldings*/
/*Begin_dbo.TL_RS_PurchaseEliminateRecs*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_PurchaseEliminateRecs' and type = 'FN')
DROP FUNCTION dbo.TL_RS_PurchaseEliminateRecs;
GO

create function [dbo].[TL_RS_PurchaseEliminateRecs](  
@IN_CurrID  char(15),
@IN_DOCDATE	datetime,  
@IN_VCRNMBR char(21),
@IN_DOCTYPE	smallint,
@IN_VENDORID char(15),
@IN_DocNumber	char(21) ,
@IN_Void	int 
)  
returns int  
begin      
 declare @remove int,    
   @Exists int,    
   @AWLI_DocNumber char(21),    
   @Letra char(1),    
   @val_letra int,    
   @CHECK_CAI tinyint,    
   @FROM_NMBR char(9),    
   @TO_NMBR char(9),    
   @FROM_DT datetime,    
   @TO_DT  datetime    
 set @remove=1      
    
if len(@IN_DocNumber) <> 17     
 and (substring(@IN_DocNumber, 3,1) <> ' ' or substring(@IN_DocNumber, 3,1) = '')    
 and (substring(@IN_DocNumber, 9,1) <> '-' or substring(@IN_DocNumber, 9,1) = '')     
  set @remove=0  
else  
 begin  
  if exists(select top 1 DOCTYPE from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and     
   DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4)  
  begin  
   select top 1 @AWLI_DocNumber=AWLI_DocNumber from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and     
   DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4    
  
   set @Letra = substring(@AWLI_DocNumber,4,1)        
   if @Letra ='A'        
    set @val_letra =1        
   else if @Letra ='B'        
    set @val_letra =2        
   else if @Letra ='C'        
    set @val_letra =3        
   else if @Letra ='E'        
    set @val_letra =4        
   else if @Letra =' '        
    set @val_letra =5        
   else if @Letra ='M'        
    set @val_letra =6      
  
   if exists(SELECT  top 1 AWLI_PM00400.DOCTYPE     
   FROM         AWLI_PM00201   
   INNER JOIN AWLI_PM00400 ON AWLI_PM00201.VENDORID = AWLI_PM00400.VENDORID AND   
      AWLI_PM00201.COMP_TYPE = AWLI_PM00400.DOCTYPE    
   where AWLI_PM00400.DOCTYPE=@IN_DOCTYPE and   
     AWLI_PM00400.VENDORID=@IN_VENDORID and   
     AWLI_PM00400.VCHRNMBR=@IN_VCRNMBR and  
     AWLI_PM00400.OP_ORIGIN<>4 and   
     AWLI_PM00201.PDV=substring(AWLI_PM00400.AWLI_DocNumber,5,4) and  
     substring(AWLI_PM00400.AWLI_DocNumber,10,8)>=AWLI_PM00201.FROM_NMBR and  
     substring(AWLI_PM00400.AWLI_DocNumber,10,8)<=AWLI_PM00201.TO_NMBR and   
     @IN_DOCDATE between AWLI_PM00201.FROM_DT and AWLI_PM00201.TO_DT and    
     AWLI_PM00201.LETRA=@val_letra   
   ORDER BY AWLI_PM00400.VENDORID ASC, AWLI_PM00400.VCHRNMBR ASC, AWLI_PM00400.DOCTYPE ASC,    
   AWLI_PM00201.PDV ASC ,AWLI_PM00201.COMP_TYPE ASC)  
  
   begin    
    if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'')     
     if not exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)        
      set @remove=0      
   end  
  end  
 end  
  
 if @IN_Void=1    
  set @remove=0     
 return @remove      
        
end    

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_PurchaseEliminateRecs]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_PurchaseEliminateRecs*/
/*Begin_dbo.TL_RS_PurchaseReqValues*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_PurchaseReqValues' and type = 'TF')
DROP FUNCTION dbo.TL_RS_PurchaseReqValues;
GO

create function [dbo].[TL_RS_PurchaseReqValues](  
@IN_Type	int 
)  
returns @TempTablePVals table
(
	Letra char(1),
	Letra_Value	int,
	PDV	char(10),	
	From_No	char(21),
	To_No	char(21),
	COD_COMP	char(3),
	CUST_CODE	char(3),
	DEST_CODE	char(5),
	NRO_DESP	char(7),
	DIGVERIF_NRODESP	char(1),
	CAI	char(31),
	TO_DT	datetime,
	CURR_CODE	char(3),
	T_CAMBIO	numeric(19,7),
	RESP_TYPE	char(3),
	CNTRLLR	tinyint,
	OP_ORIGIN	smallint,
	primkey bigint
	
) 
begin   
 declare @remove int,  
   @Exists int,  
   @AWLI_DocNumber char(21),  
   @Letra char(1),  
   @val_letra int,  
   @CHECK_CAI tinyint,  
   @FROM_NMBR char(9),  
   @TO_NMBR char(9),  
   @FROM_DT datetime,  
   @TO_DT  datetime,  
  @IN_CurrID  char(15),  
  @IN_DOCDATE datetime,    
  @IN_VCRNMBR char(21),  
  @IN_DOCTYPE smallint,  
  @IN_VENDORID char(15),  
  @IN_DocNumber char(21) ,  
  @IN_Void int,  
  @PrimKey bigint,  
  @PDV char(10),  
  @FORMAT_DOC int ,  
  @COD_COMP char(3),  
  @CUST_CODE char(3),  
  @DEST_CODE char(5),  
  @NRO_DESP char(7),  
  @DIGVERIF_NRODESP char(1),  
  @CAI char(31),  
  @ATO_DT datetime,  
  @CURR_CODE char(3),  
  @CURR_CODE_MC char(3),  
  @T_CAMBIO numeric(19,7),  
  @RESP_TYPE char(3),  
  @CNTRLLR tinyint,  
  @OP_ORIGIN smallint,  
  @XCHGRATE numeric(19,7),  
        @Save int,  
  @T_FROM_NMBR char(9),    
  @T_TO_NMBR char(9),    
  @T_FROM_DT datetime,    
  @T_TO_DT  datetime    
   
 set @remove=1    
   
if @IN_Type=1  
  declare TL_Purch_Vals cursor  fast_forward  
  for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void   
  FROM TL_RS_RG1361_PurchaseView  
else if @IN_Type=2    
  declare TL_Purch_Vals cursor  fast_forward    
  for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void     
  FROM TL_RS_PurchaseView   
else if @IN_Type=3      
  declare TL_Purch_Vals cursor  fast_forward        
  for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void         
  FROM TL_RS_SIFEREPerceptionsView 
else  
 return  
 OPEN TL_Purch_Vals  
 FETCH NEXT FROM TL_Purch_Vals INTO @PrimKey,@IN_CurrID,@IN_DOCDATE,@IN_VCRNMBR,@IN_DOCTYPE,@IN_VENDORID,  
  @IN_DocNumber,@IN_Void  
 WHILE @@fetch_status=0  
 begin
 set @PDV =''  
 set @FORMAT_DOC=0  
 set @COD_COMP =''  
 set @CUST_CODE =''  
 set @DEST_CODE =''  
 set @NRO_DESP =''  
 set @DIGVERIF_NRODESP=''  
 set @CAI=''  
 set @ATO_DT =0  
 set @CURR_CODE=''  
 set @T_CAMBIO=0  
 set @RESP_TYPE=''  
 set @CNTRLLR=0  
 set @OP_ORIGIN=0  
 set @Letra=''  
 set @val_letra=0  
 set @FROM_NMBR=''  
 set @TO_NMBR=''  
 set @Save=0  
 set @T_FROM_NMBR =''    
 set @T_TO_NMBR=''    
 set @T_FROM_DT=0    
 set @T_TO_DT=0   
 set @remove=1 
	if len(@IN_DocNumber) <> 17   
	and (substring(@IN_DocNumber, 3,1) <> ' ' or substring(@IN_DocNumber, 3,1) = '')  
	and (substring(@IN_DocNumber, 9,1) <> '-' or substring(@IN_DocNumber, 9,1) = '')  
		set @remove=0   
	else
	begin 
		if exists(select top 1 DOCTYPE from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and   
		DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4)  
		begin  
			select top 1 @AWLI_DocNumber=AWLI_DocNumber from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and   
			DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4  
			set @Letra = substring(@AWLI_DocNumber,4,1)  
	    
			if @Letra ='A'      
			set @val_letra =1      
			else if @Letra ='B'      
			set @val_letra =2      
			else if @Letra ='C'      
			set @val_letra =3      
			else if @Letra ='E'      
			set @val_letra =4      
			else if @Letra =' '      
			set @val_letra =5      
			else if @Letra ='M'      
			set @val_letra =6

			if exists
			(SELECT  top 1 AWLI_PM00400.DOCTYPE   
			FROM AWLI_PM00201 INNER JOIN  
			AWLI_PM00400 ON AWLI_PM00201.VENDORID = AWLI_PM00400.VENDORID AND 
							AWLI_PM00201.COMP_TYPE = AWLI_PM00400.DOCTYPE  
			where AWLI_PM00400.DOCTYPE=@IN_DOCTYPE and 
			AWLI_PM00400.VENDORID=@IN_VENDORID and 
			AWLI_PM00400.VCHRNMBR=@IN_VCRNMBR and 
			AWLI_PM00400.OP_ORIGIN<>4 and 
			AWLI_PM00201.PDV=substring(AWLI_PM00400.AWLI_DocNumber,5,4) and 
			substring(AWLI_PM00400.AWLI_DocNumber,10,8)>=AWLI_PM00201.FROM_NMBR and
			substring(AWLI_PM00400.AWLI_DocNumber,10,8)<=AWLI_PM00201.TO_NMBR and
			@IN_DOCDATE between AWLI_PM00201.FROM_DT and AWLI_PM00201.TO_DT and  
			AWLI_PM00201.LETRA=@val_letra 
			ORDER BY AWLI_PM00400.VENDORID ASC, AWLI_PM00400.VCHRNMBR ASC, AWLI_PM00400.DOCTYPE ASC,  
			AWLI_PM00201.PDV ASC ,AWLI_PM00201.COMP_TYPE ASC)  
			begin  
				SELECT  top 1 @FROM_NMBR=AWLI_PM00201.FROM_NMBR,@TO_NMBR=AWLI_PM00201.TO_NMBR,  
				@FROM_DT=AWLI_PM00201.FROM_DT,@TO_DT=AWLI_PM00201.TO_DT,@FORMAT_DOC=AWLI_PM00400.FORMAT_DOC   
				FROM AWLI_PM00201 INNER JOIN  
				AWLI_PM00400 ON AWLI_PM00201.VENDORID = AWLI_PM00400.VENDORID AND 
								AWLI_PM00201.COMP_TYPE = AWLI_PM00400.DOCTYPE  
				where AWLI_PM00400.DOCTYPE=@IN_DOCTYPE and 
				AWLI_PM00400.VENDORID=@IN_VENDORID and 
				AWLI_PM00400.VCHRNMBR=@IN_VCRNMBR and 
				AWLI_PM00400.OP_ORIGIN<>4 and 
				AWLI_PM00201.PDV=substring(AWLI_PM00400.AWLI_DocNumber,5,4) and 
				substring(AWLI_PM00400.AWLI_DocNumber,10,8)>=AWLI_PM00201.FROM_NMBR and
				substring(AWLI_PM00400.AWLI_DocNumber,10,8)<=AWLI_PM00201.TO_NMBR and
				@IN_DOCDATE between AWLI_PM00201.FROM_DT and AWLI_PM00201.TO_DT and  
				AWLI_PM00201.LETRA=@val_letra 
				ORDER BY AWLI_PM00400.VENDORID ASC, AWLI_PM00400.VCHRNMBR ASC, AWLI_PM00400.DOCTYPE ASC,  
				AWLI_PM00201.PDV ASC ,AWLI_PM00201.COMP_TYPE ASC

				if @FORMAT_DOC=1  
				begin  
					set @PDV=substring(@AWLI_DocNumber,5,4)  
					set @FROM_NMBR=substring(@AWLI_DocNumber,10,8)  
					set @TO_NMBR=substring(@AWLI_DocNumber,10,8)  
				end  
				else  
				begin
					set @PDV='0000'  
					set @FROM_NMBR =dbo.[TLRS_GetDocNumber_Purchase](@AWLI_DocNumber,0)  
					set @TO_NMBR=@FROM_NMBR  
				end

				if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'')   
				begin  
					if exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)      
					begin  
						select @CURR_CODE_MC=CURR_CODE from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID  
						set @CURR_CODE=@CURR_CODE_MC
						if @CURR_CODE='PES'
							set @T_CAMBIO=1
						else
						begin
							if exists(select XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR    
							 and DOCTYPE=@IN_DOCTYPE)
							begin
							 select @XCHGRATE=XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR
							 and DOCTYPE=@IN_DOCTYPE
							 set @T_CAMBIO=@XCHGRATE
							end
						end
					end
					else
						set @remove=0
				end  
				else  
				begin  
					set @CURR_CODE='PES'
					set @T_CAMBIO=1   
				end
			end
		end
	end

	if @PDV='' 
		begin
		set @PDV=substring(@IN_DocNumber,5,4)  
		set @FROM_NMBR=substring(@IN_DocNumber,10,8)  
		set @TO_NMBR=substring(@IN_DocNumber,10,8)
		end

	select	@COD_COMP=COD_COMP, 
			@CUST_CODE=CUST_CODE, 
			@DEST_CODE=DEST_CODE,  
			@NRO_DESP=NRO_DESP,
			@DIGVERIF_NRODESP=DIGVERIF_NRODESP,
			@CAI=CAI,  
			@ATO_DT=TO_DT,
			@CURR_CODE=CURR_CODE,
			@T_CAMBIO=T_CAMBIO,
			@RESP_TYPE=RESP_TYPE,  
			@CNTRLLR=CNTRLLR,
			@OP_ORIGIN=OP_ORIGIN  
	from AWLI_PM00400 
	where VENDORID=@IN_VENDORID and 
	VCHRNMBR=@IN_VCRNMBR and 
	DOCTYPE=@IN_DOCTYPE
  if @remove=1
	begin 
	insert into @TempTablePVals values(@Letra,@val_letra,@PDV,@FROM_NMBR,@TO_NMBR,  
	@COD_COMP,@CUST_CODE,@DEST_CODE,@NRO_DESP,@DIGVERIF_NRODESP,@CAI,@ATO_DT,@CURR_CODE,  
	@T_CAMBIO,@RESP_TYPE,@CNTRLLR,@OP_ORIGIN,@PrimKey)  
   end
  FETCH NEXT FROM TL_Purch_Vals INTO @PrimKey,@IN_CurrID,@IN_DOCDATE,@IN_VCRNMBR,@IN_DOCTYPE,@IN_VENDORID,  
  @IN_DocNumber,@IN_Void  
   
 end  
 close TL_Purch_Vals  
 deallocate TL_Purch_Vals  
 return    
      
end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_PurchaseReqValues]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_PurchaseReqValues*/
/*Begin_dbo.TL_RS_ReporteImpuestos*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_ReporteImpuestos' and type = 'TF')
DROP FUNCTION dbo.TL_RS_ReporteImpuestos;
GO

create function [dbo].[TL_RS_ReporteImpuestos]   
(  
@Report_Type int,
@USERID AS CHAR(15),  
@TaxValidation AS VARCHAR(15) = NULL   
)
returns @TempTable	table
(
PrimKey				bigint identity(1,1),
RPTNAME				char(30),
RPTID				char(15),
TipoReporte			smallint,
NumeroDeOrden		smallint,
IDGRIMP				char(15),
DSCRIPTN			char(31),
AWLI_DOCUMENT_STATE	char(5),
DOCTYPE				smallint,
DOCNUMBR			char(21),
VCHRNMBR			char(21),
DOCDATE				datetime,
GLPOSTDT			datetime,
CUSTVNDR			char(15),
CUSTNAME			char(65),
TXRGNNUM			char(25),
SLSAMNT				numeric(19,5),
TRDISAMT			numeric(19,5),
FRTAMNT				numeric(19,5),
MISCAMNT			numeric(19,5),
TAXAMNT				numeric(19,5),
DOCAMNT				numeric(19,5),
Void				tinyint,
DOCID				char(15),
AWLI_DOCTYPEDESC	char(7),
VOIDDATE			datetime,
CURNCYID			char(15),
OPERATION			smallint,
COL01				NUMERIC(19,5),   
COL02				NUMERIC(19,5),   
COL03				NUMERIC(19,5),    
COL04  NUMERIC(19,5),    
COL05  NUMERIC(19,5),    
COL06  NUMERIC(19,5),    
COL07  NUMERIC(19,5),   
COL08  NUMERIC(19,5),   
COL09  NUMERIC(19,5),   
COL10  NUMERIC(19,5),   
COL11  NUMERIC(19,5),   
COL12  NUMERIC(19,5),   
COL13  NUMERIC(19,5),   
COL14  NUMERIC(19,5),   
COL15  NUMERIC(19,5),   
COL16  NUMERIC(19,5),   
COL17  NUMERIC(19,5),   
COL18  NUMERIC(19,5),   
COL19  NUMERIC(19,5),   
COL20  NUMERIC(19,5)
)
begin  
     
 
DECLARE @TipoReporte as SMALLINT, @HISTORY as TINYINT, @UNPSTTRX as TINYINT, @OPENTRX as TINYINT, @SORTBY1 as SMALLINT  
DECLARE @AWFiltraXDocumentDate as TINYINT, @STTDOCDT as DATETIME, @ENDDOCDT as DATETIME, @AWFiltraXPostDate as TINYINT  
DECLARE @STTPSTDT as DATETIME, @ENDPSTDT as DATETIME, @TipoCorteControl as smallint  
DECLARE @RM_SALESINV as tinyint, @RM_DEBITMEM as tinyint, @RM_FINCHRGS as tinyint, @RM_SERVNREP as tinyint, @RM_WARRANTY as tinyint  
DECLARE @RM_CREDMEMO as tinyint, @RM_RETURNS as tinyint, @PM_INVOICE as tinyint, @PM_FINCHR as tinyint, @PM_MISCHARG AS tinyint, @PM_RETURN as tinyint  
DECLARE @PM_CRDMEM as tinyint, @FiltraSOPDOC as tinyint 
declare @ReportName char(30),@IDReporte char(15) 
  
  
  
DECLARE @D_TYPE AS INT, @D_STATE AS VARCHAR(4), @D_DOCTYPE AS INT, @D_DOCNUMBR AS CHAR(21), @D_VCHRNMBR AS CHAR(21), @D_DOCDATE AS DATETIME  
DECLARE @D_GLPOSTDT AS DATETIME, @D_CUSTVENDID AS CHAR(15), @D_CUSTVENDNAME AS CHAR(65), @D_TXRGNNUM AS CHAR(25)  
DECLARE @D_SALESPURCHAMNT AS NUMERIC(19,5), @D_TRDISAMT AS NUMERIC(19,5), @D_FRTAMNT AS NUMERIC(19,5), @D_MISCAMNT AS NUMERIC(19,5)  
DECLARE @D_TAXAMNT AS NUMERIC(19,5), @D_DOCAMNT AS NUMERIC(19,5), @D_VOIDED AS INT, @D_DOCID AS CHAR(15), @D_DOCTYPEDESC AS VARCHAR(7), @D_VOIDDATE AS DATETIME, @D_CURNCYID AS CHAR(15)  
  
DECLARE @T_TYPE AS INT, @T_DOCTYPE AS INT, @T_VCHRNMBR AS CHAR(21), @T_TAXDTLID AS CHAR(15), @T_TAXAMNT AS NUMERIC(19,5)  
DECLARE @T_TAXDTAMT AS NUMERIC(19,5), @T_TDTTXAMT AS NUMERIC(19,5)  
DECLARE @NumeroDeOrden as SMALLINT, @IDGRUPOIMP as CHAR(15), @DESCGRUPOIMP AS CHAR(31)  
  
DECLARE @COL01 AS NUMERIC(19,5), @COL02 AS NUMERIC(19,5), @COL03 AS NUMERIC(19,5), @COL04 AS NUMERIC(19,5), @COL05 AS NUMERIC(19,5)  
DECLARE @COL06 AS NUMERIC(19,5), @COL07 AS NUMERIC(19,5), @COL08 AS NUMERIC(19,5), @COL09 AS NUMERIC(19,5), @COL10 AS NUMERIC(19,5)  
DECLARE @COL11 AS NUMERIC(19,5), @COL12 AS NUMERIC(19,5), @COL13 AS NUMERIC(19,5), @COL14 AS NUMERIC(19,5), @COL15 AS NUMERIC(19,5)  
DECLARE @COL16 AS NUMERIC(19,5), @COL17 AS NUMERIC(19,5), @COL18 AS NUMERIC(19,5), @COL19 AS NUMERIC(19,5), @COL20 AS NUMERIC(19,5)  
DECLARE @MONTO AS NUMERIC(19,5), @OPERACION AS INTEGER  
DECLARE @T_COL01 AS NUMERIC(19,5), @T_COL02 AS NUMERIC(19,5), @T_COL03 AS NUMERIC(19,5), @T_COL04 AS NUMERIC(19,5), @T_COL05 AS NUMERIC(19,5)  
DECLARE @T_COL06 AS NUMERIC(19,5), @T_COL07 AS NUMERIC(19,5), @T_COL08 AS NUMERIC(19,5), @T_COL09 AS NUMERIC(19,5), @T_COL10 AS NUMERIC(19,5)  
DECLARE @T_COL11 AS NUMERIC(19,5), @T_COL12 AS NUMERIC(19,5), @T_COL13 AS NUMERIC(19,5), @T_COL14 AS NUMERIC(19,5), @T_COL15 AS NUMERIC(19,5)  
DECLARE @T_COL16 AS NUMERIC(19,5), @T_COL17 AS NUMERIC(19,5), @T_COL18 AS NUMERIC(19,5), @T_COL19 AS NUMERIC(19,5), @T_COL20 AS NUMERIC(19,5)  
DECLARE @NROGRUPO AS SMALLINT, @IDGRUPO as CHAR(15), @DESCGRUPO AS CHAR(31)  
  
DECLARE @COL_NROORDCOL AS INTEGER, @COL_TIPOIMP AS INTEGER, @COL_OPVTAX AS INTEGER, @COL_TAXDTLID AS CHAR(15)  

if @Report_Type=4 
	declare TLRS_Setup cursor fast_forward for select '' as RPRTNAME, TLRG10101.RPTID FROM         TLRG10101 INNER JOIN
					  TLRS10101 ON TLRG10101.RPTID = TLRS10101.RPTID and TLRS10101.TipoReporte=2 and TLRG10101.TLRG1361=0
else if @Report_Type=5 
	declare TLRS_Setup cursor fast_forward for select '' as RPRTNAME, TLRG10101.RPTID FROM         TLRG10101 INNER JOIN
					  TLRS10101 ON TLRG10101.RPTID = TLRS10101.RPTID and TLRS10101.TipoReporte=1 and TLRG10101.TLRG1361=0
else
	return
open TLRS_Setup
fetch next from TLRS_Setup into @ReportName,@IDReporte
while @@fetch_status=0
begin
SELECT @TipoReporte=TipoReporte, @HISTORY=HISTORY, @UNPSTTRX=UNPSTTRX, @OPENTRX=OpenTRX, @SORTBY1=SORTBY1,   
 @AWFiltraXDocumentDate=AWFiltraXDocumentDate, @STTDOCDT=STTDOCDT, @ENDDOCDT=ENDDOCDT,  @AWFiltraXPostDate=AWFiltraXPostDate,   
 @STTPSTDT=STTPSTDT, @ENDPSTDT=ENDPSTDT, @TipoCorteControl=TipoCorteControl,  
 @RM_SALESINV=SALESINV, @RM_DEBITMEM=DEBITMEM, @RM_FINCHRGS=FINCHRGS, @RM_SERVNREP=SERVNREP, @RM_WARRANTY=WARRANTY,  
 @RM_CREDMEMO=CREDMEMO, @RM_RETURNS=RETURNS, @PM_INVOICE=PMINVOIC, @PM_FINCHR=PMFINCHR, @PM_MISCHARG=MISCHARG,  
 @PM_RETURN=PMRETURN, @PM_CRDMEM=PMCRDMEM, @FiltraSOPDOC=AWLI_Filtra_SOP_Doc  
FROM TLRS10101 WHERE @IDReporte=RPTID

 If @TipoReporte=1 AND @SORTBY1=1   
  DECLARE DOCUMENTOS CURSOR FOR SELECT * FROM AWLI_DOCUMENTOS  
  WHERE  TYPE=1 AND  ((DOCTYPE=1 AND @PM_INVOICE=1) OR  (DOCTYPE=2 AND @PM_FINCHR=1) OR  (DOCTYPE=3 AND @PM_MISCHARG=1) OR   
	  (DOCTYPE=4 AND @PM_RETURN=1) OR (DOCTYPE=5 AND @PM_CRDMEM=1))  AND ((STATE='WORK' AND @UNPSTTRX=1) OR   
	  (STATE='OPEN' AND @OPENTRX=1) OR (STATE='HIST' AND @HISTORY=1)) AND (NOT @AWFiltraXDocumentDate=1 OR   
	 (DOCDATE >=@STTDOCDT AND DOCDATE<=@ENDDOCDT)) AND (NOT @AWFiltraXPostDate=1 OR (GLPOSTDT >=@STTPSTDT AND   
	 GLPOSTDT<=@ENDPSTDT))  
  ORDER BY DOCDATE,DOCNUMBR   
 else If @TipoReporte=1 AND @SORTBY1=2    
  DECLARE DOCUMENTOS CURSOR FOR SELECT * FROM AWLI_DOCUMENTOS   
  WHERE TYPE=1 AND ((DOCTYPE=1 AND @PM_INVOICE=1) OR (DOCTYPE=2 AND @PM_FINCHR=1) OR (DOCTYPE=3 AND @PM_MISCHARG=1) OR   
	 (DOCTYPE=4 AND @PM_RETURN=1) OR (DOCTYPE=5 AND @PM_CRDMEM=1)) AND ((STATE='WORK' AND @UNPSTTRX=1) OR   
	  (STATE='OPEN' AND @OPENTRX=1) OR (STATE='HIST' AND @HISTORY=1)) AND (NOT @AWFiltraXDocumentDate=1 OR   
	 (DOCDATE >=@STTDOCDT AND DOCDATE<=@ENDDOCDT)) AND (NOT @AWFiltraXPostDate=1 OR (GLPOSTDT >=@STTPSTDT AND   
	 GLPOSTDT<=@ENDPSTDT))   
  ORDER BY DOCDATE,CUSTVENDID, DOCNUMBR   
 else if @TipoReporte=2 AND @SORTBY1=1     
  DECLARE DOCUMENTOS CURSOR FOR SELECT * FROM AWLI_DOCUMENTOS  
  WHERE TYPE=2 AND ((DOCTYPE=1 AND @RM_SALESINV=1) OR (DOCTYPE=3 AND @RM_DEBITMEM=1) OR (DOCTYPE=4 AND @RM_FINCHRGS=1) OR   
	 (DOCTYPE=5 AND @RM_SERVNREP=1) OR (DOCTYPE=6 AND @RM_WARRANTY=1) OR  (DOCTYPE=7 AND @RM_CREDMEMO=1) OR   
	  (DOCTYPE=8 AND @RM_RETURNS=1) ) AND ((STATE='WORK' AND @UNPSTTRX=1) OR (STATE='OPEN' AND @OPENTRX=1) OR   
	  (STATE='HIST' AND @HISTORY=1)) AND (NOT @AWFiltraXDocumentDate=1 OR (DOCDATE >=@STTDOCDT AND DOCDATE<=@ENDDOCDT)) AND   
	 (NOT @AWFiltraXPostDate=1 OR (GLPOSTDT >=@STTPSTDT AND GLPOSTDT<=@ENDPSTDT)) AND ((DOCID = '') OR   
	  NOT EXISTS  (SELECT  *  FROM TLRS10202  WHERE  AWLI_DOCUMENTOS.DOCID = TLRS10202.DOCID AND RPTID = @IDReporte) OR   
	 NOT (@FiltraSOPDOC = 1))   
  ORDER BY DOCDATE,DOCNUMBR   
 else if @TipoReporte=2 AND @SORTBY1=2     
  DECLARE DOCUMENTOS CURSOR FOR SELECT * FROM AWLI_DOCUMENTOS  
  WHERE TYPE=2 AND ((DOCTYPE=1 AND @RM_SALESINV=1) OR (DOCTYPE=3 AND @RM_DEBITMEM=1) OR (DOCTYPE=4 AND @RM_FINCHRGS=1) OR   
	  (DOCTYPE=5 AND @RM_SERVNREP=1) OR (DOCTYPE=6 AND @RM_WARRANTY=1) OR (DOCTYPE=7 AND @RM_CREDMEMO=1) OR   
	  (DOCTYPE=8 AND @RM_RETURNS=1) ) AND ((STATE='WORK' AND @UNPSTTRX=1) OR (STATE='OPEN' AND @OPENTRX=1) OR   
	  (STATE='HIST' AND @HISTORY=1)) AND (NOT @AWFiltraXDocumentDate=1 OR (DOCDATE >=@STTDOCDT AND DOCDATE<=@ENDDOCDT)) AND   
	 (NOT @AWFiltraXPostDate=1 OR (GLPOSTDT >=@STTPSTDT AND GLPOSTDT<=@ENDPSTDT)) AND ((DOCID = '') OR   
	 NOT EXISTS  (SELECT  *  FROM TLRS10202  WHERE  AWLI_DOCUMENTOS.DOCID = TLRS10202.DOCID AND RPTID = @IDReporte) OR   
	 NOT (@FiltraSOPDOC = 1))   
  ORDER BY DOCDATE,CUSTVENDID, DOCNUMBR   
 else return   
   
  
 OPEN  DOCUMENTOS  
 FETCH NEXT FROM DOCUMENTOS INTO @D_TYPE, @D_STATE, @D_DOCTYPE, @D_DOCNUMBR, @D_VCHRNMBR, @D_DOCDATE,@D_GLPOSTDT, @D_CUSTVENDID,  
	   @D_CUSTVENDNAME,  @D_TXRGNNUM, @D_SALESPURCHAMNT, @D_TRDISAMT, @D_FRTAMNT, @D_MISCAMNT, @D_TAXAMNT,  
	  @D_DOCAMNT, @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID  
  
  
 WHILE (@@FETCH_STATUS=0)      
	  BEGIN   
    
   SELECT @COL01=0, @COL02=0, @COL03=0, @COL04=0, @COL05=0, @COL06=0, @COL07=0, @COL08=0, @COL09=0, @COL10=0, @COL11=0, @COL12=0, @COL13=0, @COL14=0, @COL15=0, @COL16=0, @COL17=0, @COL18=0, @COL19=0, @COL20=0  
    
	select @COL01=COL01,@COL02=COL02,@COL03=COL03,@COL04=COL04,@COL05=COL05,@COL06=COL06,
		   @COL07=COL07,@COL08=COL08,@COL09=COL09,@COL10=COL10,@COL11=COL11,@COL12=COL12,
		   @COL13=COL13,@COL14=COL14,@COL15=COL15,@COL16=COL16,@COL17=COL17,@COL18=COL18,
		   @COL19=COL19,@COL20=COL20  
	from TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaTotales(@IDReporte,@USERID,@D_SALESPURCHAMNT,@D_TRDISAMT,@D_FRTAMNT,@D_MISCAMNT,@D_TAXAMNT,@D_DOCAMNT,  
		  @COL01,@COL02,@COL03,@COL04,@COL05,@COL06,@COL07,@COL08,@COL09,@COL10,@COL11,@COL12,@COL13,@COL14,@COL15,@COL16,@COL17,@COL18,@COL19,@COL20)

	DECLARE DOC_IMPUESTOS CURSOR FOR   
	SELECT    AWLI_IMPUESTOS.*, ISNULL(GRUPOIMP.NumeroDeOrden, 0) AS NumeroDeOrden, ISNULL(GRUPOIMP.IDGRIMP, '')  AS IDGRUPOIMP, ISNULL(GRUPOIMP.DSCRIPTN, '') AS DSCRIPTN   
	FROM        AWLI_IMPUESTOS LEFT OUTER JOIN   
							  (SELECT     AWLI40202.TAXDTLID, TLRS10201.RPTID, TLRS10201.NumeroDeOrden, AWLI40202.IDGRIMP, TLRS10201.DSCRIPTN   
								FROM          TLRS10201 INNER JOIN   
													   AWLI40202 ON TLRS10201.IDGRIMP = AWLI40202.IDGRIMP   
								WHERE      (TLRS10201.RPTID = @IDReporte)) GRUPOIMP ON GRUPOIMP.TAXDTLID = dbo.AWLI_IMPUESTOS.TAXDTLID   
	WHERE     (TYPE=@D_TYPE AND DOCTYPE=@D_DOCTYPE AND VCHRNMBR=@D_VCHRNMBR) AND   
         
	  (  NOT EXISTS  (SELECT     TipoCorteControl FROM TLRS10101 WHERE      TLRS10101.RPTID = @IDReporte AND TipoCorteControl = 2) OR   
	 NOT  (GRUPOIMP.NumeroDeOrden IS NULL)  )   
	ORDER BY GRUPOIMP.NumeroDeOrden, dbo.AWLI_IMPUESTOS.TAXDTLID   
	OPEN DOC_IMPUESTOS  
     
	FETCH NEXT FROM DOC_IMPUESTOS INTO @T_TYPE, @T_DOCTYPE, @T_VCHRNMBR, @T_TAXDTLID, @T_TAXAMNT, @T_TAXDTAMT,  
		  @T_TDTTXAMT, @NumeroDeOrden, @IDGRUPOIMP,@DESCGRUPOIMP   
     
	IF @TipoCorteControl=1  
		 BEGIN select @NumeroDeOrden=0, @IDGRUPOIMP='', @DESCGRUPOIMP='' END  
     
	IF (@@FETCH_STATUS=0)       
		 BEGIN   
       
	  SELECT @NROGRUPO=@NumeroDeOrden, @IDGRUPO= @IDGRUPOIMP, @DESCGRUPO=@DESCGRUPOIMP  
	  SELECT @T_COL01=@COL01, @T_COL02=@COL02, @T_COL03=@COL03, @T_COL04=@COL04, @T_COL05=@COL05, @T_COL06=@COL06, @T_COL07=@COL07, @T_COL08=@COL08,  
		@T_COL09=@COL09, @T_COL10=@COL10, @T_COL11=@COL11, @T_COL12=@COL12, @T_COL13=@COL13, @T_COL14=@COL14, @T_COL15=@COL15,   
		@T_COL16=@COL16, @T_COL17=@COL17, @T_COL18=@COL18, @T_COL19=@COL19, @T_COL20=@COL20   
       
	  WHILE (@@FETCH_STATUS=0)  
		   BEGIN    
		 select @T_COL01=COL01,@T_COL02=COL02,@T_COL03=COL03,@T_COL04=COL04,@T_COL05=COL05,@T_COL06=COL06,
		   @T_COL07=COL07,@T_COL08=COL08,@T_COL09=COL09,@T_COL10=COL10,@T_COL11=COL11,@T_COL12=COL12,
		   @T_COL13=COL13,@T_COL14=COL14,@T_COL15=COL15,@T_COL16=COL16,@T_COL17=COL17,@T_COL18=COL18,
		   @T_COL19=COL19,@T_COL20=COL20 
			from TL_RS_AWLI_ReporteImpuestos_AcumuloColumnaImpuestos(@IDReporte, @USERID, @T_TAXDTLID, @T_TAXAMNT,@T_TAXDTAMT,@T_TDTTXAMT, @T_COL01,@T_COL02,@T_COL03,@T_COL04,@T_COL05,@T_COL06,@T_COL07,  
			   @T_COL08,@T_COL09,@T_COL10,@T_COL11,@T_COL12,@T_COL13,@T_COL14,@T_COL15,@T_COL16,@T_COL17,@T_COL18,@T_COL19,@T_COL20)
        
		FETCH NEXT FROM DOC_IMPUESTOS INTO @T_TYPE, @T_DOCTYPE, @T_VCHRNMBR, @T_TAXDTLID, @T_TAXAMNT, @T_TAXDTAMT, @T_TDTTXAMT, @NumeroDeOrden, @IDGRUPOIMP,@DESCGRUPOIMP  
         
		IF @TipoCorteControl=1   
			 BEGIN    
		 select @NumeroDeOrden=0, @IDGRUPOIMP='', @DESCGRUPOIMP=''   
			 END   
         
		IF (@@FETCH_STATUS=0)  
			 BEGIN   
		 IF @NROGRUPO<>@NumeroDeOrden    
			  BEGIN   
		  IF (@D_TYPE=1 AND (@D_DOCTYPE=4 OR @D_DOCTYPE=5)) OR (@D_TYPE=2 AND (@D_DOCTYPE=7 OR @D_DOCTYPE=8))   
			   BEGIN
				set @OPERACION=-1
				if exists(select Col_2 from dbo.TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))
					begin
					INSERT INTO @TempTable      
						(RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,     
						DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,            
						SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,
						COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,
						COL15,COL16,COL17,COL18,COL19,COL20)   
					VALUES   
					  (@ReportName, @IDReporte, @D_TYPE,   @NROGRUPO, @IDGRUPO, @DESCGRUPO, @D_STATE,   
					   @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,    
					   @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,   
					   @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,
						@T_COL01*@OPERACION,@T_COL02*@OPERACION,@T_COL03*@OPERACION,@T_COL04*@OPERACION,
						@T_COL05*@OPERACION,@T_COL06*@OPERACION,@T_COL07*@OPERACION,@T_COL08*@OPERACION,
						@T_COL09*@OPERACION,@T_COL10*@OPERACION,@T_COL11*@OPERACION,@T_COL12*@OPERACION,
						@T_COL13*@OPERACION,@T_COL14*@OPERACION,@T_COL15*@OPERACION,@T_COL16*@OPERACION,
						@T_COL17*@OPERACION,@T_COL18*@OPERACION,@T_COL19*@OPERACION,@T_COL20*@OPERACION)
					end
				END  
		  ELSE   
				BEGIN  
				set @OPERACION=1
				if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))
				begin
				INSERT INTO @TempTable      
					(RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,     
					DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,            
					SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,
					COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,
					COL15,COL16,COL17,COL18,COL19,COL20)   
				VALUES   
				  (@ReportName, @IDReporte, @D_TYPE,   @NROGRUPO, @IDGRUPO, @DESCGRUPO, @D_STATE,   
				   @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,    
				   @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,   
				   @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,
					@T_COL01,@T_COL02,@T_COL03,@T_COL04,@T_COL05,@T_COL06,@T_COL07,@T_COL08, @T_COL09,@T_COL10,@T_COL11,@T_COL12,@T_COL13,@T_COL14,@T_COL15,@T_COL16,@T_COL17,@T_COL18,@T_COL19,@T_COL20)
				end
				 END   
            
		  SELECT @NROGRUPO=@NumeroDeOrden, @IDGRUPO= @IDGRUPOIMP, @DESCGRUPO=@DESCGRUPOIMP   
		  SELECT @T_COL01=@COL01, @T_COL02=@COL02, @T_COL03=@COL03, @T_COL04=@COL04, @T_COL05=@COL05, @T_COL06=@COL06, @T_COL07=@COL07, @T_COL08=@COL08,   
			@T_COL09=@COL09, @T_COL10=@COL10, @T_COL11=@COL11, @T_COL12=@COL12, @T_COL13=@COL13, @T_COL14=@COL14, @T_COL15=@COL15, @T_COL16=@COL16, @T_COL17=@COL17, @T_COL18=@COL18, @T_COL19=@COL19, @T_COL20=@COL20   
			  END   
			 END    
		ELSE     
			 BEGIN   
		 IF (@D_TYPE=1 AND (@D_DOCTYPE=4 OR @D_DOCTYPE=5)) OR (@D_TYPE=2 AND (@D_DOCTYPE=7 OR @D_DOCTYPE=8))   
			  BEGIN 
			   set @OPERACION=-1
				if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))
				begin
				INSERT INTO @TempTable      
					(RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,     
					DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,            
					SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,
					COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,
					COL15,COL16,COL17,COL18,COL19,COL20)   
				VALUES   
				  (@ReportName, @IDReporte, @D_TYPE,   @NROGRUPO, @IDGRUPO, @DESCGRUPO, @D_STATE,   
				   @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,    
				   @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,   
				   @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,
				   @T_COL01*@OPERACION,@T_COL02*@OPERACION,@T_COL03*@OPERACION,@T_COL04*@OPERACION,
					@T_COL05*@OPERACION,@T_COL06*@OPERACION,@T_COL07*@OPERACION,@T_COL08*@OPERACION,
					@T_COL09*@OPERACION,@T_COL10*@OPERACION,@T_COL11*@OPERACION,@T_COL12*@OPERACION,
					@T_COL13*@OPERACION,@T_COL14*@OPERACION,@T_COL15*@OPERACION,@T_COL16*@OPERACION,
					@T_COL17*@OPERACION,@T_COL18*@OPERACION,@T_COL19*@OPERACION,@T_COL20*@OPERACION)
				end
			 END   
		 ELSE   
			  BEGIN 
				set @OPERACION=1
				if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))
				begin
				INSERT INTO @TempTable      
					(RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,     
					DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,            
					SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,
					COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,
					COL15,COL16,COL17,COL18,COL19,COL20)   
				VALUES   
				  (@ReportName, @IDReporte, @D_TYPE,   @NROGRUPO, @IDGRUPO, @DESCGRUPO, @D_STATE,   
				   @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,    
				   @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,   
				   @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,
					@T_COL01,@T_COL02,@T_COL03,@T_COL04,@T_COL05,@T_COL06,@T_COL07,@T_COL08, @T_COL09,@T_COL10,@T_COL11,@T_COL12,@T_COL13,@T_COL14,@T_COL15,@T_COL16,@T_COL17,@T_COL18,@T_COL19,@T_COL20)
				end
			 END   
			 END   
		   END       
		 END   
	ELSE           
		 BEGIN   
	 IF @TipoCorteControl=1     
		  BEGIN   
	  IF (@D_TYPE=1 AND (@D_DOCTYPE=4 OR @D_DOCTYPE=5)) OR (@D_TYPE=2 AND (@D_DOCTYPE=7 OR @D_DOCTYPE=8))   
		   BEGIN 
			set @OPERACION=-1
				if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))
				begin
				INSERT INTO @TempTable      
					(RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,     
					DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,            
					SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,
					COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,
					COL15,COL16,COL17,COL18,COL19,COL20)   
				VALUES   
				  (@ReportName, @IDReporte, @D_TYPE,   0, '', '', @D_STATE,   
				   @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,    
				   @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,   
				   @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,
					@COL01*@OPERACION,@COL02*@OPERACION,@COL03*@OPERACION,@COL04*@OPERACION,
					@COL05*@OPERACION,@COL06*@OPERACION,@COL07*@OPERACION,@COL08*@OPERACION,
					@COL09*@OPERACION,@COL10*@OPERACION,@COL11*@OPERACION,@COL12*@OPERACION,
					@COL13*@OPERACION,@COL14*@OPERACION,@COL15*@OPERACION,@COL16*@OPERACION,
					@COL17*@OPERACION,@COL18*@OPERACION,@COL19*@OPERACION,@COL20*@OPERACION)
				end
			 END   
	  ELSE   
		   BEGIN 
			set @OPERACION=1
				if exists(select Col_2 from TL_RS_TaxValidationInfo(@IDReporte,@D_VCHRNMBR,@D_TAXAMNT,@TaxValidation,@T_COL02))
				begin
				INSERT INTO @TempTable      
					(RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,     
					DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,            
					SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,
					COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,
					COL15,COL16,COL17,COL18,COL19,COL20)   
				VALUES   
				  (@ReportName, @IDReporte, @D_TYPE,   0, '', '', @D_STATE,   
				   @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,    
				   @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,   
				   @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,
					@COL01,@COL02,@COL03,@COL04,@COL05,@COL06,@COL07,@COL08, @COL09,@COL10,@COL11,@COL12,@COL13,@COL14,@COL15,@COL16,@COL17,@COL18,@COL19,@COL20)
				end
		  END   
		  END   
	 ELSE IF @TipoCorteControl=2     
		  BEGIN   
	  DECLARE CORTE_CONTROL CURSOR FOR   
	  SELECT NumeroDeOrden, IDGRIMP,DSCRIPTN FROM TLRS10201    
	  WHERE RPTID=@IDReporte AND INCZERO=1   
	  ORDER BY NumeroDeOrden, IDGRIMP   
	  OPEN CORTE_CONTROL   
	  FETCH NEXT FROM CORTE_CONTROL INTO @NumeroDeOrden, @IDGRUPOIMP,@DESCGRUPO   
	  IF (@@FETCH_STATUS<>0)   
		   BEGIN SELECT @NumeroDeOrden=0, @IDGRUPO= '', @DESCGRUPO='' END   
	  CLOSE CORTE_CONTROL   
	  DEALLOCATE CORTE_CONTROL   
	  IF (@D_TYPE=1 AND (@D_DOCTYPE=4 OR @D_DOCTYPE=5)) OR (@D_TYPE=2 AND (@D_DOCTYPE=7 OR @D_DOCTYPE=8))   
		   BEGIN set @OPERACION=-1
				
				INSERT INTO @TempTable      
					(RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,     
					DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,            
					SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,
					COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,
					COL15,COL16,COL17,COL18,COL19,COL20)   
				VALUES   
				  (@ReportName, @IDReporte, @D_TYPE,   0, '', '', @D_STATE,   
				   @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,    
				   @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,   
				   @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,
					@COL01*@OPERACION,@COL02*@OPERACION,@COL03*@OPERACION,@COL04*@OPERACION,
					@COL05*@OPERACION,@COL06*@OPERACION,@COL07*@OPERACION,@COL08*@OPERACION,
					@COL09*@OPERACION,@COL10*@OPERACION,@COL11*@OPERACION,@COL12*@OPERACION,
					@COL13*@OPERACION,@COL14*@OPERACION,@COL15*@OPERACION,@COL16*@OPERACION,
					@COL17*@OPERACION,@COL18*@OPERACION,@COL19*@OPERACION,@COL20*@OPERACION)
				
			 END   
	  ELSE   
		   BEGIN set @OPERACION=1
				
				INSERT INTO @TempTable      
					(RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE,     
					DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, GLPOSTDT,  CUSTVNDR, CUSTNAME, TXRGNNUM,            
					SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID,OPERATION,
					COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,COL12,COL13,COL14,
					COL15,COL16,COL17,COL18,COL19,COL20)   
				VALUES   
				  (@ReportName, @IDReporte, @D_TYPE,   0, '', '', @D_STATE,   
				   @D_DOCTYPE, @D_DOCNUMBR,  @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT, @D_CUSTVENDID, @D_CUSTVENDNAME,  @D_TXRGNNUM,    
				   @D_SALESPURCHAMNT*@OPERACION, @D_TRDISAMT*@OPERACION, @D_FRTAMNT*@OPERACION, @D_MISCAMNT*@OPERACION, @D_TAXAMNT*@OPERACION, @D_DOCAMNT*@OPERACION,   
				   @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE, @D_CURNCYID,@OPERACION,
					@COL01,@COL02,@COL03,@COL04,@COL05,@COL06,@COL07,@COL08, @COL09,@COL10,@COL11,@COL12,@COL13,@COL14,@COL15,@COL16,@COL17,@COL18,@COL19,@COL20)
				
			  END   
		  END   
		 END   
      
	CLOSE  DOC_IMPUESTOS   
	DEALLOCATE DOC_IMPUESTOS   
      
   FETCH NEXT FROM DOCUMENTOS INTO @D_TYPE, @D_STATE, @D_DOCTYPE, @D_DOCNUMBR, @D_VCHRNMBR, @D_DOCDATE, @D_GLPOSTDT,@D_CUSTVENDID, @D_CUSTVENDNAME,     
		   @D_TXRGNNUM, @D_SALESPURCHAMNT, @D_TRDISAMT, @D_FRTAMNT, @D_MISCAMNT, @D_TAXAMNT, @D_DOCAMNT, @D_VOIDED, @D_DOCID, @D_DOCTYPEDESC, @D_VOIDDATE,@D_CURNCYID   
	  END      
    
   
 CLOSE DOCUMENTOS   
 DEALLOCATE DOCUMENTOS
	fetch next from TLRS_Setup into @ReportName,@IDReporte	
end   
 CLOSE TLRS_Setup   
 DEALLOCATE TLRS_Setup	
return
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_ReporteImpuestos]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_ReporteImpuestos*/
/*Begin_dbo.TL_RS_PurchaseRGUnMarkReqValues*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_PurchaseRGUnMarkReqValues' and type = 'TF')
DROP FUNCTION dbo.TL_RS_PurchaseRGUnMarkReqValues;
GO

create function [dbo].[TL_RS_PurchaseRGUnMarkReqValues](  
@IN_Type	int 
)  
returns @TempTablePVals table
(
	Letra char(1),
	Letra_Value	int,
	PDV	char(10),	
	From_No	char(21),
	To_No	char(21),
	COD_COMP	char(3),
	CUST_CODE	char(3),
	DEST_CODE	char(5),
	NRO_DESP	char(7),
	DIGVERIF_NRODESP	char(1),
	CAI	char(31),
	TO_DT	datetime,
	CURR_CODE	char(3),
	T_CAMBIO	numeric(19,7),
	RESP_TYPE	char(3),
	CNTRLLR	tinyint,
	OP_ORIGIN	smallint,
	primkey bigint
	
) 
begin  
 declare @remove int,
		 @Exists int,
		 @AWLI_DocNumber	char(21),
		 @Letra	char(1),
		 @val_letra	int,
		 @CHECK_CAI tinyint,
		 @FROM_NMBR	char(9),
		 @TO_NMBR	char(9),
		 @FROM_DT	datetime,
		 @TO_DT		datetime,
		@IN_CurrID  char(15),
		@IN_DOCDATE	datetime,  
		@IN_VCRNMBR char(21),
		@IN_DOCTYPE	smallint,
		@IN_VENDORID char(15),
		@IN_DocNumber	char(21) ,
		@IN_Void	int,
		@PrimKey	bigint,
		@PDV	char(10),
		@FORMAT_DOC int	,
		@COD_COMP	char(3),
		@CUST_CODE	char(3),
		@DEST_CODE	char(5),
		@NRO_DESP	char(7),
		@DIGVERIF_NRODESP	char(1),
		@CAI	char(31),
		@ATO_DT	datetime,
		@CURR_CODE	char(3),
		@CURR_CODE_MC	char(3),
		@T_CAMBIO	numeric(19,7),
		@RESP_TYPE	char(3),
		@CNTRLLR	tinyint,
		@OP_ORIGIN	smallint,
		@XCHGRATE	numeric(19,7),
        @Save	int
	
 set @remove=1  
 
if @IN_Type=1
	 declare TL_Purch_Vals cursor  fast_forward
		for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void 
		FROM TL_RS_RG1361_PurchaseUnmarkView

else
	return
 OPEN TL_Purch_Vals
 FETCH NEXT FROM TL_Purch_Vals INTO @PrimKey,@IN_CurrID,@IN_DOCDATE,@IN_VCRNMBR,@IN_DOCTYPE,@IN_VENDORID,
		@IN_DocNumber,@IN_Void
 WHILE @@fetch_status=0
 begin	
	set @PDV	=''
	set	@FORMAT_DOC=0
	set	@COD_COMP	=''
	set	@CUST_CODE	=''
	set	@DEST_CODE	=''
	set	@NRO_DESP	=''
	set	@DIGVERIF_NRODESP=''
	set	@CAI=''
	set	@ATO_DT	=0
	set	@CURR_CODE=''
	set	@T_CAMBIO=0
	set	@RESP_TYPE=''
	set	@CNTRLLR=0
	set	@OP_ORIGIN=0
	set @Letra=''
	set @val_letra=0
	set @FROM_NMBR=''
	set @TO_NMBR=''
	set @Save=0
 if exists(select top 1 DOCTYPE from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and 
	DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4)
	begin
		select top 1 @AWLI_DocNumber=AWLI_DocNumber from AWLI_PM00400 where VCHRNMBR= @IN_VCRNMBR and 
		DOCTYPE=@IN_DOCTYPE and VENDORID=@IN_VENDORID and OP_ORIGIN<>4
		 set @Letra = substring(@AWLI_DocNumber,4,1)    
	 
		if exists(SELECT  top 1 AWLI_PM00400.DOCTYPE 
			FROM         AWLI_PM00201 INNER JOIN
			AWLI_PM00400 ON AWLI_PM00201.VENDORID = AWLI_PM00400.VENDORID 
			AND AWLI_PM00201.COMP_TYPE = AWLI_PM00400.DOCTYPE
			where AWLI_PM00400.DOCTYPE=@IN_DOCTYPE and AWLI_PM00400.VENDORID=@IN_VENDORID and AWLI_PM00400.VCHRNMBR=@IN_VCRNMBR
			and AWLI_PM00400.OP_ORIGIN<>4 and AWLI_PM00201.PDV=substring(AWLI_PM00400.AWLI_DocNumber,5,4)
			and @IN_DOCDATE >= AWLI_PM00201.FROM_DT and @IN_DOCDATE<=AWLI_PM00201.TO_DT
			ORDER BY AWLI_PM00400.VENDORID ASC, AWLI_PM00400.VCHRNMBR ASC, AWLI_PM00400.DOCTYPE ASC,
			AWLI_PM00201.VENDORID ASC,AWLI_PM00201.PDV ASC ,AWLI_PM00201.COMP_TYPE ASC)
			begin
				SELECT  top 1 @FROM_NMBR=AWLI_PM00201.FROM_NMBR,@TO_NMBR=AWLI_PM00201.TO_NMBR,
						@FROM_DT=AWLI_PM00201.FROM_DT,@TO_DT=AWLI_PM00201.TO_DT,@FORMAT_DOC=AWLI_PM00400.FORMAT_DOC 
				FROM         AWLI_PM00201 INNER JOIN
				AWLI_PM00400 ON AWLI_PM00201.VENDORID = AWLI_PM00400.VENDORID 
				AND AWLI_PM00201.COMP_TYPE = AWLI_PM00400.DOCTYPE
				where AWLI_PM00400.DOCTYPE=@IN_DOCTYPE and AWLI_PM00400.VENDORID=@IN_VENDORID and AWLI_PM00400.VCHRNMBR=@IN_VCRNMBR
				and AWLI_PM00400.OP_ORIGIN<>4 and AWLI_PM00201.PDV=substring(AWLI_PM00400.AWLI_DocNumber,5,4)
				and @IN_DOCDATE >= AWLI_PM00201.FROM_DT and @IN_DOCDATE<=AWLI_PM00201.TO_DT
				ORDER BY AWLI_PM00400.VENDORID ASC, AWLI_PM00400.VCHRNMBR ASC, AWLI_PM00400.DOCTYPE ASC,
				AWLI_PM00201.VENDORID ASC,AWLI_PM00201.PDV ASC ,AWLI_PM00201.COMP_TYPE ASC
				if substring(@IN_DocNumber,10,8)>=@FROM_NMBR and substring(@IN_DocNumber,10,8)<=@TO_NMBR
							and @IN_DOCDATE>=@FROM_DT and @IN_DOCDATE<=@TO_DT
				begin
					if @FORMAT_DOC=1
						begin
							set @PDV=substring(@AWLI_DocNumber,5,4)
							set @FROM_NMBR=substring(@AWLI_DocNumber,10,8)
							set @TO_NMBR=substring(@AWLI_DocNumber,10,8)
						end
						else
						begin
							
							set @PDV='0000'
							set @FROM_NMBR =dbo.[TLRS_GetDocNumber_Purchase](@AWLI_DocNumber,0)
							set @TO_NMBR=@FROM_NMBR
						end
						
					select @COD_COMP=COD_COMP,	@CUST_CODE=CUST_CODE,	@DEST_CODE=DEST_CODE,
					@NRO_DESP=NRO_DESP,@DIGVERIF_NRODESP=DIGVERIF_NRODESP,@CAI=CAI,
					@ATO_DT=TO_DT,@CURR_CODE=CURR_CODE,@T_CAMBIO=T_CAMBIO,@RESP_TYPE=RESP_TYPE,
					@CNTRLLR=CNTRLLR,@OP_ORIGIN=OP_ORIGIN
					from AWLI_PM00400 where VENDORID=@IN_VENDORID and VCHRNMBR=@IN_VCRNMBR  
					and DOCTYPE=@IN_DOCTYPE
				
				if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'') 
				begin
					if exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)    
					 begin
						select @CURR_CODE_MC=CURR_CODE from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID
							set @CURR_CODE=@CURR_CODE_MC
						if @CURR_CODE='PES'
							set @T_CAMBIO=1
						else
							begin
							if exists(select XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR  
									and DOCTYPE=@IN_DOCTYPE)
								begin
									select @XCHGRATE=XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR  
									and DOCTYPE=@IN_DOCTYPE
									set @T_CAMBIO=@XCHGRATE
								end
							end
						set @Save=1
					 end
					 else
					  set @remove=0
				end
				else
					begin
					set @CURR_CODE='PES'
					set @T_CAMBIO=1	
					set @Save=1	  
					end
				end
			end
			else
			begin
				select @COD_COMP=COD_COMP,@RESP_TYPE=RESP_TYPE,
					@CURR_CODE=CURR_CODE
					from AWLI_PM00400 where VENDORID=@IN_VENDORID and VCHRNMBR=@IN_VCRNMBR  
					and DOCTYPE=@IN_DOCTYPE	
			end
		end
		
 if @IN_Void=1
	 set @remove=0 
		if @Save=0
		begin
			set @PDV	=''
			set	@FORMAT_DOC=0
			set	@COD_COMP	=''
			set	@CUST_CODE	=''
			set	@DEST_CODE	=''
			set	@NRO_DESP	=''
			set	@DIGVERIF_NRODESP=''
			set	@CAI=''
			set	@ATO_DT	=0
			set	@CURR_CODE=''
			set	@T_CAMBIO=0
			set	@RESP_TYPE=''
			set	@CNTRLLR=0
			set	@OP_ORIGIN=0
			set @Letra=''
			set @val_letra=0
			set @FROM_NMBR=''
			set @TO_NMBR=''
			set @Save=0
		end	
		insert into @TempTablePVals values(@Letra,@val_letra,@PDV,@FROM_NMBR,@TO_NMBR,
		@COD_COMP,@CUST_CODE,@DEST_CODE,@NRO_DESP,@DIGVERIF_NRODESP,@CAI,@ATO_DT,@CURR_CODE,
		@T_CAMBIO,@RESP_TYPE,@CNTRLLR,@OP_ORIGIN,@PrimKey)
		
		FETCH NEXT FROM TL_Purch_Vals INTO @PrimKey,@IN_CurrID,@IN_DOCDATE,@IN_VCRNMBR,@IN_DOCTYPE,@IN_VENDORID,
		@IN_DocNumber,@IN_Void
	
 end
	close TL_Purch_Vals
	deallocate TL_Purch_Vals
 return  
    
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_PurchaseRGUnMarkReqValues]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_PurchaseRGUnMarkReqValues*/
/*Begin_dbo.TL_RS_GetSalesRGUnMarkReqValues*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_GetSalesRGUnMarkReqValues' and type = 'TF')
DROP FUNCTION dbo.TL_RS_GetSalesRGUnMarkReqValues;
GO

create function [dbo].[TL_RS_GetSalesRGUnMarkReqValues]
(    
 @IN_Type	int 
)  
returns @TempTableSalesVals table
(
	Letra char(1),
	Letra_Value	int,
	PDV	char(10),	
	From_No	char(21),
	To_No	char(21),
	COD_COMP	char(3),
	CUST_CODE	char(3),
	DEST_CODE	char(5),
	NRO_DESP	char(7),
	DIGVERIF_NRODESP	char(1),
	CAI	char(31),
	TO_DT	datetime,
	CURR_CODE	char(3),
	T_CAMBIO	numeric(19,7),
	RESP_TYPE	char(3),
	CNTRLLR	tinyint,
	OP_ORIGIN	smallint,
	primkey bigint
	
)  
begin      
 declare @SopType  int,      
   @PRSTADCD  char(15),      
   @COD_COMP  char(3),      
 @Pos_Letra  smallint,      
   @Pos_PDV  smallint,      
   @Pos_NRO  smallint,      
   @Letra   char(1),      
   @val_letra  int,      
   @PDV   char(5),      
   @FROM_NMBR  char(9),      
   @TO_NMBR  char(9),      
   @RM_FIN_CHRG_AS smallint,      
   @RM_SRVC_AS  smallint,      
   @DocType  int,      
   @UNIQ_FORM_FCNCND tinyint,      
   @remove   int ,  
   @OP_ORIGIN int ,  
   @PrimKey bigint,  
 @TO_DT datetime,  
 @CUST_CODE char(3),  
 @DEST_CODE char(5),  
 @NRO_DESP char(7),  
 @DIGVERIF_NRODESP char(1),  
 @CAI char(31),  
 @ATO_DT datetime,  
 @CURR_CODE char(3),  
 @CURR_CODE_MC char(3),  
 @T_CAMBIO numeric(19,7),  
 @RESP_TYPE char(3),  
 @CNTRLLR tinyint,  
 @XCHGRATE numeric(19,7),  
 @IN_DocNumbr char(21),      
 @IN_DocType  int,      
 @IN_CUSTVNDR char(15),      
 @IN_VCRNMBR char(21),  
 @IN_DOCID  char(15),      
 @IN_CurrID  char(15),      
 @DOCDATE  datetime,      
 @Void   tinyint,
 @CAE char(31)
  
 if @IN_Type=1  
  declare TL_Sales_Vals cursor  fast_forward  
  for select PrimKey,CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void,DOCID   
  FROM TL_RS_RG1361_SalesUnmarkView 


 else  
 return  
 OPEN TL_Sales_Vals  
 FETCH NEXT FROM TL_Sales_Vals INTO @PrimKey,@IN_CurrID,@DOCDATE,@IN_VCRNMBR,@IN_DocType,@IN_CUSTVNDR,  
  @IN_DocNumbr,@Void,@IN_DOCID  
 WHILE @@fetch_status=0  
 begin   
 set @Letra=''  
 set @val_letra=0  
 set @PDV=''  
 set @FROM_NMBR=''  
 set @TO_NMBR=''  
 set @COD_COMP=''  
 set @CUST_CODE=''  
 set @DEST_CODE=''  
 set @NRO_DESP=''  
 set @DIGVERIF_NRODESP=''  
 set @CAI=''  
 set @ATO_DT=0  
 set @CURR_CODE=''  
 set @T_CAMBIO=0  
 set @RESP_TYPE=''  
 set @CNTRLLR=0  
 set @OP_ORIGIN=0  
 set @remove=1

 if exists(select OP_ORIGIN from AWLI_RM00101 where CUSTNMBR=@IN_CUSTVNDR)  
 begin  
  select @OP_ORIGIN =OP_ORIGIN,@RESP_TYPE=RESP_TYPE from AWLI_RM00101 where CUSTNMBR=@IN_CUSTVNDR  
     if @OP_ORIGIN=4  
   begin  
    set @remove=0   
   end  
 end  
 else  
 set @remove=0   
   
 if @IN_DocType=1      
  set @SopType=3      
 else      
  set @SopType=4      
 
if @IN_DOCID <> ''      
  begin      
  if exists(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)      
	   begin      
	   if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)      
		set @remove=0   
	   end      
  else      
   if exists(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)      
		begin      
			if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)      
				set @remove=0   
			else  
				select @OP_ORIGIN=OP_ORIGIN from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN<>4    
		end 
    else      
     set @remove=0      

	if exists (select TOP 1 COD_COMP from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType ORDER BY SOPTYPE,DOCID,LETRA,COD_COMP)
		begin      
		select TOP 1 @COD_COMP=isnull(COD_COMP,''),@CNTRLLR=CNTRLLR from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType ORDER BY SOPTYPE,DOCID,LETRA,COD_COMP
		if @COD_COMP=''      
		 set @remove=0      
		else  
			begin  
			select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType      
			end  
		end      
	else      
		set @remove=0       
	end      
    
  else   
   select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40300      
  

 set @Letra = substring(@IN_DocNumbr,@Pos_Letra,1)      
  if @Letra ='A'      
   set @val_letra =1      
  else if @Letra ='B'      
   set @val_letra =2      
  else if @Letra ='C'      
   set @val_letra =3      
  else if @Letra ='E'      
   set @val_letra =4      
  else if @Letra =' '      
   set @val_letra =5      
  else if @Letra ='M'      
   set @val_letra =6      
        
        
  if @IN_DOCID = ''      
   if not exists(select TipoReporte from AWLI40370 where TipoReporte=2 and RMDTYPAL=@IN_DocType and LETRA=@val_letra)      
    set @remove=0      
  if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'')   
   if not exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)      
    set @remove=0      
      
        
  set @PDV = substring(@IN_DocNumbr,@Pos_PDV,4)      
  set @FROM_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)      
  set @TO_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)      
  select @RM_FIN_CHRG_AS =RM_FIN_CHRG_AS,@RM_SRVC_AS=RM_SRVC_AS,@UNIQ_FORM_FCNCND=UNIQ_FORM_FCNCND from AWLI40300      
  set @DocType=@IN_DocType       
  if @IN_DocType =4      
   begin      
   if @RM_FIN_CHRG_AS=1      
    set @DocType=1      
   else      
    set @DocType=3      
   end      
  else if @IN_DocType =4      
   begin      
   if @RM_SRVC_AS=1      
    set @DocType=1      
   else      
    set @DocType=3      
   end      
  else if (@IN_DocType =7) or (@IN_DocType =8)      
   set @DocType=2      
        
  if (@COD_COMP='02') or (@COD_COMP='07') or (@COD_COMP='12') or (@COD_COMP='20') or (@COD_COMP='37')      
   or (@COD_COMP='86')      
   set @DocType=3      
        
  if @UNIQ_FORM_FCNCND=1      
   set @DocType=4      
        
  if not exists (select top 1 COMP_TYPE from AWLI_RM00103 where @FROM_NMBR >=FROM_NMBR and @FROM_NMBR<=TO_NMBR and @DOCDATE between FROM_DT and TO_DT and COMP_TYPE = @DocType and LETRA = @val_letra and PDV = @PDV)
   set @remove=0      
 else  
  begin  
  select top 1 @TO_DT=TO_DT,@CAI=CAI from AWLI_RM00103 where @FROM_NMBR >=FROM_NMBR and @FROM_NMBR<=TO_NMBR and @DOCDATE between FROM_DT and TO_DT and COMP_TYPE = @DocType  and LETRA = @val_letra and PDV = @PDV
  order by CAI desc, PDV desc, LETRA desc, COMP_TYPE desc  
    
  end  
    
    
 if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'')   
  begin  
   if exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)      
   begin  
    select @CURR_CODE_MC=CURR_CODE from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID  
    set @CURR_CODE=@CURR_CODE_MC  
    if @CURR_CODE='PES'  
     set @T_CAMBIO=1  
    else  
    begin  
    if exists(select XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR    
     and DOCTYPE=@IN_DocType)  
     begin  
     select @XCHGRATE=XCHGRATE from MC020103 where VCHRNMBR=@IN_VCRNMBR    
     and DOCTYPE=@IN_DocType  
     set @T_CAMBIO=@XCHGRATE  
     end  
    end  
     
   end  
     
  end  
  else  
  begin  
     
   set @CURR_CODE='PES'  
   set @T_CAMBIO=1      
  end   
  set @ATO_DT=@TO_DT  
  
  if exists (select * from dbo.sysobjects where id = object_id(N'[XDL10114]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) and   
  exists (SELECT XDLCAEAuthorizationCode From XDL10114 Where XDL_DocNumber = @IN_DocNumbr)  
   begin  
   SELECT @CAE  = XDLCAEAuthorizationCode From XDL10114 Where XDL_DocNumber = @IN_DocNumbr  
   IF @CAE <> ''
	SET @CAI = @CAE
   end  
   else
		if exists (select * from dbo.sysobjects where id = object_id(N'[XDL10115]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) and   
		  exists (SELECT XDLCAEAuthorizationCode From XDL10115 Where XDL_DocNumber = @IN_DocNumbr)  
		   begin  
		   SELECT @CAE  = XDLCAEAuthorizationCode From XDL10115 Where XDL_DocNumber = @IN_DocNumbr  
		   IF @CAE <> ''
			SET @CAI = @CAE
		   end
  if (@remove=0) and (@Void=0 )  
   begin  
   set @Letra=''  
   set @val_letra=0  
   set @PDV=''  
   set @FROM_NMBR=''  
   set @TO_NMBR=''  
   set @COD_COMP=''  
   set @CUST_CODE=''  
   set @DEST_CODE=''  
   set @NRO_DESP=''  
   set @DIGVERIF_NRODESP=''  
   set @CAI=''  
   set @ATO_DT=0  
   set @CURR_CODE=''  
   set @T_CAMBIO=0  
   set @RESP_TYPE=''  
   set @CNTRLLR=0  
   set @OP_ORIGIN=0  
   end  
   insert into @TempTableSalesVals values(@Letra,@val_letra,@PDV,@FROM_NMBR,@TO_NMBR,  
  @COD_COMP,@CUST_CODE,@DEST_CODE,@NRO_DESP,@DIGVERIF_NRODESP,@CAI,@ATO_DT,@CURR_CODE,  
  @T_CAMBIO,@RESP_TYPE,@CNTRLLR,@OP_ORIGIN,@PrimKey)  
   FETCH NEXT FROM TL_Sales_Vals INTO @PrimKey,@IN_CurrID,@DOCDATE,@IN_VCRNMBR,@IN_DocType,@IN_CUSTVNDR,  
  @IN_DocNumbr,@Void,@IN_DOCID        
  end    
 close   TL_Sales_Vals  
 deallocate TL_Sales_Vals    
  return       
end   
  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_GetSalesRGUnMarkReqValues]  TO [DYNGRP]
GO
/*End_dbo.TL_RS_GetSalesRGUnMarkReqValues*/
/*Begin_TL_RS_IVA_purchase_Codigo*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_IVA_purchase_Codigo' and type = 'FN')
DROP FUNCTION dbo.TL_RS_IVA_purchase_Codigo;
GO

CREATE function TL_RS_IVA_purchase_Codigo(    
    
@IN_VCRNMBR  char(21)    ,  
@IN_REPORTNAME char(30),  
@IN_DocNumbr char(21),  
@IN_Format  int,  
@IN_Type  int  
)    
returns char(21)    
begin    
  declare @remove  int,    
   @totamount numeric(19,5)  ,  
   @Codigo  char(5),  
   @Ret_Value char(21),  
   @Numero  char(21),  
   @Len  int,  
   @Index  int,  
   @Number  char(21)  
 set @remove=0    
   
  
 set @Codigo=''  
 if @IN_Type=1  
 begin  
 if exists (select top 1 nfRFC_TX00201.CLASS from PM10500 inner join    
  nfRFC_TX00201 on PM10500.TAXDTLID = nfRFC_TX00201.TAXDTLID    
  where nfRFC_TX00201.CLASS=5 and PM10500.VCHRNMBR=@IN_VCRNMBR)    
  begin    
  set @remove=1    
  SELECT   @Codigo = TLIV10203.IVASIAP_CODE   FROM   TLIV10203 INNER JOIN    
   AWLI40102 ON TLIV10203.IDTAXOP = AWLI40102.IDTAXOP     
   where TLIV10203.RPRTNAME=@IN_REPORTNAME and AWLI40102.TAXDTLID in  
   ( select top 1 PM10500.TAXDTLID from PM10500 inner join    
   nfRFC_TX00201 on PM10500.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=5 and PM10500.VCHRNMBR=@IN_VCRNMBR   
   ORDER BY PM10500.VCHRNMBR desc, PM10500.TRXSORCE desc, PM10500.TAXDTLID desc)   
  
  end    
       
  if  @remove=0    
  if exists (select top 1 nfRFC_TX00201.CLASS from PM30700 inner join    
  nfRFC_TX00201 on PM30700.TAXDTLID = nfRFC_TX00201.TAXDTLID    
  where nfRFC_TX00201.CLASS=5 and PM30700.VCHRNMBR=@IN_VCRNMBR)   
  SELECT   @Codigo = TLIV10203.IVASIAP_CODE   FROM   TLIV10203 INNER JOIN    
    AWLI40102 ON TLIV10203.IDTAXOP = AWLI40102.IDTAXOP     
   where TLIV10203.RPRTNAME=@IN_REPORTNAME and AWLI40102.TAXDTLID in(  
   select top 1 PM30700.TAXDTLID from PM30700 inner join    
   nfRFC_TX00201 on PM30700.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=5 and PM30700.VCHRNMBR=@IN_VCRNMBR   
   ORDER BY PM30700.VCHRNMBR desc, PM30700.TRXSORCE desc, PM30700.TAXDTLID desc)    

 if (@Codigo  ='') or (@Codigo  is null )  
  set @Codigo  ='000'  
 end 
 set @Index =1  
 if @IN_Type=2 
  begin  
  if  @IN_Format=1  
   set @Ret_Value = substring(@IN_DocNumbr,10,8)  
  else  
   begin  
   set @Number = ltrim(rtrim(@IN_DocNumbr))  
   set @Numero = ''  
   set @Len=len(@Number)  
   while @Len>=@Index  
    begin  
     if charindex(substring(@Number,@Len+1-@Index,1),'1234567890')<>0  
      begin  
      set @Numero = substring(@Number,@Len+1-@Index,1)+@Numero  
      set @Index = @Index+1  
      end  
     else  
      set @Index =@Len+1  
    end   
    if len(@Numero)<8  
     begin  
     set @Len = len(@Numero)  
     while ((@Len+1)<=8)  
      begin  
      set @Numero = @Numero +'0'  
      set @Len = @Len +1  
      end  
        
     end  
    else  
     set @Numero = substring(@Numero,len(@Numero)-7,8)  
   set @Ret_Value = @Numero  
   end  
  end  
  
 if @IN_Type=1  
  set @Ret_Value = @Codigo  
   
  
 return @Ret_Value    
      
end 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_IVA_purchase_Codigo]  TO [DYNGRP]
GO
/*End_TL_RS_IVA_purchase_Codigo*/
/*Begin_TL_RS_IVA_purchase_totamount*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_IVA_purchase_totamount' and type = 'FN')
DROP FUNCTION dbo.TL_RS_IVA_purchase_totamount;
GO

create function TL_RS_IVA_purchase_totamount(      
      
@IN_VCRNMBR char(21),
@REPORTID	char(15)	      
)      
returns numeric(19,5)      
begin      
  declare @remove int,      
    @totamount numeric(19,5)      
  set @remove=0      
      
  if exists (select top 1 nfRFC_TX00201.CLASS from PM10500 inner join      
   nfRFC_TX00201 on PM10500.TAXDTLID = nfRFC_TX00201.TAXDTLID      
   where nfRFC_TX00201.CLASS=5 and PM10500.VCHRNMBR=@IN_VCRNMBR)      
    begin      
    set @remove=1      
    select @totamount=sum(PM10500.TAXAMNT) from PM10500 inner join      
     nfRFC_TX00201 on PM10500.TAXDTLID = nfRFC_TX00201.TAXDTLID      
     where nfRFC_TX00201.CLASS=5 and PM10500.VCHRNMBR=@IN_VCRNMBR  
	and nfRFC_TX00201.TAXDTLID IN ( SELECT DISTINCT TAXDTLID FROM 
	AWLI40102 WHERE IDTAXOP IN 
	( SELECT IDTAXOP FROM TLRS10203 WHERE RPTID = @REPORTID))   
    end      
         
  if  @remove=0      
  if exists (select top 1 nfRFC_TX00201.CLASS from PM30700 inner join      
   nfRFC_TX00201 on PM30700.TAXDTLID = nfRFC_TX00201.TAXDTLID      
   where nfRFC_TX00201.CLASS=5 and PM30700.VCHRNMBR=@IN_VCRNMBR)      
    select @totamount=sum(PM30700.TAXAMNT) from PM30700 inner join      
    nfRFC_TX00201 on PM30700.TAXDTLID = nfRFC_TX00201.TAXDTLID      
    where nfRFC_TX00201.CLASS=5 and PM30700.VCHRNMBR=@IN_VCRNMBR      
     and nfRFC_TX00201.TAXDTLID IN ( SELECT DISTINCT TAXDTLID FROM 
	AWLI40102 WHERE IDTAXOP IN 
	( SELECT IDTAXOP FROM TLRS10203 WHERE RPTID = @REPORTID))    
 return @totamount      
        
end 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_IVA_purchase_totamount]  TO [DYNGRP]
GO
/*End_TL_RS_IVA_purchase_totamount*/
/*Begin_TL_RS_Iva_purchase_Eliminate*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_Iva_purchase_Eliminate' and type = 'FN')
DROP FUNCTION dbo.TL_RS_Iva_purchase_Eliminate;
GO
CREATE function TL_RS_Iva_purchase_Eliminate(    
  
@IN_VCRNMBR char(21)      
)    
returns int    
begin    
 declare @remove int    
 set @remove=1    
   
  if not exists (select top 1 nfRFC_TX00201.CLASS from PM10500 inner join    
   nfRFC_TX00201 on PM10500.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=5 and PM10500.VCHRNMBR=@IN_VCRNMBR)    
   begin    
    set @remove=0    
   end    
  if  @remove=0    
  if exists (select top 1 nfRFC_TX00201.CLASS from PM30700 inner join    
   nfRFC_TX00201 on PM30700.TAXDTLID = nfRFC_TX00201.TAXDTLID    
   where nfRFC_TX00201.CLASS=5 and PM30700.VCHRNMBR=@IN_VCRNMBR)    
    set @remove=1    
      
   
      
    
 return @remove    
      
end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_Iva_purchase_Eliminate]  TO [DYNGRP]
GO
/*End_TL_RS_Iva_purchase_Eliminate*/
/*Begin_TL_RS_Ivasiap_Elimination*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_Ivasiap_Elimination' and type = 'FN')
DROP FUNCTION dbo.TL_RS_Ivasiap_Elimination;
GO
CREATE function TL_RS_Ivasiap_Elimination(    
@IN_DocNumbr char(21),    
@IN_DocType  int,    
@IN_CUSTVNDR char(15),    
@IN_DOCID  char(15),    
@IN_CurrID  char(15),    
@DOCDATE  datetime,    
@Void   tinyint,    
@IN_BCHSOURC char(15),    
@IN_RMDTYPAL smallint)    
returns int    
as    
begin    
 declare @SopType  int,    
   @PRSTADCD  char(15),    
   @COD_COMP  char(3),    
   @Pos_Letra  smallint,    
   @Pos_PDV  smallint,    
   @Pos_NRO  smallint,    
   @Letra   char(1),    
   @val_letra  int,    
   @PDV   char(5),    
   @FROM_NMBR  char(9),    
   @TO_NMBR  char(9),    
   @RM_FIN_CHRG_AS smallint,    
   @RM_SRVC_AS  smallint,    
   @DocType  int,    
   @UNIQ_FORM_FCNCND tinyint,    
   @remove   int    
    
 set @remove=1    
 if @IN_DocType=1    
  set @SopType=3    
 else    
  set @SopType=4    
   
    
  if @IN_BCHSOURC=''    
   set @remove=0    
  else if @IN_BCHSOURC='XRM_Sales'    
   begin    
   if not exists (SELECT  top 1 nfRFC_TX00201.CLASS FROM RM10601 INNER JOIN    
     nfRFC_TX00201 ON RM10601.TAXDTLID = nfRFC_TX00201.TAXDTLID    
     where RM10601.RMDTYPAL=@IN_RMDTYPAL and RM10601.DOCNUMBR=@IN_DocNumbr and nfRFC_TX00201.CLASS=5)    
    set @remove=0    
   end    
  else if @IN_BCHSOURC='Sales Entry'    
   begin    
   if not exists (SELECT  top 1 nfRFC_TX00201.CLASS FROM SOP10105 INNER JOIN    
     nfRFC_TX00201 ON SOP10105.TAXDTLID = nfRFC_TX00201.TAXDTLID    
     where SOP10105.SOPTYPE=3 and SOP10105.SOPNUMBE=@IN_DocNumbr and SOP10105.LNITMSEQ = 0 and nfRFC_TX00201.CLASS=5)    
    set @remove=0    
   end    
    
  if (@remove=0) and (@Void=0)    
   return 0    
      
  return 1    
end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_Ivasiap_Elimination]  TO [DYNGRP]
GO
/*End_TL_RS_Ivasiap_Elimination*/
/*Begin_TLRS_IVA_DocDetails*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TLRS_IVA_DocDetails' and type = 'FN')
DROP FUNCTION dbo.TLRS_IVA_DocDetails;
GO


CREATE function [dbo].[TLRS_IVA_DocDetails](        
@IN_DocNumbr char(21),        
@IN_DocType  int,        
@IN_CUSTVNDR char(15),        
@IN_DOCID  char(15),        
@IN_CurrID  char(15),        
@DOCDATE  datetime,        
@Void   tinyint,      
@IN_BCHSOURC char(15),      
@IN_RMDTYPAL int,      
@IN_REPORTNAME char(31),      
@IN_Type  int      
)        
returns char(21)       
as        
begin        
 declare @SopType  int,        
   @PRSTADCD  char(15),        
   @COD_COMP  char(3),        
   @Pos_Letra  smallint,        
   @Pos_PDV  smallint,        
   @Pos_NRO  smallint,        
   @Letra   char(1),        
   @val_letra  int,        
   @PDV   char(5),        
   @FROM_NMBR  char(9),        
   @TO_NMBR  char(9),        
   @RM_FIN_CHRG_AS smallint,        
   @RM_SRVC_AS  smallint,        
   @DocType  int,        
   @UNIQ_FORM_FCNCND tinyint,        
   @remove   int ,      
   @RetNumber char(21) ,      
   @Codigo  char(5)      
        
 set @remove=1        
 if @IN_DocType=1        
  set @SopType=3        
 else        
  set @SopType=4        
 if @IN_DOCID <> ''        
  begin        
  if exists(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)        
   begin        
   if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)        
    set @remove=0 
   end        
  else        
   if exists(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)        
    begin        
     if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)        
     set @remove=0 
    end        
    else        
     set @remove=0        
  if exists (select COD_COMP from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType and LETRA=0)        
   begin        
    select @COD_COMP=COD_COMP from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType and LETRA=0        
    if @COD_COMP=''        
     set @remove=0        
    else        
     select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType        
   end        
   else        
    set @remove=0         
           
          
  end        
          
  else 
   select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40300        
  set @Letra = substring(@IN_DocNumbr,@Pos_Letra,1)        
  if @Letra ='A'        
   set @val_letra =1        
  else if @Letra ='B'        
   set @val_letra =2        
  else if @Letra ='C'        
   set @val_letra =3        
  else if @Letra ='E'        
   set @val_letra =4        
  else if @Letra =' '        
   set @val_letra =5        
  else if @Letra ='M'        
   set @val_letra =6        
          
          
  if @IN_DOCID = ''        
   if not exists(select TipoReporte from AWLI40370 where TipoReporte=2 and RMDTYPAL=@IN_DocType and LETRA=@val_letra)        
    set @remove=0        
  if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'') 
   if not exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)        
    set @remove=0        
        
          
  set @PDV = substring(@IN_DocNumbr,@Pos_PDV,4)        
  set @FROM_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)        
  set @TO_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)        
  select @RM_FIN_CHRG_AS =RM_FIN_CHRG_AS,@RM_SRVC_AS=RM_SRVC_AS,@UNIQ_FORM_FCNCND=UNIQ_FORM_FCNCND from AWLI40300        
  set @DocType=@IN_DocType         
  if @IN_DocType =4        
   begin        
   if @RM_FIN_CHRG_AS=1        
    set @DocType=1        
   else        
    set @DocType=3        
   end        
  else if @IN_DocType =4        
   begin        
   if @RM_SRVC_AS=1        
    set @DocType=1        
   else        
    set @DocType=3        
   end        
  else if (@IN_DocType =7) or (@IN_DocType =8)        
   set @DocType=2        
          
  if (@COD_COMP='02') or (@COD_COMP='07') or (@COD_COMP='12') or (@COD_COMP='20') or (@COD_COMP='37')        
   or (@COD_COMP='86')        
   set @DocType=3        
        
  if @UNIQ_FORM_FCNCND=1        
   set @DocType=4        
          
  if not exists (select top 1 COMP_TYPE from AWLI_RM00103 where COMP_TYPE = @DocType and PDV=@PDV and        
    LETRA=@val_letra and @FROM_NMBR >=FROM_NMBR and @FROM_NMBR<=TO_NMBR and @DOCDATE between FROM_DT and TO_DT)        
   set @remove=0        
  set @Codigo=''      
if @IN_Type = 3 
begin  
 if @IN_BCHSOURC='XRM_Sales'        
   begin        
   if exists (SELECT  top 1 nfRFC_TX00201.CLASS FROM RM10601 INNER JOIN        
     nfRFC_TX00201 ON RM10601.TAXDTLID = nfRFC_TX00201.TAXDTLID        
     where RM10601.RMDTYPAL=@IN_RMDTYPAL and RM10601.DOCNUMBR=@IN_DocNumbr and nfRFC_TX00201.CLASS=5)       
  SELECT   @Codigo = TLIV10204.IVASIAP_CODE      
   FROM   TLIV10204 INNER JOIN      
                   AWLI40102 ON TLIV10204.IDTAXOP = AWLI40102.IDTAXOP       
     where TLIV10204.RPRTNAME=@IN_REPORTNAME and AWLI40102.TAXDTLID in(SELECT RM10601.TAXDTLID  FROM RM10601 INNER JOIN        
    nfRFC_TX00201 ON RM10601.TAXDTLID = nfRFC_TX00201.TAXDTLID        
   where RM10601.RMDTYPAL=@IN_RMDTYPAL and RM10601.DOCNUMBR=@IN_DocNumbr and nfRFC_TX00201.CLASS=5)      
          
   end        
  else if @IN_BCHSOURC='Sales Entry'        
   begin        
   if exists (SELECT  top 1 nfRFC_TX00201.CLASS FROM SOP10105 INNER JOIN        
     nfRFC_TX00201 ON SOP10105.TAXDTLID = nfRFC_TX00201.TAXDTLID        
     where SOP10105.SOPTYPE=3 and SOP10105.SOPNUMBE=@IN_DocNumbr and SOP10105.LNITMSEQ = 0 and nfRFC_TX00201.CLASS=5)        
  SELECT     @Codigo = TLIV10204.IVASIAP_CODE      
   FROM   TLIV10204 INNER JOIN      
                   AWLI40102 ON TLIV10204.IDTAXOP = AWLI40102.IDTAXOP       
     where TLIV10204.RPRTNAME=@IN_REPORTNAME and AWLI40102.TAXDTLID in(SELECT  SOP10105.TAXDTLID FROM SOP10105 INNER JOIN        
   nfRFC_TX00201 ON SOP10105.TAXDTLID = nfRFC_TX00201.TAXDTLID        
   where SOP10105.SOPTYPE=3 and SOP10105.SOPNUMBE=@IN_DocNumbr and SOP10105.LNITMSEQ = 0 and nfRFC_TX00201.CLASS=5)      
   end        
 end       
if (@Codigo is NULL) or (@Codigo='')      
 set @Codigo='000'      
      
      
      
if @IN_Type=1      
 set @RetNumber= @PDV      
else if @IN_Type =2      
 set @RetNumber= @FROM_NMBR      
else if @IN_Type = 3      
 set @RetNumber= @Codigo  
else if @IN_Type=4  
 set @RetNumber= @Letra  
return @RetNumber      
        
end 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TLRS_IVA_DocDetails]  TO [DYNGRP]
GO
/*End_TLRS_IVA_DocDetails*/
/*Begin_TLRS_IVASIAP_TotAmount*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TLRS_IVASIAP_TotAmount' and type = 'FN')
DROP FUNCTION dbo.TLRS_IVASIAP_TotAmount;
GO

create function [dbo].[TLRS_IVASIAP_TotAmount](      
@IN_DocNumbr char(21),      
@IN_DocType  int,      
@IN_CUSTVNDR char(15),      
@IN_DOCID  char(15),      
@IN_CurrID  char(15),      
@DOCDATE  datetime,      
@Void   tinyint,      
@IN_BCHSOURC char(15),      
@IN_RMDTYPAL smallint,
@IN_RPTID	char(15))      
returns numeric(19,5)      
as      
begin      
 declare @totamount numeric(19,5)    
  set @totamount=0    
      
  if @IN_BCHSOURC='XRM_Sales'      
     SELECT  @totamount =sum(RM10601.TAXAMNT) FROM RM10601 INNER JOIN      
     nfRFC_TX00201 ON RM10601.TAXDTLID = nfRFC_TX00201.TAXDTLID      
     where RM10601.RMDTYPAL=@IN_RMDTYPAL and RM10601.DOCNUMBR=@IN_DocNumbr and nfRFC_TX00201.CLASS=5      
	 and  nfRFC_TX00201.TAXDTLID in (   
	 SELECT distinct TAXDTLID FROM AWLI40102 where IDTAXOP in(
	 select IDTAXOP from TLRS10203 where RPTID=@IN_RPTID))
  else if @IN_BCHSOURC='Sales Entry'      
     SELECT  @totamount =sum(SOP10105.ORSLSTAX) FROM SOP10105 INNER JOIN      
     nfRFC_TX00201 ON SOP10105.TAXDTLID = nfRFC_TX00201.TAXDTLID      
     where SOP10105.SOPTYPE=3 and SOP10105.SOPNUMBE=@IN_DocNumbr and SOP10105.LNITMSEQ = 0 and nfRFC_TX00201.CLASS=5    
	 and  nfRFC_TX00201.TAXDTLID in (   
	 SELECT distinct TAXDTLID FROM AWLI40102 where IDTAXOP in(
	 select IDTAXOP from TLRS10203 where RPTID=@IN_RPTID))
      
return @totamount    
     
end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TLRS_IVASIAP_TotAmount]  TO [DYNGRP]
GO
/*End_TLRS_IVASIAP_TotAmount*/
/*Begin_TL_RS_CitiSalesRMOPEN*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiSalesRMOPEN' and type = 'TF')
DROP FUNCTION dbo.TL_RS_CitiSalesRMOPEN;
GO

create function TL_RS_CitiSalesRMOPEN()
returns @TempTableRMOPEN table
(
REPORTNAME	char(31),
REPORTID	char(15),
RegType	int,
DOCDATE	datetime,
DOCTYPE	int,
POS	varchar(4),
DOCNUMBER	char(21),
BUYERFISCALCODE	varchar(2),
BUYERID	varchar(11),
[NAME]	char(65),
TOTAL	numeric(19,5),
NotTaxedAmount	numeric(19,5),
TaxedAmount	numeric(19,5),
VATRATE	numeric(19,5),
LiquidTax	numeric(19,5),
ExemptOpAmount	numeric(19,5),
VATQTY	int,
TaxDtlID	char(15),
Retension_Payment_Date datetime,
Retension_Amount int
)
begin
declare @REPORTNAME	char(31),
		@REPORTID	char(15),
		@RegType	int,
		@DOCDATE	datetime,
		@DOCTYPE	int,
		@POS	varchar(4),
		@DOCNUMBER	char(21),
		@BUYERFISCALCODE	varchar(2),
		@BUYERID	varchar(11),
		@NAME	char(65),
		@TOTAL	numeric(19,5),
		@NotTaxedAmount	numeric(19,5),
		@TaxedAmount	numeric(19,5),
		@VATRATE	numeric(19,5),
		@LiquidTax	numeric(19,5),
		@ExemptOpAmount	numeric(19,5),
		@VATQTY	int,
		@TaxDtlID	char(15)
declare TL_RMOPEN cursor fast_forward for
SELECT     dbo.TLCS10101.RPRTNAME AS REPORTNAME, dbo.TLCS10101.RPTID AS REPORTID, 1 AS RegType, dbo.RM20101.GLPOSTDT AS DOCDATE,   
 CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM20101.DOCNUMBR, RM20101.RMDTYPAL, 0, 1)   
 WHEN 1 THEN dbo.TL_RS_Citi_Sales_DocFrmt(RM20101.DOCNUMBR, RM20101.RMDTYPAL, 1, 1) ELSE 0 END AS DOCTYPE,   
 CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM20101.DOCNUMBR, RM20101.RMDTYPAL, 0, 1) WHEN 1 THEN SUBSTRING(RM20101.DOCNUMBR,   
 AWLI40300.Pos_PDV, 4) ELSE '0000' END AS POS, CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM20101.DOCNUMBR, RM20101.RMDTYPAL, 0, 1)   
 WHEN 1 THEN SUBSTRING(RM20101.DOCNUMBR, AWLI40300.Pos_NRO, 8) ELSE RM20101.DOCNUMBR END AS DOCNUMBER,   
 SUBSTRING(dbo.RM00101.TXRGNNUM, LEN(dbo.RM00101.TXRGNNUM) - 1, 2) AS BUYERFISCALCODE, SUBSTRING(dbo.RM00101.TXRGNNUM, 1, 11)   
 AS BUYERID, dbo.RM00101.CUSTNAME AS NAME, dbo.RM20101.ORTRXAMT AS TOTAL, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 2,   
 dbo.TLRS10101.RPTID, 11, dbo.TX30000.TAXDTLID, 3) AS NotTaxedAmount, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 3,   
 dbo.TLRS10101.RPTID, 12, dbo.TX30000.TAXDTLID, 3) AS TaxedAmount, dbo.TX00201.TXDTLPCT AS VATRATE,   
 dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 1, dbo.TLRS10101.RPTID, 0, dbo.TX30000.TAXDTLID, 3) AS LiquidTax,   
 dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 2, dbo.TLRS10101.RPTID, 15, dbo.TX30000.TAXDTLID, 3) AS ExemptOpAmount,   
 CONVERT(int, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 4, dbo.TLRS10101.RPTID, 15, dbo.TX30000.TAXDTLID, 3)) AS VATQTY,   
 dbo.TX30000.TAXDTLID AS TaxDtlID  
FROM         dbo.TLCS10101 INNER JOIN  
 dbo.TLRS10101 ON dbo.TLCS10101.RPTID = dbo.TLRS10101.RPTID INNER JOIN  
 dbo.TLRS10100 ON dbo.TLCS10101.RPRTNAME = dbo.TLRS10100.RPRTNAME INNER JOIN  
 dbo.RM20101 INNER JOIN  
 dbo.TX30000 ON dbo.RM20101.DOCNUMBR = dbo.TX30000.DOCNUMBR INNER JOIN  
 dbo.nfRFC_TX00201 ON dbo.TX30000.TAXDTLID = dbo.nfRFC_TX00201.TAXDTLID INNER JOIN  
 dbo.RM00101 ON dbo.RM20101.CUSTNMBR = dbo.RM00101.CUSTNMBR INNER JOIN  
 dbo.TX00201 ON dbo.TX30000.TAXDTLID = dbo.TX00201.TAXDTLID ON dbo.TLCS10101.From_Date <= dbo.RM20101.GLPOSTDT AND   
 dbo.TLCS10101.TODATE >= dbo.RM20101.GLPOSTDT CROSS JOIN  
 dbo.AWLI40300  
WHERE     (dbo.nfRFC_TX00201.CLASS = 1) AND (dbo.TLRS10100.RPTID = 'CITISALES') AND (dbo.RM20101.SLSAMNT <> 0) AND (dbo.RM20101.RMDTYPAL <> 9)   
 AND (dbo.RM20101.VOIDSTTS = 0) AND (dbo.TLRS10101.OpenTRX = 1) and 
[dbo].[TLRS_CitSales_ValidateColConfigured](TLCS10101.RPTID)<>0        
order by RM20101.CUSTNMBR, RM20101.RMDTYPAL, RM20101.DOCNUMBR ,
TX30000.DOCNUMBR, TX30000.DOCTYPE, TX30000.SERIES, TX30000.RCTRXSEQ, TX30000.SEQNUMBR

open TL_RMOPEN

fetch next from  TL_RMOPEN into @REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID
while @@fetch_status=0
	begin
	if exists(select REPORTNAME from @TempTableRMOPEN where REPORTNAME=@REPORTNAME and DOCNUMBER=@DOCNUMBER)
		begin
			set @NotTaxedAmount=0
			set @ExemptOpAmount=0
		end
	insert into @TempTableRMOPEN(REPORTNAME,REPORTID	,RegType,DOCDATE,DOCTYPE,
		POS,DOCNUMBER,BUYERFISCALCODE,BUYERID,[NAME],TOTAL,NotTaxedAmount,TaxedAmount,
		VATRATE,LiquidTax,ExemptOpAmount,VATQTY,TaxDtlID,Retension_Payment_Date,Retension_Amount)
	 values(@REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID,0,0)
	fetch next from  TL_RMOPEN into @REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID

	end
	close TL_RMOPEN
	deallocate TL_RMOPEN

	insert		into @TempTableRMOPEN(REPORTNAME,REPORTID	,RegType,DOCDATE,DOCTYPE,
				POS,DOCNUMBER,BUYERFISCALCODE,BUYERID,[NAME],TOTAL,NotTaxedAmount,TaxedAmount,
				VATRATE,LiquidTax,ExemptOpAmount,VATQTY,TaxDtlID,Retension_Payment_Date,Retension_Amount)
	SELECT		dbo.TLCS10101.RPRTNAME AS REPORTNAME, dbo.TLCS10101.RPTID AS REPORTID, 1 AS RegType, dbo.RM20101.GLPOSTDT AS DOCDATE,   
				CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM20101.DOCNUMBR, RM20101.RMDTYPAL, 0, 1)   
					WHEN 1 THEN dbo.TL_RS_Citi_Sales_DocFrmt(RM20101.DOCNUMBR, RM20101.RMDTYPAL, 1, 1) 
					ELSE 0 
				END AS DOCTYPE,   

				CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM20101.DOCNUMBR, RM20101.RMDTYPAL, 0, 1) 
					WHEN 1 THEN SUBSTRING(RM20101.DOCNUMBR, AWLI40300.Pos_PDV, 4) 
					ELSE '0000' 
				END AS POS, 

				CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM20101.DOCNUMBR, RM20101.RMDTYPAL, 0, 1)   
					WHEN 1 THEN SUBSTRING(RM20101.DOCNUMBR, AWLI40300.Pos_NRO, 8) 
					ELSE RM20101.DOCNUMBR 
				END AS DOCNUMBER,   
				SUBSTRING(dbo.RM00101.TXRGNNUM, LEN(dbo.RM00101.TXRGNNUM) - 1, 2) AS BUYERFISCALCODE, 
				SUBSTRING(dbo.RM00101.TXRGNNUM, 1, 11) AS BUYERID, dbo.RM00101.CUSTNAME AS NAME, 
				dbo.RM20101.ORTRXAMT AS TOTAL, 
				0 AS NotTaxedAmount, 
				0 AS TaxedAmount, 
				0 AS VATRATE,   
				0 AS LiquidTax,   
				0 AS ExemptOpAmount,   
				0 AS VATQTY,   
				'' AS TaxDtlID, 0, 0
	FROM        dbo.TLCS10101 
	INNER JOIN	dbo.TLRS10101 ON dbo.TLCS10101.RPTID = dbo.TLRS10101.RPTID AND TLRS10101.TL_WITHOUT_TAX = 1 
	INNER JOIN  dbo.TLRS10100 ON dbo.TLCS10101.RPRTNAME = dbo.TLRS10100.RPRTNAME 
	INNER JOIN  dbo.RM20101 ON dbo.TLCS10101.From_Date <= dbo.RM20101.GLPOSTDT AND dbo.TLCS10101.TODATE >= dbo.RM20101.GLPOSTDT
	INNER JOIN  dbo.RM00101 ON dbo.RM20101.CUSTNMBR = dbo.RM00101.CUSTNMBR 
	CROSS JOIN  dbo.AWLI40300  
	WHERE	(dbo.TLRS10100.RPTID = 'CITISALES') AND 
			(dbo.RM20101.SLSAMNT <> 0) AND 
			(dbo.RM20101.RMDTYPAL <> 9)	AND 
			(dbo.RM20101.VOIDSTTS = 0) AND 
			(dbo.RM20101.TAXAMNT = 0) AND 
			(dbo.TL_RS_CitiSalesRMOpenDist_Count(RM20101.DOCNUMBR) = 0) AND
			(dbo.TLRS10101.OpenTRX = 1) AND
			[dbo].[TLRS_CitSales_ValidateColConfigured](TLCS10101.RPTID)<>0        
	order by RM20101.CUSTNMBR, RM20101.RMDTYPAL, RM20101.DOCNUMBR
	
	return
end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_CitiSalesRMOPEN]  TO [DYNGRP]
GO
/*End_TL_RS_CitiSalesRMOPEN*/
/*Begin_TL_RS_CitiSalesSOPWORK*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiSalesSOPWORK' and type = 'TF')
DROP FUNCTION dbo.TL_RS_CitiSalesSOPWORK;
GO

create function TL_RS_CitiSalesSOPWORK()
returns @TempTableSOPWORK table
(
REPORTNAME	char(31),
REPORTID	char(15),
RegType	int,
DOCDATE	datetime,
DOCTYPE	int,
POS	varchar(4),
DOCNUMBER	char(21),
BUYERFISCALCODE	varchar(2),
BUYERID	varchar(11),
[NAME]	char(65),
TOTAL	numeric(19,5),
NotTaxedAmount	numeric(19,5),
TaxedAmount	numeric(19,5),
VATRATE	numeric(19,5),
LiquidTax	numeric(19,5),
ExemptOpAmount	numeric(19,5),
VATQTY	int,
TaxDtlID	char(15),
Retension_Payment_Date datetime,
Retension_Amount int
)
begin
declare @REPORTNAME	char(31),
		@REPORTID	char(15),
		@RegType	int,
		@DOCDATE	datetime,
		@DOCTYPE	int,
		@POS	varchar(4),
		@DOCNUMBER	char(21),
		@BUYERFISCALCODE	varchar(2),
		@BUYERID	varchar(11),
		@NAME	char(65),
		@TOTAL	numeric(19,5),
		@NotTaxedAmount	numeric(19,5),
		@TaxedAmount	numeric(19,5),
		@VATRATE	numeric(19,5),
		@LiquidTax	numeric(19,5),
		@ExemptOpAmount	numeric(19,5),
		@VATQTY	int,
		@TaxDtlID	char(15)
declare TL_SOPWORK cursor fast_forward for
SELECT     TLCS10101.RPRTNAME AS REPORTNAME, TLCS10101.RPTID AS REPORTID, 1 AS REGTYPE, SOP10100.DOCDATE, 
                      convert(int,dbo.TL_RS_Citi_Sales_DocFrmtNumb(SOP10105.SOPNUMBE, SOP10100.SOPTYPE,SOP10100.DOCID ,3,0)) AS DOCTYPE, 
                       dbo.TL_RS_Citi_Sales_DocFrmtNumb(SOP10105.SOPNUMBE, SOP10100.SOPTYPE,SOP10100.DOCID ,1,0)  AS POS, dbo.TL_RS_Citi_Sales_DocFrmtNumb(SOP10105.SOPNUMBE, SOP10100.SOPTYPE,SOP10100.DOCID ,2,0) 
                      AS DOCNUMBER, 
                      SUBSTRING(RM00101.TXRGNNUM, LEN(RM00101.TXRGNNUM) - 1, 2) AS BUYERFISCALCODE, SUBSTRING(RM00101.TXRGNNUM, 1, 11) 
                      AS BUYERID, SOP10100.CUSTNAME AS NAME, SOP10100.DOCAMNT AS TOTAL, dbo.TL_RS_Citi_SalesTaxAmnt(SOP10105.SOPNUMBE, 2, 
                      TLRS10101.RPTID, 11, SOP10105.TAXDTLID, 2) AS NotTaxedAmount, dbo.TL_RS_Citi_SalesTaxAmnt(SOP10105.SOPNUMBE, 3, TLRS10101.RPTID, 12, 
                      SOP10105.TAXDTLID, 2) AS TaxedAmount, TX00201.TXDTLPCT AS VATRATE, dbo.TL_RS_Citi_SalesTaxAmnt(SOP10105.SOPNUMBE, 1, 
                      TLRS10101.RPTID, 0, SOP10105.TAXDTLID, 2) AS LiquidTax, dbo.TL_RS_Citi_SalesTaxAmnt(SOP10105.SOPNUMBE, 2, TLRS10101.RPTID, 15, 
                      SOP10105.TAXDTLID, 2) AS ExemptOpAmount, CONVERT(int, dbo.TL_RS_Citi_SalesTaxAmnt(SOP10105.SOPNUMBE, 4, TLRS10101.RPTID, 15, 
                      SOP10105.TAXDTLID, 2)) AS VATQTY, SOP10105.TAXDTLID AS TaxDtlID
FROM         TLCS10101 INNER JOIN
                      TLRS10101 ON TLCS10101.RPTID = TLRS10101.RPTID INNER JOIN
                      TLRS10100 ON TLCS10101.RPRTNAME = TLRS10100.RPRTNAME INNER JOIN
                      nfRFC_TX00201 INNER JOIN
                      SOP10105 ON nfRFC_TX00201.TAXDTLID = SOP10105.TAXDTLID INNER JOIN
                      SOP10100 ON SOP10105.SOPNUMBE = SOP10100.SOPNUMBE INNER JOIN
                      RM00101 ON SOP10100.CUSTNMBR = RM00101.CUSTNMBR INNER JOIN
                      TX00201 ON nfRFC_TX00201.TAXDTLID = TX00201.TAXDTLID ON TLCS10101.From_Date <= SOP10100.DOCDATE AND 
                      TLCS10101.TODATE >= SOP10100.DOCDATE
WHERE     (nfRFC_TX00201.CLASS = 1) AND (TLRS10100.RPTID = 'CITISALES') AND (SOP10105.LNITMSEQ = 0) AND (SOP10100.DOCAMNT <> 0) AND 
                      (SOP10100.SOPTYPE <> 9) AND (TLRS10101.UNPSTTRX = 1) AND (dbo.TLRS_CitSales_ValidateColConfigured(TLCS10101.RPTID) <> 0)
ORDER BY SOP10100.SOPNUMBE, SOP10100.SOPTYPE, SOP10105.SOPTYPE, SOP10105.SOPNUMBE, SOP10105.LNITMSEQ, TaxDtlID
open TL_SOPWORK

fetch next from  TL_SOPWORK into @REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID
while @@fetch_status=0
	begin
	if exists(select REPORTNAME from @TempTableSOPWORK where REPORTNAME=@REPORTNAME and DOCNUMBER=@DOCNUMBER)
		begin
			set @NotTaxedAmount=0
			set @ExemptOpAmount=0
		end
	insert into @TempTableSOPWORK(REPORTNAME,REPORTID	,RegType,DOCDATE,DOCTYPE,
		POS,DOCNUMBER,BUYERFISCALCODE,BUYERID,[NAME],TOTAL,NotTaxedAmount,TaxedAmount,
		VATRATE,LiquidTax,ExemptOpAmount,VATQTY,TaxDtlID,Retension_Payment_Date,Retension_Amount)
	 values(@REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID,0,0)
	fetch next from  TL_SOPWORK into @REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID

	end
	close TL_SOPWORK
	deallocate TL_SOPWORK
	

	insert		into @TempTableSOPWORK(REPORTNAME,REPORTID	,RegType,DOCDATE,DOCTYPE,
				POS,DOCNUMBER,BUYERFISCALCODE,BUYERID,[NAME],TOTAL,NotTaxedAmount,TaxedAmount,
				VATRATE,LiquidTax,ExemptOpAmount,VATQTY,TaxDtlID,Retension_Payment_Date,Retension_Amount)
	SELECT		TLCS10101.RPRTNAME AS REPORTNAME, TLCS10101.RPTID AS REPORTID, 1 AS REGTYPE, SOP10100.DOCDATE, 
				convert(int,dbo.TL_RS_Citi_Sales_DocFrmtNumb(SOP10100.SOPNUMBE, SOP10100.SOPTYPE,SOP10100.DOCID ,3,0)) AS DOCTYPE, 
				dbo.TL_RS_Citi_Sales_DocFrmtNumb(SOP10100.SOPNUMBE, SOP10100.SOPTYPE,SOP10100.DOCID ,1,0) AS POS, 
				dbo.TL_RS_Citi_Sales_DocFrmtNumb(SOP10100.SOPNUMBE, SOP10100.SOPTYPE,SOP10100.DOCID ,2,0) AS DOCNUMBER, 
				SUBSTRING(RM00101.TXRGNNUM, LEN(RM00101.TXRGNNUM) - 1, 2) AS BUYERFISCALCODE, 
				SUBSTRING(RM00101.TXRGNNUM, 1, 11) AS BUYERID, 
				SOP10100.CUSTNAME AS NAME, 
				SOP10100.DOCAMNT AS TOTAL, 
				0 AS NotTaxedAmount, 
				0 AS TaxedAmount, 
				0 AS VATRATE, 0 AS LiquidTax, 
				0 AS ExemptOpAmount, 
				0 AS VATQTY, 
				'' AS TaxDtlID,0,0
	FROM         TLCS10101 
	INNER JOIN TLRS10101 ON TLCS10101.RPTID = TLRS10101.RPTID AND TLRS10101.TL_WITHOUT_TAX = 1
	INNER JOIN TLRS10100 ON TLCS10101.RPRTNAME = TLRS10100.RPRTNAME 
	INNER JOIN SOP10100 ON TLCS10101.From_Date <= SOP10100.DOCDATE AND TLCS10101.TODATE >= SOP10100.DOCDATE
	INNER JOIN RM00101 ON SOP10100.CUSTNMBR = RM00101.CUSTNMBR 
	WHERE		(TLRS10100.RPTID = 'CITISALES') AND 
				(SOP10100.DOCAMNT <> 0) AND 
				(SOP10100.SOPTYPE <> 9) AND 
				(dbo.TL_RS_CitiSalesSOPWorkDist_Count(SOP10100.SOPNUMBE, SOP10100.SOPTYPE) = 0) AND
				(SOP10100.TAXAMNT = 0)  AND
				(TLRS10101.UNPSTTRX = 1) AND 
				(dbo.TLRS_CitSales_ValidateColConfigured(TLCS10101.RPTID) <> 0)
	ORDER BY SOP10100.SOPNUMBE, SOP10100.SOPTYPE

return
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_CitiSalesSOPWORK]  TO [DYNGRP]
GO
/*End_TL_RS_CitiSalesSOPWORK*/
/*Begin_TL_RS_CitiSalesRMWORK*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiSalesRMWORK' and type = 'TF')
DROP FUNCTION dbo.TL_RS_CitiSalesRMWORK;
GO

create function TL_RS_CitiSalesRMWORK()
returns @TempTableRMWORK table
(
REPORTNAME	char(31),
REPORTID	char(15),
RegType	int,
DOCDATE	datetime,
DOCTYPE	int,
POS	varchar(4),
DOCNUMBER	char(21),
BUYERFISCALCODE	varchar(2),
BUYERID	varchar(11),
[NAME]	char(65),
TOTAL	numeric(19,5),
NotTaxedAmount	numeric(19,5),
TaxedAmount	numeric(19,5),
VATRATE	numeric(19,5),
LiquidTax	numeric(19,5),
ExemptOpAmount	numeric(19,5),
VATQTY	int,
TaxDtlID	char(15),
Retension_Payment_Date datetime,
Retension_Amount int
)
begin
declare @REPORTNAME	char(31),
		@REPORTID	char(15),
		@RegType	int,
		@DOCDATE	datetime,
		@DOCTYPE	int,
		@POS	varchar(4),
		@DOCNUMBER	char(21),
		@BUYERFISCALCODE	varchar(2),
		@BUYERID	varchar(11),
		@NAME	char(65),
		@TOTAL	numeric(19,5),
		@NotTaxedAmount	numeric(19,5),
		@TaxedAmount	numeric(19,5),
		@VATRATE	numeric(19,5),
		@LiquidTax	numeric(19,5),
		@ExemptOpAmount	numeric(19,5),
		@VATQTY	int,
		@TaxDtlID	char(15)
declare TL_RMWORK cursor fast_forward for
SELECT     dbo.TLCS10101.RPRTNAME AS REPORTNAME, dbo.TLCS10101.RPTID AS REPORTID, 1 AS REGTYPE, dbo.RM10301.DOCDATE,   
 CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM10301.DOCNUMBR, RM10301.RMDTYPAL, 0, 1)   
 WHEN 1 THEN dbo.TL_RS_Citi_Sales_DocFrmt(RM10301.DOCNUMBR, RM10301.RMDTYPAL, 1, 1) ELSE 0 END AS DOCTYPE,   
 CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM10301.DOCNUMBR, RM10301.RMDTYPAL, 0, 1) WHEN 1 THEN SUBSTRING(RM10301.DOCNUMBR,   
 AWLI40300.Pos_PDV, 4) ELSE '0000' END AS POS, CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM10301.DOCNUMBR, RM10301.RMDTYPAL, 0, 1)   
 WHEN 1 THEN SUBSTRING(RM10301.DOCNUMBR, AWLI40300.Pos_NRO, 8) ELSE RM10301.DOCNUMBR END AS DOCNUMBER,   
 SUBSTRING(dbo.RM00101.TXRGNNUM, LEN(dbo.RM00101.TXRGNNUM) - 1, 2) AS BUYERFISCALCODE, SUBSTRING(dbo.RM00101.TXRGNNUM, 1, 11)   
 AS BUYERID, dbo.RM10301.CUSTNAME AS NAME, dbo.RM10301.DOCAMNT AS TOTAL, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.RM10601.DOCNUMBR, 2,   
 dbo.TLRS10101.RPTID, 11, dbo.RM10601.TAXDTLID, 1) AS NotTaxedAmount, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.RM10601.DOCNUMBR, 3,   
 dbo.TLRS10101.RPTID, 12, dbo.RM10601.TAXDTLID, 1) AS TaxedAmount, dbo.TX00201.TXDTLPCT AS VATRATE,   
 dbo.TL_RS_Citi_SalesTaxAmnt(dbo.RM10301.DOCNUMBR, 1, dbo.TLRS10101.RPTID, 0, dbo.RM10601.TAXDTLID, 1) AS LiquidTax,   
 dbo.TL_RS_Citi_SalesTaxAmnt(dbo.RM10601.DOCNUMBR, 2, dbo.TLRS10101.RPTID, 15, dbo.RM10601.TAXDTLID, 1) AS ExemptOpAmount,   
 CONVERT(int, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.RM10601.DOCNUMBR, 4, dbo.TLRS10101.RPTID, 15, dbo.RM10601.TAXDTLID, 1)) AS VATQTY,   
 dbo.RM10601.TAXDTLID AS TaxDtlID  
FROM         dbo.TLRS10101 INNER JOIN  
 dbo.TLCS10101 ON dbo.TLRS10101.RPTID = dbo.TLCS10101.RPTID INNER JOIN  
 dbo.TLRS10100 ON dbo.TLCS10101.RPRTNAME = dbo.TLRS10100.RPRTNAME INNER JOIN  
 dbo.RM10301 INNER JOIN  
 dbo.RM10601 ON dbo.RM10301.DOCNUMBR = dbo.RM10601.DOCNUMBR INNER JOIN  
 dbo.nfRFC_TX00201 ON dbo.RM10601.TAXDTLID = dbo.nfRFC_TX00201.TAXDTLID INNER JOIN  
 dbo.RM00101 ON dbo.RM10301.CUSTNMBR = dbo.RM00101.CUSTNMBR INNER JOIN  
 dbo.TX00201 ON dbo.RM10601.TAXDTLID = dbo.TX00201.TAXDTLID ON dbo.TLCS10101.From_Date <= dbo.RM10301.DOCDATE AND   
 dbo.TLCS10101.TODATE >= dbo.RM10301.DOCDATE CROSS JOIN  
 dbo.AWLI40300  
WHERE     (dbo.nfRFC_TX00201.CLASS = 1) AND (dbo.TLRS10100.RPTID = 'CITISALES') AND (dbo.RM10301.SLSAMNT <> 0) AND (dbo.RM10301.RMDTYPAL <> 9)   
 AND (dbo.TLRS10101.UNPSTTRX = 1) 
and 
[dbo].[TLRS_CitSales_ValidateColConfigured](TLCS10101.RPTID)<>0 
order by RM10301.RMDTYPAL, RM10301.RMDNUMWK ,
RM10601.RMDTYPAL, RM10601.DOCNUMBR, RM10601.TRXSORCE, RM10601.TAXDTLID

open TL_RMWORK

fetch next from  TL_RMWORK into @REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID
while @@fetch_status=0
	begin
	if exists(select REPORTNAME from @TempTableRMWORK where REPORTNAME=@REPORTNAME and DOCNUMBER=@DOCNUMBER)
		begin
			set @NotTaxedAmount=0
			set @ExemptOpAmount=0
		end
	insert into @TempTableRMWORK(REPORTNAME,REPORTID	,RegType,DOCDATE,DOCTYPE,
		POS,DOCNUMBER,BUYERFISCALCODE,BUYERID,[NAME],TOTAL,NotTaxedAmount,TaxedAmount,
		VATRATE,LiquidTax,ExemptOpAmount,VATQTY,TaxDtlID,Retension_Payment_Date,Retension_Amount)
	 values(@REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID,0,0)
	fetch next from  TL_RMWORK into @REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID

	end
	close TL_RMWORK
	deallocate TL_RMWORK


	insert	into @TempTableRMWORK
			(REPORTNAME,REPORTID,RegType,DOCDATE,DOCTYPE,POS,DOCNUMBER,BUYERFISCALCODE,BUYERID,
			 [NAME],TOTAL,NotTaxedAmount,TaxedAmount,VATRATE,LiquidTax,ExemptOpAmount,VATQTY,
			 TaxDtlID,Retension_Payment_Date,Retension_Amount)
	SELECT	dbo.TLCS10101.RPRTNAME AS REPORTNAME, 
			dbo.TLCS10101.RPTID AS REPORTID, 1 AS REGTYPE, 
			dbo.RM10301.DOCDATE,   
			CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM10301.DOCNUMBR, RM10301.RMDTYPAL, 0, 1)   
				WHEN 1 THEN dbo.TL_RS_Citi_Sales_DocFrmt(RM10301.DOCNUMBR, RM10301.RMDTYPAL, 1, 1) 
				ELSE 0 
			END AS DOCTYPE,   

			CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM10301.DOCNUMBR, RM10301.RMDTYPAL, 0, 1) 
				WHEN 1 THEN SUBSTRING(RM10301.DOCNUMBR,AWLI40300.Pos_PDV, 4) 
				ELSE '0000' 
			END AS POS, 

			CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM10301.DOCNUMBR, RM10301.RMDTYPAL, 0, 1)   
				WHEN 1 THEN SUBSTRING(RM10301.DOCNUMBR, AWLI40300.Pos_NRO, 8) 
				ELSE RM10301.DOCNUMBR 
			END AS DOCNUMBER,   
	 
			SUBSTRING(dbo.RM00101.TXRGNNUM, LEN(dbo.RM00101.TXRGNNUM) - 1, 2) AS BUYERFISCALCODE, 
			SUBSTRING(dbo.RM00101.TXRGNNUM, 1, 11) AS BUYERID, 
			dbo.RM10301.CUSTNAME AS NAME, 
			dbo.RM10301.DOCAMNT AS TOTAL, 
			0 AS NotTaxedAmount, 0 AS TaxedAmount, 0 AS VATRATE, 0 AS LiquidTax, 0 AS ExemptOpAmount,   
			0 AS VATQTY, '' AS TaxDtlID , 0,0
	FROM dbo.TLRS10101 
	INNER JOIN dbo.TLCS10101 ON dbo.TLRS10101.RPTID = dbo.TLCS10101.RPTID AND TLRS10101.TL_WITHOUT_TAX = 1 
	INNER JOIN dbo.TLRS10100 ON dbo.TLCS10101.RPRTNAME = dbo.TLRS10100.RPRTNAME 
	INNER JOIN dbo.RM10301 ON dbo.TLCS10101.From_Date <= dbo.RM10301.DOCDATE AND dbo.TLCS10101.TODATE >= dbo.RM10301.DOCDATE
	INNER JOIN dbo.RM00101 ON dbo.RM10301.CUSTNMBR = dbo.RM00101.CUSTNMBR 
	CROSS JOIN dbo.AWLI40300  
	WHERE	(dbo.TLRS10100.RPTID = 'CITISALES') AND 
			(dbo.RM10301.SLSAMNT <> 0) AND 
			(dbo.RM10301.TAXAMNT = 0) AND 
			(dbo.TL_RS_CitiSalesRMWorkDist_Count(RM10301.DOCNUMBR, RM10301.RMDTYPAL) = 0) AND
			(dbo.RM10301.RMDTYPAL <> 9) AND 
			(dbo.TLRS10101.UNPSTTRX = 1) AND
			[dbo].[TLRS_CitSales_ValidateColConfigured](TLCS10101.RPTID)<>0
	order by RM10301.RMDTYPAL, RM10301.RMDNUMWK
	
return
end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_CitiSalesRMWORK]  TO [DYNGRP]
GO
/*End_TL_RS_CitiSalesRMWORK*/
/*Begin_TL_RS_CitiSalesRMHIST*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiSalesRMHIST' and type = 'TF')
DROP FUNCTION dbo.TL_RS_CitiSalesRMHIST;
GO


create function TL_RS_CitiSalesRMHIST()
returns @TempTableRMHIST table
(
REPORTNAME	char(31),
REPORTID	char(15),
RegType	int,
DOCDATE	datetime,
DOCTYPE	int,
POS	varchar(4),
DOCNUMBER	char(21),
BUYERFISCALCODE	varchar(2),
BUYERID	varchar(11),
[NAME]	char(65),
TOTAL	numeric(19,5),
NotTaxedAmount	numeric(19,5),
TaxedAmount	numeric(19,5),
VATRATE	numeric(19,5),
LiquidTax	numeric(19,5),
ExemptOpAmount	numeric(19,5),
VATQTY	int,
TaxDtlID	char(15),
Retension_Payment_Date datetime,
Retension_Amount int
)
begin
declare @REPORTNAME	char(31),
		@REPORTID	char(15),
		@RegType	int,
		@DOCDATE	datetime,
		@DOCTYPE	int,
		@POS	varchar(4),
		@DOCNUMBER	char(21),
		@BUYERFISCALCODE	varchar(2),
		@BUYERID	varchar(11),
		@NAME	char(65),
		@TOTAL	numeric(19,5),
		@NotTaxedAmount	numeric(19,5),
		@TaxedAmount	numeric(19,5),
		@VATRATE	numeric(19,5),
		@LiquidTax	numeric(19,5),
		@ExemptOpAmount	numeric(19,5),
		@VATQTY	int,
		@TaxDtlID	char(15)
declare TL_RMHIST cursor fast_forward for
SELECT     dbo.TLCS10101.RPRTNAME AS REPORTNAME, dbo.TLCS10101.RPTID AS REPORTID, 1 AS REGTYPE, dbo.RM30101.GLPOSTDT AS DOCDATE,   
 CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM30101.DOCNUMBR, RM30101.RMDTYPAL, 0, 1)   
 WHEN 1 THEN dbo.TL_RS_Citi_Sales_DocFrmt(RM30101.DOCNUMBR, RM30101.RMDTYPAL, 1, 1) ELSE 0 END AS DOCTYPE,   
 CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM30101.DOCNUMBR, RM30101.RMDTYPAL, 0, 1) WHEN 1 THEN SUBSTRING(RM30101.DOCNUMBR,   
 AWLI40300.Pos_PDV, 4) ELSE '0000' END AS POS, CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM30101.DOCNUMBR, RM30101.RMDTYPAL, 0, 1)   
 WHEN 1 THEN SUBSTRING(RM30101.DOCNUMBR, AWLI40300.Pos_NRO, 8) ELSE RM30101.DOCNUMBR END AS DOCNUMBER,   
 SUBSTRING(dbo.RM00101.TXRGNNUM, LEN(dbo.RM00101.TXRGNNUM) - 1, 2) AS BUYERFISCALCODE, SUBSTRING(dbo.RM00101.TXRGNNUM, 1, 11)   
 AS BUYERID, dbo.RM00101.CUSTNAME AS NAME, dbo.RM30101.ORTRXAMT AS TOTAL, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 2,   
 dbo.TLRS10101.RPTID, 11, dbo.TX30000.TAXDTLID, 3) AS NotTaxedAmount, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 3,   
 dbo.TLRS10101.RPTID, 12, dbo.TX30000.TAXDTLID, 3) AS TaxedAmount, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 1,   
 dbo.TLRS10101.RPTID, 0, dbo.TX30000.TAXDTLID, 3) AS LiquidTax, dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 2,   
 dbo.TLRS10101.RPTID, 15, dbo.TX30000.TAXDTLID, 3) AS ExemptOpAmount, dbo.TX00201.TXDTLPCT AS VATRATE, CONVERT(int,   
 dbo.TL_RS_Citi_SalesTaxAmnt(dbo.TX30000.DOCNUMBR, 4, dbo.TLRS10101.RPTID, 15, dbo.TX30000.TAXDTLID, 3)) AS VATQTY,   
 dbo.TX30000.TAXDTLID AS TaxDtlID  
FROM         dbo.TLRS10101 INNER JOIN  
 dbo.TLCS10101 ON dbo.TLRS10101.RPTID = dbo.TLCS10101.RPTID INNER JOIN  
 dbo.TLRS10100 ON dbo.TLCS10101.RPRTNAME = dbo.TLRS10100.RPRTNAME INNER JOIN  
 dbo.RM30101 INNER JOIN  
 dbo.TX30000 ON dbo.RM30101.DOCNUMBR = dbo.TX30000.DOCNUMBR INNER JOIN  
 dbo.nfRFC_TX00201 ON dbo.TX30000.TAXDTLID = dbo.nfRFC_TX00201.TAXDTLID INNER JOIN  
 dbo.RM00101 ON dbo.RM30101.CUSTNMBR = dbo.RM00101.CUSTNMBR INNER JOIN  
 dbo.TX00201 ON dbo.TX30000.TAXDTLID = dbo.TX00201.TAXDTLID ON dbo.TLCS10101.From_Date <= dbo.RM30101.GLPOSTDT AND   
 dbo.TLCS10101.TODATE >= dbo.RM30101.GLPOSTDT CROSS JOIN  
 dbo.AWLI40300  
WHERE     (dbo.nfRFC_TX00201.CLASS = 1) AND (dbo.TLRS10100.RPTID = 'CITISALES') AND (dbo.RM30101.VOIDSTTS = 0) AND (dbo.RM30101.SLSAMNT <> 0)   
 AND (dbo.RM30101.RMDTYPAL < 9) AND (dbo.TLRS10101.HISTORY = 1) 
and 
[dbo].[TLRS_CitSales_ValidateColConfigured](TLCS10101.RPTID)<>0 
order by RM30101.CUSTNMBR, RM30101.RMDTYPAL, RM30101.DOCNUMBR  ,
TX30000.DOCNUMBR, TX30000.DOCTYPE, TX30000.SERIES, TX30000.RCTRXSEQ, TX30000.SEQNUMBR
open TL_RMHIST

fetch next from  TL_RMHIST into @REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID
while @@fetch_status=0
	begin
	if exists(select REPORTNAME from @TempTableRMHIST where REPORTNAME=@REPORTNAME and DOCNUMBER=@DOCNUMBER)
		begin
			set @NotTaxedAmount=0
			set @ExemptOpAmount=0
		end
	insert into @TempTableRMHIST(REPORTNAME,REPORTID	,RegType,DOCDATE,DOCTYPE,
		POS,DOCNUMBER,BUYERFISCALCODE,BUYERID,[NAME],TOTAL,NotTaxedAmount,TaxedAmount,
		VATRATE,LiquidTax,ExemptOpAmount,VATQTY,TaxDtlID,Retension_Payment_Date,Retension_Amount)
	 values(@REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID,0,0)
	fetch next from  TL_RMHIST into @REPORTNAME,@REPORTID	,@RegType,@DOCDATE,@DOCTYPE,
		@POS,@DOCNUMBER,@BUYERFISCALCODE,@BUYERID,@NAME,@TOTAL,@NotTaxedAmount,@TaxedAmount,
		@VATRATE,@LiquidTax,@ExemptOpAmount,@VATQTY,@TaxDtlID

	end
	close TL_RMHIST
	deallocate TL_RMHIST
	
	insert	into @TempTableRMHIST(REPORTNAME,REPORTID	,RegType,DOCDATE,DOCTYPE,
			POS,DOCNUMBER,BUYERFISCALCODE,BUYERID,[NAME],TOTAL,NotTaxedAmount,TaxedAmount,
			VATRATE,LiquidTax,ExemptOpAmount,VATQTY,TaxDtlID,Retension_Payment_Date,Retension_Amount)
	SELECT	dbo.TLCS10101.RPRTNAME AS REPORTNAME, dbo.TLCS10101.RPTID AS REPORTID, 1 AS REGTYPE, dbo.RM30101.GLPOSTDT AS DOCDATE,   
			CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM30101.DOCNUMBR, RM30101.RMDTYPAL, 0, 1)   
				WHEN 1 THEN dbo.TL_RS_Citi_Sales_DocFrmt(RM30101.DOCNUMBR, RM30101.RMDTYPAL, 1, 1) 
				ELSE 0 
			END AS DOCTYPE,   

			CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM30101.DOCNUMBR, RM30101.RMDTYPAL, 0, 1) 
				WHEN 1 THEN SUBSTRING(RM30101.DOCNUMBR, AWLI40300.Pos_PDV, 4) 
				ELSE '0000' 
			END AS POS, 

			CASE dbo.TL_RS_Citi_Sales_DocFrmt(RM30101.DOCNUMBR, RM30101.RMDTYPAL, 0, 1)   
				WHEN 1 THEN SUBSTRING(RM30101.DOCNUMBR, AWLI40300.Pos_NRO, 8) 
				ELSE RM30101.DOCNUMBR 
			END AS DOCNUMBER,   

			SUBSTRING(dbo.RM00101.TXRGNNUM, LEN(dbo.RM00101.TXRGNNUM) - 1, 2) AS BUYERFISCALCODE, 
			SUBSTRING(dbo.RM00101.TXRGNNUM, 1, 11) AS BUYERID, 
			dbo.RM00101.CUSTNAME AS NAME, 
			dbo.RM30101.ORTRXAMT AS TOTAL, 
			0 AS NotTaxedAmount, 
			0 AS TaxedAmount, 
			0 AS LiquidTax, 
			0 AS ExemptOpAmount, 
			0 AS VATRATE, 
			0 AS VATQTY,   
			'' AS TaxDtlID,0,0
	FROM	dbo.TLRS10101 
	INNER JOIN  dbo.TLCS10101 ON dbo.TLRS10101.RPTID = dbo.TLCS10101.RPTID AND TLRS10101.TL_WITHOUT_TAX = 1 
	INNER JOIN  dbo.TLRS10100 ON dbo.TLCS10101.RPRTNAME = dbo.TLRS10100.RPRTNAME 
	INNER JOIN  dbo.RM30101 ON dbo.TLCS10101.From_Date <= dbo.RM30101.GLPOSTDT AND dbo.TLCS10101.TODATE >= dbo.RM30101.GLPOSTDT 
	INNER JOIN  dbo.RM00101 ON dbo.RM30101.CUSTNMBR = dbo.RM00101.CUSTNMBR 
	CROSS JOIN  dbo.AWLI40300  
	WHERE	(dbo.TLRS10100.RPTID = 'CITISALES') AND 
			(dbo.RM30101.VOIDSTTS = 0) AND 
			(dbo.RM30101.SLSAMNT <> 0) AND 
			(dbo.RM30101.TAXAMNT = 0) AND 
			(dbo.TL_RS_CitiSalesRMOpenDist_Count(RM30101.DOCNUMBR) = 0) AND
			(dbo.RM30101.RMDTYPAL < 9) AND 
			(dbo.TLRS10101.HISTORY = 1) and 
			[dbo].[TLRS_CitSales_ValidateColConfigured](TLCS10101.RPTID)<>0 
	order by RM30101.CUSTNMBR, RM30101.RMDTYPAL, RM30101.DOCNUMBR
	
return
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_CitiSalesRMHIST]  TO [DYNGRP]
GO
/*End_TL_RS_CitiSalesRMHIST*/
/*Begin_TL_RS_SIFERE_Retentions*/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SIFERE_Retentions' and type = 'TF')
DROP FUNCTION dbo.TL_RS_SIFERE_Retentions;
GO


CREATE FUNCTION TL_RS_SIFERE_Retentions ()
RETURNS @SIFERE_Retentions TABLE 
(
RPRTNAME CHAR(31),
TXRGNNUM CHAR(25),
[Retention Date] DATETIME,
NUMBERIE CHAR(21),
MEDIOID CHAR(21),
SIFERECode CHAR(3),
APTODCNM CHAR(21),
[Document Type] CHAR(1),
[Retention Amount] NUMERIC(19,5),
[Record Count] SMALLINT,
IDENTIFICATION INT IDENTITY (1,1)
)
AS
BEGIN
	DECLARE @SIFERE_TEMP TABLE 
		(
		RPRTNAME CHAR(31),
		TXRGNNUM CHAR(25),
		[Retention Date] DATETIME,
		NUMBERIE CHAR(21),
		MEDIOID CHAR(21),
		SIFERECode CHAR(3),
		APTODCNM CHAR(21),
		[Document Type] CHAR(1),
		[Retention Amount] NUMERIC(19,5)
		)

	INSERT INTO @SIFERE_TEMP SELECT * FROM TL_RS_SIFERE_RetentionsView ORDER BY [Report Name], [Cash Receipt No], [Sales Document No], [Means ID]
		
	INSERT INTO	@SIFERE_Retentions
				(
				RPRTNAME, TXRGNNUM, [Retention Date], NUMBERIE, MEDIOID, SIFERECode, APTODCNM, 
				[Document Type], [Retention Amount], [Record Count]
				)
	SELECT	A.RPRTNAME, A.TXRGNNUM, A.[Retention Date], A.NUMBERIE, A.MEDIOID, A.SIFERECode, A.APTODCNM, 
			A.[Document Type], A.[Retention Amount], TEMP_JOIN.RecordCount
	FROM @SIFERE_TEMP AS A
	INNER JOIN (
				SELECT RPRTNAME, NUMBERIE, COUNT(NUMBERIE) AS RecordCount FROM @SIFERE_TEMP GROUP BY RPRTNAME, NUMBERIE
				) AS TEMP_JOIN ON (A.RPRTNAME = TEMP_JOIN.RPRTNAME AND A.NUMBERIE = TEMP_JOIN.NUMBERIE)
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_SIFERE_Retentions]  TO [DYNGRP]
GO
/*End_TL_RS_SIFERE_Retentions*/
/*Begin_TL_RS_SIFERE_TaxAmt*/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SIFERE_TaxAmt' and type = 'FN')
DROP FUNCTION dbo.TL_RS_SIFERE_TaxAmt;
GO

CREATE FUNCTION TL_RS_SIFERE_TaxAmt (@RPRTNAME CHAR(31), @IDTAXOP CHAR(21), @VCHRNMBR CHAR(21), @DocStatus CHAR(5)
, @RPTID CHAR(15), @TAXAMNT1 NUMERIC(19,5))  
RETURNS NUMERIC(19,5)  
AS  
BEGIN  
 DECLARE @TL_WITHOUT_TAX int
 DECLARE @TAXAMT NUMERIC(19,5)
	SELECT  @TL_WITHOUT_TAX = TL_WITHOUT_TAX FROM TLRS10101  WHERE RPTID = @RPTID
	IF @TL_WITHOUT_TAX = 0   
	BEGIN
		SELECT  @TAXAMT = dbo.TL_RS_SIFERE_TaxAmt_WithTax (@RPRTNAME , @IDTAXOP , @VCHRNMBR , @DocStatus)  
		RETURN  @TAXAMT
	END 
	ELSE IF @TL_WITHOUT_TAX = 1   
	BEGIN
		SELECT @TAXAMT = dbo.TL_RS_SIFERE_TaxAmt_WithOutTax  (@RPRTNAME , @IDTAXOP , @VCHRNMBR ,@DocStatus,@TAXAMNT1 )  
		RETURN @TAXAMT
	END 
RETURN NULL  
END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_SIFERE_TaxAmt]  TO [DYNGRP]
GO
/*End_TL_RS_SIFERE_TaxAmt*/
/*Begin_TL_RS_SICOAR_PERPos*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SICOAR_PERPos' and type = 'FN')
DROP FUNCTION TL_RS_SICOAR_PERPos
GO

CREATE FUNCTION dbo.TL_RS_SICOAR_PERPos (@TAXDTLID CHAR (15), @RPTID CHAR (15))
RETURNS SMALLINT
AS 
BEGIN
	RETURN
	(
		SELECT TOP 1 A.NRORDCOL 
		FROM TLRS10203 A
		INNER JOIN AWLI40102 B ON (A.IDTAXOP = B.IDTAXOP AND B.TAXDTLID = @TAXDTLID)
		WHERE	A.RPTID = @RPTID AND 
				A.NRORDCOL > 0
		ORDER BY B.IDTAXOP, B.NumeroDeOrden
	)
END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_SICOAR_PERPos]  TO [DYNGRP]
GO

/*End_TL_RS_SICOAR_PERPos*/
/*Begin_TL_RS_SICOAR_PERSetSicoarCode*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SICOAR_PERSetSicoarCode' and type = 'FN')
DROP FUNCTION TL_RS_SICOAR_PERSetSicoarCode
GO

CREATE FUNCTION dbo.TL_RS_SICOAR_PERSetSicoarCode (@TAXDTLID CHAR (15), @RPRTNAME CHAR (31),@DOCDATE datetime,@CUSTVNDR varchar(40),@DOCTYPE int
,@DOCNUMBR varchar(40))
RETURNS CHAR (3)
AS 
BEGIN
	DECLARE @HR int
	DECLARE @SICOAR_CODE CHAR(3)
	
	select @HR=HR from XPR00102 where CUSTNMBR= @CUSTVNDR 
	and ADRSCODE in(select ADRSCODE from RM20101 where DOCNUMBR= @DOCNUMBR and CUSTNMBR =@CUSTVNDR and RMDTYPAL =@DOCTYPE)
	and TAXDTLID =@TAXDTLID	and AX_Start_Date <=@DOCDATE and AX_Due_Date >=@DOCDATE
	if @HR<>1
	BEGIN
		select @HR=HR from XPR00102 where CUSTNMBR= @CUSTVNDR 
		and ADRSCODE in(select ADRSCODE from RM30101 where DOCNUMBR=@DOCNUMBR and CUSTNMBR =@CUSTVNDR and RMDTYPAL =@DOCTYPE)
		and TAXDTLID =@TAXDTLID	and AX_Start_Date <=@DOCDATE and AX_Due_Date >=@DOCDATE
	END

	IF @HR=1 
	 BEGIN
		 SELECT TOP 1 @SICOAR_CODE = D.TII_HGHRISK   
		 FROM TLSIC10100 A  
		 INNER JOIN TLRS10203 B ON A.RPTID = B.RPTID  
		 INNER JOIN AWLI40102 C ON B.IDTAXOP = C.IDTAXOP  
		 INNER JOIN TLSIC00200 D ON (A.RPRTNAME = D.RPRTNAME AND B.IDTAXOP = D.IDTAXOP)  
		 WHERE A.RPRTNAME = @RPRTNAME AND C.TAXDTLID = @TAXDTLID  
		 ORDER BY B.NRORDCOL, C.IDTAXOP, C.NumeroDeOrden
	 END
	ELSE  
	BEGIN
		 SELECT TOP 1 @SICOAR_CODE = D.SICOAR_CODE   
		 FROM TLSIC10100 A  
		 INNER JOIN TLRS10203 B ON A.RPTID = B.RPTID  
		 INNER JOIN AWLI40102 C ON B.IDTAXOP = C.IDTAXOP  
		 INNER JOIN TLSIC00200 D ON (A.RPRTNAME = D.RPRTNAME AND B.IDTAXOP = D.IDTAXOP)  
		 WHERE A.RPRTNAME = @RPRTNAME AND C.TAXDTLID = @TAXDTLID  
		 ORDER BY B.NRORDCOL, C.IDTAXOP, C.NumeroDeOrden
	END

	IF @SICOAR_CODE IS NULL OR @SICOAR_CODE = ''
		SET @SICOAR_CODE = '000'

RETURN @SICOAR_CODE
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_SICOAR_PERSetSicoarCode]  TO [DYNGRP]
GO

/*End_TL_RS_SICOAR_PERSetSicoarCode*/
/*Begin_TLRS_CitSales_ValidateColConfigured*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TLRS_CitSales_ValidateColConfigured' and type = 'FN')
DROP FUNCTION TLRS_CitSales_ValidateColConfigured
GO

CREATE function [dbo].[TLRS_CitSales_ValidateColConfigured](        
@IN_REPORTID char(15)      
)        
returns int       
as        
begin
	declare @ColCount bigint,
		    @Configured int
	set @ColCount=0
	set @Configured=0
	select @ColCount=count(*) from TLRS10203 where NRORDCOL in(11,12,15)
	and RPTID=@IN_REPORTID
	
	if @ColCount>=3
		set @Configured=1
	return @Configured
end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TLRS_CitSales_ValidateColConfigured]  TO [DYNGRP]
GO

/*End_TLRS_CitSales_ValidateColConfigured*/
/*Begin_TL_RS_Citi_Sales_DocFrmtNumb*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_Citi_Sales_DocFrmtNumb' and type = 'FN')
DROP FUNCTION TL_RS_Citi_Sales_DocFrmtNumb
GO

create function TL_RS_Citi_Sales_DocFrmtNumb(            
 @INDocNumbr char(21),            
 @INDocType int,     
 @INDocID char(15) ,          
 @INFindDocType int,            
 @INType int)            
 returns char(30)            
 begin        
 declare  @result int,            
    @valueset int,            
    @Letra varchar(10),            
    @PosLetra int,            
    @INDocTypeRet int  ,      
 @Let_IntValue int  ,    
 @found int ,    
 @Pos_PDV int,    
 @Pos_NRO   int,    
 @Ret_String char(10)    
  
 declare TL_doc_Number cursor fast_forward for    
 select LETRA,Pos_Letra,Pos_PDV,Pos_NRO from AWLI40380 where SOPTYPE=@INDocType and DOCID=@INDocID    
 open TL_doc_Number    
 fetch next from TL_doc_Number into @valueset,@PosLetra,@Pos_PDV,@Pos_NRO    
 while @@fetch_status=0    
 begin    
    set @found=1    
 set @Letra =  SUBSTRING(@INDocNumbr, @PosLetra, 1)              
 if @valueset=1            
  begin            
  if @Letra<>'A'            
   set @found=0           
  end          
 else if @valueset=2            
  begin          
    if @Letra<>'B'            
   set @found=0           
    end            
 else if @valueset=3            
  begin          
  if @Letra<>'C'            
   set @found=0             
  end          
 else if @valueset=4            
  begin           
  if @Letra<>'E'            
   set @found=0          
  end            
 else if @valueset=6            
 if @Letra<>'M'            
  set @found=0             
                  
    if SUBSTRING(@INDocNumbr, @PosLetra+1, 1)<>'-'            
  set @found=0    
    
 if  @found=1    
  begin    
   close   TL_doc_Number    
   deallocate TL_doc_Number     
      
   if @INFindDocType=1    
    return substring(@INDocNumbr,@Pos_PDV,4)    
   else if @INFindDocType=2   
    return substring(@INDocNumbr,@Pos_NRO,8)    
   else
	select top 1 @INDocNumbr=COD_COMP from AWLI40380 where SOPTYPE=@INDocType and DOCID=@INDocID and LETRA=@valueset
    return  @INDocNumbr     
  end    
     
  fetch next from TL_doc_Number into @valueset,@PosLetra ,@Pos_PDV,@Pos_NRO         
    end        
    close   TL_doc_Number    
 deallocate TL_doc_Number    
    
    if @INFindDocType=1     
		return '0000'    
	else if @INFindDocType=2
		return @INDocNumbr    
	else
		return 0
 return 0
end 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_Citi_Sales_DocFrmtNumb]  TO [DYNGRP]
GO

/*End_TLRS_CitSales_ValidateColConfigured*/
/*Begin_TL_RS_IVASIAP_WITHHOLD_REPORT*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from dbo.sysobjects where name = 'TL_RS_IVASIAP_WITHHOLD_REPORT' and type = 'TF')
    DROP FUNCTION dbo.TL_RS_IVASIAP_WITHHOLD_REPORT;
GO

CREATE FUNCTION TL_RS_IVASIAP_WITHHOLD_REPORT ()
RETURNS @IVASIAP TABLE 
(
RPRTNAME CHAR (31), 
RPTTYPE CHAR(20), 
IVASIAP_CODE CHAR(3), 
TXRGNNUM CHAR(25), 
DocDate DATETIME, 
CertificateNo CHAR (21), 
DocAmount NUMERIC(19,5),
PrimKey INT IDENTITY(1,1)
)
AS
BEGIN

INSERT INTO @IVASIAP (RPRTNAME, RPTTYPE, IVASIAP_CODE, TXRGNNUM, DocDate, CertificateNo, DocAmount)
SELECT     TLRS10100.RPRTNAME, 'Collection' AS RPTTYPE, TLIV10202.IVASIAP_CODE, RM00101.TXRGNNUM, nfMCP10100.EMIDATE AS DocDate, 
                      nfMCP10100.DOCNUMBR AS CertificateNo, nfMCP10100.LINEAMNT AS DocAmount
FROM         TLIV10101 INNER JOIN
                      TLRS10100 ON TLIV10101.RPRTNAME = TLRS10100.RPRTNAME INNER JOIN
                      TLIV10202 ON TLIV10101.RPRTNAME = TLIV10202.RPRTNAME INNER JOIN
                      nfMCP10000 INNER JOIN
                      nfMCP10100 ON nfMCP10000.MCPTYPID = nfMCP10100.MCPTYPID INNER JOIN
                      RM00101 ON nfMCP10000.NFENTID = RM00101.CUSTNMBR ON TLIV10101.STRTDATE <= nfMCP10100.EMIDATE AND 
                      TLIV10101.ENDDATE >= nfMCP10100.EMIDATE AND TLIV10202.MEDIOID = nfMCP10100.MEDIOID
WHERE     (TLRS10100.RPTID = 'IVASIAP') AND (TLIV10101.RetCollection = 1) AND (nfMCP10100.LINEAMNT <> 0)
UNION ALL
SELECT     TLRS10100_1.RPRTNAME, 'Collection' AS RPTTYPE, TLIV10202_1.IVASIAP_CODE, RM00101_1.TXRGNNUM, nfMCP20100.EMIDATE AS DocDate, 
                      nfMCP20100.DOCNUMBR, nfMCP20100.LINEAMNT AS DocAmount
FROM         TLIV10101 AS TLIV10101_1 INNER JOIN
                      TLRS10100 AS TLRS10100_1 ON TLIV10101_1.RPRTNAME = TLRS10100_1.RPRTNAME INNER JOIN
                      TLIV10202 AS TLIV10202_1 ON TLIV10101_1.RPRTNAME = TLIV10202_1.RPRTNAME INNER JOIN
                      nfMCP20000 INNER JOIN
                      nfMCP20100 ON nfMCP20000.NUMBERIE = nfMCP20100.NUMBERIE INNER JOIN
                      RM00101 AS RM00101_1 ON nfMCP20000.NFENTID = RM00101_1.CUSTNMBR ON TLIV10202_1.MEDIOID = nfMCP20100.MEDIOID AND 
                      TLIV10101_1.STRTDATE <= nfMCP20100.EMIDATE AND TLIV10101_1.ENDDATE >= nfMCP20100.EMIDATE
WHERE     (TLRS10100_1.RPTID = 'IVASIAP') AND (TLIV10101_1.RetCollection = 1) AND (nfMCP20100.LINEAMNT <> 0)
UNION ALL
SELECT     TLRS10100_2.RPRTNAME, 'Payments' AS RPTTYPE, TLIV10201.IVASIAP_CODE, PM00200.TXRGNNUM, 
                      nfRET_GL10020.nfRET_Fec_Retencion AS DocDate, nfRET_GL10020.nfMCP_Printing_Number AS CertificateNo, 
                      nfRET_GL10020.nfRET_Importe_Retencion AS DocAmount
FROM         TLIV10201 INNER JOIN
                      nfRET_GL10020 ON TLIV10201.ID_Retencion = nfRET_GL10020.nfRET_Retencion_ID INNER JOIN
                      PM00200 ON nfRET_GL10020.VENDORID = PM00200.VENDORID INNER JOIN
                      AWLI_PM00200 ON nfRET_GL10020.VENDORID = AWLI_PM00200.VENDORID INNER JOIN
                      TLIV10101 AS TLIV10101_2 ON TLIV10201.RPRTNAME = TLIV10101_2.RPRTNAME AND 
                      nfRET_GL10020.nfRET_Fec_Retencion >= TLIV10101_2.STRTDATE AND nfRET_GL10020.nfRET_Fec_Retencion <= TLIV10101_2.ENDDATE INNER JOIN
                      TLRS10100 AS TLRS10100_2 ON TLIV10101_2.RPRTNAME = TLRS10100_2.RPRTNAME
WHERE     (TLRS10100_2.RPTID = 'IVASIAP') AND (TLIV10101_2.RetPayments = 1) AND (nfRET_GL10020.nfRET_Importe_Retencion <> 0)

RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_IVASIAP_WITHHOLD_REPORT]  TO [DYNGRP]
GO

/*End_TL_RS_IVASIAP_WITHHOLD_REPORT*/
/*Begin_TL_RS_SUSS_Report*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SUSS_Report' and type = 'TF')
DROP FUNCTION TL_RS_SUSS_Report
GO

CREATE function [dbo].[TL_RS_SUSS_Report](
@DummyIn_Int int
)    
returns @SUSS_Temp table  
(  
 [Report ID] CHAR(15),
 [Report Name] CHAR(31),
 Code CHAR(3),
 [CUIT Number] CHAR(15),
 [Extended Amount] NUMERIC (19, 5),
 Date datetime,
 [Withholdings Amount] NUMERIC (19,5),
 [Certificate Number] CHAR(15),
 Primkey bigint IDENTITY (1,1)
)   
begin      

INSERT INTO @SUSS_Temp ([Report ID], [Report Name], Code , [CUIT Number], [Extended Amount], Date, [Withholdings Amount], [Certificate Number])
SELECT			SRSH.RPTID AS [Report ID], SRSH.RPRTNAME AS [Report Name], 
				SUSDTL.SICOAR_CODE AS CODE, 
				dbo.TLRS_FormatCuit(PM.TXRGNNUM) AS [CUIT Number], 
				MCP.nfRET_Importe_Retencion * 0 AS [Extended Amount], MCP.nfRET_Fec_Retencion AS DATE, 
                MCP.nfRET_Importe_Retencion AS [Withholdings Amount], MCP.nfMCP_Printing_Number AS [Certificate Number]
FROM         TLRS10100 AS SRSH INNER JOIN
                      TLSUS10100 AS SUSH ON SRSH.RPRTNAME = SUSH.RPRTNAME INNER JOIN
                      TLSUS10200 AS SUSDTL ON SUSH.RPRTNAME = SUSDTL.RPRTNAME INNER JOIN
                      nfRET_GL10020 AS MCP ON SUSDTL.ID_Retencion = MCP.nfRET_Retencion_ID AND SUSH.STRTDATE <= MCP.nfRET_Fec_Retencion AND 
                      SUSH.ENDDATE >= MCP.nfRET_Fec_Retencion INNER JOIN
                      PM00200 AS PM ON MCP.VENDORID = PM.VENDORID

return      
end    

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_SUSS_Report]  TO [DYNGRP]
GO

/*End_TL_RS_SUSS_Report*/
/*Begin_TL_RS_CitiPurchase_EliminateSalesRecs*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiPurchase_EliminateSalesRecs' and type = 'FN')
DROP FUNCTION TL_RS_CitiPurchase_EliminateSalesRecs
GO

create function [dbo].[TL_RS_CitiPurchase_EliminateSalesRecs]
(    
 @IN_DocNumbr char(21),    
 @IN_DocType  int,    
 @IN_CUSTVNDR char(15),    
 @IN_DOCID  char(15),    
 @IN_CurrID  char(15),    
 @DOCDATE  datetime,    
 @Void   tinyint  
)  
returns int    
as    
begin    
 declare @SopType  int,    
   @PRSTADCD  char(15),    
   @COD_COMP  char(3),    
   @Pos_Letra  smallint,    
   @Pos_PDV  smallint,    
   @Pos_NRO  smallint,    
   @Letra   char(1),    
   @val_letra  int,    
   @PDV   char(5),    
   @FROM_NMBR  char(9),    
   @TO_NMBR  char(9),    
   @RM_FIN_CHRG_AS smallint,    
   @RM_SRVC_AS  smallint,    
   @DocType  int,    
   @UNIQ_FORM_FCNCND tinyint,    
   @remove   int ,
   @OP_ORIGIN int   
 
  set @remove=1    
   
 if exists(select OP_ORIGIN from AWLI_RM00101 where CUSTNMBR=@IN_CUSTVNDR)
	begin
		select @OP_ORIGIN =OP_ORIGIN from AWLI_RM00101 where CUSTNMBR=@IN_CUSTVNDR
	    if @OP_ORIGIN=4
			return 0
	end
 else
	return 0
 
 if @IN_DocType=1    
  set @SopType=3    
 else    
  set @SopType=4    
 if @IN_DOCID <> ''    
  begin    
  if exists(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)    
   begin    
   if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP30200 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)    
    set @remove=0 
   end    
  else    
   if exists(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType)    
    begin    
     if exists(select CUSTNMBR from AWLI_RM00102 where CUSTNMBR=@IN_CUSTVNDR and ADRSCODE=(select PRSTADCD from SOP10100 where SOPNUMBE = @IN_DocNumbr and SOPTYPE=@SopType) and OP_ORIGIN=4)    
     set @remove=0 
    end    
    else    
     set @remove=0    
  if exists (select COD_COMP from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType)    
   begin    
    select @COD_COMP=isnull(COD_COMP,'') from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType   
    if @COD_COMP=''    
     set @remove=0    
    else    
     select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40380 where DOCID=@IN_DOCID and SOPTYPE=@SopType    
   end    
   else    
    set @remove=0     
       
      
  end    
      
  else /*DOCID = ''*/    
   select @Pos_Letra=Pos_Letra,@Pos_PDV=Pos_PDV,@Pos_NRO=Pos_NRO from AWLI40300    
  set @Letra = substring(@IN_DocNumbr,@Pos_Letra,1)    
  if @Letra ='A'    
   set @val_letra =1    
  else if @Letra ='B'    
   set @val_letra =2    
  else if @Letra ='C'    
   set @val_letra =3    
  else if @Letra ='E'    
   set @val_letra =4    
  else if @Letra =' '    
   set @val_letra =5    
  else if @Letra ='M'    
   set @val_letra =6    
      
      
  if @IN_DOCID = ''    
   if not exists(select TipoReporte from AWLI40370 where TipoReporte=2 and RMDTYPAL=@IN_DocType and LETRA=@val_letra)    
    set @remove=0    
  if exists (select TOP 1 CURNCYID from CM00100 WHERE CURNCYID<>'') 
   if not exists(select CURNCYID from DYNAMICS..AWLI_MC40200 WHERE CURNCYID=@IN_CurrID)    
    set @remove=0    
    
      
  set @PDV = substring(@IN_DocNumbr,@Pos_PDV,4)    
  set @FROM_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)    
  set @TO_NMBR = substring(@IN_DocNumbr,@Pos_NRO,8)    
  select @RM_FIN_CHRG_AS =RM_FIN_CHRG_AS,@RM_SRVC_AS=RM_SRVC_AS,@UNIQ_FORM_FCNCND=UNIQ_FORM_FCNCND from AWLI40300    
  set @DocType=@IN_DocType     
  if @IN_DocType =4    
   begin    
   if @RM_FIN_CHRG_AS=1    
    set @DocType=1    
   else    
    set @DocType=3    
   end    
  else if @IN_DocType =5    
   begin    
   if @RM_SRVC_AS=1    
    set @DocType=1    
   else    
    set @DocType=3    
   end    
  else if (@IN_DocType =7) or (@IN_DocType =8)    
   set @DocType=2    
      
  if (@COD_COMP='02') or (@COD_COMP='07') or (@COD_COMP='12') or (@COD_COMP='20') or (@COD_COMP='37')    
   or (@COD_COMP='86')    
   set @DocType=3    
      
  if @UNIQ_FORM_FCNCND=1    
   set @DocType=4    
      
  if not exists (select top 1 COMP_TYPE from AWLI_RM00103 where PDV=@PDV and    
    LETRA=@val_letra and @FROM_NMBR >=FROM_NMBR and @FROM_NMBR<=TO_NMBR and @DOCDATE between FROM_DT and TO_DT and COMP_TYPE = @DocType)    
   set @remove=0    
  
     
  if (@remove=0) and (@Void=0)    
   return 0    
      
  return 1    
end  
  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_CitiPurchase_EliminateSalesRecs]  TO [DYNGRP]
GO
/*End_TL_RS_CitiPurchase_EliminateSalesRecs*/
/*Begin_TL_RS_CitiSalesRMOpenDist_Count*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiSalesRMOpenDist_Count' and type = 'FN')
DROP FUNCTION TL_RS_CitiSalesRMOpenDist_Count
GO

create function TL_RS_CitiSalesRMOpenDist_Count(        
@INDocNumbr char(21))
 returns int        
begin    
DECLARE @DIST_COUNT INT
SELECT @DIST_COUNT = COUNT(*) FROM TX30000 WHERE DOCNUMBR = @INDocNumbr
RETURN ISNULL(@DIST_COUNT, 0)
end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_CitiSalesRMOpenDist_Count]  TO [DYNGRP]
GO
/*End_TL_RS_CitiSalesRMOpenDist_Count*/
/*Begin_TL_RS_CitiSalesRMWorkDist_Count*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiSalesRMWorkDist_Count' and type = 'FN')
DROP FUNCTION TL_RS_CitiSalesRMWorkDist_Count
GO

create function TL_RS_CitiSalesRMWorkDist_Count(        
@INDocNumbr char(21),        
@INDocType int)
 returns int        
begin    
DECLARE @DIST_COUNT INT
SELECT @DIST_COUNT = COUNT(*) FROM RM10601 WHERE DOCNUMBR = @INDocNumbr AND RMDTYPAL = @INDocType
RETURN ISNULL(@DIST_COUNT, 0)
end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_CitiSalesRMWorkDist_Count]  TO [DYNGRP]
GO
/*End_TL_RS_CitiSalesRMWorkDist_Count*/
/*Begin_TL_RS_CitiSalesSOPWorkDist_Count*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_CitiSalesSOPWorkDist_Count' and type = 'FN')
DROP FUNCTION TL_RS_CitiSalesSOPWorkDist_Count
GO

create function TL_RS_CitiSalesSOPWorkDist_Count(        
@INDocNumbr char(21),        
@INDocType int)
 returns int        
begin    
DECLARE @DIST_COUNT INT
SELECT @DIST_COUNT = COUNT(*) FROM SOP10105 WHERE SOPNUMBE = @INDocNumbr AND SOPTYPE = @INDocType AND LNITMSEQ = 0
RETURN ISNULL(@DIST_COUNT, 0)
end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_CitiSalesSOPWorkDist_Count]  TO [DYNGRP]
GO
/*End_TL_RS_CitiSalesSOPWorkDist_Count*/
/*Begin_TL_RS_IVASIAPREPORT*/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_IVASIAPREPORT' and type = 'TF')
DROP FUNCTION TL_RS_IVASIAPREPORT;
GO
CREATE FUNCTION TL_RS_IVASIAPREPORT()     
RETURNS @TempTableIVASIAP TABLE  
(
 PrimKey  bigint,  
 RPTNAME    char(30),  
 USERID  CHAR(15),
 RPTID    char(15), 
 TipoReporte   smallint,
 NumeroDeOrden  smallint,
 IDGRIMP    char(15),
 DSCRIPTN   char(31),
 AWLI_DOCUMENT_STATE char(5),
 DOCTYPE    smallint,
 DOCNUMBR   char(21),
 VCHRNMBR   char(21),
 DOCDATE    datetime, 
 GLPOSTDT   datetime,
 CUSTVNDR   char(15),
 CUSTNAME   char(65),
 TaxRegNo   char(25), 
 SLSAMNT    numeric(19,5),      
 TRDISAMT   numeric(19,5),      
 FRTAMNT    numeric(19,5),      
 MISCAMNT   numeric(19,5),      
 TAXAMNT    numeric(19,5),      
 DOCAMNT    numeric(19,5),
 Void    tinyint, 
 DOCID    char(15),
 AWLI_DOCTYPEDESC char(7),
 VOIDDATE   datetime,
 CURNCYID   char(15),
 COL01  NUMERIC(19,5),         
 COL02  NUMERIC(19,5),         
 COL03  NUMERIC(19,5),          
 COL04  NUMERIC(19,5),          
 COL05  NUMERIC(19,5),          
 COL06  NUMERIC(19,5),          
 COL07  NUMERIC(19,5),         
 COL08  NUMERIC(19,5),         
 COL09  NUMERIC(19,5),         
 COL10  NUMERIC(19,5),         
 COL11  NUMERIC(19,5),         
 COL12  NUMERIC(19,5),         
 COL13  NUMERIC(19,5),         
 COL14  NUMERIC(19,5),         
 COL15  NUMERIC(19,5),         
 COL16  NUMERIC(19,5),         
 COL17  NUMERIC(19,5),         
 COL18  NUMERIC(19,5),         
 COL19  NUMERIC(19,5),         
 COL20  NUMERIC(19,5),
 [Report Type] char(25), 
 Letra char(1),
 Letra_Value int,
 PDV char(10),
 From_No char(21),
 To_No char(21),
 COD_COMP char(3),  
 CUST_CODE char(3),  
 DEST_CODE char(5),  
 NRO_DESP char(7),  
 DIGVERIF_NRODESP char(1),  
 CAI char(31),  
 TO_DT datetime,  
 CURR_CODE char(3),  
 T_CAMBIO numeric(19,7),  
 RESP_TYPE char(3),  
 CNTRLLR tinyint,  
 OP_ORIGIN smallint, 
 Expr1 bigint,
 TotalAmount  NUMERIC(19,5),
 RegulationCode char(3)
)   
BEGIN

INSERT INTO @TempTableIVASIAP
SELECT     TL_RS_IVA_Sales_View.PrimKey, TL_RS_IVA_Sales_View.RPTNAME, TL_RS_IVA_Sales_View.USERID, TL_RS_IVA_Sales_View.RPTID, 
                      TL_RS_IVA_Sales_View.TipoReporte, TL_RS_IVA_Sales_View.NumeroDeOrden, TL_RS_IVA_Sales_View.IDGRIMP, TL_RS_IVA_Sales_View.DSCRIPTN, 
                      TL_RS_IVA_Sales_View.AWLI_DOCUMENT_STATE, TL_RS_IVA_Sales_View.DOCTYPE, TL_RS_IVA_Sales_View.DOCNUMBR, 
                      TL_RS_IVA_Sales_View.VCHRNMBR, TL_RS_IVA_Sales_View.DOCDATE, TL_RS_IVA_Sales_View.GLPOSTDT, TL_RS_IVA_Sales_View.CUSTVNDR, 
                      TL_RS_IVA_Sales_View.CUSTNAME, SUBSTRING(TL_RS_IVA_Sales_View.TXRGNNUM, 1, 13) AS TaxRegNo, TL_RS_IVA_Sales_View.SLSAMNT, 
                      TL_RS_IVA_Sales_View.TRDISAMT, TL_RS_IVA_Sales_View.FRTAMNT, TL_RS_IVA_Sales_View.MISCAMNT, TL_RS_IVA_Sales_View.TAXAMNT, 
                      TL_RS_IVA_Sales_View.DOCAMNT, TL_RS_IVA_Sales_View.Void, TL_RS_IVA_Sales_View.DOCID, TL_RS_IVA_Sales_View.AWLI_DOCTYPEDESC, 
                      TL_RS_IVA_Sales_View.VOIDDATE, TL_RS_IVA_Sales_View.CURNCYID, TL_RS_IVA_Sales_View.COL01, TL_RS_IVA_Sales_View.COL02, 
                      TL_RS_IVA_Sales_View.COL03, TL_RS_IVA_Sales_View.COL04, TL_RS_IVA_Sales_View.COL05, TL_RS_IVA_Sales_View.COL06, 
                      TL_RS_IVA_Sales_View.COL07, TL_RS_IVA_Sales_View.COL08, TL_RS_IVA_Sales_View.COL09, TL_RS_IVA_Sales_View.COL10, 
                      TL_RS_IVA_Sales_View.COL11, TL_RS_IVA_Sales_View.COL12, TL_RS_IVA_Sales_View.COL13, TL_RS_IVA_Sales_View.COL14, 
                      TL_RS_IVA_Sales_View.COL15, TL_RS_IVA_Sales_View.COL16, TL_RS_IVA_Sales_View.COL17, TL_RS_IVA_Sales_View.COL18, 
                      TL_RS_IVA_Sales_View.COL19, TL_RS_IVA_Sales_View.COL20, TL_RS_IVA_Sales_View.[Report Type], TL_RS_GetSalesReqValues_1.Letra, 
                      TL_RS_GetSalesReqValues_1.Letra_Value, TL_RS_GetSalesReqValues_1.PDV, TL_RS_GetSalesReqValues_1.From_No, 
                      TL_RS_GetSalesReqValues_1.To_No, TL_RS_GetSalesReqValues_1.COD_COMP, TL_RS_GetSalesReqValues_1.CUST_CODE, 
                      TL_RS_GetSalesReqValues_1.DEST_CODE, TL_RS_GetSalesReqValues_1.NRO_DESP, TL_RS_GetSalesReqValues_1.DIGVERIF_NRODESP, 
                      TL_RS_GetSalesReqValues_1.CAI, TL_RS_GetSalesReqValues_1.TO_DT, TL_RS_GetSalesReqValues_1.CURR_CODE, 
                      TL_RS_GetSalesReqValues_1.T_CAMBIO, TL_RS_GetSalesReqValues_1.RESP_TYPE, TL_RS_GetSalesReqValues_1.CNTRLLR, 
                      TL_RS_GetSalesReqValues_1.OP_ORIGIN, TL_RS_GetSalesReqValues_1.primkey AS Expr1, 
                      dbo.TLRS_IVASIAP_TotAmount(TL_RS_IVA_Sales_View.DOCNUMBR, TL_RS_IVA_Sales_View.DOCTYPE, TL_RS_IVA_Sales_View.CUSTVNDR, 
                      TL_RS_IVA_Sales_View.DOCID, TL_RS_IVA_Sales_View.CURNCYID, TL_RS_IVA_Sales_View.DOCDATE, TL_RS_IVA_Sales_View.Void, 
                      RM20101.BCHSOURC, RM20101.RMDTYPAL, TL_RS_IVA_Sales_View.RPTID) AS TotalAmount, 
                      dbo.TLRS_IVA_DocDetails(TL_RS_IVA_Sales_View.DOCNUMBR, TL_RS_IVA_Sales_View.DOCTYPE, TL_RS_IVA_Sales_View.CUSTVNDR, 
                      TL_RS_IVA_Sales_View.DOCID, TL_RS_IVA_Sales_View.CURNCYID, TL_RS_IVA_Sales_View.DOCDATE, TL_RS_IVA_Sales_View.Void, 
                      RM20101.BCHSOURC, RM20101.RMDTYPAL, TL_RS_IVA_Sales_View.RPTNAME, 3) AS RegulationCode
FROM         TL_RS_IVA_Sales_View INNER JOIN
                      dbo.TL_RS_GetSalesReqValues(4) AS TL_RS_GetSalesReqValues_1 ON 
                      TL_RS_IVA_Sales_View.PrimKey = TL_RS_GetSalesReqValues_1.primkey INNER JOIN
                      AWLI_RM00101 ON TL_RS_IVA_Sales_View.CUSTVNDR = AWLI_RM00101.CUSTNMBR INNER JOIN
                      RM20101 ON TL_RS_IVA_Sales_View.DOCNUMBR = RM20101.DOCNUMBR AND TL_RS_IVA_Sales_View.CUSTVNDR = RM20101.CUSTNMBR
WHERE     (AWLI_RM00101.OP_ORIGIN <> 4) AND (TL_RS_IVA_Sales_View.DOCTYPE <> 7) AND (TL_RS_IVA_Sales_View.DOCTYPE <> 8) AND 
                      (AWLI_RM00101.GrossIncomeStatus <> 4) AND (dbo.TL_RS_Ivasiap_Elimination(TL_RS_IVA_Sales_View.DOCNUMBR, 
                      TL_RS_IVA_Sales_View.DOCTYPE, TL_RS_IVA_Sales_View.CUSTVNDR, TL_RS_IVA_Sales_View.DOCID, TL_RS_IVA_Sales_View.CURNCYID, 
                      TL_RS_IVA_Sales_View.DOCDATE, TL_RS_IVA_Sales_View.Void, RM20101.BCHSOURC, RM20101.RMDTYPAL) <> 0)
UNION ALL
SELECT     TL_RS_PurchaseView.PrimKey, TL_RS_PurchaseView.RPTNAME, TL_RS_PurchaseView.USERID, TL_RS_PurchaseView.RPTID, 
                      TL_RS_PurchaseView.TipoReporte, TL_RS_PurchaseView.NumeroDeOrden, TL_RS_PurchaseView.IDGRIMP, TL_RS_PurchaseView.DSCRIPTN, 
                      TL_RS_PurchaseView.AWLI_DOCUMENT_STATE, TL_RS_PurchaseView.DOCTYPE, TL_RS_PurchaseView.DOCNUMBR, 
                      TL_RS_PurchaseView.VCHRNMBR, TL_RS_PurchaseView.DOCDATE, TL_RS_PurchaseView.GLPOSTDT, TL_RS_PurchaseView.CUSTVNDR, 
                      TL_RS_PurchaseView.CUSTNAME, TL_RS_PurchaseView.TXRGNNUM AS TaxRegNo, TL_RS_PurchaseView.SLSAMNT, 
                      TL_RS_PurchaseView.TRDISAMT, TL_RS_PurchaseView.FRTAMNT, TL_RS_PurchaseView.MISCAMNT, TL_RS_PurchaseView.TAXAMNT, 
                      TL_RS_PurchaseView.DOCAMNT, TL_RS_PurchaseView.Void, TL_RS_PurchaseView.DOCID, TL_RS_PurchaseView.AWLI_DOCTYPEDESC, 
                      TL_RS_PurchaseView.VOIDDATE, TL_RS_PurchaseView.CURNCYID, TL_RS_PurchaseView.COL01, TL_RS_PurchaseView.COL02, 
                      TL_RS_PurchaseView.COL03, TL_RS_PurchaseView.COL04, TL_RS_PurchaseView.COL05, TL_RS_PurchaseView.COL06, TL_RS_PurchaseView.COL07,
                       TL_RS_PurchaseView.COL08, TL_RS_PurchaseView.COL09, TL_RS_PurchaseView.COL10, TL_RS_PurchaseView.COL11, 
                      TL_RS_PurchaseView.COL12, TL_RS_PurchaseView.COL13, TL_RS_PurchaseView.COL14, TL_RS_PurchaseView.COL15, TL_RS_PurchaseView.COL16,
                       TL_RS_PurchaseView.COL17, TL_RS_PurchaseView.COL18, TL_RS_PurchaseView.COL19, TL_RS_PurchaseView.COL20, 'Purchase' AS 'Report Type', 
                      TL_RS_PurchaseReqValues_1.Letra, TL_RS_PurchaseReqValues_1.Letra_Value, TL_RS_PurchaseReqValues_1.PDV, 
                      TL_RS_PurchaseReqValues_1.From_No, TL_RS_PurchaseReqValues_1.To_No, TL_RS_PurchaseReqValues_1.COD_COMP, 
                      TL_RS_PurchaseReqValues_1.CUST_CODE, TL_RS_PurchaseReqValues_1.DEST_CODE, TL_RS_PurchaseReqValues_1.NRO_DESP, 
                      TL_RS_PurchaseReqValues_1.DIGVERIF_NRODESP, TL_RS_PurchaseReqValues_1.CAI, TL_RS_PurchaseReqValues_1.TO_DT, 
                      TL_RS_PurchaseReqValues_1.CURR_CODE, TL_RS_PurchaseReqValues_1.T_CAMBIO, TL_RS_PurchaseReqValues_1.RESP_TYPE, 
                      TL_RS_PurchaseReqValues_1.CNTRLLR, TL_RS_PurchaseReqValues_1.OP_ORIGIN, TL_RS_PurchaseReqValues_1.primkey AS Expr1, 
                      dbo.TL_RS_IVA_purchase_totamount(TL_RS_PurchaseView.VCHRNMBR, TL_RS_PurchaseView.RPTID) AS TotalAmount, 
                      dbo.TL_RS_IVA_purchase_Codigo(TL_RS_PurchaseView.VCHRNMBR, TL_RS_PurchaseView.RPTNAME, TL_RS_PurchaseView.DOCNUMBR, 0, 1) 
                      AS RegulationCode
FROM         TL_RS_PurchaseView INNER JOIN
                      dbo.TL_RS_PurchaseReqValues(2) AS TL_RS_PurchaseReqValues_1 ON 
                      TL_RS_PurchaseView.PrimKey = TL_RS_PurchaseReqValues_1.primkey INNER JOIN
                      AWLI_PM00200 ON TL_RS_PurchaseView.CUSTVNDR = AWLI_PM00200.VENDORID
WHERE   (dbo.TL_RS_Iva_purchase_Eliminate(TL_RS_PurchaseView.VCHRNMBR) <> 0) AND
(TL_RS_PurchaseView.DOCTYPE <> 7) AND (TL_RS_PurchaseReqValues_1.PDV <> '') AND (TL_RS_PurchaseView.DOCTYPE <> 8) AND (AWLI_PM00200.GrossIncomeStatus <> 4)
RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_IVASIAPREPORT]  TO [DYNGRP]
GO
/*End_TL_RS_IVASIAPREPORT*/
/*Begin_TL_RS_SICOAR_REPORT_TL_WITH_TAX*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SICOAR_REPORT_TL_WITH_TAX' and type = 'TF')
DROP FUNCTION TL_RS_SICOAR_REPORT_TL_WITH_TAX
GO

CREATE FUNCTION TL_RS_SICOAR_REPORT_TL_WITH_TAX ()  
RETURNS @SICOAR TABLE   
(  
RPRTNAME CHAR(31),   
RPTID CHAR(15),   
[Report Type] VARCHAR(20),  
DOCNUMBR CHAR(21),   
SICOAR_CODE CHAR(3),   
DOCDATE DATETIME,   
CUSTVNDR CHAR(15),  
ISIB VARCHAR(10),  
[Taxpayer ID] VARCHAR(15),  
AMOUNT NUMERIC(19, 5),  
IDENTIFICATION INT IDENTITY (1,1)  
)  
AS  
BEGIN  
  
 DECLARE @TEMP_AWLI50003 TABLE   
 (  
 RPRTNAME CHAR(31), USERID CHAR(50), RPTID CHAR(15), TipoReporte SMALLINT, NumeroDeOrden SMALLINT, IDGRIMP CHAR(15),   
 DSCRIPTN CHAR(31), AWLI_DOCUMENT_STATE CHAR(5), DOCTYPE SMALLINT, DOCNUMBR CHAR(21),  
 VCHRNMBR CHAR(21), DOCDATE DATETIME, GLPOSTDT DATETIME, CUSTVNDR CHAR(15), CUSTNAME CHAR(65),  
 TXRGNNUM CHAR(25), SLSAMNT NUMERIC(19,5), TRDISAMT NUMERIC(19,5), FRTAMNT NUMERIC(19,5),  
 MISCAMNT NUMERIC(19,5), TAXAMNT NUMERIC(19,5), DOCAMNT NUMERIC(19,5), Void TINYINT, DOCID CHAR(15),  
 AWLI_DOCTYPEDESC CHAR(7), VOIDDATE DATETIME, CURNCYID CHAR(15), CNTRLLR TINYINT, LETRA SMALLINT,  
 PDV CHAR(5), FROM_NMBR CHAR(9), TO_NMBR CHAR(9), RESP_TYPE CHAR(3), COD_COMP CHAR(3),  
 CUST_CODE CHAR(3), DEST_CODE CHAR(5), NRO_DESP CHAR(7), DIGVERIF_NRODESP CHAR(1), CAI CHAR(31),  
 TO_DT DATETIME, CURR_CODE CHAR(3), T_CAMBIO NUMERIC(19,7), OP_ORIGIN SMALLINT,   
 COLIMP01 NUMERIC(19,5), COLIMP02 NUMERIC(19,5), COLIMP03 NUMERIC(19,5), COLIMP04 NUMERIC(19,5),   
 COLIMP05 NUMERIC(19,5), COLIMP06 NUMERIC(19,5), COLIMP07 NUMERIC(19,5), COLIMP08 NUMERIC(19,5),  
 COLIMP09 NUMERIC(19,5), COLIMP10 NUMERIC(19,5), COLIMP11 NUMERIC(19,5), COLIMP12 NUMERIC(19,5),  
 COLIMP13 NUMERIC(19,5), COLIMP14 NUMERIC(19,5), COLIMP15 NUMERIC(19,5), COLIMP16 NUMERIC(19,5),  
 COLIMP17 NUMERIC(19,5), COLIMP18 NUMERIC(19,5), COLIMP19 NUMERIC(19,5), COLIMP20 NUMERIC(19,5)  
 )  
  
  
 INSERT @TEMP_AWLI50003  
 (     
    RPRTNAME,USERID,RPTID,TipoReporte,NumeroDeOrden,IDGRIMP,DSCRIPTN,AWLI_DOCUMENT_STATE,DOCTYPE,DOCNUMBR,    
    VCHRNMBR,DOCDATE,GLPOSTDT,CUSTVNDR,CUSTNAME,TXRGNNUM,SLSAMNT,TRDISAMT,FRTAMNT,MISCAMNT,TAXAMNT,DOCAMNT,    
    Void,DOCID,AWLI_DOCTYPEDESC,VOIDDATE,CURNCYID,    
    COLIMP01,COLIMP02,COLIMP03,COLIMP04,COLIMP05,COLIMP06,COLIMP07,COLIMP08,COLIMP09,COLIMP10,COLIMP11,    
    COLIMP12,COLIMP13,COLIMP14,COLIMP15,COLIMP16,COLIMP17,COLIMP18,COLIMP19,COLIMP20    
 )  
 SELECT RPTNAME,SYSTEM_USER,RPTID,TipoReporte,NumeroDeOrden,IDGRIMP,DSCRIPTN,AWLI_DOCUMENT_STATE,DOCTYPE,DOCNUMBR,    
   VCHRNMBR,DOCDATE,GLPOSTDT,CUSTVNDR,CUSTNAME,TXRGNNUM,SLSAMNT,TRDISAMT,FRTAMNT,MISCAMNT,TAXAMNT,DOCAMNT,    
   Void,DOCID,AWLI_DOCTYPEDESC,VOIDDATE,CURNCYID,    
   COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,    
   COL12,COL13,COL14,COL15,COL16,COL17,COL18,COL19,COL20  
 FROM  TL_RS_ReporteImpuestos_SM(3,'', '')    
 WHERE ( dbo.TL_RS_EliminateSalesRecs  
   ( TL_RS_ReporteImpuestos_SM.DOCNUMBR,  
    TL_RS_ReporteImpuestos_SM.DOCTYPE, TL_RS_ReporteImpuestos_SM.CUSTVNDR,  
    TL_RS_ReporteImpuestos_SM.DOCID, TL_RS_ReporteImpuestos_SM.CURNCYID,  
    TL_RS_ReporteImpuestos_SM.DOCDATE, TL_RS_ReporteImpuestos_SM.Void  
   )<> 0 ) AND  
    TL_RS_ReporteImpuestos_SM.Void <> 1  
  
  
 INSERT @SICOAR (RPRTNAME, RPTID, [Report Type], DOCNUMBR, SICOAR_CODE, DOCDATE,   
     CUSTVNDR, ISIB, [Taxpayer ID], AMOUNT)  
 SELECT TEMP.RPRTNAME, TEMP.RPTID, TEMP.[Report Type], TEMP.DOCNUMBR, TEMP.[Sicoar Code], TEMP.DOCDATE, TEMP.CUSTVNDR,   
  TEMP.ISIB, TEMP.CUIT,  
  CASE TEMP.COL_POS  
   WHEN 1 THEN TEMP.COLIMP01  
   WHEN 2 THEN TEMP.COLIMP02  
   WHEN 3 THEN TEMP.COLIMP03  
   WHEN 4 THEN TEMP.COLIMP04  
   WHEN 5 THEN TEMP.COLIMP05  
   WHEN 6 THEN TEMP.COLIMP06  
   WHEN 7 THEN TEMP.COLIMP07  
   WHEN 8 THEN TEMP.COLIMP08  
   WHEN 9 THEN TEMP.COLIMP09  
   WHEN 10 THEN TEMP.COLIMP10  
   WHEN 11 THEN TEMP.COLIMP11  
   WHEN 12 THEN TEMP.COLIMP12  
   WHEN 13 THEN TEMP.COLIMP13  
   WHEN 14 THEN TEMP.COLIMP14  
   WHEN 15 THEN TEMP.COLIMP15  
   WHEN 16 THEN TEMP.COLIMP16  
   WHEN 17 THEN TEMP.COLIMP17  
   WHEN 18 THEN TEMP.COLIMP18  
   WHEN 19 THEN TEMP.COLIMP19  
   WHEN 20 THEN TEMP.COLIMP20     
  END  
 FROM   
 (  
  SELECT  A.TAXDTLID, A.RPRTNAME, A.USERID, A.RPTID, A.TipoReporte, A.NumeroDeOrden, A.IDGRIMP, A.DSCRIPTN,   
    A.AWLI_DOCUMENT_STATE, A.DOCTYPE, A.DOCNUMBR, A.VCHRNMBR, A.DOCDATE, A.GLPOSTDT, A.CUSTVNDR, A.CUSTNAME,   
    A.TXRGNNUM, A.SLSAMNT, A.TRDISAMT, A.FRTAMNT, A.MISCAMNT, A.TAXAMNT,   
    A.DOCAMNT, A.Void,   
    A.DOCID, A.AWLI_DOCTYPEDESC, A.VOIDDATE, A.CURNCYID, A.COLIMP01, A.COLIMP02, A.COLIMP03, A.COLIMP04, A.COLIMP05, A.COLIMP06,   
    A.COLIMP07, A.COLIMP08, A.COLIMP09,   
    A.COLIMP10, A.COLIMP11, A.COLIMP12,   
    A.COLIMP13, A.COLIMP14, A.COLIMP15, A.COLIMP16, A.COLIMP17, A.COLIMP18, A.COLIMP19, A.COLIMP20,  
    dbo.TL_RS_SICOAR_PERPos(A.TAXDTLID, A.RPTID) AS COL_POS,   
    dbo.TL_RS_SICOAR_PERSetSicoarCode(A.TAXDTLID, A.RPRTNAME,A.DOCDATE,A.CUSTVNDR,A.DOCTYPE,A.DOCNUMBR) AS [Sicoar Code],  
    'Reverse Withholds' AS "Report Type",  
    CASE B.From_Customer_ISIB  
     WHEN 1 THEN SUBSTRING(C.USERDEF1, 1, 10)  
     WHEN 2 THEN SUBSTRING(C.USERDEF2, 1, 10)  
     WHEN 3 THEN SUBSTRING(C.COMMENT1, 1, 10)  
     WHEN 4 THEN SUBSTRING(C.COMMENT2, 1, 10)  
     WHEN 5 THEN SUBSTRING(C.TAXEXMT1, 1, 10)  
     WHEN 6 THEN SUBSTRING(C.TAXEXMT2, 1, 10)  
    END "ISIB",  
    dbo.TL_RS_FormatCuit(dbo.TL_RS_Set_Field_Format(A.TXRGNNUM,'RIGHT','0',11)) "CUIT"    
  FROM    (  
     SELECT A.TAXDTLID, C.RPRTNAME,SYSTEM_USER AS USERID,C.RPTID,C.TipoReporte,C.NumeroDeOrden,C.IDGRIMP,C.DSCRIPTN,  
       C.AWLI_DOCUMENT_STATE,C.DOCTYPE,C.DOCNUMBR,    
       C.VCHRNMBR,C.DOCDATE,C.GLPOSTDT,C.CUSTVNDR,C.CUSTNAME,C.TXRGNNUM,C.SLSAMNT,C.TRDISAMT,C.FRTAMNT,  
       C.MISCAMNT,C.TAXAMNT,C.DOCAMNT,    
       C.Void,C.DOCID,C.AWLI_DOCTYPEDESC,C.VOIDDATE,C.CURNCYID,    
       C.COLIMP01,C.COLIMP02,C.COLIMP03,C.COLIMP04,C.COLIMP05,C.COLIMP06,C.COLIMP07,C.COLIMP08,C.COLIMP09,C.COLIMP10,C.COLIMP11,    
       C.COLIMP12,C.COLIMP13,C.COLIMP14,C.COLIMP15,C.COLIMP16,C.COLIMP17,C.COLIMP18,C.COLIMP19,C.COLIMP20  
     FROM nfRFC_TX00201 A   
     INNER JOIN RM10601 B ON A.TAXDTLID = B.TAXDTLID    
     INNER JOIN @TEMP_AWLI50003 AS C ON B.RMDTYPAL = C.DOCTYPE and B.DOCNUMBR = C.DOCNUMBR   
     INNER JOIN AWLI_RM00101 D ON D.CUSTNMBR = C.CUSTVNDR   
     WHERE A.CLASS in(1,5)  and   
       C.DOCTYPE <> 7 AND   
       D.GrossIncomeStatus <> 4      
    ) AS A  
  INNER JOIN TLSIC10100 B ON A.RPRTNAME = B.RPRTNAME  
  INNER JOIN RM00101 C ON A.CUSTVNDR = C.CUSTNMBR  
 ) AS TEMP  
  
  
 DECLARE @TEMP2 TABLE   
 (  
  RPRTNAME CHAR(31), RPTID CHAR (15), IDTAXOP CHAR(21), NRORDCOL SMALLINT, SICOAR_CODE CHAR (3)  
 )  
  
  
 INSERT INTO @TEMP2 (RPRTNAME, RPTID, IDTAXOP, NRORDCOL, SICOAR_CODE)  
 SELECT C.RPRTNAME, D.RPTID, A.IDTAXOP, A.NRORDCOL, E.SICOAR_CODE  
 FROM TLRS10100 C  
 INNER JOIN TLSIC10100 D ON (C.RPTID = 'SICOAR' AND D.RPRTNAME = C.RPRTNAME)  
 INNER JOIN TLRS10203 A ON A.RPTID = D.RPTID  
 INNER JOIN  AWLI40102 B ON A.IDTAXOP= B.IDTAXOP  
 INNER JOIN TLSIC00200 E ON (D.RPRTNAME = E.RPRTNAME AND B.IDTAXOP = E.IDTAXOP)  
 group by C.RPRTNAME, D.RPTID, A.IDTAXOP,A.NRORDCOL, E.SICOAR_CODE having count(*) > 1  
  
  
  
 INSERT @SICOAR (RPRTNAME, RPTID, [Report Type], DOCNUMBR, SICOAR_CODE, DOCDATE,   
     CUSTVNDR, ISIB, [Taxpayer ID], AMOUNT)  
 SELECT TEMP.RPRTNAME, TEMP.RPTID, TEMP.[Report Type], TEMP.DOCNUMBR, TEMP.SICOAR_CODE,  
   TEMP.DOCDATE, TEMP.CUSTVNDR, TEMP.ISIB, TEMP.CUIT,  
  CASE TEMP.NRORDCOL  
   WHEN 1 THEN TEMP.COLIMP04  
   WHEN 2 THEN TEMP.COLIMP04  
   WHEN 3 THEN TEMP.COLIMP04  
   WHEN 4 THEN TEMP.COLIMP04  
   WHEN 5 THEN TEMP.COLIMP04  
   WHEN 6 THEN TEMP.COLIMP04  
   WHEN 7 THEN TEMP.COLIMP04  
   WHEN 8 THEN TEMP.COLIMP04  
   WHEN 9 THEN TEMP.COLIMP04  
   WHEN 10 THEN TEMP.COLIMP10  
   WHEN 11 THEN TEMP.COLIMP11  
   WHEN 12 THEN TEMP.COLIMP12  
   WHEN 13 THEN TEMP.COLIMP13  
   WHEN 14 THEN TEMP.COLIMP14  
   WHEN 15 THEN TEMP.COLIMP15  
   WHEN 16 THEN TEMP.COLIMP16  
   WHEN 17 THEN TEMP.COLIMP17  
   WHEN 18 THEN TEMP.COLIMP18  
   WHEN 19 THEN TEMP.COLIMP19  
   WHEN 20 THEN TEMP.COLIMP20   
  END AS [Perceptions Amount]    
 FROM  
 (  
  SELECT A.RPRTNAME, A.RPTID, A.DOCDATE, A.CUSTVNDR, A.DOCTYPE, A.DOCNUMBR,  
    A.COLIMP01, A.COLIMP02, A.COLIMP03, A.COLIMP04, A.COLIMP05, A.COLIMP06, A.COLIMP07, A.COLIMP08, A.COLIMP09,  
    A.COLIMP10, A.COLIMP11, A.COLIMP12, A.COLIMP13, A.COLIMP14, A.COLIMP15, A.COLIMP16, A.COLIMP17, A.COLIMP18,  
    A.COLIMP19, A.COLIMP20, C.IDTAXOP, C.NRORDCOL,  
    'Reverse Withholds' AS "Report Type",  
    CASE E.From_Customer_ISIB  
     WHEN 1 THEN SUBSTRING(D.USERDEF1, 1, 10)  
     WHEN 2 THEN SUBSTRING(D.USERDEF2, 1, 10)  
     WHEN 3 THEN SUBSTRING(D.COMMENT1, 1, 10)  
     WHEN 4 THEN SUBSTRING(D.COMMENT2, 1, 10)  
     WHEN 5 THEN SUBSTRING(D.TAXEXMT1, 1, 10)  
     WHEN 6 THEN SUBSTRING(D.TAXEXMT2, 1, 10)  
    END "ISIB",  
    dbo.TL_RS_FormatCuit(dbo.TL_RS_Set_Field_Format(A.TXRGNNUM,'RIGHT','0',11)) "CUIT",  
    CASE C.SICOAR_CODE    
     WHEN '' THEN '000'  
     WHEN NULL THEN '000'  
     ELSE C.SICOAR_CODE  
    END AS SICOAR_CODE  
  FROM @TEMP_AWLI50003  A   
  INNER JOIN @TEMP2 C ON (C.RPRTNAME = A.RPRTNAME AND C.RPTID = A.RPTID)  
  INNER JOIN AWLI_RM00101 B ON A.CUSTVNDR = B.CUSTNMBR   
  INNER JOIN RM00101 D ON A.CUSTVNDR = D.CUSTNMBR   
  INNER JOIN TLSIC10100 E ON A.RPRTNAME = E.RPRTNAME  
  WHERE A.DOCTYPE <> 7 AND   
    B.GrossIncomeStatus <> 4   
 ) AS TEMP  
 ORDER BY TEMP.DOCDATE  
  
  
 INSERT @SICOAR (RPRTNAME, RPTID, [Report Type], DOCNUMBR, SICOAR_CODE, DOCDATE,   
     CUSTVNDR, ISIB, [Taxpayer ID], AMOUNT)  
 SELECT RS_HDR.RPRTNAME, '', 'Withholds' AS "Report Type", R.DOCNUMBR, RS_SIC_RTN_STP.SICOAR_CODE, R.nfRET_Fec_Retencion,     
   R.VENDORID,  
   CASE RS_SIC_STP.From_Vendor_ISIB  
    WHEN 1 THEN dbo.TL_RS_Set_Field_Format(V.USERDEF1,'RIGHT',' ',10)  
    WHEN 2 THEN dbo.TL_RS_Set_Field_Format(V.USERDEF2,'RIGHT',' ',10)  
    WHEN 3 THEN dbo.TL_RS_Set_Field_Format(V.COMMENT1,'RIGHT',' ',10)   
    WHEN 4 THEN dbo.TL_RS_Set_Field_Format(V.COMMENT2,'RIGHT',' ',10)   
    WHEN 5 THEN dbo.TL_RS_Set_Field_Format(V.TXIDNMBR,'RIGHT',' ',10)   
    WHEN 6 THEN dbo.TL_RS_Set_Field_Format(V.ACNMVNDR,'RIGHT',' ',10)   
   END "ISIB",  
   dbo.TL_RS_FormatCuit(dbo.TL_RS_Set_Field_Format(V.TXRGNNUM,'RIGHT','0',11)) "Taxpayer ID", R.nfRET_Importe_Retencion  
 FROM TLRS10100 RS_HDR   
 INNER JOIN TLSIC10100 RS_SIC_STP ON (RS_HDR.RPRTNAME = RS_SIC_STP.RPRTNAME AND RS_SIC_STP.Retenciones = 1)  
 INNER JOIN TLSIC00100 RS_SIC_RTN_STP ON RS_SIC_STP.RPRTNAME = RS_SIC_RTN_STP.RPRTNAME  
 INNER JOIN nfRET_GL10020 R ON RS_SIC_RTN_STP.ID_Retencion = R.nfRET_Retencion_ID   
 INNER JOIN PM00200 V ON R.VENDORID = V.VENDORID  
 INNER JOIN AWLI_PM00200 A ON R.VENDORID = A.VENDORID  
 WHERE R.nfRET_Fec_Retencion >= RS_SIC_STP.STRTDATE AND   
   R.nfRET_Fec_Retencion <= RS_SIC_STP.ENDDATE AND  
   R.nfRET_Importe_Retencion <> 0 AND GrossIncomeStatus <> 4 AND   
   RS_HDR.RPTID = 'SICOAR'  
 ORDER BY RS_HDR.RPRTNAME, V.TXRGNNUM  
  
RETURN  
END  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_SICOAR_REPORT_TL_WITH_TAX]  TO [DYNGRP]
GO
/*End_TL_RS_SICOAR_REPORT_TL_WITH_TAX*/
/*Begin_TL_RS_SICOAR_REPORT_TL_WITHOUT_TAX*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SICOAR_REPORT_TL_WITHOUT_TAX' and type = 'TF')
DROP FUNCTION TL_RS_SICOAR_REPORT_TL_WITHOUT_TAX
GO

CREATE FUNCTION TL_RS_SICOAR_REPORT_TL_WITHOUT_TAX ()  
RETURNS @SICOAR TABLE   
(  
RPRTNAME CHAR(31),   
RPTID CHAR(15),   
[Report Type] VARCHAR(20),  
DOCNUMBR CHAR(21),   
SICOAR_CODE CHAR(3),   
DOCDATE DATETIME,   
CUSTVNDR CHAR(15),  
ISIB VARCHAR(10),  
[Taxpayer ID] VARCHAR(15),  
AMOUNT NUMERIC(19, 5),  
IDENTIFICATION INT IDENTITY (1,1)  
)  
AS  
BEGIN  
  
 DECLARE @TEMP_AWLI50003 TABLE   
 (  
 RPRTNAME CHAR(31), USERID CHAR(50), RPTID CHAR(15), TipoReporte SMALLINT, NumeroDeOrden SMALLINT, IDGRIMP CHAR(15),   
 DSCRIPTN CHAR(31), AWLI_DOCUMENT_STATE CHAR(5), DOCTYPE SMALLINT, DOCNUMBR CHAR(21),  
 VCHRNMBR CHAR(21), DOCDATE DATETIME, GLPOSTDT DATETIME, CUSTVNDR CHAR(15), CUSTNAME CHAR(65),  
 TXRGNNUM CHAR(25), SLSAMNT NUMERIC(19,5), TRDISAMT NUMERIC(19,5), FRTAMNT NUMERIC(19,5),  
 MISCAMNT NUMERIC(19,5), TAXAMNT NUMERIC(19,5), DOCAMNT NUMERIC(19,5), Void TINYINT, DOCID CHAR(15),  
 AWLI_DOCTYPEDESC CHAR(7), VOIDDATE DATETIME, CURNCYID CHAR(15), CNTRLLR TINYINT, LETRA SMALLINT,  
 PDV CHAR(5), FROM_NMBR CHAR(9), TO_NMBR CHAR(9), RESP_TYPE CHAR(3), COD_COMP CHAR(3),  
 CUST_CODE CHAR(3), DEST_CODE CHAR(5), NRO_DESP CHAR(7), DIGVERIF_NRODESP CHAR(1), CAI CHAR(31),  
 TO_DT DATETIME, CURR_CODE CHAR(3), T_CAMBIO NUMERIC(19,7), OP_ORIGIN SMALLINT,   
 COLIMP01 NUMERIC(19,5), COLIMP02 NUMERIC(19,5), COLIMP03 NUMERIC(19,5), COLIMP04 NUMERIC(19,5),   
 COLIMP05 NUMERIC(19,5), COLIMP06 NUMERIC(19,5), COLIMP07 NUMERIC(19,5), COLIMP08 NUMERIC(19,5),  
 COLIMP09 NUMERIC(19,5), COLIMP10 NUMERIC(19,5), COLIMP11 NUMERIC(19,5), COLIMP12 NUMERIC(19,5),  
 COLIMP13 NUMERIC(19,5), COLIMP14 NUMERIC(19,5), COLIMP15 NUMERIC(19,5), COLIMP16 NUMERIC(19,5),  
 COLIMP17 NUMERIC(19,5), COLIMP18 NUMERIC(19,5), COLIMP19 NUMERIC(19,5), COLIMP20 NUMERIC(19,5)  
 )  
  
  INSERT @TEMP_AWLI50003  
 (     
    RPRTNAME,USERID,RPTID,TipoReporte,NumeroDeOrden,IDGRIMP,DSCRIPTN,AWLI_DOCUMENT_STATE,DOCTYPE,DOCNUMBR,    
    VCHRNMBR,DOCDATE,GLPOSTDT,CUSTVNDR,CUSTNAME,TXRGNNUM,SLSAMNT,TRDISAMT,FRTAMNT,MISCAMNT,TAXAMNT,DOCAMNT,    
    Void,DOCID,AWLI_DOCTYPEDESC,VOIDDATE,CURNCYID,    
    COLIMP01,COLIMP02,COLIMP03,COLIMP04,COLIMP05,COLIMP06,COLIMP07,COLIMP08,COLIMP09,COLIMP10,COLIMP11,    
    COLIMP12,COLIMP13,COLIMP14,COLIMP15,COLIMP16,COLIMP17,COLIMP18,COLIMP19,COLIMP20    
 )  
 SELECT RPTNAME,SYSTEM_USER,TL_RS_ReporteImpuestos_SM.RPTID,TL_RS_ReporteImpuestos_SM.TipoReporte,NumeroDeOrden,IDGRIMP,TL_RS_ReporteImpuestos_SM.DSCRIPTN,AWLI_DOCUMENT_STATE,DOCTYPE,DOCNUMBR,    
   VCHRNMBR,DOCDATE,GLPOSTDT,CUSTVNDR,CUSTNAME,TXRGNNUM,SLSAMNT,TRDISAMT,FRTAMNT,MISCAMNT,ISNULL((TAXAMNT),0) AS TAXAMNT ,DOCAMNT,    
   Void,DOCID,AWLI_DOCTYPEDESC,VOIDDATE,CURNCYID,    
   COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11,    
   COL12,COL13,COL14,COL15,COL16,COL17,COL18,COL19,COL20  
 FROM  TL_RS_ReporteImpuestos_SM(3,'', 'TAXVALIDATION') 
 INNER JOIN TLRS10101 ON TL_RS_ReporteImpuestos_SM.RPTID = TLRS10101.RPTID
 WHERE ( dbo.TL_RS_EliminateSalesRecs  
   ( TL_RS_ReporteImpuestos_SM.DOCNUMBR,  
    TL_RS_ReporteImpuestos_SM.DOCTYPE, TL_RS_ReporteImpuestos_SM.CUSTVNDR,  
    TL_RS_ReporteImpuestos_SM.DOCID, TL_RS_ReporteImpuestos_SM.CURNCYID,  
    TL_RS_ReporteImpuestos_SM.DOCDATE, TL_RS_ReporteImpuestos_SM.Void  
   )<> 0 ) AND  
    TL_RS_ReporteImpuestos_SM.Void <> 1 AND
    TLRS10101.TL_WITHOUT_TAX = 1 
  
  
 INSERT @SICOAR (RPRTNAME, RPTID, [Report Type], DOCNUMBR, SICOAR_CODE, DOCDATE,   
     CUSTVNDR, ISIB, [Taxpayer ID], AMOUNT)  
 SELECT TEMP.RPRTNAME, TEMP.RPTID, TEMP.[Report Type], TEMP.DOCNUMBR, TEMP.[Sicoar Code], TEMP.DOCDATE, TEMP.CUSTVNDR,   
  TEMP.ISIB, TEMP.CUIT,     
  CASE TEMP.COL_POS  
   WHEN 0 THEN 0
   WHEN 1 THEN TEMP.COLIMP01  
   WHEN 2 THEN TEMP.COLIMP02  
   WHEN 3 THEN TEMP.COLIMP03  
   WHEN 4 THEN TEMP.COLIMP04  
   WHEN 5 THEN TEMP.COLIMP05  
   WHEN 6 THEN TEMP.COLIMP06  
   WHEN 7 THEN TEMP.COLIMP07  
   WHEN 8 THEN TEMP.COLIMP08  
   WHEN 9 THEN TEMP.COLIMP09  
   WHEN 10 THEN TEMP.COLIMP10  
   WHEN 11 THEN TEMP.COLIMP11  
   WHEN 12 THEN TEMP.COLIMP12  
   WHEN 13 THEN TEMP.COLIMP13  
   WHEN 14 THEN TEMP.COLIMP14  
   WHEN 15 THEN TEMP.COLIMP15  
   WHEN 16 THEN TEMP.COLIMP16  
   WHEN 17 THEN TEMP.COLIMP17  
   WHEN 18 THEN TEMP.COLIMP18  
   WHEN 19 THEN TEMP.COLIMP19  
   WHEN 20 THEN TEMP.COLIMP20       
  END  
 FROM   
 (  
  SELECT  A.TAXDTLID, A.RPRTNAME, A.USERID, A.RPTID, A.TipoReporte, A.NumeroDeOrden, A.IDGRIMP, A.DSCRIPTN,   
    A.AWLI_DOCUMENT_STATE, A.DOCTYPE, A.DOCNUMBR, A.VCHRNMBR, A.DOCDATE, A.GLPOSTDT, A.CUSTVNDR, A.CUSTNAME,   
    A.TXRGNNUM, A.SLSAMNT, A.TRDISAMT, A.FRTAMNT, A.MISCAMNT, ISNULL((A.TAXAMNT),0) AS TAXAMNT,   
    A.DOCAMNT, A.Void,   
    A.DOCID, A.AWLI_DOCTYPEDESC, A.VOIDDATE, A.CURNCYID, A.COLIMP01, A.COLIMP02, A.COLIMP03, A.COLIMP04, A.COLIMP05, A.COLIMP06,   
    A.COLIMP07, A.COLIMP08, A.COLIMP09,   
    A.COLIMP10, A.COLIMP11, A.COLIMP12,   
    A.COLIMP13, A.COLIMP14, A.COLIMP15, A.COLIMP16, A.COLIMP17, A.COLIMP18, A.COLIMP19, A.COLIMP20,  
    '0' AS COL_POS,
	'000' AS [Sicoar Code],  
    'Reverse Withholds' AS "Report Type",  
    CASE B.From_Customer_ISIB  
     WHEN 1 THEN SUBSTRING(C.USERDEF1, 1, 10)  
     WHEN 2 THEN SUBSTRING(C.USERDEF2, 1, 10)  
     WHEN 3 THEN SUBSTRING(C.COMMENT1, 1, 10)  
     WHEN 4 THEN SUBSTRING(C.COMMENT2, 1, 10)  
     WHEN 5 THEN SUBSTRING(C.TAXEXMT1, 1, 10)  
     WHEN 6 THEN SUBSTRING(C.TAXEXMT2, 1, 10)  
    END "ISIB",  
    dbo.TL_RS_FormatCuit(dbo.TL_RS_Set_Field_Format(A.TXRGNNUM,'RIGHT','0',11)) "CUIT"    
  FROM    (  
     SELECT '' AS TAXDTLID, C.RPRTNAME,SYSTEM_USER AS USERID,C.RPTID,C.TipoReporte,C.NumeroDeOrden,C.IDGRIMP,C.DSCRIPTN,  
       C.AWLI_DOCUMENT_STATE,C.DOCTYPE,C.DOCNUMBR,    
       C.VCHRNMBR,C.DOCDATE,C.GLPOSTDT,C.CUSTVNDR,C.CUSTNAME,C.TXRGNNUM,C.SLSAMNT,C.TRDISAMT,C.FRTAMNT,  
       C.MISCAMNT,ISNULL((C.TAXAMNT),0) AS TAXAMNT ,C.DOCAMNT,    
       C.Void,C.DOCID,C.AWLI_DOCTYPEDESC,C.VOIDDATE,C.CURNCYID,    
       C.COLIMP01,C.COLIMP02,C.COLIMP03,C.COLIMP04,C.COLIMP05,C.COLIMP06,C.COLIMP07,C.COLIMP08,C.COLIMP09,C.COLIMP10,C.COLIMP11,    
       C.COLIMP12,C.COLIMP13,C.COLIMP14,C.COLIMP15,C.COLIMP16,C.COLIMP17,C.COLIMP18,C.COLIMP19,C.COLIMP20  
     FROM RM20101 A 
     INNER JOIN @TEMP_AWLI50003 AS C ON A.DOCNUMBR = C.DOCNUMBR   
     INNER JOIN AWLI_RM00101 D ON D.CUSTNMBR = C.CUSTVNDR   
     WHERE   
       C.DOCTYPE <> 7 AND C.TAXAMNT = 0 AND  
       D.GrossIncomeStatus <> 4   AND
	   A.DOCNUMBR NOT IN (SELECT DOCNUMBR FROM RM10601)
	) AS A  
  INNER JOIN TLSIC10100 B ON A.RPRTNAME = B.RPRTNAME  
  INNER JOIN RM00101 C ON A.CUSTVNDR = C.CUSTNMBR  
 ) AS TEMP  
RETURN  
END  


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_SICOAR_REPORT_TL_WITHOUT_TAX]  TO [DYNGRP]
GO
/*End_TL_RS_SICOAR_REPORT_TL_WITHOUT_TAX*/
/*Begin_TL_RS_SIFERE_TaxAmt_WithTax*/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SIFERE_TaxAmt_WithTax' and type = 'FN')
DROP FUNCTION TL_RS_SIFERE_TaxAmt_WithTax;
GO

CREATE FUNCTION TL_RS_SIFERE_TaxAmt_WithTax (@RPRTNAME CHAR(31), @IDTAXOP CHAR(21), @VCHRNMBR CHAR(21), @DocStatus CHAR(5))  
RETURNS NUMERIC(19,5)  
AS  
BEGIN  
 IF @DocStatus = 'OPEN'   
 RETURN  
  (  
  SELECT    SUM(F.TAXAMNT) AS [Perceptions Amount]  
  FROM TLSF10200 D  
  INNER JOIN AWLI40102 B ON (D.IDTAXOP = B.IDTAXOP AND (D.RPRTNAME = @RPRTNAME AND D.IDTAXOP = @IDTAXOP))  
  INNER JOIN nfRFC_TX00201 A ON B.TAXDTLID = A.TAXDTLID  
  INNER JOIN PM10500 F ON (A.TAXDTLID = F.TAXDTLID AND F.VCHRNMBR = @VCHRNMBR)  
  WHERE A.CLASS = 5  
  )  
  
 ELSE IF @DocStatus = 'HIST'  
  RETURN  
  (  
  SELECT    SUM(F.TAXAMNT) AS [Perceptions Amount]  
  FROM TLSF10200 D  
  INNER JOIN AWLI40102 B ON (D.IDTAXOP = B.IDTAXOP AND (D.RPRTNAME = @RPRTNAME AND D.IDTAXOP = @IDTAXOP))  
  INNER JOIN nfRFC_TX00201 A ON B.TAXDTLID = A.TAXDTLID  
  INNER JOIN PM30700 F ON (A.TAXDTLID = F.TAXDTLID AND F.VCHRNMBR = @VCHRNMBR)  
  WHERE A.CLASS = 5    
  )  
  
RETURN NULL  
END  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_SIFERE_TaxAmt_WithTax]  TO [DYNGRP]
GO
/*End_TL_RS_SIFERE_TaxAmt_WithTax*/
/*Begin_TL_RS_SIFERE_TaxAmt_WithOutTax*/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SIFERE_TaxAmt_WithOutTax' and type = 'FN')
DROP FUNCTION TL_RS_SIFERE_TaxAmt_WithOutTax;
GO
CREATE FUNCTION TL_RS_SIFERE_TaxAmt_WithOutTax (@RPRTNAME CHAR(31), @IDTAXOP CHAR(21), @VCHRNMBR CHAR(21)
, @DocStatus CHAR(5), @TAXAMNT NUMERIC(19,5))  
RETURNS NUMERIC(19,5)  
AS  
BEGIN  
 IF @DocStatus = 'OPEN'
 BEGIN
	IF @TAXAMNT <> 0   
	RETURN  
	(  
	  SELECT SUM(F.TAXAMNT) AS [Perceptions Amount]  
		  FROM TLSF10200 D  
		  INNER JOIN AWLI40102 B ON (D.IDTAXOP = B.IDTAXOP AND (D.RPRTNAME = @RPRTNAME AND D.IDTAXOP = @IDTAXOP))   
		  INNER JOIN nfRFC_TX00201 A ON B.TAXDTLID = A.TAXDTLID  
		  INNER JOIN PM10500 F ON (A.TAXDTLID = F.TAXDTLID AND F.VCHRNMBR = @VCHRNMBR)  
		  WHERE A.CLASS = 5 
	)   
	IF @TAXAMNT = 0 
	RETURN  
	(  
		 SELECT ISNULL(SUM(F.TAXAMNT),0) AS [Perception Amount] FROM TLSF10200 D 
		 INNER JOIN AWLI40102 B ON (D.IDTAXOP = B.IDTAXOP AND (D.RPRTNAME = @RPRTNAME AND D.IDTAXOP = @IDTAXOP))     
		 LEFT OUTER JOIN nfRFC_TX00201 A ON B.TAXDTLID = A.TAXDTLID  
		 LEFT OUTER JOIN PM10500 F ON (F.VCHRNMBR =@VCHRNMBR) 
		 INNER JOIN PM20000 G ON G.VCHRNMBR =  @VCHRNMBR
		 WHERE G.TAXAMNT = 0 AND A.CLASS = 5   GROUP BY D.SIFERECode  
	)  
 END
 ELSE IF @DocStatus = 'HIST' 
 BEGIN 
	IF @TAXAMNT <> 0 
	RETURN  
	(
		  SELECT   SUM(F.TAXAMNT)  AS [Perceptions Amount]  
		  FROM TLSF10200 D  
		  INNER JOIN AWLI40102 B ON (D.IDTAXOP = B.IDTAXOP AND (D.RPRTNAME = @RPRTNAME AND D.IDTAXOP = @IDTAXOP))   
		  INNER JOIN nfRFC_TX00201 A ON B.TAXDTLID = A.TAXDTLID  
		  INNER JOIN PM30700 F ON (A.TAXDTLID = F.TAXDTLID AND F.VCHRNMBR = @VCHRNMBR)  
		  WHERE A.CLASS = 5    
	) 
	IF @TAXAMNT = 0 
	RETURN  
	(
		 SELECT ISNULL(SUM(F.TAXAMNT),0) AS [Perception Amount] FROM TLSF10200 D 
		 INNER JOIN AWLI40102 B ON (D.IDTAXOP = B.IDTAXOP AND (D.RPRTNAME = @RPRTNAME AND D.IDTAXOP = @IDTAXOP))     
		 LEFT OUTER JOIN nfRFC_TX00201 A ON B.TAXDTLID = A.TAXDTLID  
		 LEFT OUTER JOIN PM30700 F ON (F.VCHRNMBR =@VCHRNMBR) 
		 INNER JOIN PM30200 G ON G.VCHRNMBR =  @VCHRNMBR
		 WHERE G.TAXAMNT = 0 AND A.CLASS = 5   GROUP BY D.SIFERECode    
	)  
 END
RETURN NULL  
END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_SIFERE_TaxAmt_WithOutTax]  TO [DYNGRP]
GO
/*End_TL_RS_SIFERE_TaxAmt_WithOutTax*/
/*Begin_TL_RS_SIFEREREPORT*/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_SIFEREREPORT' and type = 'TF')
DROP FUNCTION TL_RS_SIFEREREPORT;
GO
CREATE FUNCTION TL_RS_SIFEREREPORT()     
RETURNS @TempTableSIFERE TABLE  
(  
 RPTNAME    char(30),  
 RPTID    char(15),  
 CUSTVNDR   char(15),   
 CUSTNAME   char(65),   
 TXRGNNUM   char(25), 
 Letra char(1),  
 PDV char(10),  
 From_No char(21),     
 DOCNUMBR   char(21),      
 VCHRNMBR   char(21),   
 DOCDATE    datetime,
 AWLI_DOCUMENT_STATE char(5), 
 DOCID    char(15),  
 CAI char(31),  
 AWLI_DOCTYPEDESC char(7), 
 SIFERECode char(3),
 DOCAMNT    numeric(19,5),  
 SLSAMNT    numeric(19,5),      
 TRDISAMT   numeric(19,5),      
 FRTAMNT    numeric(19,5),      
 MISCAMNT   numeric(19,5),      
 TAXAMNT    numeric(19,5),  
 PERCEPAMT    numeric(19,5),  
 IDTAXOP CHAR(21),
 NRORDCOL smallint,
 PrimKey  bigint  
   
)   
BEGIN

INSERT INTO @TempTableSIFERE
SELECT    RPTNAME AS [Report Name], RPTID AS [Report ID], CUSTVNDR AS [Customer ID], CUSTNAME AS [Customer Name], TXRGNNUM AS TaxRegNo, Letra, 
                      PDV AS [Point of Sale], From_No AS [Document No], DOCNUMBR AS [Document No Complete], VCHRNMBR AS [Voucher No], 
                      DOCDATE AS [Document Date], AWLI_DOCUMENT_STATE AS [Document Status], DOCID AS [Document ID], CAI AS [CAI Series], 
                      AWLI_DOCTYPEDESC AS [Document Type Description], SIFERECode AS [Jurisdiction Code], DOCAMNT AS [Document Amount], 
                      SLSAMNT AS [Sales Amount], TRDISAMT AS [Trade Discount Amount], FRTAMNT AS [Freight Amount], MISCAMNT AS [Misceleneous Amount], 
                      TAXAMNT AS [Document Tax Amount], [Perceptions Amount], IDTAXOP AS [Tax Column ID], NRORDCOL, PrimKey
FROM         (SELECT    B.RPTNAME, B.RPTID, 'Purchase' AS 'Report Type', A.SIFERECode, A.IDTAXOP, B.TXRGNNUM, B.DOCDATE, 
                                              TL_RS_PurchaseReqValues_1.PDV, TL_RS_PurchaseReqValues_1.From_No, B.AWLI_DOCUMENT_STATE, 
                                              B.DOCTYPE AS [Document Type], B.DOCNUMBR, B.VCHRNMBR, B.GLPOSTDT, B.CUSTVNDR, B.CUSTNAME, B.SLSAMNT, B.TRDISAMT, 
                                              B.FRTAMNT, B.MISCAMNT, B.TAXAMNT, B.DOCAMNT, B.Void AS [Void Status], B.DOCID, B.AWLI_DOCTYPEDESC, 
                                              B.VOIDDATE AS [Void Date], B.CURNCYID AS [Currency ID], TL_RS_PurchaseReqValues_1.Letra, TL_RS_PurchaseReqValues_1.To_No, 
                                              TL_RS_PurchaseReqValues_1.COD_COMP AS [Codigo Comprobante], TL_RS_PurchaseReqValues_1.CUST_CODE AS [Customer Code], 
                                              TL_RS_PurchaseReqValues_1.DEST_CODE AS [Destination Code], TL_RS_PurchaseReqValues_1.CAI, 
                                              TL_RS_PurchaseReqValues_1.CURR_CODE AS [Currency Code], TL_RS_PurchaseReqValues_1.CNTRLLR, 
                                              TL_RS_PurchaseReqValues_1.OP_ORIGIN, B.NumeroDeOrden, TL_RS_PurchaseReqValues_1.RESP_TYPE, 
                                              TL_RS_PurchaseReqValues_1.T_CAMBIO, TL_RS_PurchaseReqValues_1.TO_DT, TL_RS_PurchaseReqValues_1.DIGVERIF_NRODESP, 
                                              TL_RS_PurchaseReqValues_1.NRO_DESP, B.DSCRIPTN, B.TipoReporte, 
											  TL_RS_PurchaseReqValues_1.Letra_Value, B.IDGRIMP, 
                                              B.PrimKey, A.NRORDCOL, B.COL01, B.COL02, B.COL03, B.COL04, B.COL05, B.COL06, B.COL07, B.COL08, B.COL09, B.COL10, B.COL11, 
                                              B.COL12, B.COL13, B.COL14, B.COL15, B.COL16, B.COL17, B.COL18, B.COL19, B.COL20, B.USERID AS [User ID], 
                                              CASE WHEN B.DOCTYPE = 4 OR
                                              B.DOCTYPE = 5 THEN dbo.TL_RS_SIFERE_TaxAmt(B.RPTNAME, A.IDTAXOP, B.VCHRNMBR, B.AWLI_DOCUMENT_STATE,B.RPTID, B.TAXAMNT) 
                                              * - 1 ELSE dbo.TL_RS_SIFERE_TaxAmt(B.RPTNAME, A.IDTAXOP, B.VCHRNMBR, B.AWLI_DOCUMENT_STATE,B.RPTID, B.TAXAMNT) 
                                              END AS [Perceptions Amount]
                       FROM          TL_RS_SIFEREPerceptionsView AS B INNER JOIN
                                              dbo.TL_RS_PurchaseReqValues(3) AS TL_RS_PurchaseReqValues_1 ON B.PrimKey = TL_RS_PurchaseReqValues_1.primkey INNER JOIN

                                              AWLI_PM00200 AS C ON B.CUSTVNDR = C.VENDORID INNER JOIN
                                              TLSF10200 AS A ON B.RPTNAME = A.RPRTNAME
                       WHERE      (B.DOCTYPE <> 7) 
AND (TL_RS_PurchaseReqValues_1.PDV <> '') 
AND (B.DOCTYPE <> 8) 
AND (C.GrossIncomeStatus <> 4)
) 
                      AS TEMP
WHERE     ([Perceptions Amount] IS NOT NULL)
RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[TL_RS_SIFEREREPORT]  TO [DYNGRP]
GO
/*End_TL_RS_SIFEREREPORT*/
/*Begin_TL_RS_Get_WITHOUT_TAX*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where name = 'TL_RS_Get_WITHOUT_TAX' and type = 'FN')
DROP FUNCTION TL_RS_Get_WITHOUT_TAX
GO

CREATE FUNCTION TL_RS_Get_WITHOUT_TAX(@IN_RPTID char(15))  
RETURNS INT
BEGIN
DECLARE @TL_WITHOUT_TAX int
	SELECT @TL_WITHOUT_TAX = TL_WITHOUT_TAX FROM TLRS10101  WHERE RPTID = @IN_RPTID
	RETURN @TL_WITHOUT_TAX
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[TL_RS_Get_WITHOUT_TAX]  TO [DYNGRP]
GO
/*End_TL_RS_Get_WITHOUT_TAX*/
/*Begin_TL_RS_CitiSales_RMHIST*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_CitiSales_RMHIST]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_CitiSales_RMHIST]
GO

CREATE VIEW [dbo].[TL_RS_CitiSales_RMHIST]
AS
select * from TL_RS_CitiSalesRMHIST()

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_CitiSales_RMHIST]  TO [DYNGRP] 
GO 

/*End_TL_RS_CitiSales_RMHIST*/
/*Begin_TL_RS_CitiSales_RMOPEN*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_CitiSales_RMOPEN]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_CitiSales_RMOPEN]
GO

CREATE VIEW [dbo].[TL_RS_CitiSales_RMOPEN]
AS
select * from TL_RS_CitiSalesRMOPEN()

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_CitiSales_RMOPEN]  TO [DYNGRP] 
GO 

/*End_TL_RS_CitiSales_RMOPEN*/
/*Begin_TL_RS_CitiSales_RMWORK*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_CitiSales_RMWORK]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_CitiSales_RMWORK]
GO

CREATE VIEW [dbo].[TL_RS_CitiSales_RMWORK]
AS
select * from TL_RS_CitiSalesRMWORK()

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_CitiSales_RMWORK]  TO [DYNGRP] 
GO 

/*End_TL_RS_CitiSales_RMWORK*/
/*Begin_TL_RS_CitiSales_SOPWORK*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_CitiSales_SOPWORK]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_CitiSales_SOPWORK]
GO

CREATE VIEW [dbo].[TL_RS_CitiSales_SOPWORK]
AS
select * from TL_RS_CitiSalesSOPWORK()

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_CitiSales_SOPWORK]  TO [DYNGRP] 
GO 

/*End_TL_RS_CitiSales_SOPWORK*/
/*Begin_sirft_withholding_view*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sirft_withholding_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[sirft_withholding_view]
GO

create view sirft_withholding_view as
select * from TLRS_Sirft_WithHoldings()

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[sirft_withholding_view]  TO [DYNGRP] 
GO 

/*End_sirft_withholding_view*/