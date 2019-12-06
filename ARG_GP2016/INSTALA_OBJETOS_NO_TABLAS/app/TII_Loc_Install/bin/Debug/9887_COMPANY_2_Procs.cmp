/*Count : 15 */
 
set DATEFORMAT ymd 
GO 
 
/*Begin_nsaIF_UP_MSTR_Nit_I*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_UP_MSTR_Nit_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsaIF_UP_MSTR_Nit_I]
GO

 create procedure nsaIF_UP_MSTR_Nit_I     as     DELETE FROM nsaIF006661     INSERT INTO nsaIF006661     SELECT  [nsaIFNit], [nsaIF_CV], [nsaIF_Type_Nit], [nsaIF_Name], [nsaIF_Address], [PHNUMBR2]     FROM nsaIF00666 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nsaIF_UP_MSTR_Nit_I] TO [DYNGRP] 
GO 

/*End_nsaIF_UP_MSTR_Nit_I*/
/*Begin_nsaIF_Validar_Tabla_Nit*/
SET QUOTED_IDENTIFIER OFF 
GO

SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_Validar_Tabla_Nit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsaIF_Validar_Tabla_Nit]
GO

 Create procedure nsaIF_Validar_Tabla_Nit    (     @Num_Reg integer OUTPUT )     AS     set @Num_Reg = (select TOP 1 USERDEF1    from nsaIF00666) 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nsaIF_Validar_Tabla_Nit] TO [DYNGRP] 
GO 

/*End_nsaIF_Validar_Tabla_Nit*/
/*Begin_trptIF1001AddRecord*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trptIF1001AddRecord]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[trptIF1001AddRecord]
GO

  
 Create procedure trptIF1001AddRecord   
 @OrgTxSrc     varchar(15),  
 @JrnEntry int,  
 @SEQNUMBR int,    
 @TrxDate datetime,  
 @DebitAmt numeric(19,5),  
 @CreditAmt numeric(19,5),  
 @ActIndx int,  
 @OpenYear smallint,  
 @OrgMstrID varchar(31),  
 @OrgTrxNum varchar (21),  
 @OrigSeqNum int,  
 @OrgTrxType smallint,  
 @OrgDocNum varchar(25),  
 @RCTRXSEQ numeric(19,5)  
  
 as  
 set nocount on  
 declare @VendorID varchar(15),  
  @TempVendorID varchar(15),  
  @VENDNAME  varchar(60),  
  @POPRCTNM  varchar(20)  
  
   
 select @VendorID = ''  
 select @TempVendorID = ''  
 select @VENDNAME=''  
 select @POPRCTNM=''  
  
if SUBSTRING ( @OrgTxSrc ,1 , 5 ) = (select SQL_MSG FROM DYNAMICS..MESSAGES WHERE MSGNUM = 00280 and Language_ID = 0)   
 OR SUBSTRING ( @OrgTxSrc ,1 , 5 ) = (select SQL_MSG FROM DYNAMICS..MESSAGES WHERE MSGNUM = 00281 and Language_ID = 0)   
	Begin  
		if @OrgTrxType = 1 or @OrgTrxType = 4  OR @OrgTrxType = 5 OR @OrgTrxType = 3 or @OrgTrxType = 2  
			select @VendorID = VENDORID from dbo.PM30600 where VCHRNMBR = @OrgTrxNum and DSTSQNUM = @OrigSeqNum AND CNTRLTYP = 0 and DSTINDX = @ActIndx  
		else if @OrgTrxType = 6   
			select @VendorID = VENDORID from dbo.IF10100 where VCHRNMBR = @OrgTrxNum and DSTSQNUM = @OrigSeqNum AND CNTRLTYP = 1 and ACTINDX = @ActIndx  
	end  
else  
	Begin  
		if @OrgTrxType = 1 or @OrgTrxType = 4 or @OrgTrxType = 5  
			select @VendorID = VENDORID from dbo.IF10100 where VCHRNMBR = @OrgTrxNum and DSTSQNUM = @OrigSeqNum AND CNTRLTYP = 0 and ACTINDX = @ActIndx  
		else if @OrgTrxType = 6  
			select @VendorID = VENDORID from dbo.IF10100 where VCHRNMBR = @OrgTrxNum and DSTSQNUM = @OrigSeqNum AND CNTRLTYP = 1 and ACTINDX = @ActIndx  
		else if @OrgTrxType = 3 or @OrgTrxType = 2  
			begin  
				if SUBSTRING ( @OrgTxSrc ,1 , 5 ) = (select SQL_MSG FROM DYNAMICS..MESSAGES WHERE MSGNUM = 17794 and Language_ID = 0)   
				OR SUBSTRING ( @OrgTxSrc ,1 , 5 ) = (select SQL_MSG FROM DYNAMICS..MESSAGES WHERE MSGNUM = 18742 and Language_ID = 0)  
					select @VendorID = VENDORID from dbo.IF00390 where POPRCTNM = @OrgTrxNum and SEQNUMBR = @SEQNUMBR and ACTINDX = @ActIndx    
				else  
					select @VendorID = VENDORID from dbo.IF10100 where VCHRNMBR = @OrgTrxNum and DSTSQNUM = @OrigSeqNum AND CNTRLTYP = 0 and ACTINDX = @ActIndx  
			end  
	end  
    
 /*Void POP Trxs */   
   
 if LEN(@VendorID)=0  
	Begin   
		select @POPRCTNM = POPRCTNM FROM POP30300 WHERE VNDDOCNM = @OrgDocNum and VENDORID = @OrgMstrID and VCHRNMBR = @OrgTrxNum  
		select @VendorID = VENDORID from dbo.IF00390 where POPRCTNM = @POPRCTNM and SEQNUMBR = @SEQNUMBR and ACTINDX = @ActIndx  
	End/*Void POP Trxs */  
  
if LEN(@VendorID)>0  
	select @TempVendorID = @VendorID  
else  
	select @TempVendorID = @OrgMstrID    
   
if not exists(select 1 from dbo.IF10001 where JRNENTRY = @JrnEntry and SQNCLINE = @SEQNUMBR)   
	Begin  
		Insert into dbo.IF10001(JRNENTRY,SQNCLINE,TRXDATE,DEBITAMT,CRDTAMNT,ACTINDX,YEAR1,CUSTVNDR,TERCTYPE,POSTED)  
		values(@JrnEntry,@SEQNUMBR,@TrxDate,@DebitAmt,@CreditAmt,@ActIndx,@OpenYear,@TempVendorID,2,1)  
	end  
  
 select @VENDNAME = VENDNAME from PM00200 where VENDORID = @TempVendorID  
 update GL20000 set ORMSTRID = @TempVendorID,ORMSTRNM = @VENDNAME   
 where JRNENTRY = @JrnEntry and SEQNUMBR = @SEQNUMBR AND OPENYEAR = @OpenYear AND RCTRXSEQ = @RCTRXSEQ  
   
 UPDATE IF10001 SET POSTED = 1 WHERE JRNENTRY = @JrnEntry and SQNCLINE = @SEQNUMBR AND YEAR1 = @OpenYear  
 set nocount off  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[trptIF1001AddRecord] TO [DYNGRP] 
GO 

/*End_trptIF1001AddRecord*/
/*Begin_ProcessAllHistYears*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ProcessAllHistYears]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ProcessAllHistYears]
GO
create procedure ProcessAllHistYears
(
@IN_Msg		char(10),
@IN_Open	int
)as
begin

	DECLARE @M1 		int
	DECLARE @M2 		int
	DECLARE @TRXDATE 	datetime 
	DECLARE @CRDT		VARCHAR(12)
	DECLARE @DBT		VARCHAR(12)
	DECLARE @SI		VARCHAR(12)
	DECLARE @SF		VARCHAR(12)
	DECLARE @HSTYEAR	INT
	DECLARE @HSTYEAR1	INT
	DECLARE @ORMSTRID 	VARCHAR(30)
	DECLARE @COUNT		INT
	DECLARE @sCOLS		VARCHAR(8000)
	DECLARE @C1		INT
	DECLARE @NIT		VARCHAR(16)
	DECLARE @NITTYPE	VARCHAR(5)
	DECLARE	@SQL		VARCHAR(8000)
	DECLARE @sSQL		VARCHAR(3000)
	DECLARE @CName		char(15)
	DECLARE @COLS		VARCHAR(8000)
	DECLARE @SQL1		VARCHAR(3000)
	DECLARE @SI1		VARCHAR(3000)
	DECLARE @SI2		VARCHAR(3000)
	DECLARE @SF1		VARCHAR(3000)
	DECLARE @COLS1		VARCHAR(8000)

	SET @SQL1 = ''
	SET @TRXDATE = '' 
	SET @CRDT = 'nsaIF_SCred_'
	SET @DBT= 'nsaIF_SDeb_'
	SET @SI= 'nsaIF_SI_'
	SET @SF= 'nsaIF_SF_'
	SET @COUNT = 0
	SET @C1 = 0
	SET @NIT = ''
	SET @NITTYPE = ''
	SET @SQL =''
	SET @sSQL = ''

	/*ACTNUMBER BEGIN*/ 
	DECLARE c CURSOR FAST_FORWARD FOR  
	SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='GL00100' AND COLUMN_NAME LIKE 'ACTNUMBR%' 
	OPEN c 
	FETCH NEXT FROM c INTO @CName 
	WHILE @@FETCH_STATUS=0 
	BEGIN 
		SET @sSQL = @sSQL + ltrim(rtrim(@CName)) 
		IF EXISTS (( SELECT * FROM SY00300 WHERE SGMTNUMB = substring(@CName, CHARINDEX('_',@CName) + 1,len(@CName)))) 
		BEGIN	 
			SET @SQL = @SQL+ ltrim(rtrim(@CName)) 
		END	 
		SET @SQL1 = @SQL1 +' N1.'+ltrim(rtrim(@CName)) 
		FETCH NEXT FROM c INTO @CName 
		if @@FETCH_STATUS=0 
		BEGIN 
			SET @sSQL = @sSQL + ',' 
			IF EXISTS (( SELECT * FROM SY00300 WHERE SGMTNUMB = substring(@CName, CHARINDEX('_',@CName) + 1,len(@CName)))) 
			BEGIN	 
				SET @SQL = 'ltrim(rtrim(' + @SQL +' ))' + '+''-''+' 
			END	 
			SET @SQL1 =  @SQL1 + ',' 
		END	 
	END 
	close c 
	deallocate c 
	/* END */ 


	DECLARE C1 CURSOR FAST_FORWARD FOR 
	SELECT DISTINCT MONTH(GL.TRXDATE),GL.HSTYEAR FROM GL30000 GL, SY40101 SY
	WHERE GL.HSTYEAR = SY.YEAR1 AND GL.SOURCDOC <> @IN_Msg order by GL.HSTYEAR
	OPEN C1
	FETCH NEXT FROM C1 INTO @M1,@HSTYEAR
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		SET @C1 = @M1 + 1
		SET @SI1 = ''
		SET @SF1 = '('+@DBT+LTRIM(STR(@M1))+ '+ GL.DEBITAMT) - ('+@CRDT+LTRIM(STR(@M1))+ '+ GL.CRDTAMNT) + '+ @SI+LTRIM(STR(@M1))
		SET @sCOLS = ''
		SET @COLS = ''
		SET @COLS1 = ''
		SET @M2 = 1
		SET @SI2 = 'N2.nsaIF_SF_12'
		WHILE @C1 < 13 
		BEGIN
			SET @SI1 = @SF1
			SET @SF1 = (@DBT+LTRIM(STR(@C1))+' - '+@CRDT+LTRIM(STR(@C1))+' + '+@SF1)
			SET @sCOLS = @sCOLS+', '+@SI+LTRIM(STR(@C1))+ ' = '+@SI1+', '+@SF+LTRIM(STR(@C1))+' = '+@SF1
			SET @C1 = @C1 + 1
		END
		WHILE @M2 < 12 
		BEGIN
			SET @SI2 =('nsaIF_GL00050.'+@DBT+LTRIM(STR(@M2))+' - nsaIF_GL00050.'+@CRDT+LTRIM(STR(@M2))+' + '+@SI2)
			SET @SF1 = ('nsaIF_GL00050.'+@DBT+LTRIM(STR(@M2+1))+' - nsaIF_GL00050.'+@CRDT+LTRIM(STR(@M2+1))+' + '+@SI2)
			IF @M2 < 9
			BEGIN
			SET @COLS = @COLS+', nsaIF_GL00050.'+@SI+LTRIM(STR(@M2+1))+ ' = '+@SI2+', nsaIF_GL00050.'+@SF+LTRIM(STR(@M2+1))+' = '+@SF1
			END
			ELSE
			BEGIN
			SET @COLS1 = @COLS1+', nsaIF_GL00050.'+@SI+LTRIM(STR(@M2+1))+ ' = '+@SI2+', nsaIF_GL00050.'+@SF+LTRIM(STR(@M2+1))+' = '+@SF1
			END
			SET @M2 = @M2 + 1
		END

		EXEC ('INSERT INTO nsaIF_GL00050 (nsaIF_YEAR, ACTINDX, ORMSTRID, ORMSTRNM,
			nsaIF_SCred_1,nsaIF_SCred_2,nsaIF_SCred_3,nsaIF_SCred_4,nsaIF_SCred_5,nsaIF_SCred_6,nsaIF_SCred_7,nsaIF_SCred_8,nsaIF_SCred_9,nsaIF_SCred_10,nsaIF_SCred_11,nsaIF_SCred_12,
			nsaIF_SDeb_1,nsaIF_SDeb_2,nsaIF_SDeb_3,nsaIF_SDeb_4,nsaIF_SDeb_5,nsaIF_SDeb_6,nsaIF_SDeb_7,nsaIF_SDeb_8,nsaIF_SDeb_9,nsaIF_SDeb_10,nsaIF_SDeb_11,nsaIF_SDeb_12,
			nsaIF_SF_1,nsaIF_SF_2,nsaIF_SF_3,nsaIF_SF_4,nsaIF_SF_5,nsaIF_SF_6,nsaIF_SF_7,nsaIF_SF_8,nsaIF_SF_9,nsaIF_SF_10,nsaIF_SF_11,nsaIF_SF_12,
			nsaIF_SI_1,nsaIF_SI_2,nsaIF_SI_3,nsaIF_SI_4,nsaIF_SI_5,nsaIF_SI_6,nsaIF_SI_7,nsaIF_SI_8,nsaIF_SI_9,nsaIF_SI_10,nsaIF_SI_11,nsaIF_SI_12,
			nsaIF_SI0,nsaIF_SF0,nsaIF_SDeb0,nsaIF_SDeb01,nsaIF_Type_Nit,nsaIFNit,'+ @sSQL+ ',ACTNUMST)
			SELECT distinct GL.HSTYEAR,GL.ACTINDX, GL.ORMSTRID, '''',
			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
			''0.00'',''0.00'',''0.00'',''0.00'','''','''','+@sSQL+','+@SQL+' FROM GL30000 GL, GL00100  
			WHERE GL.SOURCDOC <> '''+@IN_Msg+''' AND HSTYEAR = '+@HSTYEAR+' AND GL.ACTINDX = GL00100.ACTINDX  
			AND NOT EXISTS (SELECT GL1.TRXDATE FROM GL30000 GL1,nsaIF_GL00050 NGL1 WHERE GL1.SOURCDOC <> '''+@IN_Msg+''' AND GL1.ACTINDX = NGL1.ACTINDX AND 
			GL1.ORMSTRID = NGL1.ORMSTRID AND GL1.HSTYEAR = NGL1.nsaIF_YEAR AND GL1.DEX_ROW_ID = GL.DEX_ROW_ID) AND MONTH(TRXDATE)=' +@M1)

		EXECUTE('UPDATE nsaIF_GL00050 SET '+ @CRDT+@M1  +' = ('+ @CRDT+@M1 + ' + GL.CRDTAMNT ),
			'+ @DBT+@M1 +' = ('+ @DBT+@M1 + ' + GL.DEBITAMT ),'+ @SF+@M1 +' = '+
			'('+@DBT+@M1+ '+ GL.DEBITAMT) - ('+@CRDT+@M1+ '+ GL.CRDTAMNT) + '+ @SI+@M1 +', nsaIF_SDeb01 = (nsaIF_SDeb01 + GL.CRDTAMNT), 
			nsaIF_SDeb0 = (nsaIF_SDeb0 + GL.DEBITAMT)' + @sCOLS + ', nsaIFNit =''' +
			@NIT + ''',nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050 NGL, 
			(select sum(CRDTAMNT) as CRDTAMNT, sum(DEBITAMT) as DEBITAMT,
			ACTINDX,HSTYEAR,ORMSTRID FROM GL30000 where MONTH(TRXDATE)='+ @M1 + ' AND HSTYEAR = '+ @HSTYEAR+
			'and SOURCDOC NOT IN ( '''+@IN_Msg+''', ''P/L'') GROUP BY ACTINDX,HSTYEAR,ORMSTRID) GL 
			WHERE NGL.ORMSTRID = GL.ORMSTRID AND NGL.ACTINDX = GL.ACTINDX AND NGL.nsaIF_YEAR = '+@HSTYEAR) 

		/*THE BELOW EXECUTE STATEMENT IS ADDED FOR P/L ACCOUNT UPDATE*/	
		EXECUTE('UPDATE nsaIF_GL00050 SET '+ @SF+@M1 +' = '+
			'('+@DBT+@M1+ '+ GL.DEBITAMT) - ('+@CRDT+@M1+ '+ GL.CRDTAMNT) + '+ @SI+@M1 +', nsaIF_SDeb01 = (nsaIF_SDeb01 + GL.CRDTAMNT), 
			nsaIF_SDeb0 = (nsaIF_SDeb0 + GL.DEBITAMT)' + @sCOLS + ', nsaIFNit =''' +
			@NIT + ''',nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050 NGL, 
			(select sum(CRDTAMNT) as CRDTAMNT, sum(DEBITAMT) as DEBITAMT,
			ACTINDX,HSTYEAR,ORMSTRID FROM GL30000 where MONTH(TRXDATE)='+ @M1 + ' AND HSTYEAR = '+ @HSTYEAR+
			'and SOURCDOC = ''P/L'' GROUP BY ACTINDX,HSTYEAR,ORMSTRID) GL 
			WHERE NGL.ORMSTRID = GL.ORMSTRID AND NGL.ACTINDX = GL.ACTINDX AND NGL.nsaIF_YEAR = '+@HSTYEAR) 
			
	
		EXECUTE('UPDATE nsaIF_GL00050 SET nsaIF_GL00050.nsaIF_SI_1 = N2.nsaIF_SF_12, nsaIF_GL00050.nsaIF_SF_1 = (nsaIF_GL00050.nsaIF_SDeb_1 - nsaIF_GL00050.nsaIF_SCred_1 + N2.nsaIF_SF_12), 
			nsaIF_GL00050.nsaIF_SDeb01 = N2.nsaIF_SDeb01, nsaIF_GL00050.nsaIF_SDeb0 = N2.nsaIF_SDeb0' + @COLS + @COLS1 +',nsaIF_GL00050.nsaIFNit =''' +
			@NIT + ''',nsaIF_GL00050.nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050,nsaIF_GL00050 N2, GL00100,GL30000 GL
			 WHERE nsaIF_GL00050.ORMSTRID = N2.ORMSTRID AND N2.ACTINDX = GL00100.ACTINDX AND
			 N2.ORMSTRID = GL.ORMSTRID AND N2.ACTINDX = GL.ACTINDX AND N2.nsaIF_YEAR = GL.HSTYEAR AND GL.SOURCDOC = ''P/L'' 
			AND GL00100.PSTNGTYP = 0 AND nsaIF_GL00050.ACTINDX = N2.ACTINDX AND nsaIF_GL00050.nsaIF_YEAR = N2.nsaIF_YEAR AND 
			N2.nsaIF_YEAR = '+@HSTYEAR) 

		/*ADD_TRX_NEW_YEAR*/



		DECLARE C2 CURSOR FAST_FORWARD FOR 
		select YEAR1 from SY40101 where YEAR1 > @HSTYEAR
		OPEN C2
		FETCH NEXT FROM C2 INTO @HSTYEAR1
		WHILE @@FETCH_STATUS = 0 
		BEGIN

			EXEC ('INSERT INTO nsaIF_GL00050 (nsaIF_YEAR, ACTINDX, ORMSTRID, ORMSTRNM,
				nsaIF_SCred_1,nsaIF_SCred_2,nsaIF_SCred_3,nsaIF_SCred_4,nsaIF_SCred_5,nsaIF_SCred_6,nsaIF_SCred_7,nsaIF_SCred_8,nsaIF_SCred_9,nsaIF_SCred_10,nsaIF_SCred_11,nsaIF_SCred_12,
				nsaIF_SDeb_1,nsaIF_SDeb_2,nsaIF_SDeb_3,nsaIF_SDeb_4,nsaIF_SDeb_5,nsaIF_SDeb_6,nsaIF_SDeb_7,nsaIF_SDeb_8,nsaIF_SDeb_9,nsaIF_SDeb_10,nsaIF_SDeb_11,nsaIF_SDeb_12,
				nsaIF_SF_1,nsaIF_SF_2,nsaIF_SF_3,nsaIF_SF_4,nsaIF_SF_5,nsaIF_SF_6,nsaIF_SF_7,nsaIF_SF_8,nsaIF_SF_9,nsaIF_SF_10,nsaIF_SF_11,nsaIF_SF_12,
				nsaIF_SI_1,nsaIF_SI_2,nsaIF_SI_3,nsaIF_SI_4,nsaIF_SI_5,nsaIF_SI_6,nsaIF_SI_7,nsaIF_SI_8,nsaIF_SI_9,nsaIF_SI_10,nsaIF_SI_11,nsaIF_SI_12,
				nsaIF_SI0,nsaIF_SF0,nsaIF_SDeb0,nsaIF_SDeb01,nsaIF_Type_Nit,nsaIFNit,'+ @sSQL+ ',ACTNUMST)
				SELECT '+@HSTYEAR1+', N1.ACTINDX, N1.ORMSTRID, N1.ORMSTRNM,
				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
				''0.00'',''0.00'',''0.00'',''0.00'','''','''','+@SQL1+', N1.ACTNUMST FROM nsaIF_GL00050 N1, GL00100  
				WHERE N1.ACTINDX = GL00100.ACTINDX  
				AND NOT EXISTS (SELECT N2.nsaIF_YEAR FROM nsaIF_GL00050 N2 WHERE N1.ACTINDX = N2.ACTINDX AND 
				N1.ORMSTRID = N2.ORMSTRID AND N2.nsaIF_YEAR = '+@HSTYEAR1+') AND 
				GL00100.PSTNGTYP = 0 AND N1.nsaIF_YEAR = '+@HSTYEAR)

			EXECUTE('UPDATE nsaIF_GL00050 SET nsaIF_GL00050.nsaIF_SI_1 = N2.nsaIF_SF_12, nsaIF_GL00050.nsaIF_SF_1 = (nsaIF_GL00050.nsaIF_SDeb_1 - nsaIF_GL00050.nsaIF_SCred_1 + N2.nsaIF_SF_12), 
				nsaIF_GL00050.nsaIF_SDeb01 = N2.nsaIF_SDeb01, nsaIF_GL00050.nsaIF_SDeb0 = N2.nsaIF_SDeb0' + @COLS + @COLS1 +',nsaIF_GL00050.nsaIFNit =''' +
				@NIT + ''',nsaIF_GL00050.nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050,nsaIF_GL00050 N2, GL00100
				 WHERE nsaIF_GL00050.ORMSTRID = N2.ORMSTRID AND N2.ACTINDX = GL00100.ACTINDX AND
				GL00100.PSTNGTYP = 0 AND nsaIF_GL00050.ACTINDX = N2.ACTINDX AND nsaIF_GL00050.nsaIF_YEAR = '+@HSTYEAR1+' AND 
				N2.nsaIF_YEAR = '+@HSTYEAR) 

			FETCH NEXT FROM C2 INTO @HSTYEAR1
		END /*WHILE*/
		CLOSE C2
		DEALLOCATE C2


		FETCH NEXT FROM C1 INTO @M1,@HSTYEAR

	END /*WHILE*/
	CLOSE C1
	DEALLOCATE C1
	if @IN_Open = 0 
	begin
		/* To update the NIT and NIT TYPE values in table nsaIF_GL00050*/
		update nsaIF_GL00050 set nsaIF_Type_Nit = NV.nsaIF_Type_Nit, nsaIFNit = NV.nsaIFNit  from nsaIF_GL00050, nsaIF01666 NV
		where ORMSTRID = NV.VENDORID 
		update nsaIF_GL00050 set nsaIF_Type_Nit = NC.nsaIF_Type_Nit, nsaIFNit = NC.nsaIFNit  from nsaIF_GL00050, nsaIF02666 NC
		where ORMSTRID = NC.CUSTNMBR 
		UPDATE nsaIF_GL00050 SET nsaIF_GL00050.ORMSTRNM = PM.VENDNAME FROM nsaIF_GL00050, PM00200 PM WHERE nsaIF_GL00050.ORMSTRID = PM.VENDORID 
		UPDATE nsaIF_GL00050 SET nsaIF_GL00050.ORMSTRNM = RM.CUSTNAME FROM nsaIF_GL00050, RM00101 RM WHERE nsaIF_GL00050.ORMSTRID = RM.CUSTNMBR 
	end /*end of if */

end /*end of SP*/

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON [dbo].[ProcessAllHistYears] TO [DYNGRP] 
GO 


/*End_ProcessAllHistYears*/
/*Begin_ProcessAllOpenYears*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ProcessAllOpenYears]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ProcessAllOpenYears]
GO
create procedure ProcessAllOpenYears
(
@IN_Msg		char(10)
)as
begin

	DECLARE @M1 		int
	DECLARE @M2 		int
	DECLARE @TRXDATE 	datetime 
	DECLARE @CRDT		VARCHAR(12)
	DECLARE @DBT		VARCHAR(12)
	DECLARE @SI		VARCHAR(12)
	DECLARE @SF		VARCHAR(12)
	DECLARE @OPENYEAR	INT
	DECLARE @OPENYEAR1	INT
	DECLARE	@ORMSTRID 	VARCHAR(30)
	DECLARE @COUNT	 	INT
	DECLARE @sCOLS		VARCHAR(8000)
	DECLARE @C1		INT
	DECLARE @NIT		VARCHAR(16)
	DECLARE	@NITTYPE	VARCHAR(5)
	DECLARE	@SQL		VARCHAR(8000)
	DECLARE @sSQL		VARCHAR(3000)
	DECLARE @CName		char(15)
	DECLARE	@COLS		VARCHAR(8000)
	DECLARE	@SQL1		VARCHAR(3000)
	DECLARE @SI1		VARCHAR(3000)
	DECLARE @SI2		VARCHAR(3000)
	DECLARE @SF1		VARCHAR(3000)
	DECLARE @COLS1		VARCHAR(8000)

	SET @SQL1 = ''
	SET @TRXDATE = '' 
	SET @CRDT = 'nsaIF_SCred_'
	SET @DBT= 'nsaIF_SDeb_'
	SET @SI= 'nsaIF_SI_'
	SET @SF= 'nsaIF_SF_'
	SET @COUNT = 0
	SET @C1 = 0
	SET @NIT = ''
	SET @NITTYPE = ''
	SET @SQL =''
	SET @sSQL = ''


	/*ACTNUMBER BEGIN*/
	DECLARE c CURSOR FAST_FORWARD FOR  
	SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='GL00100' AND COLUMN_NAME LIKE 'ACTNUMBR%' 
	OPEN c 
	FETCH NEXT FROM c INTO @CName 
	WHILE @@FETCH_STATUS=0 
	BEGIN 
		SET @sSQL = @sSQL + ltrim(rtrim(@CName)) 
		IF EXISTS (( SELECT * FROM SY00300 WHERE SGMTNUMB = substring(@CName, CHARINDEX('_',@CName) + 1,len(@CName)))) 
		BEGIN	 
			SET @SQL = @SQL+ ltrim(rtrim(@CName)) 
		END	 
		SET @SQL1 = @SQL1 +' N1.'+ltrim(rtrim(@CName)) 
		FETCH NEXT FROM c INTO @CName 
		if @@FETCH_STATUS=0 
		BEGIN 
			SET @sSQL = @sSQL + ',' 
			IF EXISTS (( SELECT * FROM SY00300 WHERE SGMTNUMB = substring(@CName, CHARINDEX('_',@CName) + 1,len(@CName)))) 
			BEGIN	  
				SET @SQL = 'ltrim(rtrim(' + @SQL +' ))' + '+''-''+' 
			END	 
			SET @SQL1 =  @SQL1 + ',' 
		END 
	END 	 
	close c 
	deallocate c  
	/*END*/ 


	DECLARE C1 CURSOR FAST_FORWARD FOR 
	SELECT DISTINCT MONTH(GL.TRXDATE),GL.OPENYEAR 
	FROM GL20000 GL, SY40101 SY
	WHERE GL.OPENYEAR = SY.YEAR1 AND GL.SOURCDOC <> 'BBF' 
	ORDER BY GL.OPENYEAR
	OPEN C1
	FETCH NEXT FROM C1 INTO @M1,@OPENYEAR
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		SET @C1 = @M1 + 1
		SET @SI1 = ''
		SET @SF1 = '('+@DBT+LTRIM(STR(@M1))+ '+ GL.DEBITAMT) - ('+@CRDT+LTRIM(STR(@M1))+ '+ GL.CRDTAMNT) + '+ @SI+LTRIM(STR(@M1))
		SET @sCOLS = ''
		SET @COLS = ''
		SET @COLS1 = ''
		SET @M2 = 1
		SET @SI2 = 'N2.nsaIF_SF_12'
		WHILE @C1 < 13 
		BEGIN
			SET @SI1 = @SF1
			SET @SF1 = (@DBT+LTRIM(STR(@C1))+' - '+@CRDT+LTRIM(STR(@C1))+' + '+@SF1)
			SET @sCOLS = @sCOLS+', '+@SI+LTRIM(STR(@C1))+ ' = '+@SI1+', '+@SF+LTRIM(STR(@C1))+' = '+@SF1
			SET @C1 = @C1 + 1
		END
		WHILE @M2 < 12 
		BEGIN
			SET @SI2 =('nsaIF_GL00050.'+@DBT+LTRIM(STR(@M2))+' - nsaIF_GL00050.'+@CRDT+LTRIM(STR(@M2))+' + '+@SI2)
			SET @SF1 = ('nsaIF_GL00050.'+@DBT+LTRIM(STR(@M2+1))+' - nsaIF_GL00050.'+@CRDT+LTRIM(STR(@M2+1))+' + '+@SI2)
			IF @M2 < 9
			BEGIN
				SET @COLS = @COLS+', nsaIF_GL00050.'+@SI+LTRIM(STR(@M2+1))+ ' = '+@SI2+', nsaIF_GL00050.'+@SF+LTRIM(STR(@M2+1))+' = '+@SF1
			END
			ELSE
			BEGIN
				SET @COLS1 = @COLS1+', nsaIF_GL00050.'+@SI+LTRIM(STR(@M2+1))+ ' = '+@SI2+', nsaIF_GL00050.'+@SF+LTRIM(STR(@M2+1))+' = '+@SF1
			END
			SET @M2 = @M2 + 1
		END

		
		EXEC ('INSERT INTO nsaIF_GL00050 (nsaIF_YEAR, ACTINDX, ORMSTRID, ORMSTRNM,
			nsaIF_SCred_1,nsaIF_SCred_2,nsaIF_SCred_3,nsaIF_SCred_4,nsaIF_SCred_5,nsaIF_SCred_6,nsaIF_SCred_7,nsaIF_SCred_8,nsaIF_SCred_9,nsaIF_SCred_10,nsaIF_SCred_11,nsaIF_SCred_12,
			nsaIF_SDeb_1,nsaIF_SDeb_2,nsaIF_SDeb_3,nsaIF_SDeb_4,nsaIF_SDeb_5,nsaIF_SDeb_6,nsaIF_SDeb_7,nsaIF_SDeb_8,nsaIF_SDeb_9,nsaIF_SDeb_10,nsaIF_SDeb_11,nsaIF_SDeb_12,
			nsaIF_SF_1,nsaIF_SF_2,nsaIF_SF_3,nsaIF_SF_4,nsaIF_SF_5,nsaIF_SF_6,nsaIF_SF_7,nsaIF_SF_8,nsaIF_SF_9,nsaIF_SF_10,nsaIF_SF_11,nsaIF_SF_12,
			nsaIF_SI_1,nsaIF_SI_2,nsaIF_SI_3,nsaIF_SI_4,nsaIF_SI_5,nsaIF_SI_6,nsaIF_SI_7,nsaIF_SI_8,nsaIF_SI_9,nsaIF_SI_10,nsaIF_SI_11,nsaIF_SI_12,
			nsaIF_SI0,nsaIF_SF0,nsaIF_SDeb0,nsaIF_SDeb01,nsaIF_Type_Nit,nsaIFNit,'+ @sSQL+ ',ACTNUMST)
			SELECT distinct GL.OPENYEAR,GL.ACTINDX, GL.ORMSTRID, '''',
			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
			''0.00'',''0.00'',''0.00'',''0.00'','''','''','+@sSQL+','+@SQL+' FROM GL20000 GL, GL00100  
			WHERE GL.SOURCDOC <> ''BBF'' AND OPENYEAR = '+@OPENYEAR+' AND GL.ACTINDX = GL00100.ACTINDX  
			AND NOT EXISTS (SELECT GL1.TRXDATE FROM GL20000 GL1,nsaIF_GL00050 NGL1 WHERE GL1.SOURCDOC <> ''BBF'' AND GL1.ACTINDX = NGL1.ACTINDX AND 
			GL1.ORMSTRID = NGL1.ORMSTRID AND GL1.OPENYEAR = NGL1.nsaIF_YEAR AND GL1.DEX_ROW_ID = GL.DEX_ROW_ID) AND MONTH(TRXDATE)=' +@M1)


		EXECUTE('UPDATE nsaIF_GL00050 SET '+ @CRDT+@M1  +' = ('+ @CRDT+@M1 + ' + GL.CRDTAMNT ),
			'+ @DBT+@M1 +' = ('+ @DBT+@M1 + ' + GL.DEBITAMT ),'+ @SF+@M1 +' = '+
			'('+@DBT+@M1+ '+ GL.DEBITAMT) - ('+@CRDT+@M1+ '+ GL.CRDTAMNT) + '+ @SI+@M1 +', nsaIF_SDeb01 = (nsaIF_SDeb01 + GL.CRDTAMNT), 
			nsaIF_SDeb0 = (nsaIF_SDeb0 + GL.DEBITAMT)' + @sCOLS + ', nsaIFNit =''' +
			@NIT + ''',nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050 NGL, 
			(select sum(CRDTAMNT) as CRDTAMNT, sum(DEBITAMT) as DEBITAMT,
			ACTINDX,OPENYEAR,ORMSTRID FROM GL20000 where MONTH(TRXDATE)='+ @M1 + ' AND OPENYEAR = '+ @OPENYEAR+
			' AND SOURCDOC not in (''BBF'', ''P/L'') GROUP BY ACTINDX, OPENYEAR, ORMSTRID) GL 
			WHERE NGL.ORMSTRID = GL.ORMSTRID AND NGL.ACTINDX = GL.ACTINDX AND NGL.nsaIF_YEAR = '+@OPENYEAR) 
			
		/*THE BELOW EXECUTE STATEMENT IS ADDED FOR P/L ACCOUNT UPDATE*/	
		EXECUTE('UPDATE nsaIF_GL00050 SET '+ @SF+@M1 +' = '+
			'('+@DBT+@M1+ '+ GL.DEBITAMT) - ('+@CRDT+@M1+ '+ GL.CRDTAMNT) + '+ @SI+@M1 +', nsaIF_SDeb01 = (nsaIF_SDeb01 + GL.CRDTAMNT), 
			nsaIF_SDeb0 = (nsaIF_SDeb0 + GL.DEBITAMT)' + @sCOLS + ', nsaIFNit =''' +
			@NIT + ''',nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050 NGL, 
			(select sum(CRDTAMNT) as CRDTAMNT, sum(DEBITAMT) as DEBITAMT,
			ACTINDX,OPENYEAR,ORMSTRID FROM GL20000 where MONTH(TRXDATE)='+ @M1 + ' AND OPENYEAR = '+ @OPENYEAR+
			' AND SOURCDOC = ''P/L'' GROUP BY ACTINDX, OPENYEAR, ORMSTRID) GL 
			WHERE NGL.ORMSTRID = GL.ORMSTRID AND NGL.ACTINDX = GL.ACTINDX AND NGL.nsaIF_YEAR = '+@OPENYEAR) 
			
		EXECUTE('UPDATE nsaIF_GL00050 SET nsaIF_GL00050.nsaIF_SI_1 = N2.nsaIF_SF_12, nsaIF_GL00050.nsaIF_SF_1 = (nsaIF_GL00050.nsaIF_SDeb_1 - nsaIF_GL00050.nsaIF_SCred_1 + N2.nsaIF_SF_12), 
			nsaIF_GL00050.nsaIF_SDeb01 = N2.nsaIF_SDeb01, nsaIF_GL00050.nsaIF_SDeb0 = N2.nsaIF_SDeb0' + @COLS + @COLS1 +',nsaIF_GL00050.nsaIFNit =''' +
			@NIT + ''',nsaIF_GL00050.nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050,nsaIF_GL00050 N2, GL00100,GL20000 GL
			WHERE nsaIF_GL00050.ORMSTRID = N2.ORMSTRID AND N2.ACTINDX = GL00100.ACTINDX AND
			N2.ORMSTRID = GL.ORMSTRID AND N2.ACTINDX = GL.ACTINDX AND N2.nsaIF_YEAR = GL.OPENYEAR AND GL.SOURCDOC = ''P/L''   
			AND GL00100.PSTNGTYP = 0 AND nsaIF_GL00050.ACTINDX = N2.ACTINDX AND nsaIF_GL00050.nsaIF_YEAR = N2.nsaIF_YEAR AND 
			N2.nsaIF_YEAR = '+@OPENYEAR)

		/*ADD_TRX_NEW_YEAR*/

		IF EXISTS (select YEAR1 from SY40101 where YEAR1 > @OPENYEAR)
		BEGIN
			DECLARE C2 CURSOR FAST_FORWARD FOR 
			select YEAR1 from SY40101 where YEAR1 > @OPENYEAR
			OPEN C2
			SET @COUNT = @@ROWCOUNT
			FETCH NEXT FROM C2 INTO @OPENYEAR1
			WHILE @@FETCH_STATUS = 0 
			BEGIN

				EXEC ('INSERT INTO nsaIF_GL00050 (nsaIF_YEAR, ACTINDX, ORMSTRID, ORMSTRNM,
					nsaIF_SCred_1,nsaIF_SCred_2,nsaIF_SCred_3,nsaIF_SCred_4,nsaIF_SCred_5,nsaIF_SCred_6,nsaIF_SCred_7,nsaIF_SCred_8,nsaIF_SCred_9,nsaIF_SCred_10,nsaIF_SCred_11,nsaIF_SCred_12,
					nsaIF_SDeb_1,nsaIF_SDeb_2,nsaIF_SDeb_3,nsaIF_SDeb_4,nsaIF_SDeb_5,nsaIF_SDeb_6,nsaIF_SDeb_7,nsaIF_SDeb_8,nsaIF_SDeb_9,nsaIF_SDeb_10,nsaIF_SDeb_11,nsaIF_SDeb_12,
					nsaIF_SF_1,nsaIF_SF_2,nsaIF_SF_3,nsaIF_SF_4,nsaIF_SF_5,nsaIF_SF_6,nsaIF_SF_7,nsaIF_SF_8,nsaIF_SF_9,nsaIF_SF_10,nsaIF_SF_11,nsaIF_SF_12,
					nsaIF_SI_1,nsaIF_SI_2,nsaIF_SI_3,nsaIF_SI_4,nsaIF_SI_5,nsaIF_SI_6,nsaIF_SI_7,nsaIF_SI_8,nsaIF_SI_9,nsaIF_SI_10,nsaIF_SI_11,nsaIF_SI_12,
					nsaIF_SI0,nsaIF_SF0,nsaIF_SDeb0,nsaIF_SDeb01,nsaIF_Type_Nit,nsaIFNit,'+ @sSQL+ ',ACTNUMST)
					SELECT '+@OPENYEAR1+', N1.ACTINDX, N1.ORMSTRID, N1.ORMSTRNM,
					''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
					''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
					''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
					''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
					''0.00'',''0.00'',''0.00'',''0.00'','''','''','+@SQL1+', N1.ACTNUMST FROM nsaIF_GL00050 N1, GL00100  
					WHERE N1.ACTINDX = GL00100.ACTINDX  
					AND NOT EXISTS (SELECT N2.nsaIF_YEAR FROM nsaIF_GL00050 N2 WHERE N1.ACTINDX = N2.ACTINDX AND 
					N1.ORMSTRID = N2.ORMSTRID AND N2.nsaIF_YEAR = '+@OPENYEAR1+') AND 
					GL00100.PSTNGTYP = 0 AND N1.nsaIF_YEAR = '+@OPENYEAR)

				EXECUTE('UPDATE nsaIF_GL00050 SET nsaIF_GL00050.nsaIF_SI_1 = N2.nsaIF_SF_12, nsaIF_GL00050.nsaIF_SF_1 = (nsaIF_GL00050.nsaIF_SDeb_1 - nsaIF_GL00050.nsaIF_SCred_1 + N2.nsaIF_SF_12), 
					nsaIF_GL00050.nsaIF_SDeb01 = N2.nsaIF_SDeb01, nsaIF_GL00050.nsaIF_SDeb0 = N2.nsaIF_SDeb0' + @COLS + @COLS1 +',nsaIF_GL00050.nsaIFNit =''' +
					@NIT + ''',nsaIF_GL00050.nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050,nsaIF_GL00050 N2, GL00100
					 WHERE nsaIF_GL00050.ORMSTRID = N2.ORMSTRID AND N2.ACTINDX = GL00100.ACTINDX AND
					GL00100.PSTNGTYP = 0 AND nsaIF_GL00050.ACTINDX = N2.ACTINDX AND nsaIF_GL00050.nsaIF_YEAR = '+@OPENYEAR1+' AND 
					N2.nsaIF_YEAR = '+@OPENYEAR) 

				FETCH NEXT FROM C2 INTO @OPENYEAR1
			END /*WHILE*/
			CLOSE C2
			DEALLOCATE C2
		END
		ELSE
		BEGIN
			SET @OPENYEAR1 = @OPENYEAR + 1
			EXEC ('INSERT INTO nsaIF_GL00050 (nsaIF_YEAR, ACTINDX, ORMSTRID, ORMSTRNM,
				nsaIF_SCred_1,nsaIF_SCred_2,nsaIF_SCred_3,nsaIF_SCred_4,nsaIF_SCred_5,nsaIF_SCred_6,nsaIF_SCred_7,nsaIF_SCred_8,nsaIF_SCred_9,nsaIF_SCred_10,nsaIF_SCred_11,nsaIF_SCred_12,
				nsaIF_SDeb_1,nsaIF_SDeb_2,nsaIF_SDeb_3,nsaIF_SDeb_4,nsaIF_SDeb_5,nsaIF_SDeb_6,nsaIF_SDeb_7,nsaIF_SDeb_8,nsaIF_SDeb_9,nsaIF_SDeb_10,nsaIF_SDeb_11,nsaIF_SDeb_12,
				nsaIF_SF_1,nsaIF_SF_2,nsaIF_SF_3,nsaIF_SF_4,nsaIF_SF_5,nsaIF_SF_6,nsaIF_SF_7,nsaIF_SF_8,nsaIF_SF_9,nsaIF_SF_10,nsaIF_SF_11,nsaIF_SF_12,
				nsaIF_SI_1,nsaIF_SI_2,nsaIF_SI_3,nsaIF_SI_4,nsaIF_SI_5,nsaIF_SI_6,nsaIF_SI_7,nsaIF_SI_8,nsaIF_SI_9,nsaIF_SI_10,nsaIF_SI_11,nsaIF_SI_12,
				nsaIF_SI0,nsaIF_SF0,nsaIF_SDeb0,nsaIF_SDeb01,nsaIF_Type_Nit,nsaIFNit,'+ @sSQL+ ',ACTNUMST)
				SELECT '+@OPENYEAR1+', N1.ACTINDX, N1.ORMSTRID, N1.ORMSTRNM,
				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',
				''0.00'',''0.00'',''0.00'',''0.00'','''','''','+@SQL1+', N1.ACTNUMST FROM nsaIF_GL00050 N1, GL00100  
				WHERE N1.ACTINDX = GL00100.ACTINDX  
				AND NOT EXISTS (SELECT N2.nsaIF_YEAR FROM nsaIF_GL00050 N2 WHERE N1.ACTINDX = N2.ACTINDX AND 
				N1.ORMSTRID = N2.ORMSTRID AND N2.nsaIF_YEAR = '+@OPENYEAR1+') AND 
				GL00100.PSTNGTYP = 0 AND N1.nsaIF_YEAR = '+@OPENYEAR)

			EXECUTE('UPDATE nsaIF_GL00050 SET nsaIF_GL00050.nsaIF_SI_1 = N2.nsaIF_SF_12, nsaIF_GL00050.nsaIF_SF_1 = (nsaIF_GL00050.nsaIF_SDeb_1 - nsaIF_GL00050.nsaIF_SCred_1 + N2.nsaIF_SF_12), 
				nsaIF_GL00050.nsaIF_SDeb01 = N2.nsaIF_SDeb01, nsaIF_GL00050.nsaIF_SDeb0 = N2.nsaIF_SDeb0' + @COLS + @COLS1 +',nsaIF_GL00050.nsaIFNit =''' +
				@NIT + ''',nsaIF_GL00050.nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050,nsaIF_GL00050 N2, GL00100
				 WHERE nsaIF_GL00050.ORMSTRID = N2.ORMSTRID AND N2.ACTINDX = GL00100.ACTINDX AND
				GL00100.PSTNGTYP = 0 AND nsaIF_GL00050.ACTINDX = N2.ACTINDX AND nsaIF_GL00050.nsaIF_YEAR = '+@OPENYEAR1+' AND 
				N2.nsaIF_YEAR = '+@OPENYEAR) 
		END

		FETCH NEXT FROM C1 INTO @M1,@OPENYEAR

	END /*WHILE*/
	CLOSE C1
	DEALLOCATE C1
	/* To update the NIT and NIT TYPE values in table nsaIF_GL00050*/
	update nsaIF_GL00050 set nsaIF_Type_Nit = NV.nsaIF_Type_Nit, nsaIFNit = NV.nsaIFNit  from nsaIF_GL00050, nsaIF01666 NV
	where ORMSTRID = NV.VENDORID 
	update nsaIF_GL00050 set nsaIF_Type_Nit = NC.nsaIF_Type_Nit, nsaIFNit = NC.nsaIFNit  from nsaIF_GL00050, nsaIF02666 NC
	where ORMSTRID = NC.CUSTNMBR 
	UPDATE nsaIF_GL00050 SET nsaIF_GL00050.ORMSTRNM = PM.VENDNAME FROM nsaIF_GL00050, PM00200 PM WHERE nsaIF_GL00050.ORMSTRID = PM.VENDORID 
	UPDATE nsaIF_GL00050 SET nsaIF_GL00050.ORMSTRNM = RM.CUSTNAME FROM nsaIF_GL00050, RM00101 RM WHERE nsaIF_GL00050.ORMSTRID = RM.CUSTNMBR 

end /*end of SP*/

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON [dbo].[ProcessAllOpenYears] TO [DYNGRP] 
GO 


/*End_ProcessAllOpenYears*/
/*Begin_nsaIF_Update_Table*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_Update_Table]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsaIF_Update_Table]
GO

Create procedure nsaIF_Update_Table 
(@Indice  int,   
@Tercero char (21),     
@Tercero_Nombre char(31),    
@Año smallint,               
@Fecha_TRX datetime,   
@Debito numeric(19,5),   
@Credito numeric(19,5),    
@f int,   
@Deb varchar(50),   
@Cred varchar(50),     
@s_f varchar(50),    
@s_i varchar(50),    
@SQL varchar(8000), 
@PostingType int, 
@ACTNUMST varchar(129)  )   AS  

declare @Año1	smallint 
declare @Año2	smallint 
declare @Count	smallint 
declare @CNT	integer
declare	@ACTS	varchar(8000)
declare	@SQLS	varchar(8000)
declare @SQL1	varchar(8000)
declare @SQLD	varchar(8000)
declare	@s_ii	varchar(50)
declare @Tercero2 char (21)
declare @Tercero_Nombre2 char(31)

SET @Tercero2 = replace(@Tercero,'''','''''')
SET @Tercero_Nombre2 = replace(@Tercero_Nombre,'''','''''')

select @CNT = count(1) from DYNAMICS..SY00302
set @Año1 = @Año 
set @Año2 = @Año 

set @SQL = '' 
	if @f<13 
	begin		
		set @SQL = 'update nsaIF_GL00050 set ' 
		
	end

	set @Count = 0 
	while (@f< 13)    
	begin      	
	
		set @Cred ='nsaIF_SCred_' + LTRIM(RTRIM(str(@f)))         
		set @Deb = 'nsaIF_SDeb_' + LTRIM(RTRIM(str(@f)))           
		set @s_f = 'nsaIF_SF_'+LTRIM(RTRIM(str(@f)))       
		set @s_i = 'nsaIF_SI_'+LTRIM(RTRIM(str(@f)))  
		set @s_ii = 'nsaIF_SI_'+LTRIM(RTRIM(str(@f-1)))   

		/*Old Code*/ 
		/*if @f <> 0 set @SQL = @SQL + ', '*/ 
		/*New Code*/ 
		/*if @f <> 0 and @Count >1 set @SQL = @SQL + ', ' */

		if @Count = 0 
		begin 
			set @SQL = @SQL + @Cred + '=' + @Cred + '+' +RTRIM(LTRIM(str(@Credito,19,5))) + ','  
			+ @Deb + '=' + @Deb + '+' + RTRIM(LTRIM(str(@Debito,19,5))) + ',' 
			+ @s_f + ' = ' 	+ '(' + (@Deb + '+' + RTRIM(LTRIM(str(@Debito,19,5)))) + ')' 
			+ '-' + '(' + (@Cred + '+' +RTRIM(LTRIM(str(@Credito,19,5)))) + ')' 
			+ '+' + @s_i 
		end 
		else
		begin
			if @Debito > @Credito
				set @SQL = @SQL + ', ' + @s_f + ' = ' + @s_f + '+ ' + RTRIM(LTRIM(str(@Debito,19,5)))
			else
				set @SQL = @SQL + ', ' + @s_f + ' = ' + @s_f + '- ' + RTRIM(LTRIM(str(@Credito,19,5)))   				
		end 
		
		if (@f < 12) and @Count <> 0
		begin
			if @Debito > @Credito
				set @SQL = @SQL + ', nsaIF_SI_' + LTRIM(RTRIM(str(@f+1))) + ' = nsaIF_SI_' + LTRIM(RTRIM(str(@f+1))) + '+ ' + RTRIM(LTRIM(str(@Debito,19,5)))	
			else
				set @SQL = @SQL + ', nsaIF_SI_' + LTRIM(RTRIM(str(@f+1))) + ' = nsaIF_SI_' + LTRIM(RTRIM(str(@f+1))) + '- ' + RTRIM(LTRIM(str(@Credito,19,5)))	
		end
		
		set @f = @f+1 
		set @Count = @Count + 1 
	end 
	if @SQL <> '' and @Count <> 0
	begin 
		set @SQL = @SQL + ' where ACTINDX=' + RTRIM(LTRIM(str(@Indice))) 
		+ ' and nsaIF_YEAR=' + RTRIM(LTRIM( str(@Año)))  
		+ ' and ORMSTRID=' + char(39) + RTRIM(LTRIM( @Tercero2))  + char(39)  
		exec (@SQL)    
	end 


	if @Tercero in ( select nsaIFNit from nsaIF01666 where @Tercero =VENDORID)   
		update nsaIF_GL00050 set nsaIF_Type_Nit = (select nsaIF_Type_Nit from nsaIF01666  where VENDORID=@Tercero), nsaIFNit=(select nsaIFNit from nsaIF01666  where VENDORID=@Tercero) 
		where ACTINDX=@Indice and nsaIF_YEAR=@Año and ORMSTRID=@Tercero     
	else if @Tercero in ( select nsaIFNit from nsaIF02666 where @Tercero=CUSTNMBR)    
		update nsaIF_GL00050 set nsaIF_Type_Nit = (select nsaIF_Type_Nit from nsaIF02666  where CUSTNMBR=@Tercero) , nsaIFNit=(select nsaIFNit from nsaIF02666  where CUSTNMBR=@Tercero) 
		where ACTINDX=@Indice and nsaIF_YEAR=@Año and ORMSTRID=@Tercero    	

	if @CNT = 1 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1 '
	end
	else if @CNT = 2 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2 '
	end
	else if @CNT = 3 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2, nsaIF_GL00050.ACTNUMBR_3=GL00100.ACTNUMBR_3 '
	end
	else if @CNT = 4 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2, nsaIF_GL00050.ACTNUMBR_3=GL00100.ACTNUMBR_3, nsaIF_GL00050.ACTNUMBR_4=GL00100.ACTNUMBR_4 '
	end
	else if @CNT = 5 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2, nsaIF_GL00050.ACTNUMBR_3=GL00100.ACTNUMBR_3, nsaIF_GL00050.ACTNUMBR_4=GL00100.ACTNUMBR_4, nsaIF_GL00050.ACTNUMBR_5=GL00100.ACTNUMBR_5 '
	end
	else if @CNT = 6 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2, nsaIF_GL00050.ACTNUMBR_3=GL00100.ACTNUMBR_3, nsaIF_GL00050.ACTNUMBR_4=GL00100.ACTNUMBR_4, nsaIF_GL00050.ACTNUMBR_5=GL00100.ACTNUMBR_5, nsaIF_GL00050.ACTNUMBR_6=GL00100.ACTNUMBR_6 '
	end
	else if @CNT = 7 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2, nsaIF_GL00050.ACTNUMBR_3=GL00100.ACTNUMBR_3, nsaIF_GL00050.ACTNUMBR_4=GL00100.ACTNUMBR_4, nsaIF_GL00050.ACTNUMBR_5=GL00100.ACTNUMBR_5, nsaIF_GL00050.ACTNUMBR_6=GL00100.ACTNUMBR_6, nsaIF_GL00050.ACTNUMBR_7=GL00100.ACTNUMBR_7 '
	end
	else if @CNT = 8 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2, nsaIF_GL00050.ACTNUMBR_3=GL00100.ACTNUMBR_3, nsaIF_GL00050.ACTNUMBR_4=GL00100.ACTNUMBR_4, nsaIF_GL00050.ACTNUMBR_5=GL00100.ACTNUMBR_5, nsaIF_GL00050.ACTNUMBR_6=GL00100.ACTNUMBR_6, nsaIF_GL00050.ACTNUMBR_7=GL00100.ACTNUMBR_7, nsaIF_GL00050.ACTNUMBR_8=GL00100.ACTNUMBR_8 '
	end
	else if @CNT = 9 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2, nsaIF_GL00050.ACTNUMBR_3=GL00100.ACTNUMBR_3, nsaIF_GL00050.ACTNUMBR_4=GL00100.ACTNUMBR_4, nsaIF_GL00050.ACTNUMBR_5=GL00100.ACTNUMBR_5, nsaIF_GL00050.ACTNUMBR_6=GL00100.ACTNUMBR_6, nsaIF_GL00050.ACTNUMBR_7=GL00100.ACTNUMBR_7, nsaIF_GL00050.ACTNUMBR_8=GL00100.ACTNUMBR_8, nsaIF_GL00050.ACTNUMBR_9=GL00100.ACTNUMBR_9 '
	end
	else if @CNT = 10 
	begin
		set @ACTS = ' nsaIF_GL00050.ACTNUMBR_1=GL00100.ACTNUMBR_1, nsaIF_GL00050.ACTNUMBR_2=GL00100.ACTNUMBR_2, nsaIF_GL00050.ACTNUMBR_3=GL00100.ACTNUMBR_3, nsaIF_GL00050.ACTNUMBR_4=GL00100.ACTNUMBR_4, nsaIF_GL00050.ACTNUMBR_5=GL00100.ACTNUMBR_5, nsaIF_GL00050.ACTNUMBR_6=GL00100.ACTNUMBR_6, nsaIF_GL00050.ACTNUMBR_7=GL00100.ACTNUMBR_7, nsaIF_GL00050.ACTNUMBR_8=GL00100.ACTNUMBR_8, nsaIF_GL00050.ACTNUMBR_9=GL00100.ACTNUMBR_9, nsaIF_GL00050.ACTNUMBR_10=GL00100.ACTNUMBR_10 '
	end
	set @SQLS ='update nsaIF_GL00050 set '+ @ACTS +' from GL00100 INNER JOIN nsaIF_GL00050 ON GL00100.ACTINDX = nsaIF_GL00050.ACTINDX  where GL00100.ACTINDX = ' + RTRIM(LTRIM(str(@Indice))) + ' and nsaIF_GL00050.nsaIF_YEAR= ' +       RTRIM(LTRIM( str(@Año)))  + ' and nsaIF_GL00050.ORMSTRID= ' + char(39) + RTRIM(LTRIM( @Tercero2))  + char(39)             
	exec( @SQLS)  

	set @PostingType = (Select PSTNGTYP from GL00100 where ACTINDX =  RTRIM(LTRIM(str(@Indice))))   	
	if ( @PostingType=0 ) 
	begin  
		set @Año=@Año+1    
		while exists (select YEAR1 from SY40101   where YEAR1=@Año)   
		begin  
		set @s_i = @s_f               
		set @f = 1   
		if @Tercero not in (select ORMSTRID from nsaIF_GL00050 where ACTINDX=@Indice and nsaIF_YEAR=@Año and ORMSTRID=@Tercero )    
		begin    
			SET @ACTNUMST = (SELECT ACTNUMST FROM GL00105 WHERE ACTINDX= @Indice)   
			if @CNT = 1 
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 2
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2],[ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 3
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 4
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], 
				[ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 5
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5], 
				[ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''','''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 6
			begin
				EXEC( 'INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5],
				[ACTNUMBR_6], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''','''','''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 7
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5],
				[ACTNUMBR_6], [ACTNUMBR_7] , [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''','''','''', '''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 8
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5],
				[ACTNUMBR_6], [ACTNUMBR_7], [ACTNUMBR_8], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''','''','''', '''', '''','''',  '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 9
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5],
				[ACTNUMBR_6], [ACTNUMBR_7], [ACTNUMBR_8], [ACTNUMBR_9], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''','''','''', '''', '''','''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end
			else if @CNT = 10
			begin
				EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5],
				[ACTNUMBR_6], [ACTNUMBR_7], [ACTNUMBR_8], [ACTNUMBR_9], [ACTNUMBR_10], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0],
				[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8],
				[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5],
				[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
				[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2],
				[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12])
				VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''', '''', '''','''','''', '''', '''','''', '''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
			end 
		end   
		
		set @Cred ='nsaIF_SCred_' + LTRIM(RTRIM(str(@f)))   
		set @Deb = 'nsaIF_SDeb_' + LTRIM(RTRIM(str(@f)))   
		
		if exists(select nsaIF_SF_12 from nsaIF_GL00050 where ACTINDX= @Indice and nsaIF_YEAR= (@Año - 1)  and ORMSTRID= @Tercero)  
		update nsaIF_GL00050 set nsaIF_SI_1 = (select nsaIF_SF_12 from nsaIF_GL00050 where ACTINDX= @Indice and nsaIF_YEAR= (@Año - 1)  and ORMSTRID= @Tercero)   where ACTINDX= RTRIM(LTRIM(str(@Indice)))  and nsaIF_YEAR= RTRIM(LTRIM( str(@Año)))  and ORMSTRID= RTRIM(LTRIM( @Tercero))             

		set @SQL = '' 
		set @Count = 0 
		if @f<13 set @SQL = 'update nsaIF_GL00050 set ' 
		while (@f< 13)   
		begin   
			set @Cred ='nsaIF_SCred_' + LTRIM(RTRIM(str(@f)))   
			set @Deb = 'nsaIF_SDeb_' + LTRIM(RTRIM(str(@f)))   
			set @s_f = 'nsaIF_SF_'+LTRIM(RTRIM(str(@f)))   
			set @s_i = 'nsaIF_SI_'+LTRIM(RTRIM(str(@f)))   
			if @f <> 0 and @Count <> 0 set @SQL = @SQL + ', ' 
			set @SQL = @SQL + @s_f + ' = ' + @Deb + '-' + @Cred + '+' + @s_i 
			if (@f < 12) set @SQL = @SQL + ', nsaIF_SI_' + LTRIM(RTRIM(str(@f+1))) + ' = ' + @s_f 	
			
			set @f=@f+1   
			set @Count = @Count + 1 
		end    

		if @SQL <> '' 
		begin 
			set @SQL = @SQL + ' where ACTINDX='+RTRIM(LTRIM(str(@Indice))) 
			+ ' and nsaIF_YEAR='+RTRIM(LTRIM( str(@Año))) 
			+ ' and ORMSTRID='+ char(39)+ RTRIM(LTRIM( @Tercero2))+ char(39)   
			exec (@SQL) 
		end 

		if @Tercero in ( select nsaIFNit from nsaIF01666 where @Tercero = VENDORID)    
			update nsaIF_GL00050 set 	nsaIF_Type_Nit=(select nsaIF_Type_Nit from nsaIF01666 where VENDORID=@Tercero), nsaIFNit=(select nsaIFNit from nsaIF01666  where VENDORID=@Tercero) 
			where ACTINDX=@Indice and nsaIF_YEAR=@Año and ORMSTRID=@Tercero    

		else if @Tercero in ( select nsaIFNit from nsaIF02666 where @Tercero=CUSTNMBR)   
			update nsaIF_GL00050 set 	nsaIF_Type_Nit=(select nsaIF_Type_Nit from nsaIF02666  where CUSTNMBR=@Tercero), nsaIFNit=(select nsaIFNit from nsaIF02666  where CUSTNMBR=@Tercero)     
			where ACTINDX=@Indice and nsaIF_YEAR=@Año and ORMSTRID=@Tercero    	

		set @Año=@Año+1   
	end  


	set @SQLS =' update nsaIF_GL00050 set '+ @ACTS +' from GL00100 INNER JOIN nsaIF_GL00050 ON GL00100.ACTINDX = nsaIF_GL00050.ACTINDX  where GL00100.ACTINDX = ' + str(@Indice) + ' and nsaIF_GL00050.nsaIF_YEAR > ' + str(@Año2) + ' and nsaIF_GL00050.ORMSTRID = ' + char(39)+ @Tercero2  + char(39) 
	exec( @SQLS)  
end  /*end of SP*/
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON [dbo].[nsaIF_Update_Table] TO [DYNGRP] 
GO 
/*End_nsaIF_Update_Table*/
/*Begin_ProcessCertificadosOpenY*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ProcessCertificadosOpenY]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[ProcessCertificadosOpenY]
GO

CREATE PROCEDURE ProcessCertificadosOpenY 
( 
@IN_Msg		char(10), 
@YEAR	int 
)  
AS  
BEGIN  
DECLARE @CONT			INT  
DECLARE @JRNENTRY		INT 
DECLARE @ORCTRNUM		VARCHAR(50) 
DECLARE @ORMSTRID		VARCHAR(50) 
DECLARE @SOURCDOC		VARCHAR(11) 
DECLARE @SERIES			SMALLINT 
DECLARE @ORTRXTYP		SMALLINT 
DECLARE @ORDOCNUM		VARCHAR(50) 
DECLARE @ORGNTSRC		VARCHAR(15) 
DECLARE @Num_Factura	VARCHAR(50) 
DECLARE @ORGNATYP		SMALLINT 
DECLARE @l_Fin			INT 
DECLARE @ACTINDX		INT 
DECLARE @TACTINDX		INT 
DECLARE @EXISTS			INT 
DECLARE @EXISTS1		INT 
DECLARE @DEBITAMT		NUMERIC(19,5) 
DECLARE @CRDTAMNT		NUMERIC(19,5) 
DECLARE @OPENYEAR		SMALLINT 
DECLARE @TRXDATE		DATETIME 
DECLARE @TAXDTLID		CHAR(15) 
DECLARE @TAXAMNT		NUMERIC(19,5) 
DECLARE @TDTTXPUR		NUMERIC(19,5) 
DECLARE @L_FIN1			INT 
DECLARE @nsaIFNit		CHAR(15) 
DECLARE @CMNYTXID		CHAR(15) 
DECLARE @nsaIF_CV		SMALLINT 
DECLARE @nsaIF_CI		SMALLINT 
DECLARE @PRCNTOFTTL		NUMERIC(19,5) 
DECLARE @TXDTLPCT		NUMERIC(19,5) 
DECLARE @ROWCNT			INT 
DECLARE @BAND			INT 
DECLARE @TRXSORCE		CHAR(13) 
DECLARE @VENDORID		CHAR(15) 
DECLARE WITHHOLD CURSOR FOR  
SELECT JRNENTRY, ORCTRNUM, ORMSTRID, SOURCDOC,SERIES, ORTRXTYP, ORDOCNUM, ORGNTSRC,ORGNATYP, ACTINDX, DEBITAMT, CRDTAMNT, OPENYEAR, TRXDATE, TRXSORCE FROM GL20000 
WHERE OPENYEAR = @YEAR AND SERIES = 4 AND SOURCDOC <> @IN_Msg 
AND ACTINDX IN ( SELECT DISTINCT ACTINDX FROM nsaIF_GL00100 WHERE nsaIF_CI > 0) 
/* nsaIF_Create_Certificados_Open */ 
OPEN WITHHOLD 
FETCH NEXT FROM WITHHOLD INTO @JRNENTRY, @ORCTRNUM, @ORMSTRID, @SOURCDOC
,@SERIES, @ORTRXTYP, @ORDOCNUM, @ORGNTSRC, @ORGNATYP, @ACTINDX, @DEBITAMT, @CRDTAMNT, @OPENYEAR, @TRXDATE, @TRXSORCE 
WHILE @@FETCH_STATUS = 0  
BEGIN 
SET @CONT = 0 
SET @l_Fin = 0 
SET @Num_Factura = @ORCTRNUM 
/*	nsaIF_Num_Fact_POP */ 
SELECT @CONT = 1
, @Num_Factura = VCHRNMBR FROM POP30300 WHERE POPRCTNM  = @ORCTRNUM	 
IF @CONT = 0 SET @Num_Factura = @ORCTRNUM 
SET @CONT = 0	 
SELECT @CONT = 1 FROM PM30200 WHERE VCHRNMBR = @Num_Factura AND VOIDED = 1 AND VENDORID = @ORMSTRID AND DOCTYPE = @ORGNATYP 
IF @CONT = 0  
BEGIN 
/*	nsaIF_Create_Certificados_Purchases	*/ 
SET @EXISTS	= 0 
SELECT @EXISTS = COUNT(1) FROM PM10500 WHERE VCHRNMBR = @Num_Factura AND ACTINDX = @ACTINDX AND VENDORID = @ORMSTRID 
IF ( @EXISTS = 0 ) 
BEGIN 
/*		nsaIF_Create_Certificados_Purchases_WORK		*/ 
SET @EXISTS1 = 0 
IF EXISTS(SELECT COUNT(1) FROM PM30700 WHERE VCHRNMBR = @Num_Factura AND ACTINDX = @ACTINDX AND VENDORID = @ORMSTRID) 
BEGIN				 
SET @L_FIN1  = 0 
DECLARE CURPM30700 CURSOR FOR  
SELECT TAXDTLID, TAXAMNT, TDTTXPUR, 
ACTINDX, VENDORID FROM PM30700  
WHERE VCHRNMBR =  @Num_Factura AND ACTINDX = @ACTINDX AND ABS(TAXAMNT) = ABS(@DEBITAMT + @CRDTAMNT) 
OPEN CURPM30700 
FETCH NEXT FROM CURPM30700 INTO @TAXDTLID, @TAXAMNT, @TDTTXPUR, @TACTINDX, @VENDORID  
WHILE @@FETCH_STATUS = 0 AND @L_FIN1 <> 1 
BEGIN 
IF @TACTINDX = @ACTINDX AND ABS(@TAXAMNT) = ABS(@DEBITAMT + @CRDTAMNT) 
BEGIN 
SELECT @ROWCNT = COUNT(1) FROM nsaIF_GL10000  
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @OPENYEAR AND TAXDTLID = @TAXDTLID 
IF (@ROWCNT > 0) 
BEGIN 
SET @nsaIF_CV = 0 
SET @nsaIFNit = ''	 
SET @CMNYTXID = '' 
SET	@nsaIF_CI = 0 
SET @PRCNTOFTTL = 0 
SELECT TOP 1 @nsaIF_CI = nsaIF_CI FROM nsaIF_GL00100 WHERE ACTINDX = @ACTINDX AND nsaIF_CI > 0 
SELECT @nsaIFNit = nsaIFNit, @nsaIF_CV  =nsaIF_CV FROM nsaIF01666 WHERE VENDORID = @ORMSTRID							 
SELECT @PRCNTOFTTL = ABS(TXDTLPCT), @CMNYTXID = CMNYTXID FROM TX00201 WHERE TAXDTLID = @TAXDTLID 
SELECT @PRCNTOFTTL = (TXDTLPCT * -1), @CMNYTXID = CMNYTXID FROM TX00201 WHERE TAXDTLID = @TAXDTLID AND TXDTLPCT < 0
IF (@DEBITAMT - @CRDTAMNT) <  0  
BEGIN 
UPDATE  nsaIF_GL10000 SET nsaIFNit = @nsaIFNit, PRCNTOFTTL = @PRCNTOFTTL, TXDTSPTX = ABS(@TAXAMNT), TXDTTXSP = ABS(@TDTTXPUR),  CMNYTXID = @CMNYTXID, 
nsaIF_CI = @nsaIF_CI, nsaIF_CV = @nsaIF_CV, SERIES = 4,TRXSORCE = @TRXSORCE 
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @OPENYEAR AND TAXDTLID = @TAXDTLID 
END 
ELSE 
BEGIN 
UPDATE  nsaIF_GL10000 SET nsaIFNit = @nsaIFNit, PRCNTOFTTL = @PRCNTOFTTL, TXDTSPTX = (ABS(@TAXAMNT) * -1), TXDTTXSP = (ABS(@TDTTXPUR) * -1),  CMNYTXID = @CMNYTXID, nsaIF_CI = @nsaIF_CI, nsaIF_CV = @nsaIF_CV, SERIES = 4,TRXSORCE = @TRXSORCE 
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @OPENYEAR AND TAXDTLID = @TAXDTLID 
END	 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1				 
END 
ELSE IF (@ROWCNT = 0)  
BEGIN 
SET @nsaIF_CV = 0 
SET @nsaIFNit = ''	 
SET @CMNYTXID = '' 
SET	@nsaIF_CI = 0 
SET @PRCNTOFTTL = 0 
SELECT TOP 1 @nsaIF_CI = nsaIF_CI FROM nsaIF_GL00100 WHERE ACTINDX = @ACTINDX AND nsaIF_CI > 0 
SELECT @nsaIFNit = nsaIFNit, @nsaIF_CV  =nsaIF_CV FROM nsaIF01666 WHERE VENDORID = @ORMSTRID							 
SELECT @PRCNTOFTTL = ABS(TXDTLPCT), @CMNYTXID = CMNYTXID FROM TX00201 WHERE TAXDTLID = @TAXDTLID 
SELECT @PRCNTOFTTL = (TXDTLPCT * -1) FROM TX00201 WHERE TAXDTLID = @TAXDTLID AND TXDTLPCT < 0
IF (@DEBITAMT - @CRDTAMNT) <  0 
BEGIN 
INSERT INTO nsaIF_GL10000(ORDOCNUM, ORMSTRID, TAXDTLID, nsaIFNit,  
YEAR1, PERIODID, PRCNTOFTTL, TXDTTXSP, TXDTSPTX, CMNYTXID,  
nsaIF_CI, nsaIF_CV, SERIES, TRXSORCE) 
SELECT @Num_Factura, @ORMSTRID, @TAXDTLID,@nsaIFNit, 
@OPENYEAR, MONTH(@TRXDATE), @PRCNTOFTTL,ABS(@TDTTXPUR) , ABS(@TAXAMNT), @CMNYTXID, 
@nsaIF_CI, @nsaIF_CV,4,@TRXSORCE		 
END 
ELSE 
BEGIN 
INSERT INTO nsaIF_GL10000(ORDOCNUM, ORMSTRID, TAXDTLID, nsaIFNit,  
YEAR1, PERIODID, PRCNTOFTTL, TXDTTXSP, TXDTSPTX, CMNYTXID,  
nsaIF_CI, nsaIF_CV, SERIES, TRXSORCE) 
SELECT @Num_Factura, @ORMSTRID, @TAXDTLID,@nsaIFNit, 
@OPENYEAR, MONTH(@TRXDATE), @PRCNTOFTTL,(ABS(@TDTTXPUR) * -1) , (ABS(@TAXAMNT) * -1), @CMNYTXID, 
@nsaIF_CI, @nsaIF_CV,4,@TRXSORCE 
END 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1		 
END		 
END 
FETCH NEXT FROM CURPM30700 INTO @TAXDTLID, @TAXAMNT, @TDTTXPUR, @TACTINDX, @VENDORID  
END 
CLOSE CURPM30700 
DEALLOCATE CURPM30700 
END 
/*		nsaIF_Create_Certificados_Purchases_WORK		*/ 
END		 
ELSE IF ( @EXISTS > 0 )  
BEGIN 
SET @L_FIN1  = 0 
DECLARE CURPM10500 CURSOR FOR  
SELECT TAXDTLID, TAXAMNT, TDTTXPUR, ACTINDX, VENDORID FROM PM10500  
WHERE VCHRNMBR =  @Num_Factura AND ACTINDX = @ACTINDX AND ABS(TAXAMNT) = ABS(@DEBITAMT + @CRDTAMNT) 
OPEN CURPM10500 
FETCH NEXT FROM CURPM10500 INTO @TAXDTLID, @TAXAMNT, @TDTTXPUR, @TACTINDX, @VENDORID  
WHILE @@FETCH_STATUS = 0 AND @L_FIN1 <> 1 
BEGIN 
IF @TACTINDX = @ACTINDX AND ABS(@TAXAMNT) = ABS(@DEBITAMT + @CRDTAMNT) 
BEGIN 
SELECT @ROWCNT = COUNT(1) FROM nsaIF_GL10000  
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @OPENYEAR AND TAXDTLID = @TAXDTLID 
IF (@ROWCNT > 0) 
BEGIN 
SET @nsaIF_CV = 0 
SET @TXDTLPCT = 0 
SET @nsaIFNit = ''	 
SET @CMNYTXID = '' 
SET	@nsaIF_CI = 0 
SET @PRCNTOFTTL = 0 
SET @BAND = 0 
SELECT TOP 1 @nsaIF_CI = nsaIF_CI FROM nsaIF_GL00100 WHERE ACTINDX = @ACTINDX AND nsaIF_CI > 0 
SELECT @nsaIFNit = nsaIFNit, @nsaIF_CV  =nsaIF_CV FROM nsaIF01666 WHERE VENDORID = @ORMSTRID							 
SELECT @PRCNTOFTTL = ABS(TXDTLPCT), @CMNYTXID = CMNYTXID, @TXDTLPCT = TXDTLPCT FROM TX00201 WHERE TAXDTLID = @TAXDTLID 
SELECT @PRCNTOFTTL = (TXDTLPCT * -1) FROM TX00201 WHERE TAXDTLID = @TAXDTLID AND TXDTLPCT < 0
IF @TXDTLPCT > 0 SET @BAND = 1 
IF (@BAND = 0) 
BEGIN 
IF (@DEBITAMT - @CRDTAMNT) <  0  
BEGIN 
UPDATE  nsaIF_GL10000 SET nsaIFNit = @nsaIFNit, PRCNTOFTTL =
 @PRCNTOFTTL, TXDTSPTX = ABS(@TAXAMNT), TXDTTXSP = ABS(@TDTTXPUR),  CMNYTXID = @CMNYTXID, nsaIF_CI = @nsaIF_CI, nsaIF_CV = @nsaIF_CV, SERIES = 4,TRXSORCE = @TRXSORCE 
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @OPENYEAR AND TAXDTLID = @TAXDTLID 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1	 
END 
ELSE 
BEGIN 
UPDATE  nsaIF_GL10000 SET nsaIFNit = @nsaIFNit, PRCNTOFTTL = @PRCNTOFTTL, TXDTSPTX = (ABS(@TAXAMNT) * -1), TXDTTXSP = (ABS(@TDTTXPUR) * -1),  CMNYTXID = @CMNYTXID, nsaIF_CI = @nsaIF_CI, nsaIF_CV = @nsaIF_CV, SERIES = 4,TRXSORCE = @TRXSORCE 
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @OPENYEAR AND TAXDTLID = @TAXDTLID 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1	 

END	 
END 
END 
ELSE IF (@ROWCNT = 0)  
BEGIN 
SET @nsaIF_CV = 0  
SET @TXDTLPCT = 0 
SET @nsaIFNit = ''	 
SET @CMNYTXID = '' 
SET	@nsaIF_CI = 0 
SET @PRCNTOFTTL = 0 
SET @BAND = 0 
SELECT TOP 1 @nsaIF_CI = nsaIF_CI FROM nsaIF_GL00100 WHERE ACTINDX = @ACTINDX AND nsaIF_CI > 0 
SELECT @nsaIFNit = nsaIFNit, @nsaIF_CV  =nsaIF_CV FROM nsaIF01666 WHERE VENDORID = @ORMSTRID							 
SELECT @PRCNTOFTTL = ABS(TXDTLPCT), @CMNYTXID = CMNYTXID, @TXDTLPCT = TXDTLPCT FROM TX00201 WHERE TAXDTLID = @TAXDTLID 
SELECT @PRCNTOFTTL = (TXDTLPCT * -1) FROM TX00201 WHERE TAXDTLID = @TAXDTLID AND TXDTLPCT < 0
IF @TXDTLPCT > 0 SET @BAND = 1 
IF (@BAND = 0) 
BEGIN 
IF (@DEBITAMT - @CRDTAMNT) <  0 
BEGIN 
INSERT INTO nsaIF_GL10000(ORDOCNUM, ORMSTRID, TAXDTLID, nsaIFNit,  
YEAR1, PERIODID, PRCNTOFTTL, TXDTTXSP, TXDTSPTX, CMNYTXID,  
nsaIF_CI, nsaIF_CV, SERIES, TRXSORCE) 
SELECT @Num_Factura, @ORMSTRID, @TAXDTLID,@nsaIFNit, 
@OPENYEAR, MONTH(@TRXDATE), @PRCNTOFTTL,ABS(@TDTTXPUR) , ABS(@TAXAMNT), @CMNYTXID, 
@nsaIF_CI, @nsaIF_CV,4,@TRXSORCE	 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1	 
END 
ELSE 
BEGIN 
INSERT INTO nsaIF_GL10000(ORDOCNUM, ORMSTRID, TAXDTLID, nsaIFNit,  
YEAR1, PERIODID, PRCNTOFTTL, TXDTTXSP, TXDTSPTX, CMNYTXID,  
nsaIF_CI, nsaIF_CV, SERIES, TRXSORCE) 
SELECT @Num_Factura, @ORMSTRID, @TAXDTLID,@nsaIFNit, 
@OPENYEAR, MONTH(@TRXDATE), @PRCNTOFTTL,(ABS(@TDTTXPUR) * -1) , (ABS(@TAXAMNT) * -1), @CMNYTXID, 
@nsaIF_CI, @nsaIF_CV,4,@TRXSORCE 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1 
END 
END			 
END		 
END 
FETCH NEXT FROM CURPM10500 INTO @TAXDTLID, @TAXAMNT, @TDTTXPUR, @TACTINDX, @VENDORID  
END 
CLOSE CURPM10500 
DEALLOCATE CURPM10500 
END 
/*	nsaIF_Create_Certificados_Purchases	*/ 
END 
FETCH NEXT FROM WITHHOLD INTO @JRNENTRY, @ORCTRNUM, @ORMSTRID, @SOURCDOC,@SERIES, @ORTRXTYP, @ORDOCNUM, @ORGNTSRC, @ORGNATYP, @ACTINDX, @DEBITAMT, @CRDTAMNT, @OPENYEAR, @TRXDATE, @TRXSORCE 
END 
CLOSE WITHHOLD 
DEALLOCATE WITHHOLD 
/* nsaIF_Create_Certificados_Open */ 
END 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[ProcessCertificadosOpenY] TO [DYNGRP] 
GO 
/*End_ProcessCertificadosOpenY*/
/*Begin_ProcessCertificadosHistY*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ProcessCertificadosHistY]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[ProcessCertificadosHistY]
GO

CREATE PROCEDURE ProcessCertificadosHistY 
( 
@IN_Msg		char(10), 
@YEAR	int 
) 
AS 
BEGIN 
DECLARE @CONT			INT 
DECLARE @JRNENTRY		INT 
DECLARE @ORCTRNUM		VARCHAR(50) 
DECLARE @ORMSTRID		VARCHAR(50) 
DECLARE @SOURCDOC		VARCHAR(11) 
DECLARE @SERIES			SMALLINT 
DECLARE @ORTRXTYP		SMALLINT 
DECLARE @ORDOCNUM		VARCHAR(50) 
DECLARE @ORGNTSRC		VARCHAR(15) 
DECLARE @Num_Factura	VARCHAR(50) 
DECLARE @ORGNATYP		SMALLINT 
DECLARE @l_Fin			INT 
DECLARE @ACTINDX		INT 
DECLARE @TACTINDX		INT 
DECLARE @EXISTS			INT 
DECLARE @EXISTS1		INT 
DECLARE @DEBITAMT		NUMERIC(19,5) 
DECLARE @CRDTAMNT		NUMERIC(19,5) 
DECLARE @HSTYEAR		SMALLINT 
DECLARE @TRXDATE		DATETIME 
DECLARE @TAXDTLID		CHAR(15) 
DECLARE @TAXAMNT		NUMERIC(19,5) 
DECLARE @TDTTXPUR		NUMERIC(19,5) 
DECLARE @L_FIN1			INT 
DECLARE @nsaIFNit		CHAR(15) 
DECLARE @CMNYTXID		CHAR(15) 
DECLARE @nsaIF_CV		SMALLINT 
DECLARE @nsaIF_CI		SMALLINT 
DECLARE @PRCNTOFTTL		NUMERIC(19,5) 
DECLARE @TXDTLPCT		NUMERIC(19,5) 
DECLARE @ROWCNT			INT 
DECLARE @BAND			INT 
DECLARE @TRXSORCE		CHAR(13) 
DECLARE @VENDORID		CHAR(15) 
DECLARE WITHHOLD CURSOR FOR  
SELECT JRNENTRY, ORCTRNUM, ORMSTRID, SOURCDOC,SERIES, ORTRXTYP, ORDOCNUM, ORGNTSRC,ORGNATYP, ACTINDX, DEBITAMT, CRDTAMNT, HSTYEAR, TRXDATE,TRXSORCE FROM GL30000 
WHERE HSTYEAR = @YEAR AND SERIES = 4 AND SOURCDOC <> @IN_Msg 
AND ACTINDX IN ( SELECT ACTINDX FROM nsaIF_GL00100 WHERE nsaIF_CI > 0) 
/* nsaIF_Create_Certificados_Hist */ 
OPEN WITHHOLD 
FETCH NEXT FROM WITHHOLD INTO @JRNENTRY, @ORCTRNUM, @ORMSTRID, @SOURCDOC,@SERIES, @ORTRXTYP, @ORDOCNUM, @ORGNTSRC, @ORGNATYP, @ACTINDX, @DEBITAMT, @CRDTAMNT, @HSTYEAR, @TRXDATE,@TRXSORCE 
WHILE @@FETCH_STATUS = 0  
BEGIN 
SET @CONT = 0 
SET @l_Fin = 0 
SET @Num_Factura = @ORCTRNUM 
/*	nsaIF_Num_Fact_POP */ 
SELECT @CONT = 1, @Num_Factura = VCHRNMBR FROM POP30300 WHERE POPRCTNM  = @ORCTRNUM	 
IF @CONT = 0 SET @Num_Factura = @ORCTRNUM	 
SET @CONT = 0	 
SELECT @CONT = 1 FROM PM30200 WHERE VCHRNMBR = @Num_Factura AND VOIDED = 1 AND VENDORID = @ORMSTRID 
AND DOCTYPE = @ORGNATYP 
IF @CONT = 0  
BEGIN 
/*	nsaIF_Create_Certificados_Purchases_Hist	*/ 
SET @EXISTS	= 0 
SELECT @EXISTS = COUNT(1) FROM PM10500 WHERE VCHRNMBR = @Num_Factura AND ACTINDX = @ACTINDX 
IF ( @EXISTS = 0 ) 
BEGIN 
/*		nsaIF_Create_Certificados_Purchases_Hist_WORK		*/ 
SET @EXISTS1 = 0 
IF EXISTS(SELECT COUNT(1) FROM PM30700 WHERE VCHRNMBR = @Num_Factura AND ACTINDX = @ACTINDX) 
BEGIN				 
SET @L_FIN1  = 0 
DECLARE CURPM30700 CURSOR FOR  
SELECT TAXDTLID, TAXAMNT, TDTTXPUR, ACTINDX, VENDORID FROM PM30700  
WHERE VCHRNMBR =  @Num_Factura AND ACTINDX = @ACTINDX AND ABS(TAXAMNT) = ABS(@DEBITAMT + @CRDTAMNT) 
OPEN CURPM30700 
FETCH NEXT FROM CURPM30700 INTO @TAXDTLID, @TAXAMNT, @TDTTXPUR, @TACTINDX, @VENDORID  
WHILE @@FETCH_STATUS = 0 AND @L_FIN1 <> 1 
BEGIN 
IF @TACTINDX = @ACTINDX AND ABS(@TAXAMNT) = ABS(@DEBITAMT + @CRDTAMNT) 
BEGIN 
SELECT @ROWCNT = COUNT(1) FROM nsaIF_GL10000  
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @HSTYEAR AND  TAXDTLID = @TAXDTLID 
IF (@ROWCNT > 0) 
BEGIN 
SET @nsaIF_CV = 0 
SET @TXDTLPCT = 0 
SET @nsaIFNit = ''	 
SET @CMNYTXID = '' 
SET	@nsaIF_CI = 0 
SET @PRCNTOFTTL = 0 
SET @BAND = 0 
SELECT TOP 1 @nsaIF_CI = nsaIF_CI FROM nsaIF_GL00100 WHERE ACTINDX = @ACTINDX AND nsaIF_CI > 0 
SELECT @nsaIFNit = nsaIFNit, @nsaIF_CV  =nsaIF_CV FROM nsaIF01666 WHERE VENDORID = @ORMSTRID 							 
SELECT @PRCNTOFTTL = ABS(TXDTLPCT), @CMNYTXID = CMNYTXID, @TXDTLPCT = TXDTLPCT FROM TX00201 WHERE TAXDTLID = @TAXDTLID 
IF @TXDTLPCT > 0 SET @BAND = 1 
IF (@BAND = 0) 
BEGIN 
IF (@DEBITAMT - @CRDTAMNT) <  0  
BEGIN 
UPDATE  nsaIF_GL10000 SET nsaIFNit = @nsaIFNit, PRCNTOFTTL = @PRCNTOFTTL, TXDTSPTX = ABS(@TAXAMNT), TXDTTXSP = ABS(@TDTTXPUR),  CMNYTXID = @CMNYTXID, nsaIF_CI = @nsaIF_CI, nsaIF_CV = @nsaIF_CV, SERIES = 4, TRXSORCE = @TRXSORCE 
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @HSTYEAR AND TAXDTLID = @TAXDTLID 
END 
ELSE 
BEGIN 
UPDATE  nsaIF_GL10000 SET nsaIFNit = @nsaIFNit, PRCNTOFTTL = @PRCNTOFTTL, TXDTSPTX = (ABS(@TAXAMNT) * -1), TXDTTXSP = (ABS(@TDTTXPUR) * -1),  CMNYTXID = @CMNYTXID, nsaIF_CI = @nsaIF_CI, nsaIF_CV = @nsaIF_CV, SERIES = 4, TRXSORCE = @TRXSORCE 
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND
 PERIODID = MONTH(@TRXDATE) AND YEAR1 = @HSTYEAR AND TAXDTLID = @TAXDTLID 
END	 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1				 
END 
END 
ELSE IF (@ROWCNT = 0)  
BEGIN 
SET @nsaIF_CV = 0 
SET @TXDTLPCT = 0 
SET @nsaIFNit = ''	 
SET @CMNYTXID = '' 
SET	@nsaIF_CI = 0 
SET @PRCNTOFTTL = 0 
SET @BAND = 0 
SELECT TOP 1 @nsaIF_CI = nsaIF_CI FROM nsaIF_GL00100 WHERE ACTINDX = @ACTINDX AND nsaIF_CI > 0 
SELECT @nsaIFNit = nsaIFNit, @nsaIF_CV  =nsaIF_CV FROM nsaIF01666 WHERE VENDORID = @ORMSTRID						 
SELECT @PRCNTOFTTL = ABS(TXDTLPCT), @CMNYTXID = CMNYTXID, @TXDTLPCT = TXDTLPCT FROM TX00201 WHERE TAXDTLID = @TAXDTLID 
IF @TXDTLPCT > 0 SET @BAND = 1 
IF (@BAND = 0) 
BEGIN 
IF (@DEBITAMT - @CRDTAMNT) <  0 
BEGIN 
INSERT INTO nsaIF_GL10000(ORDOCNUM, ORMSTRID, TAXDTLID, nsaIFNit,  
YEAR1, PERIODID, PRCNTOFTTL, TXDTTXSP, TXDTSPTX, CMNYTXID,  
nsaIF_CI, nsaIF_CV, SERIES, TRXSORCE) 
SELECT @Num_Factura, @ORMSTRID, @TAXDTLID,@nsaIFNit, 
@HSTYEAR, MONTH(@TRXDATE), @PRCNTOFTTL,ABS(@TDTTXPUR) , ABS(@TAXAMNT), @CMNYTXID, 
@nsaIF_CI, @nsaIF_CV,4,@TRXSORCE		 
END 
ELSE 
BEGIN 
INSERT INTO nsaIF_GL10000(ORDOCNUM, ORMSTRID, TAXDTLID, nsaIFNit,  
YEAR1, PERIODID, PRCNTOFTTL, TXDTTXSP, TXDTSPTX, CMNYTXID,  
nsaIF_CI, nsaIF_CV, SERIES, TRXSORCE) 
SELECT @Num_Factura, @ORMSTRID, @TAXDTLID,
@nsaIFNit, 
@HSTYEAR, MONTH(@TRXDATE), @PRCNTOFTTL,(ABS(@TDTTXPUR) * -1) , (ABS(@TAXAMNT) * -1), @CMNYTXID, 
@nsaIF_CI, @nsaIF_CV,4,@TRXSORCE 
END 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1		 
END 
END		 
END 
FETCH NEXT FROM CURPM30700 INTO @TAXDTLID, @TAXAMNT, @TDTTXPUR, @TACTINDX, @VENDORID  
END 
CLOSE CURPM30700 
DEALLOCATE CURPM30700 
END 
/*		nsaIF_Create_Certificados_Purchases_Hist_WORK		*/ 
END		 
ELSE IF ( @EXISTS > 0 )  
BEGIN 
SET @L_FIN1  = 0 
DECLARE CURPM10500 CURSOR FOR  
SELECT TAXDTLID, TAXAMNT,
 TDTTXPUR, ACTINDX, VENDORID FROM PM10500  
WHERE VCHRNMBR =  @Num_Factura AND ACTINDX = @ACTINDX AND ABS(TAXAMNT) = ABS(@DEBITAMT + @CRDTAMNT) 
OPEN CURPM10500 
FETCH NEXT FROM CURPM10500 INTO @TAXDTLID, @TAXAMNT, @TDTTXPUR, @TACTINDX, @VENDORID  
WHILE 
@@FETCH_STATUS = 0 AND @L_FIN1 <> 1 
BEGIN 
IF @TACTINDX = @ACTINDX AND ABS(@TAXAMNT) = ABS(@DEBITAMT + @CRDTAMNT) 
BEGIN					 
SELECT @ROWCNT = COUNT(1) FROM nsaIF_GL10000  
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @HSTYEAR AND TAXDTLID = @TAXDTLID 
IF (@ROWCNT > 0) 
BEGIN 
SET @nsaIF_CV = 0 
SET @nsaIFNit = ''	 
SET @CMNYTXID = '' 
SET	@nsaIF_CI = 0 
SET @PRCNTOFTTL = 0 
SET @BAND = 0 
SELECT TOP 1 @nsaIF_CI = nsaIF_CI FROM nsaIF_GL00100 WHERE ACTINDX = @ACTINDX AND nsaIF_CI > 0 
SELECT @nsaIFNit = nsaIFNit, @nsaIF_CV  =nsaIF_CV FROM nsaIF01666 WHERE VENDORID = @ORMSTRID	
SELECT @PRCNTOFTTL = ABS(TXDTLPCT), @CMNYTXID = CMNYTXID, @TXDTLPCT = TXDTLPCT FROM TX00201 WHERE TAXDTLID = @TAXDTLID 
IF @TXDTLPCT > 0 SET @BAND = 1 
IF @BAND = 0 
BEGIN 
IF (@DEBITAMT - @CRDTAMNT) <  0  
BEGIN 
UPDATE  nsaIF_GL10000 SET nsaIFNit = @nsaIFNit, PRCNTOFTTL = @PRCNTOFTTL, TXDTSPTX = ABS(@TAXAMNT), TXDTTXSP = ABS(@TDTTXPUR),  CMNYTXID = @CMNYTXID, nsaIF_CI = @nsaIF_CI, nsaIF_CV = @nsaIF_CV, SERIES = 4,TRXSORCE = @TRXSORCE 
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @HSTYEAR AND TAXDTLID = @TAXDTLID 
END 
ELSE 
BEGIN 
UPDATE  nsaIF_GL10000 SET nsaIFNit = @nsaIFNit, PRCNTOFTTL = @PRCNTOFTTL, TXDTSPTX = (ABS(@TAXAMNT) * -1), TXDTTXSP = (ABS(@TDTTXPUR) * -1),  CMNYTXID = @CMNYTXID, nsaIF_CI = @nsaIF_CI, nsaIF_CV = @nsaIF_CV, SERIES = 4, TRXSORCE = @TRXSORCE 
WHERE ORDOCNUM = @Num_Factura AND ORMSTRID = @ORMSTRID AND PERIODID = MONTH(@TRXDATE) AND YEAR1 = @HSTYEAR AND TAXDTLID = @TAXDTLID 
END	 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1				 
END 
END 
ELSE IF (@ROWCNT = 0)  
BEGIN 
SET @nsaIF_CV = 0 
SET @nsaIFNit = ''	 
SET @CMNYTXID = '' 
SET	@nsaIF_CI = 0 
SET @PRCNTOFTTL = 0 
SET @BAND = 0 
SELECT TOP 1 @nsaIF_CI = nsaIF_CI FROM nsaIF_GL00100 WHERE ACTINDX = @ACTINDX AND nsaIF_CI > 0 
SELECT @nsaIFNit = nsaIFNit, @nsaIF_CV  =nsaIF_CV FROM nsaIF01666 WHERE VENDORID = @ORMSTRID 
SELECT @PRCNTOFTTL = ABS(TXDTLPCT), @CMNYTXID = CMNYTXID, @TXDTLPCT = TXDTLPCT FROM TX00201 WHERE TAXDTLID = @TAXDTLID 
IF @TXDTLPCT > 0 SET @BAND = 1 
IF @BAND = 0 
BEGIN 
IF (@DEBITAMT - @CRDTAMNT) <  0 
BEGIN 
INSERT INTO nsaIF_GL10000(ORDOCNUM, ORMSTRID, TAXDTLID, nsaIFNit,  
YEAR1, PERIODID, PRCNTOFTTL, TXDTTXSP, TXDTSPTX, CMNYTXID,  
nsaIF_CI, nsaIF_CV, SERIES, TRXSORCE) 
SELECT @Num_Factura, @ORMSTRID, @TAXDTLID,@nsaIFNit, 
@HSTYEAR, MONTH(@TRXDATE), @PRCNTOFTTL,ABS(@TDTTXPUR) , ABS(@TAXAMNT), @CMNYTXID, 
@nsaIF_CI, @nsaIF_CV,4,@TRXSORCE		 END 
ELSE 
BEGIN 
INSERT INTO nsaIF_GL10000(ORDOCNUM, ORMSTRID, TAXDTLID, nsaIFNit,  
YEAR1, PERIODID, PRCNTOFTTL, TXDTTXSP, TXDTSPTX, CMNYTXID,  
nsaIF_CI, nsaIF_CV, SERIES, TRXSORCE) 
SELECT @Num_Factura, @ORMSTRID, @TAXDTLID,@nsaIFNit, 
@HSTYEAR, MONTH
(@TRXDATE), @PRCNTOFTTL,(ABS(@TDTTXPUR) * -1) , (ABS(@TAXAMNT) * -1), @CMNYTXID, 
@nsaIF_CI, @nsaIF_CV,4,@TRXSORCE 
END 
IF @@ROWCOUNT > 0	SET @L_FIN1 = 1		 
END		 
END		 
END 
FETCH NEXT FROM CURPM10500 INTO @TAXDTLID, @TAXAMNT, @TDTTXPUR, @TACTINDX, @VENDORID  
END 
CLOSE CURPM10500 
DEALLOCATE CURPM10500 
END 
/*	nsaIF_Create_Certificados_Purchases_Hist	*/ 
END 
FETCH NEXT FROM WITHHOLD INTO @JRNENTRY, @ORCTRNUM, @ORMSTRID, @SOURCDOC,@SERIES, @ORTRXTYP, @ORDOCNUM, @ORGNTSRC, @ORGNATYP, @ACTINDX, @DEBITAMT, @CRDTAMNT, @HSTYEAR, @TRXDATE,@TRXSORCE 
END 
CLOSE WITHHOLD 
DEALLOCATE WITHHOLD 
/* nsaIF_Create_Certificados_Hist */ 
END 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[ProcessCertificadosHistY] TO [DYNGRP] 
GO 
/*End_ProcessCertificadosHistY*/
/*Begin_nsaIF_UpdateVendorID*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_UpdateVendorID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[nsaIF_UpdateVendorID]
GO

CREATE       procedure nsaIF_UpdateVendorID
@faPurchaseMasterTemp varchar(64) = ''
AS
begin
DECLARE		@ASSETINDEX		INT
DECLARE		@FAPERIODID		SMALLINT
DECLARE		@VENDORID		CHAR(15)
DECLARE		@OLDASSETINDEX	INT
DECLARE		@OLDFAPERIODID	SMALLINT
DECLARE		@OLDVENDORID	CHAR(15)	

	IF @faPurchaseMasterTemp <> ''
	BEGIN
		EXEC('UPDATE IF_FA00905 SET VENDORID = A.VENDORID FROM IF_FA00905 INNER JOIN
			' + @faPurchaseMasterTemp + ' A ON IF_FA00905.ASSETINDEX = A.ASSETINDEX AND
			IF_FA00905.FAPERIOD = A.PERIODID AND A.DEX_ROW_ID = 
			(SELECT MAX(DEX_ROW_ID) FROM ' + @faPurchaseMasterTemp + ' WHERE ASSETINDEX = A.ASSETINDEX
			AND PERIODID = A.PERIODID)')

		DECLARE CURUPDVNDRID CURSOR FAST_FORWARD FOR 
		SELECT DISTINCT ASSETINDEX, FAPERIOD, VENDORID FROM IF_FA00905
		ORDER BY ASSETINDEX, FAPERIOD

		SET @OLDVENDORID = '-~!@$'
		SET @OLDASSETINDEX = 0
		SET @OLDFAPERIODID = 0
		OPEN CURUPDVNDRID
		FETCH NEXT FROM CURUPDVNDRID INTO @ASSETINDEX, @FAPERIODID, @VENDORID
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @VENDORID <> @OLDVENDORID AND @OLDASSETINDEX <> @ASSETINDEX AND @OLDFAPERIODID <> @FAPERIODID
			BEGIN	
				SET @OLDVENDORID = '-~!@$'
				IF @VENDORID <> ''
				BEGIN		
					SET @OLDVENDORID = @VENDORID
				END			
				UPDATE IF_FA00905 SET VENDORID = @VENDORID	
				WHERE ASSETINDEX = @ASSETINDEX AND FAPERIOD = @FAPERIODID				
			END
			ELSE
			BEGIN
				IF @OLDVENDORID = '-~!@$' 
				BEGIN
					SET @OLDVENDORID = ''
				END		
				IF @VENDORID <> ''
				BEGIN		
					SET @OLDVENDORID = @VENDORID
				END
				UPDATE IF_FA00905 SET VENDORID = @OLDVENDORID
				WHERE ASSETINDEX = @ASSETINDEX AND FAPERIOD = @FAPERIODID				
			END				
			SET @OLDASSETINDEX = @ASSETINDEX
			SET @OLDFAPERIODID = @FAPERIODID
			FETCH NEXT FROM CURUPDVNDRID INTO @ASSETINDEX, @FAPERIODID, @VENDORID
		END
		CLOSE CURUPDVNDRID
		DEALLOCATE CURUPDVNDRID
	END
END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nsaIF_UpdateVendorID] TO [DYNGRP] 
GO 

/*End_nsaIF_UpdateVendorID*/
/*Begin_nsaIF_Cuenta_NIT_Detallado*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_Cuenta_NIT_Detallado]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsaIF_Cuenta_NIT_Detallado]
GO
  
CREATE Procedure nsaIF_Cuenta_NIT_Detallado          
    
@I_nsaIF_Year as char(4),            
@I_Month_Fr as int,            
@I_Month_To as int,            
@I_From_Date as datetime,       
@I_To_Date as datetime,            
@I_Acc_Num_Fr as char(129),            
@I_Acc_Num_To as char(129),            
@I_From_NITID as char (31),    
@I_To_NITID as char (31),    
@I_nsaIF_Table as char(25)            
as            
set nocount on            
Declare            
 @Tot_Month as int,            
 @Count as int,             
 @Calc_Month as int,            
 @SrcDoc1 as char(5),       
 @SrcDoc2 as char(5),            
 @SQL_Cred as varchar(200),            
 @SQL_Debit as varchar(200),            
 @SQL_SF as varchar(200),            
 @SQL_SI as varchar(200),            
 @MainQuery as varchar(8000)  ,          
 @dt_Date as char(10),    
 @CName as char(15),    
 @sSQL as varchar(8000),    
 @sSQLGL as varchar(8000)    ,
 @StrAllTodo as char(10)  

set @StrAllTodo = ''

if @I_Acc_Num_Fr = 'All'
BEGIN
	SET @StrAllTodo = 'All'
END
else if @I_Acc_Num_Fr = 'Todo'
BEGIN
	SET @StrAllTodo = 'Todo'
END	
      
BEGIN             
 if @I_Month_Fr <= @I_Month_To             
  BEGIN            
  set @Tot_Month = @I_Month_To - @I_Month_Fr             
  END            
 set @Count = 0             
 set @Calc_Month = @I_Month_Fr            
 set @SQL_Cred =''            
 set @SQL_Debit = ''            
 set @SQL_SF = ''             
 set @SQL_SI = ''            
 set @SrcDoc1 = 'BBAL'            
 set @SrcDoc2 = 'BBF'            
 set @dt_Date = '01-01-1900'          
 while  @Count <= @Tot_Month            
 BEGIN            
  if @Count <> @Tot_Month            
   BEGIN            
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'            
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'            
   END            
  else            
   BEGIN            
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month)))             
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month)))             
   END            
  set @SQL_SI = ' nsaIF_SI_' + ltrim(Rtrim(str(@I_Month_Fr)))          
  set @SQL_SF = ' nsaIF_SF_' + ltrim(Rtrim(str(@I_Month_To)))           
  set @Calc_Month = @Calc_Month + 1            
  set @Count = @Count + 1            
 END            
   
 declare c cursor fast_forward for     
 select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='GL00100' and COLUMN_NAME like 'ACTNUMBR%'    
 open c    
 fetch next from c into @CName    
 set @sSQL = ''    
 set @sSQLGL = ''    
 WHILE @@fetch_status=0    
 BEGIN    
 set @sSQL = @sSQL + ltrim(rtrim(@CName))    
 set @sSQLGL = @sSQLGL + 'nsaIF_GL00050.' + ltrim(rtrim(@CName))    
 fetch next from c into @CName    
 if @@fetch_status=0    
 begin    
 set @sSQL = @sSQL + ','    
 set @sSQLGL = @sSQLGL + ','    
 end    
 end    
 close c    
 deallocate c    
  
 BEGIN          
  set @MainQuery = 'INSERT INTO ' + @I_nsaIF_Table + '(' + @sSQL + ',SEQNUMBR,       
  nsaIF_YEAR, ACTINDX, ACTNUMST,ACTDESCR,ORMSTRID,ORMSTRNM, nsaIFNit, nsaIF_Type_Nit, nsaIF_Name, TRXDATE, JRNENTRY, TRXSORCE, DEBITAMT, CRDTAMNT,    
  nsaIF_SCred_Sum, nsaIF_SDeb_Sum, nsaIF_SI_Sum, nsaIF_SF_Sum, nsaIF_Tot_Db, nsaIF_Tot_Cr, nsaIF_Tot_SI, nsaIF_Tot_SF)            
  SELECT  ' + @sSQLGL + ',GL20000.SEQNUMBR, nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID,    
  nsaIF_GL00050.ORMSTRNM,       
  (CASE WHEN nsaIF_GL00050.nsaIFNit = '+ char(39) + char(39) +' THEN '+ char(39) + ' ' + char(39) +' ELSE nsaIF_GL00050.nsaIFNit END) as nsaIFNit,     
  (CASE WHEN nsaIF_GL00050.nsaIF_Type_Nit = '+ char(39) + char(39) +' THEN '+ char(39) + ' ' + char(39) +' ELSE nsaIF_GL00050.nsaIF_Type_Nit END) as nsaIF_Type_Nit,     
  ISNULL((CASE WHEN nsaIF00666.nsaIF_Name = '+ char(39) + char(39) +' THEN '+ char(39) + ' ' + char(39) +' ELSE nsaIF00666.nsaIF_Name END),' + char(39) + ' ' + char(39) + ') as nsaIF_Name,     
  GL20000.TRXDATE, GL20000.JRNENTRY,     
  GL20000.TRXSORCE, GL20000.DEBITAMT, GL20000.CRDTAMNT, SUM(' + @SQL_Cred + '), SUM('+ @SQL_Debit +'), 0.00 as nsaIF_SI_SUM, 0.00 as nsaIF_SF_SUM,     
  0.00 as nsaIF_Tot_Db, 0.00 as nsaIF_Tot_Cr, 0.00 as nsaIF_Tot_SI, 0.00 as nsaIF_Tot_SF             
  FROM   nsaIF_GL00050 INNER JOIN GL20000     
  ON nsaIF_GL00050.ACTINDX = GL20000.ACTINDX             
  AND nsaIF_GL00050.ORMSTRID = GL20000.ORMSTRID             
  AND nsaIF_GL00050.nsaIF_YEAR = GL20000.OPENYEAR INNER JOIN            
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX          
  LEFT OUTER JOIN nsaIF00666     
  ON nsaIF_GL00050.nsaIFNit = nsaIF00666.nsaIFNit AND nsaIF_GL00050.nsaIF_Type_Nit = nsaIF00666.nsaIF_Type_Nit        
  WHERE nsaIF_GL00050.nsaIF_YEAR =  '+ @I_nsaIF_Year + ' '            
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo  and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo     
   BEGIN             
   set @MainQuery = @MainQuery + 'AND nsaIF_GL00050.ACTNUMST >= ' + char(39) + @I_Acc_Num_Fr + char(39) + 'AND nsaIF_GL00050.ACTNUMST <= ' + char(39) + @I_Acc_Num_To + char(39) +  ' '          
   END       
  if ltrim(rtrim(@I_From_NITID)) <>'' and ltrim(rtrim(@I_To_NITID)) <> ''    
   BEGIN            
   set @MainQuery = @MainQuery + ' AND nsaIF_GL00050.nsaIFNit >= '+ char(39) + @I_From_NITID + char(39) + ' AND nsaIF_GL00050.nsaIFNit <= '+ char(39) + @I_To_NITID + char(39) + ' '          
   END           
  set @MainQuery = @MainQuery + ' AND GL20000.SOURCDOC <> '+ char(39) + ltrim(rtrim(@SrcDoc1)) + char(39) + ' AND GL20000.SOURCDOC <> '+ char(39)+ ltrim(rtrim(@SrcDoc2)) + char(39) + '            
  AND GL20000.TRXDATE >= convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103) AND GL20000.TRXDATE <=  convert(datetime, '''+ ltrim(rtrim(@I_To_Date)) + ''',103)    
  GROUP BY ' + @sSQLGL + ', nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID,    
  nsaIF_GL00050.ORMSTRNM,  nsaIF_GL00050.nsaIFNit, nsaIF_GL00050.nsaIF_Type_Nit, nsaIF00666.nsaIF_Name, GL20000.TRXDATE,             
  GL20000.JRNENTRY, GL20000.TRXSORCE, GL20000.DEBITAMT, GL20000.CRDTAMNT,GL20000.SEQNUMBR           
  ORDER BY nsaIF_GL00050.ACTNUMST,  nsaIF_GL00050.nsaIFNit,   GL20000.TRXDATE'            
  
  exec(@MainQuery)            
 END         
  
 BEGIN    
  set @MainQuery = 'If exists (select 1 from '+ @I_nsaIF_Table + ') BEGIN '  
  set @MainQuery = @MainQuery + 'INSERT INTO ' + @I_nsaIF_Table + '(' + @sSQL + ',SEQNUMBR,       
  nsaIF_YEAR, ACTINDX, ACTNUMST,ACTDESCR,ORMSTRID,ORMSTRNM, nsaIFNit, nsaIF_Type_Nit, nsaIF_Name, TRXDATE, JRNENTRY, TRXSORCE, DEBITAMT, CRDTAMNT,    
  nsaIF_SCred_Sum, nsaIF_SDeb_Sum, nsaIF_SI_Sum, nsaIF_SF_Sum, nsaIF_Tot_Db, nsaIF_Tot_Cr, nsaIF_Tot_SI, nsaIF_Tot_SF)            
  SELECT DISTINCT ' + @sSQLGL + ',0,nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID,     
  nsaIF_GL00050.ORMSTRNM, ' + char(39) + ' ' + char(39) + ', ' + char(39) + ' ' + char(39) + ', ' + char(39) + ' ' + char(39) + ',     
  '''+ @dt_Date +''', 0,' + char(39) + ' ' + char(39) +', 0.00, 0.00, 0.00, 0.00,    
  ' + @SQL_SI + ' as nsaIF_SI_SUM,  ' + @SQL_SF + ' as nsaIF_SF_SUM, 0.00, 0.00, 0.00, 0.00           
  FROM   nsaIF_GL00050 INNER JOIN          
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX       
  WHERE nsaIF_GL00050.nsaIF_YEAR =  ' + @I_nsaIF_Year + ' and nsaIF_GL00050.nsaIFNit = ' + char(39) + ' ' + char(39)    
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo  and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo     
   BEGIN             
   set @MainQuery = @MainQuery + 'AND nsaIF_GL00050.ACTNUMST >= ' + char(39) + @I_Acc_Num_Fr + char(39) + 'AND nsaIF_GL00050.ACTNUMST <= ' + char(39) + @I_Acc_Num_To + char(39) +  ' '    
   END      
  set @MainQuery = @MainQuery + ' and (nsaIF_SF_12 <>0 and nsaIF_SI_1 <> 0) END '    
    
  exec(@MainQuery)     
 END    
  
 BEGIN    
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SDeb_Sum =       
  (select sum(DEBITAMT) from ' + @I_nsaIF_Table + ' B where       
  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX
  and B.nsaIFNit=' + @I_nsaIF_Table + '.nsaIFNit
  group by ACTINDX,nsaIFNit)'    
  /*and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX      
  group by ACTINDX, ORMSTRID)' */           
  
  exec(@MainQuery)        
  
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SCred_Sum =       
  (select sum(CRDTAMNT) from ' + @I_nsaIF_Table + ' B where       
  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX
  and B.nsaIFNit=' + @I_nsaIF_Table + '.nsaIFNit
  group by ACTINDX,nsaIFNit)'          
  /*and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX      
  group by ACTINDX, ORMSTRID)'*/            
  
  exec(@MainQuery)       
 END    
  
 BEGIN           
  set @MainQuery=''          
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_SI = nsaIF_SI.nsaIF_SI_SUM          
  from ' + @I_nsaIF_Table + ' tmp,           
  (SELECT  nsaIF_GL00050.ACTINDX, ' + @SQL_SI + ' as nsaIF_SI_SUM          
  FROM   nsaIF_GL00050 INNER JOIN          
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX            
  WHERE nsaIF_GL00050.nsaIF_YEAR = ' + @I_nsaIF_Year + ' and nsaIF_GL00050.ORMSTRID = ' + char(39) + char(39) + ' and ' + @SQL_SF + ' <>0 and ' + @SQL_SI + ' <> 0) nsaIF_SI          
  where tmp.ACTINDX = nsaIF_SI.ACTINDX'          
  
  exec(@MainQuery)          
 END          
  
 BEGIN           
  
  set @MainQuery=''          
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Db = nsaIF_Tot.Db , nsaIF_Tot_Cr = nsaIF_Tot.Cr          
  FROM ' + @I_nsaIF_Table + ' tmp,          
  (select ACTNUMST,ACTINDX, sum(DEBITAMT) as Db, sum(CRDTAMNT) as Cr from           
  (select ACTNUMST,ACTINDX,ORMSTRID, sum(DEBITAMT) DEBITAMT, sum(CRDTAMNT) CRDTAMNT  from  ' + @I_nsaIF_Table + '  WHERE           
  (CRDTAMNT > 0 or DEBITAMT > 0 )          
  group by ACTNUMST,ACTINDX,ORMSTRID) A          
  group by ACTNUMST,ACTINDX) nsaIF_Tot          
  WHERE tmp.ACTINDX = nsaIF_Tot.ACTINDX'          
  
  exec(@MainQuery)          
 END          
  
 BEGIN          
  set @MainQuery=''          
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SF_Sum = (nsaIF_SI_Sum + (nsaIF_SDeb_Sum - nsaIF_SCred_Sum))          
  FROM ' + @I_nsaIF_Table + ' INNER JOIN GL00100 ON (' + @I_nsaIF_Table + '.ACTINDX = GL00100.ACTINDX) '          
  

  exec(@MainQuery)          
 END          
  
 BEGIN           
  set @MainQuery=''          
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_SF = (nsaIF_Tot_SI + (nsaIF_Tot_Db - nsaIF_Tot_Cr))          
  FROM ' + @I_nsaIF_Table + ' INNER JOIN GL00100 ON (' + @I_nsaIF_Table + '.ACTINDX = GL00100.ACTINDX) '          
  
  exec(@MainQuery)          
 END          
 set nocount off            
  
END            

  GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nsaIF_Cuenta_NIT_Detallado] TO [DYNGRP] 
GO 
/*End_nsaIF_Cuenta_NIT_Detallado*/
/*Begin_nsaIF_Cuenta_NIT_Detallado_Hist*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_Cuenta_NIT_Detallado_Hist]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsaIF_Cuenta_NIT_Detallado_Hist]
GO
  
CREATE Procedure nsaIF_Cuenta_NIT_Detallado_Hist          
    
@I_nsaIF_Year as char(4),            
@I_Month_Fr as int,            
@I_Month_To as int,            
@I_From_Date as datetime,       
@I_To_Date as datetime,            
@I_Acc_Num_Fr as char(129),            
@I_Acc_Num_To as char(129),            
@I_From_NITID as char (31),    
@I_To_NITID as char (31),    
@I_nsaIF_Table as char(25)            
as            
set nocount on            
Declare            
 @Tot_Month as int,            
 @Count as int,             
 @Calc_Month as int,            
 @SrcDoc1 as char(5),       
 @SrcDoc2 as char(5),            
 @SQL_Cred as varchar(200),            
 @SQL_Debit as varchar(200),            
 @SQL_SF as varchar(200),            
 @SQL_SI as varchar(200),            
 @MainQuery as varchar(8000)  ,          
 @dt_Date as char(10),    
 @CName as char(15),    
 @sSQL as varchar(8000),    
 @sSQLGL as varchar(8000)    ,
 @StrAllTodo as char(10)         

set @StrAllTodo = ''

if @I_Acc_Num_Fr = 'All'
BEGIN
	SET @StrAllTodo = 'All'
END
else if @I_Acc_Num_Fr = 'Todo'
BEGIN
	SET @StrAllTodo = 'Todo'
END	
       
BEGIN             
 if @I_Month_Fr <= @I_Month_To             
  BEGIN            
  set @Tot_Month = @I_Month_To - @I_Month_Fr             
  END            
 set @Count = 0             
 set @Calc_Month = @I_Month_Fr            
 set @SQL_Cred =''            
 set @SQL_Debit = ''            
 set @SQL_SF = ''             
 set @SQL_SI = ''            
 set @SrcDoc1 = 'BBAL'            
 set @SrcDoc2 = 'BBF'            
 set @dt_Date = '01-01-1900'          
 while  @Count <= @Tot_Month            
 BEGIN            
  if @Count <> @Tot_Month            
   BEGIN            
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'            
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'            
   END            
  else            
   BEGIN            
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month)))             
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month)))             
   END            
  set @SQL_SI = ' nsaIF_SI_' + ltrim(Rtrim(str(@I_Month_Fr)))          
  set @SQL_SF = ' nsaIF_SF_' + ltrim(Rtrim(str(@I_Month_To)))           
  set @Calc_Month = @Calc_Month + 1            
  set @Count = @Count + 1            
 END            
  
 declare c cursor fast_forward for     
 select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='GL00100' and COLUMN_NAME like 'ACTNUMBR%'    
 open c    
 fetch next from c into @CName    
 set @sSQL = ''    
 set @sSQLGL = ''    
 WHILE @@fetch_status=0    
  BEGIN    
   set @sSQL = @sSQL + ltrim(rtrim(@CName))    
   set @sSQLGL = @sSQLGL + 'nsaIF_GL00050.' + ltrim(rtrim(@CName))    
   fetch next from c into @CName    
   if @@fetch_status=0    
    begin    
    set @sSQL = @sSQL + ','    
    set @sSQLGL = @sSQLGL + ','    
    end    
  END    
 close c    
 deallocate c    
  
  
 BEGIN          
  set @MainQuery = 'INSERT INTO ' + @I_nsaIF_Table + '(' + @sSQL + ',SEQNUMBR,       
  nsaIF_YEAR, ACTINDX, ACTNUMST,ACTDESCR,ORMSTRID,ORMSTRNM, nsaIFNit, nsaIF_Type_Nit, nsaIF_Name, TRXDATE, JRNENTRY, TRXSORCE, DEBITAMT, CRDTAMNT,    
  nsaIF_SCred_Sum, nsaIF_SDeb_Sum, nsaIF_SI_Sum, nsaIF_SF_Sum, nsaIF_Tot_Db, nsaIF_Tot_Cr, nsaIF_Tot_SI, nsaIF_Tot_SF)            
  SELECT  ' + @sSQLGL + ',GL30000.SEQNUMBR, nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID,    
  nsaIF_GL00050.ORMSTRNM,       
  (CASE WHEN nsaIF_GL00050.nsaIFNit = '+ char(39) + char(39) +' THEN '+ char(39) + ' ' + char(39) +' ELSE nsaIF_GL00050.nsaIFNit END) as nsaIFNit,     
  (CASE WHEN nsaIF_GL00050.nsaIF_Type_Nit = '+ char(39) + char(39) +' THEN '+ char(39) + ' ' + char(39) +' ELSE nsaIF_GL00050.nsaIF_Type_Nit END) as nsaIF_Type_Nit,     
  ISNULL((CASE WHEN nsaIF00666.nsaIF_Name = '+ char(39) + char(39) +' THEN '+ char(39) + ' ' + char(39) +' ELSE nsaIF00666.nsaIF_Name END),' + char(39) + ' ' + char(39) + ') as nsaIF_Name,     
  GL30000.TRXDATE, GL30000.JRNENTRY,     
  GL30000.TRXSORCE, GL30000.DEBITAMT, GL30000.CRDTAMNT, SUM(' + @SQL_Cred + '), SUM('+ @SQL_Debit +'), 0.00 as nsaIF_SI_SUM, 0.00 as nsaIF_SF_SUM,     
  0.00 as nsaIF_Tot_Db, 0.00 as nsaIF_Tot_Cr, 0.00 as nsaIF_Tot_SI, 0.00 as nsaIF_Tot_SF             
  FROM   nsaIF_GL00050 INNER JOIN GL30000     
  ON nsaIF_GL00050.ACTINDX = GL30000.ACTINDX             
  AND nsaIF_GL00050.ORMSTRID = GL30000.ORMSTRID             
  AND nsaIF_GL00050.nsaIF_YEAR = GL30000.HSTYEAR INNER JOIN            
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX          
  LEFT OUTER JOIN nsaIF00666     
  ON nsaIF_GL00050.nsaIFNit = nsaIF00666.nsaIFNit AND nsaIF_GL00050.nsaIF_Type_Nit = nsaIF00666.nsaIF_Type_Nit         
  WHERE nsaIF_GL00050.nsaIF_YEAR =  '+ @I_nsaIF_Year + ' '            
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo  and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo     
   BEGIN             
   set @MainQuery = @MainQuery + 'AND nsaIF_GL00050.ACTNUMST >= ' + char(39) + @I_Acc_Num_Fr + char(39) + 'AND nsaIF_GL00050.ACTNUMST <= ' + char(39) + @I_Acc_Num_To + char(39) +  ' '          
   END       
  if ltrim(rtrim(@I_From_NITID)) <>'' and ltrim(rtrim(@I_To_NITID)) <> ''    
   BEGIN            
   set @MainQuery = @MainQuery + ' AND nsaIF_GL00050.nsaIFNit >= '+ char(39) + @I_From_NITID + char(39) + ' AND nsaIF_GL00050.nsaIFNit <= '+ char(39) + @I_To_NITID + char(39) + ' '          
   END           
  set @MainQuery = @MainQuery + ' AND GL30000.SOURCDOC <> '+ char(39) + ltrim(rtrim(@SrcDoc1)) + char(39) + ' AND GL30000.SOURCDOC <> '+ char(39)+ ltrim(rtrim(@SrcDoc2)) + char(39) + '            
  AND GL30000.TRXDATE >= convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103) AND GL30000.TRXDATE <=  convert(datetime, '''+ ltrim(rtrim(@I_To_Date)) + ''',103)    
  GROUP BY ' + @sSQLGL + ', nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID,    
  nsaIF_GL00050.ORMSTRNM,  nsaIF_GL00050.nsaIFNit, nsaIF_GL00050.nsaIF_Type_Nit, nsaIF00666.nsaIF_Name, GL30000.TRXDATE,             
  GL30000.JRNENTRY, GL30000.TRXSORCE, GL30000.DEBITAMT, GL30000.CRDTAMNT,GL30000.SEQNUMBR           
  ORDER BY nsaIF_GL00050.ACTNUMST,  nsaIF_GL00050.nsaIFNit,   GL30000.TRXDATE'            
  
  exec(@MainQuery)            
 END         
  
 BEGIN    
  set @MainQuery = 'If exists (select 1 from '+ @I_nsaIF_Table + ') BEGIN '  
  set @MainQuery = @MainQuery + 'INSERT INTO ' + @I_nsaIF_Table + '(' + @sSQL + ',SEQNUMBR,       
  nsaIF_YEAR, ACTINDX, ACTNUMST,ACTDESCR,ORMSTRID,ORMSTRNM, nsaIFNit, nsaIF_Type_Nit, nsaIF_Name, TRXDATE, JRNENTRY, TRXSORCE, DEBITAMT, CRDTAMNT,    
  nsaIF_SCred_Sum, nsaIF_SDeb_Sum, nsaIF_SI_Sum, nsaIF_SF_Sum, nsaIF_Tot_Db, nsaIF_Tot_Cr, nsaIF_Tot_SI, nsaIF_Tot_SF)            
  SELECT DISTINCT ' + @sSQLGL + ',0, nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID,     
  nsaIF_GL00050.ORMSTRNM, ' + char(39) + ' ' + char(39) + ', ' + char(39) + ' ' + char(39) + ', ' + char(39) + ' ' + char(39) + ',     
  '''+ @dt_Date +''', 0,' + char(39) + ' ' + char(39) +', 0.00, 0.00, 0.00, 0.00,    
  ' + @SQL_SI + ' as nsaIF_SI_SUM,  ' + @SQL_SF + ' as nsaIF_SF_SUM, 0.00, 0.00, 0.00, 0.00           
  FROM   nsaIF_GL00050 INNER JOIN          
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX       
  WHERE nsaIF_GL00050.nsaIF_YEAR =  ' + @I_nsaIF_Year + ' and nsaIF_GL00050.nsaIFNit = ' + char(39) + ' ' + char(39)    
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo  and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo     
   BEGIN             
   set @MainQuery = @MainQuery + 'AND nsaIF_GL00050.ACTNUMST >= ' + char(39) + @I_Acc_Num_Fr + char(39) + 'AND nsaIF_GL00050.ACTNUMST <= ' + char(39) + @I_Acc_Num_To + char(39) +  ' '    
   END      
  set @MainQuery = @MainQuery + ' and (nsaIF_SF_12 <>0 and nsaIF_SI_1 <> 0) END '    
  
  exec(@MainQuery)     
 END    
  
 BEGIN    
  /* UPDATING DEB_SUM and CRED_SUM */      
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SDeb_Sum =       
  (select sum(DEBITAMT) from ' + @I_nsaIF_Table + ' B where       
  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX      
  group by ACTINDX, ORMSTRID)'            
  
  exec(@MainQuery)        
  
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SCred_Sum =       
  (select sum(CRDTAMNT) from ' + @I_nsaIF_Table + ' B where       
  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR    
  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX      
  group by ACTINDX, ORMSTRID)'            
  
  exec(@MainQuery)       
 END    
  
 BEGIN           
  set @MainQuery=''          
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_SI = nsaIF_SI.nsaIF_SI_SUM          
  from ' + @I_nsaIF_Table + ' tmp,           
  (SELECT  nsaIF_GL00050.ACTINDX, ' + @SQL_SI + ' as nsaIF_SI_SUM          
  FROM   nsaIF_GL00050 INNER JOIN          
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX            
  WHERE nsaIF_GL00050.nsaIF_YEAR = ' + @I_nsaIF_Year + ' and nsaIF_GL00050.ORMSTRID = ' + char(39) + char(39) + ' and ' + @SQL_SF + ' <>0 and ' + @SQL_SI + ' <> 0) nsaIF_SI          
  where tmp.ACTINDX = nsaIF_SI.ACTINDX'          
  
  exec(@MainQuery)          
 END          
  
 BEGIN           
  set @MainQuery=''          
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Db = nsaIF_Tot.Db , nsaIF_Tot_Cr = nsaIF_Tot.Cr          
  FROM ' + @I_nsaIF_Table + ' tmp,          
  (select ACTNUMST,ACTINDX, sum(nsaIF_SDeb_Sum) as Db, sum(nsaIF_SCred_Sum) as Cr from           
  (select ACTNUMST,ACTINDX,ORMSTRID, min(nsaIF_SDeb_Sum)nsaIF_SDeb_Sum, min(nsaIF_SCred_Sum) nsaIF_SCred_Sum  from  ' + @I_nsaIF_Table + '  WHERE           
  (nsaIF_SCred_Sum > 0 or nsaIF_SDeb_Sum > 0 )          
  group by ACTNUMST,ACTINDX,ORMSTRID) A          
  group by ACTNUMST,ACTINDX) nsaIF_Tot          
  WHERE tmp.ACTINDX = nsaIF_Tot.ACTINDX'          
  exec(@MainQuery)          
 END          
  
 BEGIN          
  set @MainQuery=''          
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SF_Sum = (nsaIF_SI_Sum + (nsaIF_SDeb_Sum - nsaIF_SCred_Sum))          
  FROM ' + @I_nsaIF_Table + ' INNER JOIN GL00100 ON (' + @I_nsaIF_Table + '.ACTINDX = GL00100.ACTINDX) '          
  exec(@MainQuery)          
 END          
  
 BEGIN           
  set @MainQuery=''          
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_SF = (nsaIF_Tot_SI + (nsaIF_Tot_Db - nsaIF_Tot_Cr))          
  FROM ' + @I_nsaIF_Table + ' INNER JOIN GL00100 ON (' + @I_nsaIF_Table + '.ACTINDX = GL00100.ACTINDX) '          
  exec(@MainQuery)          
 END          
 set nocount off            
  
END            
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nsaIF_Cuenta_NIT_Detallado_Hist] TO [DYNGRP] 
GO 
/*End_nsaIF_Cuenta_NIT_Detallado_Hist*/
/*Begin_nsaIF_Cuenta_Tercero_Detallado*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_Cuenta_Tercero_Detallado]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsaIF_Cuenta_Tercero_Detallado]
GO
  
CREATE Procedure nsaIF_Cuenta_Tercero_Detallado            
    
@I_nsaIF_Year as char(4),              
@I_Month_Fr as int,              
@I_Month_To as int,              
@I_From_Date as datetime,              
@I_To_Date as datetime,              
@I_Acc_Num_Fr as char(129),              
@I_Acc_Num_To as char(129),              
@I_From_ORMSTRID as char (31),              
@I_To_ORMSTRID as char (31),              
@I_nsaIF_Table as char(25),
@I_ReportNumber as int             
as              
set nocount on              
Declare              
 @Tot_Month as int,              
 @Count as int,               
 @Calc_Month as int,              
 @SrcDoc1 as char(5),         
 @SrcDoc2 as char(5),              
 @SQL_Cred as varchar(200),              
 @SQL_Debit as varchar(200),              
 @SQL_SF as varchar(200),              
 @SQL_SI as varchar(200),              
 @MainQuery as varchar(8000),            
 @dt_Date as char(10),      
 @CName as char(15),      
 @sSQL as varchar(8000),      
 @sSQLGL as varchar(8000),
 @StrAllTodo as char(10),
 @nsaIF_SI_Sum NUMERIC(19,5),
 @l_ParmDefinition   nvarchar(500),
 @l_cmdNExec nvarchar(1000)  

set @nsaIF_SI_Sum = 0
set @StrAllTodo = ''

if @I_Acc_Num_Fr = 'All'
BEGIN
	SET @StrAllTodo = 'All'
END
else if @I_Acc_Num_Fr = 'Todo'
BEGIN
	SET @StrAllTodo = 'Todo'
END	
        
BEGIN               
 if @I_Month_Fr <= @I_Month_To               
  BEGIN              
  set @Tot_Month = @I_Month_To - @I_Month_Fr               
  END              
 set @Count = 0               
 set @Calc_Month = @I_Month_Fr              
 set @SQL_Cred =''              
 set @SQL_Debit = ''              
 set @SQL_SF = ''               
 set @SQL_SI = ''              
 set @SrcDoc1 = 'BBAL'              
 set @SrcDoc2 = 'BBF'              
 set @dt_Date = '01-01-1900'            
 while  @Count <= @Tot_Month              
 BEGIN              
  if @Count <> @Tot_Month              
   BEGIN              
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'              
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'              
   END              
  else              
   BEGIN              
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month)))               
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month)))               
   END              
  set @Calc_Month = @Calc_Month + 1              
  set @Count = @Count + 1              
 END              
/*
set @SQL_SI = ' nsaIF_SI_' + ltrim(Rtrim(str(@I_Month_Fr)))            
set @SQL_SF = ' nsaIF_SF_' + ltrim(Rtrim(str(@I_Month_To))) 
 */
set @SQL_SI = ' nsaIF_SI_1'           
set @SQL_SF = ' nsaIF_SF_12'
  
 declare c cursor fast_forward for       
 select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='GL00100' and COLUMN_NAME like 'ACTNUMBR%'      
 open c      
 fetch next from c into @CName      
 set @sSQL = ''      
 set @sSQLGL = ''      
 WHILE @@fetch_status=0      
 BEGIN      
  set @sSQL = @sSQL + ltrim(rtrim(@CName))      
  set @sSQLGL = @sSQLGL + 'nsaIF_GL00050.' + ltrim(rtrim(@CName))      
  fetch next from c into @CName      
  if @@fetch_status=0      
   begin      
   set @sSQL = @sSQL + ','      
   set @sSQLGL = @sSQLGL + ','      
   end      
 END      
 close c      
 deallocate c      
  
 BEGIN            
  set @MainQuery = 'INSERT INTO ' + @I_nsaIF_Table + '(' + @sSQL + ',SEQNUMBR,         
  nsaIF_YEAR, ACTINDX, ACTNUMST,ACTDESCR,ORMSTRID,ORMSTRNM, nsaIFNit, nsaIF_Name, nsaIF_Type_Nit, TRXDATE, JRNENTRY, TRXSORCE, DEBITAMT,   
  CRDTAMNT, nsaIF_SCred_Sum, nsaIF_SDeb_Sum, nsaIF_SI_Sum, nsaIF_SF_Sum, nsaIF_Tot_Db, nsaIF_Tot_Cr, nsaIF_Tot_SI, nsaIF_Tot_SF)              
  SELECT  ' + @sSQLGL + ',GL20000.SEQNUMBR,      
  nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID, nsaIF_GL00050.ORMSTRNM, ' + char(39) + ' ' + char(39) +', '+ char(39) + ' ' + char(39) + ', '+ char(39) + ' ' + char(39) + ',      
  GL20000.TRXDATE, GL20000.JRNENTRY, GL20000.TRXSORCE, sum(GL20000.DEBITAMT), sum(GL20000.CRDTAMNT),              
  0.00 as Cred_SUM,       
  0.00 as Deb_SUM, 0.00 as nsaIF_SI_SUM, ' + @SQL_SF + ' as nsaIF_SF_SUM,      
  0.00 as nsaIF_Tot_Db, 0.00 as nsaIF_Tot_Cr, 0.00 as nsaIF_Tot_SI, 0.00 as nsaIF_Tot_SF               
  FROM   nsaIF_GL00050 INNER JOIN              
  GL20000 ON nsaIF_GL00050.ACTINDX = GL20000.ACTINDX               
  AND nsaIF_GL00050.ORMSTRID = GL20000.ORMSTRID               
  AND nsaIF_GL00050.nsaIF_YEAR = GL20000.OPENYEAR INNER JOIN              
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX                
  WHERE GL20000.OPENYEAR =  '+ @I_nsaIF_Year + ' '              
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo               
   BEGIN               
   set @MainQuery = @MainQuery + 'AND nsaIF_GL00050.ACTNUMST >= ' + char(39) + @I_Acc_Num_Fr + char(39) + 'AND nsaIF_GL00050.ACTNUMST <= ' + char(39) + @I_Acc_Num_To + char(39) +  ' '            
   END              
  if ltrim(rtrim(@I_From_ORMSTRID)) <>'' and ltrim(rtrim(@I_To_ORMSTRID)) <> ''              
   BEGIN              
   set @MainQuery = @MainQuery + ' AND nsaIF_GL00050.ORMSTRID >= '+ char(39) + @I_From_ORMSTRID + char(39) + ' AND nsaIF_GL00050.ORMSTRID <= '+ char(39) + @I_To_ORMSTRID + char(39) + ' '            
   END              
  set @MainQuery = @MainQuery + ' AND GL20000.SOURCDOC <> '+ char(39) + ltrim(rtrim(@SrcDoc1)) + char(39) + ' AND GL20000.SOURCDOC <> '+ char(39)+ ltrim(rtrim(@SrcDoc2)) + char(39) + '              
  
  /*AND GL20000.TRXDATE >= convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103) */AND GL20000.TRXDATE <=  convert(datetime, '''+ ltrim(rtrim(@I_To_Date)) + ''',103)               
  GROUP BY ' + @sSQLGL + ',GL20000.SEQNUMBR,     
  nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID, nsaIF_GL00050.ORMSTRNM, GL20000.TRXDATE,               
  GL20000.JRNENTRY, GL20000.TRXSORCE, ' + @SQL_SI + ', ' + @SQL_SF + '      
  ORDER BY nsaIF_GL00050.ACTNUMST,  nsaIF_GL00050.ORMSTRID,   GL20000.TRXDATE'              
  print @MainQuery
  exec(@MainQuery)              
 END           
  
  
 BEGIN            
  set @MainQuery = ''            
  /*set @MainQuery = 'If exists (select 1 from '+ @I_nsaIF_Table + ') BEGIN '*/  
  set @MainQuery = @MainQuery + 'INSERT INTO ' + @I_nsaIF_Table + '(' + @sSQL + ',SEQNUMBR,        
  nsaIF_YEAR, ACTINDX, ACTNUMST,ACTDESCR,ORMSTRID,ORMSTRNM, nsaIFNit, nsaIF_Name, nsaIF_Type_Nit, TRXDATE, JRNENTRY, TRXSORCE, DEBITAMT,   
  CRDTAMNT, nsaIF_SCred_Sum, nsaIF_SDeb_Sum, nsaIF_SI_Sum, nsaIF_SF_Sum, nsaIF_Tot_Db, nsaIF_Tot_Cr, nsaIF_Tot_SI, nsaIF_Tot_SF)            
  SELECT  ' + @sSQLGL + ',0,      
  nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID, nsaIF_GL00050.ORMSTRNM,  ' + char(39) + ' ' + char(39) +', '+ char(39) + ' ' + char(39) + ', '+ char(39) + ' ' + char(39) + ',       
  '''+ @dt_Date +''',0,' + char(39) + ' ' + char(39) +', 0.00, 0.00, 0.00, 0.00,            
  ' + @SQL_SI + ' as nsaIF_SI_SUM, ' + @SQL_SF + ' as nsaIF_SF_SUM, 0.00, 0.00, 0.00, 0.00             
  FROM   nsaIF_GL00050 INNER JOIN            
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX              
  WHERE nsaIF_GL00050.nsaIF_YEAR =  ' + @I_nsaIF_Year + ' '/*' - 1 ' and nsaIF_GL00050.ORMSTRID = ' + char(39) + char(39) + ' and (nsaIF_SF_12 <>0 or nsaIF_SI_1 <> 0)'          */
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo               
  BEGIN               
  set @MainQuery = @MainQuery + 'AND nsaIF_GL00050.ACTNUMST >= ' + char(39) + @I_Acc_Num_Fr + char(39) + 'AND nsaIF_GL00050.ACTNUMST <= ' + char(39) + @I_Acc_Num_To + char(39) +  ' '            
  END              
  if ltrim(rtrim(@I_From_ORMSTRID)) <>'' and ltrim(rtrim(@I_To_ORMSTRID)) <> ''                  
  BEGIN                  
   set @MainQuery = @MainQuery + ' AND nsaIF_GL00050.ORMSTRID >= '+ char(39) + @I_From_ORMSTRID + char(39) + ' AND nsaIF_GL00050.ORMSTRID <= '+ char(39) + @I_To_ORMSTRID + char(39) + ' '                
  END    
  set @MainQuery = @MainQuery + ' ORDER BY nsaIF_GL00050.ACTINDX,  nsaIF_GL00050.ORMSTRID' /*  END' */            
  print @MainQuery
  exec(@MainQuery)            
 END            
  
 BEGIN  
 
 IF (select HISTORYR from SY40101 where YEAR1 = @I_nsaIF_Year-1) = 1
 BEGIN 
	begin
		set @MainQuery = '
		  UPDATE [' + @I_nsaIF_Table + '] SET nsaIF_SI_Sum = A.nsaIF_SI_Sum FROM (SELECT distinct (SELECT ISNULL((SELECT SUM(D.nsaIF_SI_Sum) FROM     
								[' + @I_nsaIF_Table + '] D where D.JRNENTRY = 0 and D.ACTINDX = C.ACTINDX AND D.ORMSTRID = C.ORMSTRID GROUP BY D.ACTINDX, D.ORMSTRID),0) + 
				ISNULL(SUM(B.DEBITAMT),0) - ISNULL(SUM(B.CRDTAMNT),0) FROM 
				[' + @I_nsaIF_Table + '] B WHERE 
				B.TRXDATE < convert(datetime, ''' + ltrim(rtrim(@I_From_Date)) +''', 103) AND B.nsaIF_YEAR = C.nsaIF_YEAR       
					  and B.ORMSTRID = C.ORMSTRID and B.ACTINDX = C.ACTINDX AND B.ACTINDX NOT IN(SELECT DISTINCT ACTINDX FROM GL20000 GL 
    WHERE B.ACTINDX = GL.ACTINDX AND B.JRNENTRY = GL.JRNENTRY AND B.nsaIF_YEAR = GL.OPENYEAR AND GL.SOURCDOC = ''P/L'') ) as nsaIF_SI_Sum,C.ACTINDX,C.ORMSTRID FROM [' + @I_nsaIF_Table + '] C ) A
		INNER JOIN [' + @I_nsaIF_Table + ']  ON A.ACTINDX = [' + @I_nsaIF_Table + '].ACTINDX AND A.ORMSTRID = [' + @I_nsaIF_Table + '].ORMSTRID'
		  print @MainQuery
		exec(@MainQuery) 
	end
END
 ELSE
  BEGIN 
		set @MainQuery = '
			  UPDATE [' + @I_nsaIF_Table + '] SET nsaIF_SI_Sum = A.nsaIF_SI_Sum FROM (SELECT distinct (SELECT ISNULL(SUM(B.DEBITAMT),0) - ISNULL(SUM(B.CRDTAMNT),0) FROM 
			[' + @I_nsaIF_Table + '] B WHERE 
			B.TRXDATE < convert(datetime, ''' + ltrim(rtrim(@I_From_Date)) +''', 103) AND B.nsaIF_YEAR = C.nsaIF_YEAR       
				  and B.ORMSTRID = C.ORMSTRID and B.ACTINDX = C.ACTINDX  ) as nsaIF_SI_Sum,C.ACTINDX,C.ORMSTRID FROM [' + @I_nsaIF_Table + '] C ) A
	    INNER JOIN [' + @I_nsaIF_Table + ']  ON A.ACTINDX = [' + @I_nsaIF_Table + '].ACTINDX AND A.ORMSTRID = [' + @I_nsaIF_Table + '].ORMSTRID'	 
	      print @MainQuery
			exec(@MainQuery) 
			  
 END
  
 set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET DEBITAMT = 0 , CRDTAMNT = 0 where       
  ' + @I_nsaIF_Table + '.TRXDATE < convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103)
  AND ' + @I_nsaIF_Table + '.nsaIF_SI_Sum <> 0'      
   print @MainQuery        
   exec(@MainQuery)     
 
          
 set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SDeb_Sum =       
  ISNULL((select sum(DEBITAMT) from ' + @I_nsaIF_Table + ' B where       
  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX  
  /*and ' + @I_nsaIF_Table + '.TRXDATE >= convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103)     */
  group by ACTINDX, ORMSTRID),0)'            
  print @MainQuery      
  exec(@MainQuery)        
  
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SCred_Sum =       
  ISNULL((select sum(CRDTAMNT) from ' + @I_nsaIF_Table + ' B where       
  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX    
  /*and ' + @I_nsaIF_Table + '.TRXDATE >= convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103)     */
  group by ACTINDX, ORMSTRID),0)'            
  print @MainQuery      
  exec(@MainQuery)        
  end
 if @I_ReportNumber = 5
 begin
		  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Db =       
		  ISNULL((select sum(DEBITAMT) from ' + @I_nsaIF_Table + ' B where       
		  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
		  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID   
		 group by ORMSTRID),0)'            
		  print @MainQuery      
		  exec(@MainQuery)        
		  
		  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Cr =       
		  ISNULL((select sum(CRDTAMNT) from ' + @I_nsaIF_Table + ' B where       
		  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
		  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID 
		  group by ORMSTRID),0)'            
		  exec(@MainQuery)    
		  
		  set @MainQuery=''      
		  set @MainQuery='IF EXISTS (SELECT TOP 1 1 FROM ' + @I_nsaIF_Table + ' B INNER JOIN ' + @I_nsaIF_Table + ' ON B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR and B.JRNENTRY = 0)'
		    set @MainQuery =@MainQuery + ' UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
			 ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
			 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and  B.JRNENTRY = 0      
			and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID    
			group by ORMSTRID),0)'     
		    set @MainQuery =@MainQuery + ' ELSE UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
			 ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
			 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and  B.JRNENTRY <> 0      
			and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID    
			group by ORMSTRID),0)'     
			print @MainQuery        
			exec(@MainQuery)    
		      
  end
  else
  begin
		  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Db =       
		  ISNULL((select sum(DEBITAMT) from ' + @I_nsaIF_Table + ' B where       
		  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
		  and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX   
		 group by ACTINDX),0)'            
		  print @MainQuery      
		  exec(@MainQuery)        
		  
		  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Cr =       
		  ISNULL((select sum(CRDTAMNT) from ' + @I_nsaIF_Table + ' B where       
		  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
		  and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX 
		  group by ACTINDX),0)'            
		  exec(@MainQuery)        
	  
	 /*set @MainQuery=''      
	  set @MainQuery =' UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
	  ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
		 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and       
		 B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX group by ACTINDX),0)'  
	   print @MainQuery        
	   exec(@MainQuery) */
	   
	  set @MainQuery=''      
	  set @MainQuery='IF EXISTS (SELECT TOP 1 1 FROM ' + @I_nsaIF_Table + ' B INNER JOIN ' + @I_nsaIF_Table + ' ON B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR and B.JRNENTRY = 0)'
	    set @MainQuery =@MainQuery + ' UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
		 ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
		 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and  B.JRNENTRY = 0 and     
		 B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX group by ACTINDX),0)'     
	    set @MainQuery =@MainQuery + ' ELSE UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
		 ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
		 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and  B.JRNENTRY <> 0 and  
		 B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX group by ACTINDX),0)'     
		print @MainQuery        
		exec(@MainQuery) 	   

  end       
  BEGIN 
  
  set @MainQuery=''              
    set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SF_Sum = (nsaIF_SI_Sum + (nsaIF_SDeb_Sum - nsaIF_SCred_Sum))              
    FROM ' + @I_nsaIF_Table + ' INNER JOIN GL00100 ON (' + @I_nsaIF_Table + '.ACTINDX = GL00100.ACTINDX) WHERE nsaIF_SDeb_Sum <> 0
    OR nsaIF_SCred_Sum <> 0 OR nsaIF_SI_Sum <> 0'              
    print @MainQuery        
    exec(@MainQuery)              
   END              
          
   BEGIN               
    set @MainQuery=''              
    set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_SF = (nsaIF_Tot_SI + (nsaIF_Tot_Db - nsaIF_Tot_Cr))              
    FROM ' + @I_nsaIF_Table + ' INNER JOIN GL00100 ON (' + @I_nsaIF_Table + '.ACTINDX = GL00100.ACTINDX) '              
    print @MainQuery        
    exec(@MainQuery)              
 
  set @MainQuery ='DELETE FROM ' + @I_nsaIF_Table + ' WHERE        
  TRXDATE < convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103)
  AND nsaIF_SI_Sum = 0 AND SEQNUMBR = 0 AND DEBITAMT =0 AND CRDTAMNT = 0'      
   print @MainQuery        
   exec(@MainQuery) 
   END         
  
 set nocount off              

END 
              
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nsaIF_Cuenta_Tercero_Detallado] TO [DYNGRP] 
GO 
/*End_nsaIF_Cuenta_Tercero_Detallado*/
/*Begin_nsaIF_Cuenta_Tercero_Detallado_Hist*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_Cuenta_Tercero_Detallado_Hist]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsaIF_Cuenta_Tercero_Detallado_Hist]
GO
  
CREATE Procedure nsaIF_Cuenta_Tercero_Detallado_Hist  
    

@I_nsaIF_Year as char(4),                
@I_Month_Fr as int,                
@I_Month_To as int,                
@I_From_Date as datetime,                
@I_To_Date as datetime,                
@I_Acc_Num_Fr as char(129),                
@I_Acc_Num_To as char(129),                
@I_From_ORMSTRID as char (31),                
@I_To_ORMSTRID as char (31),                
@I_nsaIF_Table as char(25),
@I_ReportNumber as int                
as                
set nocount on                
Declare                
 @Tot_Month as int,                
 @Count as int,                 
 @Calc_Month as int,                
 @SrcDoc1 as char(5),           
 @SrcDoc2 as char(5),                
 @SQL_Cred as varchar(200),                
 @SQL_Debit as varchar(200),                
 @SQL_SF as varchar(200),                
 @SQL_SI as varchar(200),                
 @MainQuery as varchar(8000)  ,              
 @dt_Date as char(10),        
 @CName as char(15),        
 @sSQL as varchar(8000),        
 @sSQLGL as varchar(8000)   ,  
 @StrAllTodo as char(10),           
 @nsaIF_SI_Sum NUMERIC(19,5),  
 @l_ParmDefinition   nvarchar(500),  
 @l_cmdNExec nvarchar(1000)    
  
set @nsaIF_SI_Sum = 0  
  
  
set @StrAllTodo = ''  
  
if @I_Acc_Num_Fr = 'All'  
BEGIN  
 SET @StrAllTodo = 'All'  
END  
else if @I_Acc_Num_Fr = 'Todo'  
BEGIN  
 SET @StrAllTodo = 'Todo'  
END   
           
BEGIN                 
 if @I_Month_Fr <= @I_Month_To                 
  BEGIN                
   set @Tot_Month = @I_Month_To - @I_Month_Fr                 
  END                
 set @Count = 0                 
 set @Calc_Month = @I_Month_Fr                
 set @SQL_Cred =''                
 set @SQL_Debit = ''                
 set @SQL_SF = ''                 
 set @SQL_SI = ''                
 set @SrcDoc1 = 'BBAL'                
 set @SrcDoc2 = 'BBF'                
 set @dt_Date = '01-01-1900'              
 while  @Count <= @Tot_Month                
 BEGIN                
  if @Count <> @Tot_Month                
   BEGIN                
    set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'                
    set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'                
   END                
  else                
  BEGIN                
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month)))                 
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month)))                 
  END                
  set @Calc_Month = @Calc_Month + 1                
  set @Count = @Count + 1                
 END                
  /*
  set @SQL_SI = ' nsaIF_SI_' + ltrim(Rtrim(str(@I_Month_Fr)))              
  set @SQL_SF = ' nsaIF_SF_' + ltrim(Rtrim(str(@I_Month_To)))     
  */
set @SQL_SI = ' nsaIF_SI_1'           
set @SQL_SF = ' nsaIF_SF_12'

declare c cursor fast_forward for         
 select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='GL00100' and COLUMN_NAME like 'ACTNUMBR%'        
 open c        
 fetch next from c into @CName        
 set @sSQL = ''        
 set @sSQLGL = ''        
 WHILE @@fetch_status=0        
 BEGIN        
  set @sSQL = @sSQL + ltrim(rtrim(@CName))        
  set @sSQLGL = @sSQLGL + 'nsaIF_GL00050.' + ltrim(rtrim(@CName))        
  fetch next from c into @CName        
  if @@fetch_status=0        
  begin        
   set @sSQL = @sSQL + ','        
   set @sSQLGL = @sSQLGL + ','        
  end        
 end        
 close c        
 deallocate c        
    
 BEGIN              
  set @MainQuery = 'INSERT INTO ' + @I_nsaIF_Table + '(' + @sSQL + ',SEQNUMBR,           
  nsaIF_YEAR, ACTINDX, ACTNUMST,ACTDESCR,ORMSTRID,ORMSTRNM, nsaIFNit, nsaIF_Name, nsaIF_Type_Nit, TRXDATE, JRNENTRY, TRXSORCE,     
  DEBITAMT, CRDTAMNT,   nsaIF_SCred_Sum, nsaIF_SDeb_Sum, nsaIF_SI_Sum, nsaIF_SF_Sum, nsaIF_Tot_Db, nsaIF_Tot_Cr, nsaIF_Tot_SI, nsaIF_Tot_SF)                
  SELECT  ' + @sSQLGL + ',GL30000.SEQNUMBR,        
  nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID, nsaIF_GL00050.ORMSTRNM, ' + char(39) + ' ' + char(39) +', '+ char(39) + ' ' + char(39) + ', '+ char(39) + ' ' + char(39) + ',        
  GL30000.TRXDATE, GL30000.JRNENTRY, GL30000.TRXSORCE, sum(GL30000.DEBITAMT), sum(GL30000.CRDTAMNT),                  
  0.00 AS Cred_SUM,         
  0.00 AS Deb_SUM, 0.00 as nsaIF_SI_SUM, ' + @SQL_SF + ' as nsaIF_SF_SUM,        
  0.00 as nsaIF_Tot_Db, 0.00 as nsaIF_Tot_Cr, 0.00 as nsaIF_Tot_SI, 0.00 as nsaIF_Tot_SF                 
  FROM   nsaIF_GL00050 INNER JOIN                
  GL30000 ON nsaIF_GL00050.ACTINDX = GL30000.ACTINDX                 
  AND nsaIF_GL00050.ORMSTRID = GL30000.ORMSTRID                 
  AND nsaIF_GL00050.nsaIF_YEAR = GL30000.HSTYEAR INNER JOIN                
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX                  
  WHERE GL30000.HSTYEAR =  '+ @I_nsaIF_Year + ' '                
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo                 
  BEGIN                 
   set @MainQuery = @MainQuery + 'AND nsaIF_GL00050.ACTNUMST >= ' + char(39) + @I_Acc_Num_Fr + char(39) + 'AND nsaIF_GL00050.ACTNUMST <= ' + char(39) + @I_Acc_Num_To + char(39) +  ' '              
  END                
  if ltrim(rtrim(@I_From_ORMSTRID)) <>'' and ltrim(rtrim(@I_To_ORMSTRID)) <> ''                
  BEGIN                
   set @MainQuery = @MainQuery + ' AND nsaIF_GL00050.ORMSTRID >= '+ char(39) + @I_From_ORMSTRID + char(39) + ' AND nsaIF_GL00050.ORMSTRID <= '+ char(39) + @I_To_ORMSTRID + char(39) + ' '              
  END                
  set @MainQuery = @MainQuery + ' AND GL30000.SOURCDOC <> '+ char(39) + ltrim(rtrim(@SrcDoc1)) + char(39) + ' AND GL30000.SOURCDOC <> '+ char(39)+ ltrim(rtrim(@SrcDoc2)) + char(39) + '                
  /*AND GL30000.TRXDATE >= convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103) */ AND GL30000.TRXDATE <=  convert(datetime, '''+ ltrim(rtrim(@I_To_Date)) + ''',103)                 
  GROUP BY ' + @sSQLGL + ',GL30000.SEQNUMBR,  
  nsaIF_GL00050.nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID, nsaIF_GL00050.ORMSTRNM, GL30000.TRXDATE,                 
  GL30000.JRNENTRY, GL30000.TRXSORCE,  ' + @SQL_SI + ', ' + @SQL_SF + '        
  ORDER BY nsaIF_GL00050.ACTNUMST,  nsaIF_GL00050.ORMSTRID,   GL30000.TRXDATE'                
  print @MainQuery        
  exec(@MainQuery)                
 END             
 BEGIN              
  set @MainQuery = ''              
  /*set @MainQuery = 'If exists (select 1 from '+ @I_nsaIF_Table + ') BEGIN '*/  
  set @MainQuery = @MainQuery + 'INSERT INTO ' + @I_nsaIF_Table + '(' + @sSQL + ',SEQNUMBR,         
  nsaIF_YEAR, ACTINDX, ACTNUMST,ACTDESCR,ORMSTRID,ORMSTRNM, nsaIFNit, nsaIF_Name, nsaIF_Type_Nit, TRXDATE, JRNENTRY, TRXSORCE, DEBITAMT,     
  CRDTAMNT, nsaIF_SCred_Sum, nsaIF_SDeb_Sum, nsaIF_SI_Sum, nsaIF_SF_Sum, nsaIF_Tot_Db, nsaIF_Tot_Cr, nsaIF_Tot_SI, nsaIF_Tot_SF)              
  SELECT  ' + @sSQLGL + ',0,        
  nsaIF_YEAR, nsaIF_GL00050.ACTINDX, nsaIF_GL00050.ACTNUMST, GL00100.ACTDESCR, nsaIF_GL00050.ORMSTRID, nsaIF_GL00050.ORMSTRNM,  ' + char(39) + ' ' + char(39) +', '+ char(39) + ' ' + char(39) + ', '+ char(39) + ' ' + char(39) + ',         
  '''+ @dt_Date +''',0,' + char(39) + ' ' + char(39) +', 0.00, 0.00, 0.00, 0.00,              
  ' + @SQL_SI + ' as nsaIF_SI_SUM, ' + @SQL_SF + ' as nsaIF_SF_SUM, 0.00, 0.00, 0.00, 0.00               
  FROM   nsaIF_GL00050 INNER JOIN              
  GL00100 ON nsaIF_GL00050.ACTINDX = GL00100.ACTINDX                
  WHERE nsaIF_GL00050.nsaIF_YEAR =  ' + @I_nsaIF_Year + ' '/* - 1 '  and nsaIF_GL00050.ORMSTRID = ' + char(39) + char(39) + ' and (nsaIF_SF_12 <>0 or nsaIF_SI_1 <> 0)'          */  
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo                 
  BEGIN                 
   set @MainQuery = @MainQuery + 'AND nsaIF_GL00050.ACTNUMST >= ' + char(39) + @I_Acc_Num_Fr + char(39) + 'AND nsaIF_GL00050.ACTNUMST <= ' + char(39) + @I_Acc_Num_To + char(39) +  ' '              
  END                
  if ltrim(rtrim(@I_From_ORMSTRID)) <>'' and ltrim(rtrim(@I_To_ORMSTRID)) <> ''                    
  BEGIN                    
   set @MainQuery = @MainQuery + ' AND nsaIF_GL00050.ORMSTRID >= '+ char(39) + @I_From_ORMSTRID + char(39) + ' AND nsaIF_GL00050.ORMSTRID <= '+ char(39) + @I_To_ORMSTRID + char(39) + ' '                  
  END    
  set @MainQuery = @MainQuery + ' ORDER BY nsaIF_GL00050.ACTINDX,  nsaIF_GL00050.ORMSTRID' /* END'          */  
    
  exec(@MainQuery)              
 END              
    
 BEGIN          
	set @MainQuery = '
	  UPDATE [' + @I_nsaIF_Table + '] SET nsaIF_SI_Sum = A.nsaIF_SI_Sum FROM (SELECT distinct (SELECT ISNULL((SELECT SUM(D.nsaIF_SI_Sum) FROM     
							[' + @I_nsaIF_Table + '] D where D.JRNENTRY = 0 and D.ACTINDX = C.ACTINDX AND D.ORMSTRID = C.ORMSTRID GROUP BY D.ACTINDX, D.ORMSTRID),0) + 
			ISNULL(SUM(B.DEBITAMT),0) - ISNULL(SUM(B.CRDTAMNT),0) FROM 
			[' + @I_nsaIF_Table + '] B WHERE 
			B.TRXDATE < convert(datetime, ''' + ltrim(rtrim(@I_From_Date)) +''', 103) AND B.nsaIF_YEAR = C.nsaIF_YEAR       
				  and B.ORMSTRID = C.ORMSTRID and B.ACTINDX = C.ACTINDX AND B.ACTINDX NOT IN(SELECT DISTINCT ACTINDX FROM GL30000 GL 
    WHERE B.ACTINDX = GL.ACTINDX AND B.JRNENTRY = GL.JRNENTRY AND B.nsaIF_YEAR = GL.HSTYEAR AND GL.SOURCDOC = ''P/L'') ) as nsaIF_SI_Sum,C.ACTINDX,C.ORMSTRID FROM [' + @I_nsaIF_Table + '] C ) A
	INNER JOIN [' + @I_nsaIF_Table + ']  ON A.ACTINDX = [' + @I_nsaIF_Table + '].ACTINDX AND A.ORMSTRID = [' + @I_nsaIF_Table + '].ORMSTRID'
	  print @MainQuery
	exec(@MainQuery)  
    
     
 set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET DEBITAMT = 0 , CRDTAMNT = 0 where         
  ' + @I_nsaIF_Table + '.TRXDATE < convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103)  
  AND ' + @I_nsaIF_Table + '.nsaIF_SI_Sum <> 0'        
   print @MainQuery          
   exec(@MainQuery)       
       
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SDeb_Sum =         
 ISNULL( (select sum(DEBITAMT) from ' + @I_nsaIF_Table + ' B where         
  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR         
  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX        
  /*and ' + @I_nsaIF_Table + '.TRXDATE >= convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103) */   
  group by ACTINDX, ORMSTRID), 0)'              
  print @MainQuery        
  exec(@MainQuery)          
    
  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SCred_Sum =         
 ISNULL( (select sum(CRDTAMNT) from ' + @I_nsaIF_Table + ' B where         
  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR         
  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX        
 /* and ' + @I_nsaIF_Table + '.TRXDATE >= convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103)     */
  group by ACTINDX, ORMSTRID), 0)'              
  print @MainQuery        
  exec(@MainQuery)          
end 
if @I_ReportNumber = 5
 begin  
		  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Db =       
		  ISNULL((select sum(DEBITAMT) from ' + @I_nsaIF_Table + ' B where       
		  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
		  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID    
		 group by ORMSTRID),0)'            
		  print @MainQuery      
		  exec(@MainQuery)        
		  
		  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Cr =       
		  ISNULL((select sum(CRDTAMNT) from ' + @I_nsaIF_Table + ' B where       
		  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
		  and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID 
		  group by ORMSTRID),0)'            
		  exec(@MainQuery)    
		  
		  set @MainQuery=''      
		  set @MainQuery='IF EXISTS (SELECT TOP 1 1 FROM ' + @I_nsaIF_Table + ' B INNER JOIN ' + @I_nsaIF_Table + ' ON B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR and B.JRNENTRY = 0)'
		    set @MainQuery =@MainQuery + ' UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
			 ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
			 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and  B.JRNENTRY = 0      
			and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID    
			group by ORMSTRID),0)'     
		    set @MainQuery =@MainQuery + ' ELSE UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
			 ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
			 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and  B.JRNENTRY <> 0      
			and B.ORMSTRID = ' + @I_nsaIF_Table + '.ORMSTRID    
			group by ORMSTRID),0)'     
			print @MainQuery        
			exec(@MainQuery)    
  
  END
  else
  begin
		  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Db =       
		  ISNULL((select sum(DEBITAMT) from ' + @I_nsaIF_Table + ' B where       
		  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
		  and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX   
		 group by ACTINDX),0)'            
		  print @MainQuery      
		  exec(@MainQuery)        
		  
		  set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_Cr =       
		  ISNULL((select sum(CRDTAMNT) from ' + @I_nsaIF_Table + ' B where       
		  B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR       
		  and B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX 
		  group by ACTINDX),0)'            
		  exec(@MainQuery)        
	  
	 /*set @MainQuery=''      
	  set @MainQuery =' UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
	  ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
		 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and       
		 B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX group by ACTINDX),0)'  
	   print @MainQuery        
	   exec(@MainQuery) */
	   
	  set @MainQuery=''      
	  set @MainQuery='IF EXISTS (SELECT TOP 1 1 FROM ' + @I_nsaIF_Table + ' B INNER JOIN ' + @I_nsaIF_Table + ' ON B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR and B.JRNENTRY = 0)'
	    set @MainQuery =@MainQuery + ' UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
		 ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
		 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and  B.JRNENTRY = 0 and     
		 B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX group by ACTINDX),0)'     
	    set @MainQuery =@MainQuery + ' ELSE UPDATE ' + @I_nsaIF_Table + '  set nsaIF_Tot_SI = 
		 ISNULL((select sum(nsaIF_SI_Sum) from ' + @I_nsaIF_Table + ' B where       
		 B.nsaIF_YEAR = ' + @I_nsaIF_Table + '.nsaIF_YEAR  and  B.JRNENTRY <> 0 and  
		 B.ACTINDX = ' + @I_nsaIF_Table + '.ACTINDX group by ACTINDX),0)'     
		print @MainQuery        
		exec(@MainQuery) 

  end     
  
  BEGIN                
    set @MainQuery=''                
set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_SF_Sum = (nsaIF_SI_Sum + (nsaIF_SDeb_Sum - nsaIF_SCred_Sum))                
    FROM ' + @I_nsaIF_Table + ' INNER JOIN GL00100 ON (' + @I_nsaIF_Table + '.ACTINDX = GL00100.ACTINDX) WHERE nsaIF_SDeb_Sum <> 0  
    OR nsaIF_SCred_Sum <> 0 OR nsaIF_SI_Sum <> 0'                
    print @MainQuery          
    exec(@MainQuery)                
   END                
   
  BEGIN             
   set @MainQuery=''            
   set @MainQuery ='UPDATE ' + @I_nsaIF_Table + ' SET nsaIF_Tot_SF = (nsaIF_Tot_SI + (nsaIF_Tot_Db - nsaIF_Tot_Cr))            
   FROM ' + @I_nsaIF_Table + ' INNER JOIN GL00100 ON (' + @I_nsaIF_Table + '.ACTINDX = GL00100.ACTINDX) '            
   print @MainQuery      
   exec(@MainQuery)            
  END       
  
BEGIN  
  set @MainQuery=''   
   set @MainQuery ='DELETE FROM ' + @I_nsaIF_Table + ' WHERE          
  TRXDATE < convert(datetime,''' + ltrim(rtrim(@I_From_Date)) +''',103)  
  AND nsaIF_SI_Sum = 0 AND SEQNUMBR = 0 AND DEBITAMT =0 AND CRDTAMNT = 0'        
   print @MainQuery          
   exec(@MainQuery)   
END  
    
 set nocount off                
  
END              
  GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nsaIF_Cuenta_Tercero_Detallado_Hist] TO [DYNGRP] 
GO 
/*End_nsaIF_Cuenta_Tercero_Detallado_Hist*/
/*Begin_nsaIF_Cuenta_NIT_Resumen*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsaIF_Cuenta_NIT_Resumen]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsaIF_Cuenta_NIT_Resumen]
GO

CREATE Procedure nsaIF_Cuenta_NIT_Resumen  
  
    
@I_nsaIF_Year as char(4),            
@I_Month_Fr as int,            
@I_Month_To as int,            
@I_From_Date as datetime,            
@I_To_Date as datetime,            
@I_Acc_Num_Fr as char(129),            
@I_Acc_Num_To as char(129),            
@I_From_NITID as char (31),    
@I_To_NITID as char (31),    
@I_nsaIF_Table as char(25)            
as            
set nocount on            
Declare            
 @Tot_Month as int,            
 @Count as int,             
 @Calc_Month as int,            
 @SQL_Cred as varchar(200),            
 @SQL_Debit as varchar(200),            
 @SQL_SF as varchar(200),            
 @SQL_SI as varchar(200),            
 @MainQuery as varchar(8000)  ,          
 @dt_Date as char(10),    
 @CName as char(15),    
 @sSQL as varchar(8000),    
 @sSQLGL as varchar(8000),    
 @sSQLAlias as varchar(8000) ,
 @StrAllTodo as char(10)         

set @StrAllTodo = ''

if @I_Acc_Num_Fr = 'All'
BEGIN
	SET @StrAllTodo = 'All'
END
else if @I_Acc_Num_Fr = 'Todo'
BEGIN
	SET @StrAllTodo = 'Todo'
END	

BEGIN             
 if @I_Month_Fr <= @I_Month_To             
 BEGIN            
  set @Tot_Month = @I_Month_To - @I_Month_Fr             
 END            
 set @Count = 0             
 set @Calc_Month = @I_Month_Fr            
 set @SQL_Cred =''            
 set @SQL_Debit = ''            
 set @SQL_SF = ''             
 set @SQL_SI = ''            
 set @dt_Date = '01-01-1900'          
  
 while  @Count <= @Tot_Month            
 BEGIN            
  if @Count <> @Tot_Month            
   BEGIN            
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'            
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month))) + ' +'            
   END            
  else            
   BEGIN            
   set @SQL_Cred = @SQL_Cred + ' nsaIF_SCred_' + ltrim(Rtrim(str(@Calc_Month)))             
   set @SQL_Debit = @SQL_Debit + ' nsaIF_SDeb_' + ltrim(Rtrim(str(@Calc_Month)))             
   END            
  set @SQL_SI = ' nsaIF_SI_' + ltrim(Rtrim(str(@I_Month_Fr)))          
  set @SQL_SF = ' nsaIF_SF_' + ltrim(Rtrim(str(@I_Month_To)))           
  set @Calc_Month = @Calc_Month + 1            
  set @Count = @Count + 1            
 END            
  
 declare c cursor fast_forward for     
 select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='GL00100' and COLUMN_NAME like 'ACTNUMBR%'    
 open c    
 fetch next from c into @CName    
 set @sSQL = ''    
 set @sSQLGL = ''    
 set @sSQLAlias = ''    
 WHILE @@fetch_status=0    
 BEGIN    
  set @sSQL = @sSQL + ltrim(rtrim(@CName))    
  set @sSQLAlias = @sSQLAlias + 'nsaIF_GL00050.' + ltrim(rtrim(@CName)) + ' AS ' + @CName    
  set @sSQLGL = @sSQLGL + 'nsaIF_GL00050.' + ltrim(rtrim(@CName))    
  fetch next from c into @CName    
  if @@fetch_status=0    
   begin    
    set @sSQL = @sSQL + ','    
    set @sSQLGL = @sSQLGL + ','    
    set @sSQLAlias = @sSQLAlias + ','    
   end    
 END    
 close c    
 deallocate c    
  
 BEGIN          
  set @MainQuery = 'INSERT INTO ' + @I_nsaIF_Table + ' (ACTINDX,' + @sSQL + ', ACTNUMST,ACTDESCR, nsaIFNit, CUSTNAME, VENDNAME,  nsaIF_SI_Sum, nsaIF_SDeb_Sum, nsaIF_SCred_Sum, nsaIF_SF_Sum)    
  SELECT ACTINDX, ' + @sSQL + ', ACTNUMST, ACTDESCR, nsaIFNit,    
  (case when CName is not null then CName when VName is not null then VName else ' + char(39) + ' ' + char(39) + ' end) NitName, ' + char(39) + ' ' + char(39) + ',     
  nsaIF_SI_NET, nsaIF_SDeb, nsaIF_SCred, nsaIF_SF_NET from (    
  SELECT nsaIF_GL00050.ACTINDX, ' + @sSQLAlias + ', nsaIF_GL00050.ACTNUMST ACTNUMST, GL00100.ACTDESCR,     
  isnull(nsaIF_GL00050.nsaIFNit,' + char(39) + '' + char(39) + ') nsaIFNit,     
  nsaIF02666.CUSTNAME CName,     
  nsaIF01666.VENDNAME VName,    
  SUM(' + @SQL_SI + ') as nsaIF_SI_NET ,     
  SUM(' + @SQL_Debit + ') as nsaIF_SDeb,     
  SUM(' + @SQL_Cred + ') as nsaIF_SCred ,    
  SUM(' + @SQL_SF + ') as nsaIF_SF_NET     
  FROM  GL00100 INNER JOIN nsaIF_GL00050 ON    
  GL00100.ACTINDX  = nsaIF_GL00050.ACTINDX  LEFT OUTER JOIN nsaIF02666  ON    
  nsaIF02666.nsaIFNit = nsaIF_GL00050.nsaIFNit AND nsaIF02666.CUSTNMBR = nsaIF_GL00050.ORMSTRID LEFT OUTER JOIN nsaIF01666 ON    
  nsaIF01666.nsaIFNit = nsaIF_GL00050.nsaIFNit AND nsaIF01666.VENDORID = nsaIF_GL00050.ORMSTRID    
  WHERE nsaIF_YEAR = ' + @I_nsaIF_Year + '  and (1 = 1 '        
  if ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo  and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo         
  BEGIN         
   set @MainQuery = @MainQuery + ' AND nsaIF_GL00050.ACTNUMST BETWEEN ' + char(39) + @I_Acc_Num_Fr + char(39) + ' and ' + char(39) + @I_Acc_Num_To + char(39) + ' '        
  END        
  if (ltrim(rtrim(@I_From_NITID)) <> '' and ltrim(rtrim(@I_To_NITID)) <> '') and ltrim(rtrim(@I_Acc_Num_Fr)) = @StrAllTodo  and ltrim(rtrim(@I_Acc_Num_To)) = @StrAllTodo        
  BEGIN  
   set @MainQuery = @MainQuery + ' and '  
  END  
  if (ltrim(rtrim(@I_From_NITID)) <> '' and ltrim(rtrim(@I_To_NITID)) <> '') and ltrim(rtrim(@I_Acc_Num_Fr)) <> @StrAllTodo  and ltrim(rtrim(@I_Acc_Num_To)) <> @StrAllTodo        
  BEGIN  
   set @MainQuery = @MainQuery + ' or  '    
  END   
  if ltrim(rtrim(@I_From_NITID)) <>'' and ltrim(rtrim(@I_To_NITID)) <> ''        
  BEGIN                
   set @MainQuery = @MainQuery + ' nsaIF_GL00050.nsaIFNit BETWEEN ' + char(39) + @I_From_NITID + char(39) + ' and '+ char(39) + @I_To_NITID + char(39) + '         
   AND nsaIF_GL00050.nsaIFNit <> ' + char(39) + '' + char(39) + ''        
  END         
  
  set @MainQuery = @MainQuery + ' )'        
  
  set @MainQuery = @MainQuery + ' GROUP BY  nsaIF_GL00050.nsaIFNit, nsaIF_GL00050.ACTINDX, ' + @sSQLGL + ', nsaIF_GL00050.ACTNUMST, nsaIF02666.CUSTNAME,        
  nsaIF01666.VENDNAME, GL00100.ACTDESCR         
  )A ORDER BY ACTNUMST '        
  
 exec (@MainQuery)        
 END    
 set nocount off            
  
END   
  GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nsaIF_Cuenta_NIT_Resumen] TO [DYNGRP] 
GO 
/*End_nsaIF_Cuenta_NIT_Resumen*/
/*Begin_Generacion_de_Archivos_Format1007*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Generacion_de_Archivos_Format1007]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Generacion_de_Archivos_Format1007]
GO

CREATE PROC Generacion_de_Archivos_Format1007
	@TableName	VARCHAR(20),
	@Year		BIT,
	@INYEAR		INTEGER,
	@IN_sFormat	VARCHAR(10)
AS
	DECLARE 
		@TempTbName	VARCHAR(20),
		@User		VARCHAR(100),
		@DBName	VARCHAR(100)

BEGIN
	SELECT @User = SYSTEM_USER, @DBName = DB_NAME(),@TempTbName = '##1007'+@User+@DBName

	
	EXEC('SELECT ORMSTRID, SERIES, ACTINDX, TPCLBLNC, CrdDocAmt, ''0000'' nsaIF_Code, DEBITAMT DEBITAMT1, CRDTAMNT CRDTAMNT1, 
		
		DEBITAMT DEBITAMT2, CRDTAMNT CRDTAMNT2, DEBITAMT DEBITAMT3, CRDTAMNT CRDTAMNT3, 
		
		DEBITAMT DEBITAMT4, CRDTAMNT CRDTAMNT4, DEBITAMT DEBITAMT5, CRDTAMNT CRDTAMNT5, 
		
		DEBITAMT DEBITAMT6, CRDTAMNT CRDTAMNT6, DEBITAMT DEBITAMT7, CRDTAMNT CRDTAMNT7  
		
		INTO ##TEMP'+ @User + @DBName +' FROM '+@TableName)


	EXEC('DROP TABLE '+ @TableName)

	

	EXEC('SELECT * INTO '+@TableName+' FROM ##TEMP'+ @User+ @DBName)

	

	EXEC('DROP TABLE ##TEMP'+ @User+ @DBName)

	
	IF @Year = 0
	
	BEGIN
		
		EXEC('SELECT ac.ORMSTRID, ac.SERIES, ac.ACTINDX, SUM(ac.DEBITAMT) DEBITAMT, SUM(ac.CRDTAMNT) CRDTAMNT, 
		
		(SELECT TPCLBLNC FROM GL00100 WHERE ACTINDX = ac.ACTINDX) TPCLBLNC, nsaIF_Format1007, nsaIF_GL00080.nsaIF_Code INTO ['+@TempTbName+']
		
		FROM GL20000 as ac 
INNER JOIN nsaIF_GL00080 ON ac.ACTINDX =nsaIF_GL00080.ACTINDX
		INNER JOIN nsaIF_GL00100 ON ac.ACTINDX =nsaIF_GL00100.ACTINDX AND nsaIF_GL00100.nsaIF_Code = nsaIF_GL00080.nsaIF_Code 
		WHERE ac.OPENYEAR = '+@INYEAR+' AND nsaIF_Format1007 <> 0 AND
 ((SERIES = 3 AND ORTRXTYP IN (1,3,4,7,8,9)) OR SERIES = 2 OR SERIES = 4)  AND 
		
		ac.ACTINDX NOT IN ( SELECT nsaIF_Destination FROM nsaIF_GL00030 ) AND 
ac.ACTINDX IN ( SELECT ACTINDX FROM nsaIF_GL00100 WHERE nsaIF_Code IN  
		( SELECT nsaIF_Code FROM nsaIF_GL00010 WHERE Numero_de_Formato = '+@IN_sFormat+'))  AND 
SUBSTRING(ORTRXSRC,1,5) NOT IN  (''PMVPY'',''PMVVR'',''SLSVT'',''RMMSC'') AND 
		
		SOURCDOC <> ''BBF'' AND (ORCTRNUM NOT IN (SELECT DOCNUMBR FROM RM20101 WHERE VOIDSTTS = 1 AND CUSTNMBR = ac.ORMSTRID AND DOCNUMBR = ac.ORCTRNUM AND ac.SERIES = 3) AND
 
		ORCTRNUM NOT IN (SELECT DOCNUMBR FROM RM30101 WHERE VOIDSTTS = 1 AND CUSTNMBR = ac.ORMSTRID AND DOCNUMBR = ac.ORCTRNUM AND ac.SERIES = 3) AND 

		ORCTRNUM NOT IN (SELECT VCHRNMBR FROM PM20000 WHERE VOIDED = 1 AND VENDORID = ac.ORMSTRID AND VCHRNMBR  = ac.ORCTRNUM  AND ac.SERIES = 4) AND 

		ORCTRNUM NOT IN (SELECT VCHRNMBR FROM PM30200 WHERE VOIDED = 1 AND VENDORID = ac.ORMSTRID AND VCHRNMBR  = ac.ORCTRNUM  AND ac.SERIES = 4)) 

		GROUP BY ORMSTRID, SERIES, ac.ACTINDX ,nsaIF_Format1007, nsaIF_GL00080.nsaIF_Code

		ORDER BY ORMSTRID, SERIES, ac.ACTINDX ')
	
	END
	
	ELSE

	BEGIN

		EXEC('SELECT ac.ORMSTRID, ac.SERIES, ac.ACTINDX, SUM(ac.DEBITAMT) DEBITAMT, SUM(ac.CRDTAMNT) CRDTAMNT, 

		(SELECT TPCLBLNC FROM GL00100 WHERE ACTINDX = ac.ACTINDX) TPCLBLNC, nsaIF_Format1007, nsaIF_GL00080.nsaIF_Code INTO ['+@TempTbName+'] 
		FROM GL30000 as ac 

		INNER JOIN nsaIF_GL00080 ON ac.ACTINDX =nsaIF_GL00080.ACTINDX
		INNER JOIN nsaIF_GL00100 ON ac.ACTINDX =nsaIF_GL00100.ACTINDX AND nsaIF_GL00100.nsaIF_Code = nsaIF_GL00080.nsaIF_Code 
		WHERE ac.HSTYEAR = '+@INYEAR+' AND nsaIF_Format1007 <> 0 AND

		((SERIES = 3 AND ORTRXTYP IN (1,3,4,7,8,9)) OR SERIES = 2 OR SERIES = 4)  AND 

		ac.ACTINDX NOT IN ( SELECT nsaIF_Destination FROM nsaIF_GL00030 ) AND 

		ac.ACTINDX IN ( SELECT ACTINDX FROM nsaIF_GL00100 WHERE nsaIF_Code IN  ( SELECT nsaIF_Code FROM nsaIF_GL00010 WHERE Numero_de_Formato = '+@IN_sFormat+'))  AND 

		SUBSTRING(ORTRXSRC,1,5) NOT IN  (''PMVPY'',''PMVVR'',''SLSVT'',''RMMSC'') AND 
SOURCDOC <> ''BBF''
 AND (ORCTRNUM NOT IN 
		(SELECT DOCNUMBR FROM RM20101 WHERE VOIDSTTS = 1 AND CUSTNMBR = ac.ORMSTRID AND DOCNUMBR = ac.ORCTRNUM AND ac.SERIES = 3) AND 

		ORCTRNUM NOT IN (SELECT DOCNUMBR FROM RM30101 WHERE VOIDSTTS = 1 AND CUSTNMBR = ac.ORMSTRID AND DOCNUMBR = ac.ORCTRNUM AND ac.SERIES = 3) AND
 
		ORCTRNUM NOT IN (SELECT VCHRNMBR FROM PM20000 WHERE VOIDED = 1 AND VENDORID = ac.ORMSTRID AND VCHRNMBR  = ac.ORCTRNUM  AND ac.SERIES = 4) AND 

		ORCTRNUM NOT IN (SELECT VCHRNMBR FROM PM30200 WHERE VOIDED = 1 AND VENDORID = ac.ORMSTRID AND VCHRNMBR  = ac.ORCTRNUM  AND ac.SERIES = 4)) 

		GROUP BY ORMSTRID, SERIES, ac.ACTINDX ,nsaIF_Format1007, nsaIF_GL00080.nsaIF_Code

		ORDER BY ORMSTRID, SERIES, ac.ACTINDX ')

	END


	EXEC('INSERT INTO '+@TableName+' SELECT DISTINCT a.ORMSTRID,a.SERIES,a.ACTINDX,a.TPCLBLNC,0, a.nsaIF_Code
		,( SELECT ISNULL(SUM(b.DEBITAMT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 1 ) DEBIT1
		,( SELECT ISNULL(SUM(b.CRDTAMNT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 1 ) CREDIT1
		,( SELECT ISNULL(SUM(b.DEBITAMT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 2 ) DEBIT2
		,( SELECT ISNULL(SUM(b.CRDTAMNT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 2 ) CREDIT2
		,( SELECT ISNULL(SUM(b.DEBITAMT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 3 ) DEBIT3
		,( SELECT ISNULL(SUM(b.CRDTAMNT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 3 ) CREDIT3
		,( SELECT ISNULL(SUM(b.DEBITAMT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 4 ) DEBIT4
		,( SELECT ISNULL(SUM(b.CRDTAMNT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 4 ) CREDIT4
		,( SELECT ISNULL(SUM(b.DEBITAMT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 5 ) DEBIT5
		,( SELECT ISNULL(SUM(b.CRDTAMNT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 5 ) CREDIT5
		,( SELECT ISNULL(SUM(b.DEBITAMT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 6 ) DEBIT6
		,( SELECT ISNULL(SUM(b.CRDTAMNT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 6 ) CREDIT6
		,( SELECT ISNULL(SUM(b.DEBITAMT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 7 ) DEBIT7
		,( SELECT ISNULL(SUM(b.CRDTAMNT),0) FROM ['+@TempTbName+'] b WHERE a.SERIES = b.SERIES AND b.ORMSTRID=a.ORMSTRID AND b.ACTINDX=a.ACTINDX AND b.TPCLBLNC=a.TPCLBLNC AND b.nsaIF_Code = a.nsaIF_Code AND b.nsaIF_Format1007 = a.nsaIF_Format1007 AND b.nsaIF_Format1007 = 7 ) CREDIT7
	FROM ['+@TempTbName+'] a ')
	
	EXEC('DROP TABLE ['+@TempTbName+']')

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[Generacion_de_Archivos_Format1007] TO [DYNGRP] 
GO 
/*End_Generacion_de_Archivos_Format1007*/
