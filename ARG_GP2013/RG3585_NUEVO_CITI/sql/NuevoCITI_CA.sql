USE [ARG10]
GO

/****** Object:  StoredProcedure [dbo].[NuevoCITI_CA]    Script Date: 04/25/2019 14:49:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Object:  Stored Procedure dbo.NuevoCITI_CA    Script Date: 14/6/2015 12:34:37 PM ******/

CREATE PROCEDURE[dbo].[NuevoCITI_CA] @PERIODO CHAR(6), @REPORTE CHAR(15), @NOGRAVADO tinyint
AS

CREATE TABLE #TEMP
	(
		VCHRNMBR CHAR(21),
		DOCTYPE SMALLINT,
		VENDORID CHAR(15),
		DOCNUMBR CHAR(21),
		TRXDSCRN CHAR(31),
		PORDNMBR CHAR(21),
		DOCDATE datetime,
		COMPTYPE CHAR(3),
		PDV CHAR(6),
		NROCOMP CHAR(20),
		DESPACHO CHAR(16),
		CODDOC CHAR(2),
		NROIDENT	CHAR(20),
		NOMBRE	CHAR(30),
		TOTAL	NUMERIC(19, 5),
		GRAV NUMERIC(19, 5),
		NOGRAV	NUMERIC(19, 5),
		PERCNOCAT NUMERIC(19, 5),
		EXENTO	NUMERIC(19, 5),
		PERCIVA	NUMERIC(19, 5),
		PERCNAC	NUMERIC(19, 5),
		PERCIIBB	NUMERIC(19, 5),
		PERCMUN	NUMERIC(19, 5),
		IMPINT	NUMERIC(19, 5),
		MONEDA	CHAR(3),
		CAMBIO	NUMERIC(19, 7),
		ALICUOTAS	INT,
		CODOPER	CHAR(1),
		CREDFISC	NUMERIC(19, 5),
		OTROSTRIB NUMERIC(19, 5),
		ERRORES CHAR(500)
	)

CREATE TABLE #TEMP2
	(
		VCHRNMBR CHAR(21),
		DOCTYPE SMALLINT,
		VENDORID CHAR(15),
		GRAVADO21 NUMERIC(19, 5),
		IVA21 NUMERIC(19, 5),
		GRAVADO105 NUMERIC(19, 5),
		IVA105 NUMERIC(19, 5),
		GRAVADO27 NUMERIC(19, 5),
		IVA27	NUMERIC(19, 5)
	)

INSERT INTO #TEMP
SELECT A.VCHRNMBR, A.DOCTYPE, A.VENDORID, ISNULL(AW.AWLI_DocNumber, TRX.DOCNUMBR) DOCNUMBR, TRX.TRXDSCRN, TRX.PORDNMBR, TRX.DOCDATE, '0' + ISNULL(AW.COD_COMP, '00') COMTYPE, CASE WHEN ISNULL(AW.COD_COMP, '00') <> '66' THEN RIGHT('00000' + ISNULL(RTRIM(SUBSTRING(AW.AWLI_DocNumber, 5, 5)), '00000'), 5) ELSE '00000' END PDV,
CASE WHEN ISNULL(AW.COD_COMP, '00') <> '66' THEN RIGHT(REPLICATE('0', 20) + ISNULL(RTRIM(SUBSTRING(AW.AWLI_DocNumber, 11, 8)), '0000'), 20) ELSE REPLICATE('0', 20) END NROCOMP, 
CASE WHEN ISNULL(AW.COD_COMP, '00') <> '66' THEN REPLICATE(' ', 16) ELSE RTRIM(LEFT(TRX.DOCNUMBR, 16)) + REPLICATE(' ', 16 - LEN(RTRIM(LEFT(TRX.DOCNUMBR, 16)))) END NRODESPACHO,
RIGHT('00' + CASE WHEN RIGHT(ISNULL(MP.TXRGNNUM, '00'), 2) = '  ' THEN '80' ELSE RIGHT(ISNULL(MP.TXRGNNUM, '00'), 2) END, 2) CODCOC, 
RIGHT(REPLICATE('0', 20) + CASE WHEN LEFT(ISNULL(MP.TXRGNNUM, '00000000000'), 11) = '           ' THEN '00000000000' ELSE LEFT(ISNULL(MP.TXRGNNUM, '00000000000'), 11) END, 20) NROIDENT,
LEFT(RTRIM(MP.VENDNAME) + REPLICATE(' ', 30), 30) NOMBRE, TRX.DOCAMNT,
SUM(CASE WHEN CI.ColumnaArchivo = 1 THEN TDTTXPUR ELSE 0 END) GRAV,
SUM(CASE WHEN CI.ColumnaArchivo = 4 THEN TDTTXPUR ELSE 0 END) NOGRAV, 
SUM(CASE WHEN CI.ColumnaArchivo = 5 THEN A.TAXAMNT ELSE 0 END) PERCNOCAT, 
SUM(CASE WHEN CI.ColumnaArchivo = 3 THEN TDTTXPUR ELSE 0 END) EXENTO, 
SUM(CASE WHEN CI.ColumnaArchivo = 6 THEN A.TAXAMNT ELSE 0 END) PERCIVA,
SUM(CASE WHEN CI.ColumnaArchivo = 7 THEN A.TAXAMNT ELSE 0 END) PIMPNAC,
SUM(CASE WHEN CI.ColumnaArchivo = 8 THEN A.TAXAMNT ELSE 0 END) PIIBB,
SUM(CASE WHEN CI.ColumnaArchivo = 9 THEN A.TAXAMNT ELSE 0 END) PERCMUN, 
SUM(CASE WHEN CI.ColumnaArchivo = 10 THEN A.TAXAMNT ELSE 0 END) IMPINT, MC.CURR_CODE MONEDA, ISNULL(MC1.XCHGRATE, 1) TCAMBIO, 0 ALICUOTAS, CONVERT(VARCHAR, ISNULL(AW.OP_ORIGIN, 0)) CODOPER, 
SUM(CASE WHEN CI.ColumnaArchivo = 2 THEN A.TAXAMNT ELSE 0 END) CREDFISC, 
SUM(CASE WHEN CI.ColumnaArchivo = 11 THEN A.TAXAMNT ELSE 0 END) OTROSTRIB
, '' ERRORES

FROM PM10500 A
INNER JOIN PM20000 TRX ON A.VCHRNMBR = TRX.VCHRNMBR AND A.DOCTYPE = TRX.DOCTYPE
INNER JOIN AWLI_PM00400 AW ON A.VCHRNMBR = AW.VCHRNMBR AND A.DOCTYPE = AW.DOCTYPE AND A.VENDORID = AW.VENDORID
INNER JOIN PM00200 MP ON A.VENDORID = MP.VENDORID
INNER JOIN DYNAMICS..AWLI_MC40200 MC ON TRX.CURNCYID = MC.CURNCYID
INNER JOIN
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLDSC FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where rptid IN(@REPORTE)	 ) TX ON A.TAXDTLID = TX.TAXDTLID
INNER JOIN TX00201 B ON TX.TAXDTLID = B.TAXDTLID
INNER JOIN tblColumnasIVA CI ON TX.RPTID = CI.RPTID AND TX.NRORDCOL = CI.NRORDCOL
LEFT OUTER JOIN MC020103 MC1 ON A.VCHRNMBR = MC1.VCHRNMBR AND A.DOCTYPE = MC1.DOCTYPE AND A.VENDORID = MC1.VENDORID
WHERE TRX.VOIDED = 0 and left(CONVERT(char(8), TRX.PSTGDATE, 112), 6) = @PERIODO AND CI.TipoReporte = 1
GROUP BY A.VENDORID, TRX.DOCNUMBR, TRX.TRXDSCRN, TRX.PORDNMBR, TRX.DOCDATE, TRX.PSTGDATE, A.VCHRNMBR, A.DOCTYPE, TRX.DOCAMNT, AW.COD_COMP, AW.AWLI_DocNumber, MP.TXRGNNUM,
MP.VENDNAME, MC.CURR_CODE, AW.OP_ORIGIN, ISNULL(MC1.XCHGRATE, 1), ISNULL(AW.NRO_DESP, '') 

INSERT INTO #TEMP
SELECT A.VCHRNMBR, A.DOCTYPE, A.VENDORID, ISNULL(AW.AWLI_DocNumber, TRX.DOCNUMBR) DOCNUMBR, TRX.TRXDSCRN, TRX.PORDNMBR, TRX.DOCDATE, '0' + ISNULL(AW.COD_COMP, '00') COMTYPE, CASE WHEN ISNULL(AW.COD_COMP, '00') <> '66' THEN RIGHT('00000' + ISNULL(RTRIM(SUBSTRING(AW.AWLI_DocNumber, 5, 5)), '0000'), 5) ELSE '00000' END PDV,
CASE WHEN ISNULL(AW.COD_COMP, '00') <> '66' THEN RIGHT(REPLICATE('0', 20) + ISNULL(RTRIM(SUBSTRING(AW.AWLI_DocNumber, 11, 8)), '0000'), 20) ELSE REPLICATE('0', 20) END NROCOMP, 
CASE WHEN ISNULL(AW.COD_COMP, '00') <> '66' THEN REPLICATE(' ', 16) ELSE RTRIM(LEFT(TRX.DOCNUMBR, 16)) + REPLICATE(' ', 16 - LEN(RTRIM(LEFT(TRX.DOCNUMBR, 16)))) END NRODESPACHO,
RIGHT('00' + CASE WHEN RIGHT(ISNULL(MP.TXRGNNUM, '00'), 2) = '  ' THEN '80' ELSE RIGHT(ISNULL(MP.TXRGNNUM, '00'), 2) END, 2) CODCOC, 
RIGHT(REPLICATE('0', 20) + CASE WHEN LEFT(ISNULL(MP.TXRGNNUM, '00000000000'), 11) = '           ' THEN '00000000000' ELSE LEFT(ISNULL(MP.TXRGNNUM, '00000000000'), 11) END, 20) NROIDENT,
LEFT(RTRIM(MP.VENDNAME) + REPLICATE(' ', 30), 30) NOMBRE, TRX.DOCAMNT,
SUM(CASE WHEN CI.ColumnaArchivo = 1 THEN TDTTXPUR ELSE 0 END) GRAV,
SUM(CASE WHEN CI.ColumnaArchivo = 4 THEN TDTTXPUR ELSE 0 END) NOGRAV, 
SUM(CASE WHEN CI.ColumnaArchivo = 5 THEN A.TAXAMNT ELSE 0 END) PERCNOCAT, 
SUM(CASE WHEN CI.ColumnaArchivo = 3 THEN TDTTXPUR ELSE 0 END) EXENTO, 
SUM(CASE WHEN CI.ColumnaArchivo = 6 THEN A.TAXAMNT ELSE 0 END) PERCIVA,
SUM(CASE WHEN CI.ColumnaArchivo = 7 THEN A.TAXAMNT ELSE 0 END) PIMPNAC,
SUM(CASE WHEN CI.ColumnaArchivo = 8 THEN A.TAXAMNT ELSE 0 END) PIIBB,
SUM(CASE WHEN CI.ColumnaArchivo = 9 THEN A.TAXAMNT ELSE 0 END) PERCMUN, 
SUM(CASE WHEN CI.ColumnaArchivo = 10 THEN A.TAXAMNT ELSE 0 END) IMPINT, MC.CURR_CODE MONEDA, ISNULL(MC1.XCHGRATE, 1) TCAMBIO, 0 ALICUOTAS, CONVERT(VARCHAR, ISNULL(AW.OP_ORIGIN, 0)) CODOPER, 
SUM(CASE WHEN CI.ColumnaArchivo = 2 THEN A.TAXAMNT ELSE 0 END) CREDFISC, 
SUM(CASE WHEN CI.ColumnaArchivo = 11 THEN A.TAXAMNT ELSE 0 END) OTROSTRIB
, '' ERRORES

FROM PM30700 A
INNER JOIN PM30200 TRX ON A.VCHRNMBR = TRX.VCHRNMBR AND A.DOCTYPE = TRX.DOCTYPE
INNER JOIN AWLI_PM00400 AW ON A.VCHRNMBR = AW.VCHRNMBR AND A.DOCTYPE = AW.DOCTYPE AND A.VENDORID = AW.VENDORID
INNER JOIN PM00200 MP ON A.VENDORID = MP.VENDORID
INNER JOIN DYNAMICS..AWLI_MC40200 MC ON TRX.CURNCYID = MC.CURNCYID
INNER JOIN
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLDSC FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where rptid IN(@REPORTE)	 ) TX ON A.TAXDTLID = TX.TAXDTLID
INNER JOIN TX00201 B ON TX.TAXDTLID = B.TAXDTLID
INNER JOIN tblColumnasIVA CI ON TX.RPTID = CI.RPTID AND TX.NRORDCOL = CI.NRORDCOL
LEFT OUTER JOIN MC020103 MC1 ON A.VCHRNMBR = MC1.VCHRNMBR AND A.DOCTYPE = MC1.DOCTYPE AND A.VENDORID = MC1.VENDORID
WHERE (TRX.VOIDED = 0 OR (TRX.VOIDED = 1 AND LEFT(CONVERT(CHAR(8), TRX.PSTGDATE, 112), 6) <> LEFT(CONVERT(CHAR(8), TRX.VOIDPDATE, 112), 6))) and left(CONVERT(char(8), TRX.PSTGDATE, 112), 6) = @PERIODO
AND CI.TipoReporte = 1
GROUP BY A.VENDORID, TRX.DOCNUMBR, TRX.TRXDSCRN, TRX.PORDNMBR, TRX.DOCDATE, TRX.PSTGDATE, A.VCHRNMBR, A.DOCTYPE, TRX.DOCAMNT, AW.COD_COMP, AW.AWLI_DocNumber, MP.TXRGNNUM,
MP.VENDNAME, MC.CURR_CODE, AW.OP_ORIGIN, ISNULL(MC1.XCHGRATE, 1), ISNULL(AW.NRO_DESP, '') 

UPDATE #TEMP
SET ALICUOTAS = TX.ALICUOTAS
FROM #TEMP A
INNER JOIN (SELECT VCHRNMBR, DOCTYPE, VENDORID, COUNT(TXDTLPCT) ALICUOTAS FROM
(SELECT DISTINCT A.VCHRNMBR, A.DOCTYPE, A.VENDORID, TX.TXDTLPCT FROM PM10500 A INNER JOIN
AWLI40102 B ON A.TAXDTLID = B.TAXDTLID INNER JOIN AWLI40004 C ON B.IDTAXOP = C.IDTAXOP
INNER JOIN tblColumnasIVA CI ON C.RPTID = CI.RPTID AND C.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 TX ON A.TAXDTLID = TX.TAXDTLID
WHERE C.RPTID IN(@REPORTE) AND CI.TipoReporte = 1 AND CI.ColumnaArchivo = 2 AND A.TAXAMNT > 0 
) PCT
GROUP BY VCHRNMBR, DOCTYPE, VENDORID ) TX ON A.VCHRNMBR = TX.VCHRNMBR AND A.DOCTYPE = TX.DOCTYPE AND A.VENDORID = TX.VENDORID

UPDATE #TEMP
SET ALICUOTAS = TX.ALICUOTAS
FROM #TEMP A
INNER JOIN (SELECT VCHRNMBR, DOCTYPE, VENDORID, COUNT(TXDTLPCT) ALICUOTAS FROM
(SELECT DISTINCT A.VCHRNMBR, A.DOCTYPE, A.VENDORID, TX.TXDTLPCT FROM PM30700 A INNER JOIN
AWLI40102 B ON A.TAXDTLID = B.TAXDTLID INNER JOIN AWLI40004 C ON B.IDTAXOP = C.IDTAXOP
INNER JOIN tblColumnasIVA CI ON C.RPTID = CI.RPTID AND C.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 TX ON A.TAXDTLID = TX.TAXDTLID
WHERE C.RPTID IN(@REPORTE) AND CI.TipoReporte = 1 AND CI.ColumnaArchivo = 2 AND A.TAXAMNT > 0
) PCT
GROUP BY VCHRNMBR, DOCTYPE, VENDORID) TX ON A.VCHRNMBR = TX.VCHRNMBR AND A.DOCTYPE = TX.DOCTYPE AND A.VENDORID = TX.VENDORID

UPDATE #TEMP SET NROIDENT = CASE WHEN ISNULL(RTRIM(MP.CUIT_Pais), '') = '' THEN A.NROIDENT ELSE RIGHT(REPLICATE('0', 20) + RTRIM(SUBSTRING(MP.CUIT_Pais, 1, 11)), 20) END
FROM #TEMP A LEFT OUTER JOIN AWLI_PM00200 MP ON A.VENDORID = MP.VENDORID

UPDATE #TEMP SET CODDOC = RIGHT('80' + RTRIM(PORDNMBR), 2), NROIDENT = RIGHT(REPLICATE('0', 20) + RTRIM(LEFT(PORDNMBR, 11)), 20),
CODOPER = 1, NOMBRE = TRXDSCRN
FROM #TEMP A INNER JOIN PM00200 B ON A.VENDORID = B.VENDORID
WHERE B.VNDCLSID IN(SELECT VNDCLSID FROM TII_CHQ_SY40000)

UPDATE #TEMP SET GRAV = GRAVADO
FROM #TEMP T INNER JOIN 
(SELECT A.VCHRNMBR, A.DOCTYPE, A.VENDORID, SUM(ROUND(B.TAXAMNT/(TX.TXDTLPCT/100), 2)) GRAVADO
FROM #TEMP A INNER JOIN PM10500 B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
INNER JOIN 
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLPCT, CI.ColumnaArchivo FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN tblColumnasIVA CI ON A.RPTID = CI.RPTID AND A.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where A.rptid IN(@REPORTE) AND CI.TipoReporte = 1 AND CI.ColumnaArchivo = 2 ) TX ON B.TAXDTLID = TX.TAXDTLID
WHERE TX.ColumnaArchivo = 2 AND A.CODOPER IN(1, 2, 3) AND B.TAXAMNT > 0 AND A.ALICUOTAS <> 0
GROUP BY A.VCHRNMBR, A.DOCTYPE, A.VENDORID) TX ON T.VCHRNMBR = TX.VCHRNMBR AND T.DOCTYPE = TX.DOCTYPE AND T.VENDORID = TX.VENDORID
WHERE T.COMPTYPE IN('001', '002', '003', '051', '052', '053', '066')

UPDATE #TEMP SET GRAV = GRAVADO
FROM #TEMP T INNER JOIN 
(SELECT A.VCHRNMBR, A.DOCTYPE, A.VENDORID, SUM(ROUND(B.TAXAMNT/(TX.TXDTLPCT/100), 2)) GRAVADO
FROM #TEMP A INNER JOIN PM30700 B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
INNER JOIN 
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLPCT, CI.ColumnaArchivo FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN tblColumnasIVA CI ON A.RPTID = CI.RPTID AND A.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where A.rptid IN(@REPORTE) AND CI.TipoReporte = 1 AND CI.ColumnaArchivo = 2 ) TX ON B.TAXDTLID = TX.TAXDTLID
WHERE TX.ColumnaArchivo = 2 AND A.CODOPER IN(1, 2, 3) AND B.TAXAMNT > 0 AND A.ALICUOTAS <> 0
GROUP BY A.VCHRNMBR, A.DOCTYPE, A.VENDORID) TX ON T.VCHRNMBR = TX.VCHRNMBR AND T.DOCTYPE = TX.DOCTYPE AND T.VENDORID = TX.VENDORID
WHERE T.COMPTYPE IN('001', '002', '003', '051', '052', '053', '066')

UPDATE #TEMP SET TOTAL = GRAV+NOGRAV+PERCNOCAT+EXENTO+PERCIVA+PERCNAC+PERCIIBB+PERCMUN+IMPINT+CREDFISC+OTROSTRIB WHERE COMPTYPE IN('001', '002', '003', '051', '052', '053', '066')

IF @NOGRAVADO = 1
BEGIN
	UPDATE #TEMP SET NOGRAV = NOGRAV + TOTAL-(GRAV+NOGRAV+PERCNOCAT+EXENTO+PERCIVA+PERCNAC+PERCIIBB+PERCMUN+IMPINT+CREDFISC+OTROSTRIB)
	WHERE TOTAL-(GRAV+NOGRAV+PERCNOCAT+EXENTO+PERCIVA+PERCNAC+PERCIIBB+PERCMUN+IMPINT+CREDFISC+OTROSTRIB) > 0
END

UPDATE #TEMP SET GRAV = GRAV + TOTAL-(GRAV+NOGRAV+PERCNOCAT+EXENTO+PERCIVA+PERCNAC+PERCIIBB+PERCMUN+IMPINT+CREDFISC+OTROSTRIB)
WHERE TOTAL-(GRAV+NOGRAV+PERCNOCAT+EXENTO+PERCIVA+PERCNAC+PERCIIBB+PERCMUN+IMPINT+CREDFISC+OTROSTRIB) BETWEEN -0.20 AND -0.01
AND COMPTYPE IN('001', '002', '003', '051', '052', '053', '066') 
AND GRAV > ABS(TOTAL-(GRAV+NOGRAV+PERCNOCAT+EXENTO+PERCIVA+PERCNAC+PERCIIBB+PERCMUN+IMPINT+CREDFISC+OTROSTRIB))

UPDATE #TEMP SET COMPTYPE = '003' WHERE DOCTYPE IN(4, 5) AND COMPTYPE IN('001', '002')
UPDATE #TEMP SET COMPTYPE = '008' WHERE DOCTYPE IN(4, 5) AND COMPTYPE IN('006', '007')
UPDATE #TEMP SET COMPTYPE = '013' WHERE DOCTYPE IN(4, 5) AND COMPTYPE IN('011', '012')
UPDATE #TEMP SET COMPTYPE = '053' WHERE DOCTYPE IN(4, 5) AND COMPTYPE IN('051', '052')
UPDATE #TEMP SET COMPTYPE = '001' WHERE DOCTYPE NOT IN(4, 5) AND COMPTYPE = '003'
UPDATE #TEMP SET COMPTYPE = '006' WHERE DOCTYPE NOT IN(4, 5) AND COMPTYPE = '008'
UPDATE #TEMP SET COMPTYPE = '011' WHERE DOCTYPE NOT IN(4, 5) AND COMPTYPE = '013'
UPDATE #TEMP SET COMPTYPE = '051' WHERE DOCTYPE NOT IN(4, 5) AND COMPTYPE = '053'

INSERT INTO #TEMP2
SELECT A.VCHRNMBR, A.DOCTYPE, A.VENDORID, 
SUM(CASE WHEN TX.TXDTLPCT = 21.00000 THEN B.TDTTXPUR ELSE 0 END) GRAVADO21,
 SUM(CASE WHEN TX.TXDTLPCT = 21.00000 THEN B.TAXAMNT ELSE 0 END) IVA21,
SUM(CASE WHEN TX.TXDTLPCT = 10.50000 THEN B.TDTTXPUR ELSE 0 END) GRAVADO105,
 SUM(CASE WHEN TX.TXDTLPCT = 10.50000 THEN B.TAXAMNT ELSE 0 END) IVA105,
SUM(CASE WHEN TX.TXDTLPCT = 27.00000 THEN B.TDTTXPUR ELSE 0 END) GRAVADO27,
 SUM(CASE WHEN TX.TXDTLPCT = 27.00000 THEN B.TAXAMNT ELSE 0 END) IVA27
FROM #TEMP A INNER JOIN PM10500 B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
INNER JOIN 
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLPCT, CI.ColumnaArchivo FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN tblColumnasIVA CI ON A.RPTID = CI.RPTID AND A.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where A.rptid IN(@REPORTE)	 AND CI.TipoReporte = 1 AND CI.ColumnaArchivo = 2 ) TX ON B.TAXDTLID = TX.TAXDTLID
WHERE TX.ColumnaArchivo = 2 AND B.TAXAMNT > 0 AND A.ALICUOTAS <> 0
GROUP BY A.VCHRNMBR, A.DOCTYPE, A.VENDORID

INSERT INTO #TEMP2
SELECT A.VCHRNMBR, A.DOCTYPE, A.VENDORID, 
SUM(CASE WHEN TX.TXDTLPCT = 21.00000 THEN B.TDTTXPUR ELSE 0 END) GRAVADO21,
 SUM(CASE WHEN TX.TXDTLPCT = 21.00000 THEN B.TAXAMNT ELSE 0 END) IVA21,
SUM(CASE WHEN TX.TXDTLPCT = 10.50000 THEN B.TDTTXPUR ELSE 0 END) GRAVADO105,
 SUM(CASE WHEN TX.TXDTLPCT = 10.50000 THEN B.TAXAMNT ELSE 0 END) IVA105,
SUM(CASE WHEN TX.TXDTLPCT = 27.00000 THEN B.TDTTXPUR ELSE 0 END) GRAVADO27,
 SUM(CASE WHEN TX.TXDTLPCT = 27.00000 THEN B.TAXAMNT ELSE 0 END) IVA27
FROM #TEMP A INNER JOIN PM30700 B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
INNER JOIN 
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLPCT, CI.ColumnaArchivo FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN tblColumnasIVA CI ON A.RPTID = CI.RPTID AND A.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where a.rptid IN(@REPORTE)	 AND CI.TipoReporte = 1 AND CI.ColumnaArchivo = 2 ) TX ON B.TAXDTLID = TX.TAXDTLID
WHERE TX.ColumnaArchivo = 2 AND B.TAXAMNT > 0 AND A.ALICUOTAS <> 0
GROUP BY A.VCHRNMBR, A.DOCTYPE, A.VENDORID

INSERT INTO #TEMP2
SELECT A.VCHRNMBR, A.DOCTYPE, A.VENDORID,
0 GRAVADO21, 0 IVA21, 0 GRAVADO105, 0 IVA105, 0 GRAVADO27, 0 IVA27
FROM #TEMP A INNER JOIN PM20000 B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
LEFT OUTER JOIN #TEMP2 C ON A.VCHRNMBR = C.VCHRNMBR AND A.DOCTYPE = C.DOCTYPE AND A.VENDORID = C.VENDORID
WHERE A.ALICUOTAS = 0 AND C.VCHRNMBR IS NULL 
 
INSERT INTO #TEMP2
SELECT A.VCHRNMBR, A.DOCTYPE, A.VENDORID,
0 GRAVADO21, 0 IVA21, 0 GRAVADO105, 0 IVA105, 0 GRAVADO27, 0 IVA27
FROM #TEMP A INNER JOIN PM30200 B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
LEFT OUTER JOIN #TEMP2 C ON A.VCHRNMBR = C.VCHRNMBR AND A.DOCTYPE = C.DOCTYPE AND A.VENDORID = C.VENDORID
WHERE A.ALICUOTAS = 0 AND C.VCHRNMBR IS NULL 

SELECT * INTO #TEMPTXT FROM
(SELECT 
RTRIM(B.COMPTYPE)						+		-- TIPO COMPROBANTE
RTRIM(B.PDV)							+		-- PUNTO DE VENTA
RTRIM(B.NROCOMP)						+		-- NUMERO DE COMPROBANTE
RTRIM(B.CODDOC)						+		-- CODIGO DOCUMENTO VENDEDOR
RIGHT('000000000' + RTRIM(B.NROIDENT), 20)						+		-- NRO IDENTIFICACION VENDEDOR
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, 
A.GRAVADO21), LEN(CONVERT(VARCHAR, A.GRAVADO21))-3), '.', ''), 15)   + -- GRAVADO21
'0005' + -- ALICUOTA
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, A.IVA21), LEN(CONVERT(VARCHAR, A.IVA21))-3), '.', ''), 15)   TEXTO -- IMPUESTO
FROM #TEMP2 A INNER JOIN #TEMP B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
INNER JOIN
(SELECT COMPTYPE, PDV, NROCOMP, NROIDENT FROM #TEMP GROUP BY COMPTYPE, PDV, NROCOMP, NROIDENT HAVING COUNT(VCHRNMBR) = 1) C
ON B.COMPTYPE = C.COMPTYPE AND B.PDV = C.PDV AND B.NROCOMP = C.NROCOMP AND B.NROIDENT = C.NROIDENT
WHERE B.COMPTYPE NOT IN('000', '014', '063', '087')
AND ((B.TOTAL=(B.GRAV+B.NOGRAV+B.PERCNOCAT+B.EXENTO+B.PERCIVA+B.PERCNAC+B.PERCIIBB+B.PERCMUN+B.IMPINT+B.CREDFISC+B.OTROSTRIB) 
AND B.COMPTYPE NOT IN('006', '007', '008', '011', '012', '013')) OR B.COMPTYPE IN('006', '007', '008', '011', '012', '013'))
AND dbo.fncESNUMERICO(B.PDV) = 1 AND dbo.fncESNUMERICO(B.NROCOMP) = 1 AND dbo.fncESNUMERICO(B.NROIDENT) = 1
AND B.DOCDATE < DATEADD(m, 1, @PERIODO + '01') 
AND B.PDV BETWEEN '00001' AND '99999'
AND A.GRAVADO21 >= A.IVA21
AND NOT (B.CREDFISC <> 0 AND B.COMPTYPE NOT IN('001', '002', '003', '004') )
AND A.IVA21 <> 0
UNION
SELECT 
RTRIM(B.COMPTYPE)						+		-- TIPO COMPROBANTE
RTRIM(B.PDV)							+		-- PUNTO DE VENTA
RTRIM(B.NROCOMP)						+		-- NUMERO DE COMPROBANTE
RTRIM(B.CODDOC)						+		-- CODIGO DOCUMENTO VENDEDOR
RIGHT('000000000' + RTRIM(B.NROIDENT), 20)						+		-- NRO IDENTIFICACION VENDEDOR
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, A.GRAVADO105), LEN(CONVERT(VARCHAR, A.GRAVADO105))-3), '.', ''), 15)   + -- GRAVADO21
'0004' + -- ALICUOTA
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, A.IVA105), LEN(CONVERT(VARCHAR, A.IVA105))-3), '.', ''), 15)   TEXTO -- IMPUESTO
FROM #TEMP2 A INNER JOIN #TEMP B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
INNER JOIN
(SELECT COMPTYPE, PDV, NROCOMP, NROIDENT FROM #TEMP GROUP BY COMPTYPE, PDV, NROCOMP, NROIDENT HAVING COUNT(VCHRNMBR) = 1) C
ON B.COMPTYPE = C.COMPTYPE AND B.PDV = C.PDV AND B.NROCOMP = C.NROCOMP AND B.NROIDENT = C.NROIDENT
WHERE B.COMPTYPE NOT IN('000', '014', '063', '087')
AND ((B.TOTAL=(B.GRAV+B.NOGRAV+B.PERCNOCAT+B.EXENTO+B.PERCIVA+B.PERCNAC+B.PERCIIBB+B.PERCMUN+B.IMPINT+B.CREDFISC+B.OTROSTRIB) 
AND B.COMPTYPE NOT IN('006', '007', '008', '011', '012', '013')) OR B.COMPTYPE IN('006', '007', '008', '011', '012', '013'))
AND dbo.fncESNUMERICO(B.PDV) = 1 AND dbo.fncESNUMERICO(B.NROCOMP) = 1 AND dbo.fncESNUMERICO(B.NROIDENT) = 1
AND B.DOCDATE < DATEADD(m, 1, @PERIODO + '01') 
AND B.PDV BETWEEN '00001' AND '99999'
AND A.GRAVADO105 >= A.IVA105
AND NOT (B.CREDFISC <> 0 AND B.COMPTYPE NOT IN('001', '002', '003', '004') )
AND A.IVA105 <> 0
UNION
SELECT 
RTRIM(B.COMPTYPE)						+		-- TIPO COMPROBANTE
RTRIM(B.PDV)							+		-- PUNTO DE VENTA
RTRIM(B.NROCOMP)						+		-- NUMERO DE COMPROBANTE
RTRIM(B.CODDOC)						+		-- CODIGO DOCUMENTO VENDEDOR
RIGHT('000000000' + RTRIM(B.NROIDENT), 20)						+		-- NRO IDENTIFICACION VENDEDOR
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, A.GRAVADO27), LEN(CONVERT(VARCHAR, A.GRAVADO27))-3), '.', ''), 15)   + -- GRAVADO21
'0006' + -- ALICUOTA
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, A.IVA27), LEN(CONVERT(VARCHAR, A.IVA27))-3), '.', ''), 15)   TEXTO -- IMPUESTO
FROM #TEMP2 A INNER JOIN #TEMP B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
INNER JOIN
(SELECT COMPTYPE, PDV, NROCOMP, NROIDENT FROM #TEMP GROUP BY COMPTYPE, PDV, NROCOMP, NROIDENT HAVING COUNT(VCHRNMBR) = 1) C
ON B.COMPTYPE = C.COMPTYPE AND B.PDV = C.PDV AND B.NROCOMP = C.NROCOMP AND B.NROIDENT = C.NROIDENT
WHERE B.COMPTYPE NOT IN('000', '014', '063', '087')
AND ((B.TOTAL=(B.GRAV+B.NOGRAV+B.PERCNOCAT+B.EXENTO+B.PERCIVA+B.PERCNAC+B.PERCIIBB+B.PERCMUN+B.IMPINT+B.CREDFISC+B.OTROSTRIB) 
AND B.COMPTYPE NOT IN('006', '007', '008', '011', '012', '013')) OR B.COMPTYPE IN('006', '007', '008', '011', '012', '013'))
AND dbo.fncESNUMERICO(B.PDV) = 1 AND dbo.fncESNUMERICO(B.NROCOMP) = 1 AND dbo.fncESNUMERICO(B.NROIDENT) = 1
AND B.DOCDATE < DATEADD(m, 1, @PERIODO + '01') 
AND B.PDV BETWEEN '00001' AND '99999'
AND A.GRAVADO27 >= A.IVA27
AND NOT (B.CREDFISC <> 0 AND B.COMPTYPE NOT IN('001', '002', '003', '004') )
AND A.IVA27 <> 0
UNION ALL
SELECT 
RTRIM(B.COMPTYPE)						+		-- TIPO COMPROBANTE
RTRIM(B.PDV)							+		-- PUNTO DE VENTA
RTRIM(B.NROCOMP)						+		-- NUMERO DE COMPROBANTE
RTRIM(B.CODDOC)						+		-- CODIGO DOCUMENTO VENDEDOR
RIGHT('000000000' + RTRIM(B.NROIDENT), 20)						+		-- NRO IDENTIFICACION VENDEDOR
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, 0.00000), LEN(CONVERT(VARCHAR, 0.00000))-3), '.', ''), 15)   + -- GRAVADO21
'0003' + -- ALICUOTA
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, 0.00000), LEN(CONVERT(VARCHAR, 0.00000))-3), '.', ''), 15)   TEXTO -- IMPUESTO
FROM #TEMP2 A INNER JOIN #TEMP B ON A.VCHRNMBR = B.VCHRNMBR AND A.DOCTYPE = B.DOCTYPE AND A.VENDORID = B.VENDORID
INNER JOIN
(SELECT COMPTYPE, PDV, NROCOMP, NROIDENT FROM #TEMP GROUP BY COMPTYPE, PDV, NROCOMP, NROIDENT HAVING COUNT(VCHRNMBR) = 1) C
ON B.COMPTYPE = C.COMPTYPE AND B.PDV = C.PDV AND B.NROCOMP = C.NROCOMP AND B.NROIDENT = C.NROIDENT
WHERE B.COMPTYPE NOT IN('000', '014', '063', '087')
AND ((B.TOTAL=(B.GRAV+B.NOGRAV+B.PERCNOCAT+B.EXENTO+B.PERCIVA+B.PERCNAC+B.PERCIIBB+B.PERCMUN+B.IMPINT+B.CREDFISC+B.OTROSTRIB) 
AND B.COMPTYPE NOT IN('006', '007', '008', '011', '012', '013')) OR B.COMPTYPE IN('006', '007', '008', '011', '012', '013'))
AND dbo.fncESNUMERICO(B.PDV) = 1 AND dbo.fncESNUMERICO(B.NROCOMP) = 1 AND dbo.fncESNUMERICO(B.NROIDENT) = 1
AND B.DOCDATE < DATEADD(m, 1, @PERIODO + '01') 
AND B.PDV BETWEEN '00001' AND '99999'
AND A.IVA21+A.IVA105+A.IVA27 = 0
AND NOT (B.CREDFISC <> 0 AND B.COMPTYPE NOT IN('001', '002', '003', '004') )
) TEXTOS

SELECT TEXTO FROM #TEMPTXT WHERE TEXTO IS NOT NULL ORDER BY TEXTO



GO


