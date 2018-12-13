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
/*Begin_TL_RS_CitiPurchase_PURCH*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_CitiPurchase_PURCH]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_CitiPurchase_PURCH]
GO

CREATE VIEW TL_RS_CitiPurchase_PURCH
AS
SELECT RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE, DOCTYPE, DOCNUMBR, VCHRNMBR, DOCDATE, 
 GLPOSTDT, CUSTVNDR, CUSTNAME, SUBSTRING (TXRGNNUM,1,11) 'Tax Number', SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, 
 AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID, OPERATION, COL01, COL02, COL03, COL04, COL05, COL06, COL07, COL08, COL09, COL10, COL11, 
 COL12, COL13, COL14, COL15, COL16, COL17, COL18, COL19, COL20, PrimKey, 'Purchase' AS 'Report Type'
FROM TL_RS_ReporteImpuestos_SM(6, 'sa', 'TAXVALIDATION')
WHERE dbo.TL_RS_CITIPurchase_ValoresLibros_PURCH
 (
 TL_RS_ReporteImpuestos_SM.CURNCYID, 
 TL_RS_ReporteImpuestos_SM.DOCDATE, 
 TL_RS_ReporteImpuestos_SM.VCHRNMBR, 
 TL_RS_ReporteImpuestos_SM.DOCTYPE, 
 TL_RS_ReporteImpuestos_SM.CUSTVNDR, 
 TL_RS_ReporteImpuestos_SM.DOCNUMBR, 
 TL_RS_ReporteImpuestos_SM.Void
 )<>0
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_CitiPurchase_PURCH]  TO [DYNGRP] 
GO 

/*End_TL_RS_CitiPurchase_PURCH*/
/*Begin_TL_RS_CitiPurchase_PURCHValues*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_CitiPurchase_PURCHValues]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_CitiPurchase_PURCHValues]
GO

CREATE VIEW TL_RS_CitiPurchase_PURCHValues
AS
SELECT * FROM dbo.TL_RS_CitiPurchaseReqValues(1)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_CitiPurchase_PURCHValues]  TO [DYNGRP] 
GO 

/*End_TL_RS_CitiPurchase_PURCHValues*/
/*Begin_TL_RS_CitiPurchase_SALES*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_CitiPurchase_SALES]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_CitiPurchase_SALES]
GO

CREATE VIEW TL_RS_CitiPurchase_SALES AS
SELECT PrimKey, RPTNAME,SYSTEM_USER 'USERID' ,RPTID,TipoReporte,NumeroDeOrden,IDGRIMP,DSCRIPTN,AWLI_DOCUMENT_STATE,DOCTYPE, 
 DOCNUMBR,VCHRNMBR,DOCDATE,GLPOSTDT,CUSTVNDR,CUSTNAME,
 dbo.TL_RS_TaxNumber(TXRGNNUM) 'Tax Number',
 SLSAMNT,TRDISAMT,FRTAMNT,MISCAMNT,TAXAMNT,DOCAMNT, 
 Void,DOCID,AWLI_DOCTYPEDESC,VOIDDATE,CURNCYID, 
 COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11, 
 COL12,COL13,COL14,COL15,COL16,COL17,COL18,COL19,COL20, 'Sales' as 'Report Type'
 FROM  TL_RS_ReporteImpuestos_SM(7,'', 'TAXVALIDATION') 
 WHERE ( dbo.TL_RS_CitiPurchase_EliminateSalesRecs
 ( TL_RS_ReporteImpuestos_SM.DOCNUMBR,
 TL_RS_ReporteImpuestos_SM.DOCTYPE, TL_RS_ReporteImpuestos_SM.CUSTVNDR,
 TL_RS_ReporteImpuestos_SM.DOCID, TL_RS_ReporteImpuestos_SM.CURNCYID,
 TL_RS_ReporteImpuestos_SM.DOCDATE, TL_RS_ReporteImpuestos_SM.Void
 )<> 0 )
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_CitiPurchase_SALES]  TO [DYNGRP] 
GO 

/*End_TL_RS_CitiPurchase_SALES*/
/*Begin_TL_RS_CitiPurchase_SALESValues*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_CitiPurchase_SALESValues]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_CitiPurchase_SALESValues]
GO

CREATE VIEW TL_RS_CitiPurchase_SALESValues AS
SELECT * FROM TL_RS_GetSalesReqValues(1)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_CitiPurchase_SALESValues]  TO [DYNGRP] 
GO 

/*End_TL_RS_CitiPurchase_SALESValues*/
/*Begin_TL_RS_RG1361_PurchaseUnmarkView*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_RG1361_PurchaseUnmarkView]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_RG1361_PurchaseUnmarkView]
GO

create view TL_RS_RG1361_PurchaseUnmarkView as 
select * from [TL_RS_ReporteImpuestos](5,'sa','TAXVALIDATION')

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_RG1361_PurchaseUnmarkView]  TO [DYNGRP] 
GO 

/*End_TL_RS_RG1361_PurchaseUnmarkView*/
/*Begin_TL_RS_RG1361_PurchaseView*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_RG1361_PurchaseView]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_RG1361_PurchaseView]
GO

create view TL_RS_RG1361_PurchaseView as
select * from TL_RS_ReporteImpuestos_SM(5,'sa','TAXVALIDATION')
where dbo.[TL_RS_PurchaseEliminateRecs](
CURNCYID,DOCDATE,VCHRNMBR,DOCTYPE,CUSTVNDR,DOCNUMBR,Void)<>0
AND TL_RS_ReporteImpuestos_SM.Void <> 1
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_RG1361_PurchaseView]  TO [DYNGRP] 
GO 

/*End_TL_RS_RG1361_PurchaseView*/
/*Begin_TL_RS_RG1361_SalesUnmarkView*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_RG1361_SalesUnmarkView]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_RG1361_SalesUnmarkView]
GO

create view TL_RS_RG1361_SalesUnmarkView as 
select * from [TL_RS_ReporteImpuestos](4,'sa','TAXVALIDATION')
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_RG1361_SalesUnmarkView]  TO [DYNGRP] 
GO 

/*End_TL_RS_RG1361_SalesUnmarkView*/
/*Begin_TL_RS_RG1361_SalesView*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_RG1361_SalesView]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_RG1361_SalesView]
GO

create view TL_RS_RG1361_SalesView as
select * from TL_RS_ReporteImpuestos_SM(4,'sa','TAXVALIDATION')
AS TL_RS_ReporteImpuestos_SM_1
where dbo.TL_RS_EliminateSalesRecs(TL_RS_ReporteImpuestos_SM_1.DOCNUMBR, TL_RS_ReporteImpuestos_SM_1.DOCTYPE, 
 TL_RS_ReporteImpuestos_SM_1.CUSTVNDR, TL_RS_ReporteImpuestos_SM_1.DOCID,TL_RS_ReporteImpuestos_SM_1.CURNCYID, TL_RS_ReporteImpuestos_SM_1.DOCDATE, 
 TL_RS_ReporteImpuestos_SM_1.Void) <> 0
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_RG1361_SalesView]  TO [DYNGRP] 
GO 

/*End_TL_RS_RG1361_SalesView*/
/*Begin_TL_RS_Sirft_Rev_Whold_ReqValues*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_Sirft_Rev_Whold_ReqValues]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_Sirft_Rev_Whold_ReqValues]
GO

create view TL_RS_Sirft_Rev_Whold_ReqValues 
as select * from [TL_RS_GetSalesReqValues](3)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_Sirft_Rev_Whold_ReqValues]  TO [DYNGRP] 
GO 

/*End_TL_RS_Sirft_Rev_Whold_ReqValues*/
/*Begin_TL_RS_Sirft_Rev_Whold_View*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_Sirft_Rev_Whold_View]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_Sirft_Rev_Whold_View]
GO

CREATE VIEW TL_RS_Sirft_Rev_Whold_View AS   
SELECT * FROM [TL_RS_ReporteImpuestos_SM](10,'','SIRFT') AS TL_RS_ReporteImpuestos_SM_1 
WHERE ((dbo.TL_RS_Get_WITHOUT_TAX(TL_RS_ReporteImpuestos_SM_1.RPTID)= 0 AND COL02 <> 0 AND
dbo.TL_RS_EliminateSalesRecs(TL_RS_ReporteImpuestos_SM_1.DOCNUMBR, TL_RS_ReporteImpuestos_SM_1.DOCTYPE,   
 TL_RS_ReporteImpuestos_SM_1.CUSTVNDR, TL_RS_ReporteImpuestos_SM_1.DOCID,TL_RS_ReporteImpuestos_SM_1.CURNCYID, TL_RS_ReporteImpuestos_SM_1.DOCDATE,   
 TL_RS_ReporteImpuestos_SM_1.Void) <> 0  ) OR (dbo.TL_RS_Get_WITHOUT_TAX(TL_RS_ReporteImpuestos_SM_1.RPTID)= 1  AND
dbo.TL_RS_EliminateSalesRecs(TL_RS_ReporteImpuestos_SM_1.DOCNUMBR, TL_RS_ReporteImpuestos_SM_1.DOCTYPE,   
 TL_RS_ReporteImpuestos_SM_1.CUSTVNDR, TL_RS_ReporteImpuestos_SM_1.DOCID,TL_RS_ReporteImpuestos_SM_1.CURNCYID, TL_RS_ReporteImpuestos_SM_1.DOCDATE,   
 TL_RS_ReporteImpuestos_SM_1.Void) <> 0  ))
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_Sirft_Rev_Whold_View]  TO [DYNGRP] 
GO 
/*End_TL_RS_Sirft_Rev_Whold_View*/
/*Begin_TL_RS_IVA_Sales_View*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_IVA_Sales_View]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_IVA_Sales_View]
GO

create view TL_RS_IVA_Sales_View as
select PrimKey, RPTNAME,SYSTEM_USER 'USERID' ,RPTID,TipoReporte,NumeroDeOrden,IDGRIMP,DSCRIPTN,AWLI_DOCUMENT_STATE,DOCTYPE, 
 DOCNUMBR,VCHRNMBR,DOCDATE,GLPOSTDT,CUSTVNDR,CUSTNAME,
 TXRGNNUM ,
 SLSAMNT,TRDISAMT,FRTAMNT,MISCAMNT,TAXAMNT,DOCAMNT, 
 Void,DOCID,AWLI_DOCTYPEDESC,VOIDDATE,CURNCYID, 
 COL01,COL02,COL03,COL04,COL05,COL06,COL07,COL08,COL09,COL10,COL11, 
 COL12,COL13,COL14,COL15,COL16,COL17,COL18,COL19,COL20, 'Sales' as 'Report Type'
from [TL_RS_ReporteImpuestos_SM](11,'','TAXVALIDATION')
 WHERE ( dbo.TL_RS_EliminateSalesRecs( TL_RS_ReporteImpuestos_SM.DOCNUMBR,
 TL_RS_ReporteImpuestos_SM.DOCTYPE, TL_RS_ReporteImpuestos_SM.CUSTVNDR,
 TL_RS_ReporteImpuestos_SM.DOCID, TL_RS_ReporteImpuestos_SM.CURNCYID,
 TL_RS_ReporteImpuestos_SM.DOCDATE, TL_RS_ReporteImpuestos_SM.Void
 )<> 0)
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_IVA_Sales_View]  TO [DYNGRP] 
GO 

/*End_TL_RS_IVA_Sales_View*/
/*Begin_TL_RS_PurchaseView*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_PurchaseView]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_PurchaseView]
GO

create view TL_RS_PurchaseView as
select PrimKey, SYSTEM_USER as USERID,RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE, DOCTYPE, DOCNUMBR, VCHRNMBR, 
                      DOCDATE, GLPOSTDT, CUSTVNDR, CUSTNAME, TXRGNNUM, SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, 
                      AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID, OPERATION, COL01, COL02, COL03, COL04, COL05, COL06, COL07, COL08, COL09, COL10, COL11, 
                      COL12, COL13, COL14, COL15, COL16, COL17, COL18, COL19, COL20 from TL_RS_ReporteImpuestos_SM(12,'sa','TAXVALIDATION')
where dbo.TL_RS_PurchaseEliminateRecs
(
 TL_RS_ReporteImpuestos_SM.CURNCYID, 
 TL_RS_ReporteImpuestos_SM.DOCDATE, 
 TL_RS_ReporteImpuestos_SM.VCHRNMBR, 
 TL_RS_ReporteImpuestos_SM.DOCTYPE, 
 TL_RS_ReporteImpuestos_SM.CUSTVNDR, 
 TL_RS_ReporteImpuestos_SM.DOCNUMBR, 
 TL_RS_ReporteImpuestos_SM.Void
 )<>0
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_PurchaseView]  TO [DYNGRP] 
GO 

/*End_TL_RS_PurchaseView*/
/*Begin_TL_RS_SIFEREPerceptionsView*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_SIFEREPerceptionsView]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_SIFEREPerceptionsView]
GO

create view TL_RS_SIFEREPerceptionsView as
select PrimKey, SYSTEM_USER as USERID,RPTNAME, RPTID, TipoReporte, NumeroDeOrden, IDGRIMP, DSCRIPTN, AWLI_DOCUMENT_STATE, DOCTYPE, DOCNUMBR, VCHRNMBR, 
                      DOCDATE, GLPOSTDT, CUSTVNDR, CUSTNAME, TXRGNNUM, SLSAMNT, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, DOCAMNT, Void, DOCID, 
                      AWLI_DOCTYPEDESC, VOIDDATE, CURNCYID, OPERATION, COL01, COL02, COL03, COL04, COL05, COL06, COL07, COL08, COL09, COL10, COL11, 
                      COL12, COL13, COL14, COL15, COL16, COL17, COL18, COL19, COL20 
from TL_RS_ReporteImpuestos_SM(13,'sa','')
where dbo.TL_RS_PurchaseEliminateRecs
(
 TL_RS_ReporteImpuestos_SM.CURNCYID, 
 TL_RS_ReporteImpuestos_SM.DOCDATE, 
 TL_RS_ReporteImpuestos_SM.VCHRNMBR, 
 TL_RS_ReporteImpuestos_SM.DOCTYPE, 
 TL_RS_ReporteImpuestos_SM.CUSTVNDR, 
 TL_RS_ReporteImpuestos_SM.DOCNUMBR, 
 TL_RS_ReporteImpuestos_SM.Void
 )<>0
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_SIFEREPerceptionsView]  TO [DYNGRP] 
GO 

/*End_TL_RS_SIFEREPerceptionsView*/
/*Begin_TL_RS_SIFERE_RetentionsView*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TL_RS_SIFERE_RetentionsView]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[TL_RS_SIFERE_RetentionsView]
GO

CREATE VIEW dbo.TL_RS_SIFERE_RetentionsView
AS 

SELECT	TEMP_JOIN.RPRTNAME AS [Report Name], D.TXRGNNUM AS [Tax Registration No], B.EMIDATE AS [Retention Date], 
		B.DOCNUMBR AS [Cash Receipt No], B.MEDIOID AS [Means ID], TEMP_JOIN.SIFERECode AS [Jurisdiction Code], E.APTODCNM AS [Sales Document No],
		CASE E.APTODCTY
			WHEN 1 THEN 'F'
			WHEN 3 THEN 'D'
			WHEN 7 THEN 'C'
			WHEN NULL THEN ' '
			ELSE 'O'
		END AS [Document Type],
		B.LINEAMNT AS [Retention Amount]
FROM nfMCP20000 C
INNER JOIN nfMCP20100 B ON (C.MCPTYPID = B.MCPTYPID AND C.NUMBERIE = B.NUMBERIE)
INNER JOIN (	SELECT F.RPRTNAME, H.MEDIOID, H.SIFERECode, G.STRTDATE, ENDDATE 
				FROM TLRS10100 F 
				INNER JOIN TLSF10100 G ON (F.RPRTNAME = G.RPRTNAME AND F.RPRTNAME <> 'XYZ123')
				INNER JOIN TLSF10201 H ON G.RPRTNAME = H.RPRTNAME
			) TEMP_JOIN ON B.MEDIOID = TEMP_JOIN.MEDIOID
INNER JOIN RM00101 D ON C.NFENTID = D.CUSTNMBR
LEFT OUTER JOIN RM20201 E ON C.NUMBERIE = E.APFRDCNM
WHERE	(B.EMIDATE >= TEMP_JOIN.STRTDATE) AND 
		(B.EMIDATE <= TEMP_JOIN.ENDDATE) AND 
		(B.LINEAMNT <> 0) AND
		(C.VOIDSTTS <> 1)

UNION ALL


SELECT	TEMP_JOIN.RPRTNAME AS [Report Name], D.TXRGNNUM AS [Tax Registration No], B.EMIDATE AS [Retention Date], 
		B.DOCNUMBR AS [Cash Receipt No], B.MEDIOID AS [Means ID], TEMP_JOIN.SIFERECode AS [Jurisdiction Code], E.APTODCNM AS [Sales Document No],
		CASE E.APTODCTY
			WHEN 1 THEN 'F'
			WHEN 3 THEN 'D'
			WHEN 7 THEN 'C'
			WHEN NULL THEN ' '
			ELSE 'O'
		END AS [Document Type],
		B.LINEAMNT AS [Retention Amount]
FROM nfMCP30000 C
INNER JOIN nfMCP30100 B ON (C.MCPTYPID = B.MCPTYPID AND C.NUMBERIE = B.NUMBERIE)
INNER JOIN (	SELECT F.RPRTNAME, H.MEDIOID, H.SIFERECode, G.STRTDATE, ENDDATE 
				FROM TLRS10100 F 
				INNER JOIN TLSF10100 G ON (F.RPRTNAME = G.RPRTNAME AND F.RPRTNAME <> 'XYZ123')
				INNER JOIN TLSF10201 H ON G.RPRTNAME = H.RPRTNAME
			) TEMP_JOIN ON B.MEDIOID = TEMP_JOIN.MEDIOID
INNER JOIN RM00101 D ON C.NFENTID = D.CUSTNMBR
LEFT OUTER JOIN RM30201 E ON C.NUMBERIE = E.APFRDCNM
WHERE	(B.EMIDATE >= TEMP_JOIN.STRTDATE) AND 
		(B.EMIDATE <= TEMP_JOIN.ENDDATE) AND 
		(B.LINEAMNT <> 0) AND
		(C.VOIDSTTS <> 1)



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[TL_RS_SIFERE_RetentionsView]  TO [DYNGRP] 
GO
