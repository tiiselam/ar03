/*Count : 2 */
 
set DATEFORMAT ymd 
GO 
 
/*Begin_trptIF10001Ins*/

if exists (select * from sysobjects where id = object_id('dbo.trptIF10001Ins') and sysstat & 0xf = 8)
 drop trigger dbo.trptIF10001Ins
GO

create trigger dbo.trptIF10001Ins
on GL20000
for insert
as

declare @OrgTxSrc		varchar(15),
	@JrnEntry			int,
	@SEQNUMBR			int,
	@SEQNUMBR1			int,	
	@TrxDate			datetime,
	@DebitAmt			numeric(19,5),
	@CreditAmt			numeric(19,5),
	@ActIndx			int,
	@OpenYear			smallint,
	@OrgMstrID			varchar(31),
	@OrgTrxNum			varchar (21),
	@Series				smallint,
	@OrgTrxType			smallint,
	@CUSTVNDR			varchar(30),
	@ORMSTRNM			varchar(60),
	@TERCTYPE			smallint,
	@CUSTNAME			varchar(60),
	@OrigSeqNum			int,
	@OrgDocNum			varchar(25),
	@RCTRXSEQ			numeric(19,5),
	@QKOFSET			int,
	@TRXSRC				varchar(255),
	@l_cINTERID			char(5)	,
	@l_cTrxSrc          varchar(255),
	@l_nStatus          int,
	@l_nSQL_Error_State int



select  @OrgTxSrc = '',
	@JrnEntry = 0,
	@SEQNUMBR = 0,
	@SEQNUMBR1 = 0,
	@TrxDate = 0,
	@DebitAmt = 0,
	@CreditAmt = 0,
	@ActIndx = 0,
	@OpenYear = 0,
	@OrgMstrID = '',
	@OrgTrxNum =  '',
	@Series = 0,
	@OrgTrxType =0,
	@CUSTVNDR = '',
	@ORMSTRNM = '',
	@TERCTYPE = 0,
	@CUSTNAME = '',
	@OrigSeqNum = 0,
	@OrgDocNum = '',
	@RCTRXSEQ = 0,
	@TRXSRC = '',
	@l_cINTERID = '',
	@l_cTrxSrc = ''

select @l_cINTERID = db_name()
exec  @l_nStatus = DYNAMICS.dbo.smGetMsgString 15575, @l_cINTERID, @l_cTrxSrc output, @l_nSQL_Error_State output

DECLARE GL_OrmstrID CURSOR STATIC FOR 
select  ORGNTSRC,
        JRNENTRY,
        SEQNUMBR,
        TRXDATE,
        DEBITAMT,
		CRDTAMNT,
		ACTINDX,
		OPENYEAR,	
		ORMSTRID,
		ORCTRNUM,
		SERIES,
		OrigSeqNum,
		ORTRXTYP,
		ORDOCNUM,
		RCTRXSEQ,
		QKOFSET,
		TRXSORCE from inserted 

OPEN GL_OrmstrID
FETCH NEXT FROM GL_OrmstrID INTO
				@OrgTxSrc ,
				@JrnEntry ,
				@SEQNUMBR ,
				@TrxDate ,
				@DebitAmt ,
				@CreditAmt ,
				@ActIndx ,
				@OpenYear ,	
				@OrgMstrID ,
				@OrgTrxNum ,
				@Series ,
				@OrigSeqNum ,
				@OrgTrxType ,
				@OrgDocNum ,
				@RCTRXSEQ ,
				@QKOFSET ,
				@TRXSRC 

WHILE @@FETCH_STATUS = 0
BEGIN

	if not exists(select 1 from IF10001 where JRNENTRY = @JrnEntry and SQNCLINE = @SEQNUMBR) 
	and exists(select 1 from IFGL10100 where JRNENTRY = @JrnEntry)
	begin
		if @QKOFSET = 0
		begin
			select @CUSTVNDR = '' + CustomerVendor_ID, @TERCTYPE = TERCTYPE  from dbo.IFGL10100 
			where JRNENTRY = @JrnEntry
		end
		else
		begin
			select @CUSTVNDR = '' + CustomerVendor_ID, @TERCTYPE = TERCTYPE  from dbo.IFGL10101 
			where JRNENTRY = @JrnEntry and SQNCLINE = @SEQNUMBR
		end		
		insert into IF10001 (JRNENTRY,SQNCLINE,CUSTVNDR,TERCTYPE,POSTED,TRXDATE,DEBITAMT,CRDTAMNT,ACTINDX,YEAR1)
		values(@JrnEntry,@SEQNUMBR,@CUSTVNDR,@TERCTYPE,1,@TrxDate,@DebitAmt,@CreditAmt,@ActIndx,@OpenYear)
	end
	ELSE
	BEGIN
		UPDATE IF10001 SET POSTED = 1 WHERE JRNENTRY = @JrnEntry and SQNCLINE = @SEQNUMBR
	END

	if ltrim(rtrim(substring(ltrim(rtrim(@TRXSRC)), 1, len(ltrim(rtrim(@l_cTrxSrc)))))) = ltrim(rtrim(@l_cTrxSrc))
	begin	
		select @SEQNUMBR1 = cast(substring(ltrim(rtrim(SEQNUMBR)), 3, len(ltrim(rtrim(SEQNUMBR)))) as integer)
			from GL20000 where JRNENTRY = @JrnEntry and SEQNUMBR = @SEQNUMBR 

		select @CUSTVNDR = '' + CUSTVNDR, @TERCTYPE = TERCTYPE  from dbo.IF10001 where JRNENTRY = @JrnEntry and SQNCLINE = @SEQNUMBR1
	end
	else
		select @CUSTVNDR = '' + CUSTVNDR, @TERCTYPE = TERCTYPE  from dbo.IF10001 where JRNENTRY = @JrnEntry and SQNCLINE = @SEQNUMBR	
	
	if @TERCTYPE = 1 
	begin
		select @CUSTNAME = '' + CUSTNAME from RM00101 where CUSTNMBR = @CUSTVNDR
		update GL20000 set ORMSTRID = @CUSTVNDR, ORMSTRNM = @CUSTNAME 
		where JRNENTRY = @JrnEntry and SEQNUMBR = @SEQNUMBR AND OPENYEAR = @OpenYear AND RCTRXSEQ = @RCTRXSEQ
	end
	else 
	if @TERCTYPE = 2
	begin	
		select @CUSTNAME = '' + VENDNAME from PM00200 where VENDORID = @CUSTVNDR
		update GL20000 set ORMSTRID = @CUSTVNDR, ORMSTRNM = @CUSTNAME 
		where JRNENTRY = @JrnEntry and SEQNUMBR = @SEQNUMBR AND OPENYEAR = @OpenYear AND RCTRXSEQ = @RCTRXSEQ
	end
	else		
	begin
		if @Series = 4
		begin
			exec trptIF1001AddRecord 
				@OrgTxSrc,
				@JrnEntry,
				@SEQNUMBR,
				@TrxDate,
				@DebitAmt,
				@CreditAmt,
				@ActIndx,
				@OpenYear,
				@OrgMstrID,
				@OrgTrxNum,
				@OrigSeqNum,
				@OrgTrxType,
				@OrgDocNum,
				@RCTRXSEQ
		end
		else if @Series = 3
		Begin
			select @CUSTVNDR = '' + CUSTNMBR from dbo.IFRM10101 
			where DOCNUMBR = @OrgDocNum and RMDTYPAL = @OrgTrxType AND SEQNUMBR = @SEQNUMBR and DSTINDX = @ActIndx
			
			if LEN(@CUSTVNDR)=0
			begin
				select @CUSTVNDR = '' + CUSTNMBR from dbo.IFSOP10102 
				where SOPNUMBE = @OrgTrxNum and SOPTYPE = @OrgTrxType AND SEQNUMBR = @OrigSeqNum and ACTINDX = @ActIndx

			END
			IF LEN(@CUSTVNDR)=0 
			Begin
				select top 1 @CUSTVNDR = '' + CUSTNMBR FROM dbo.RM10101 
				WHERE DOCNUMBR = @OrgTrxNum and RMDTYPAL = @OrgTrxType AND SEQNUMBR = @OrigSeqNum and DSTINDX = @ActIndx
			end			
			if LEN(@CUSTVNDR)=0
			Begin
				select @CUSTVNDR = @OrgMstrID
			End
			
			select @CUSTNAME = '' + CUSTNAME from dbo.RM00101 where CUSTNMBR = @CUSTVNDR
			
			update GL20000 set ORMSTRID = @CUSTVNDR, ORMSTRNM = @CUSTNAME 
			where JRNENTRY = @JrnEntry and SEQNUMBR = @SEQNUMBR AND OPENYEAR = @OpenYear AND RCTRXSEQ = @RCTRXSEQ
			
			insert into IF10001 (JRNENTRY,SQNCLINE,CUSTVNDR,TERCTYPE,POSTED,TRXDATE,DEBITAMT,CRDTAMNT,ACTINDX,YEAR1)
			values(@JrnEntry,@SEQNUMBR,@CUSTVNDR,1,1,@TrxDate,@DebitAmt,@CreditAmt,@ActIndx,@OpenYear)
		
		End	

	end
	FETCH NEXT FROM GL_OrmstrID  INTO
				@OrgTxSrc ,
				@JrnEntry ,
				@SEQNUMBR ,
				@TrxDate ,
				@DebitAmt ,
				@CreditAmt ,
				@ActIndx ,
				@OpenYear ,	
				@OrgMstrID ,
				@OrgTrxNum ,
				@Series ,
				@OrigSeqNum ,
				@OrgTrxType ,
				@OrgDocNum ,
				@RCTRXSEQ ,
				@QKOFSET ,
				@TRXSRC
END
CLOSE GL_OrmstrID
DEALLOCATE GL_OrmstrID
 
GO

/*End_trptIF10001Ins*/
/*Begin_nsaIFAgregar_Datos*/
if exists (select * from sysobjects where id = object_id('dbo.nsaIFAgregar_Datos') and sysstat & 0xf = 8)
 drop trigger dbo.nsaIFAgregar_Datos
GO
CREATE TRIGGER nsaIFAgregar_Datos on GL20000  
FOR INSERT as  
declare @Indice  int, @Tercero char (21),@Tercero_Nombre char(31),@Año smallint, @Fecha_TRX datetime,   
            @Debito numeric(19,5), @Credito numeric(19,5),@f int, @deb varchar(50),  
            @Cred varchar(50),@s_f varchar(50),@s_i varchar(50),@SQL varchar(255), @TRXSOURCE varchar(20),@PostingType int,@ACTNUMST varchar(129), @CNT integer, @JrnEntry	int, @SEQNUMBR	int,
			@Tercero2 char (21),@Tercero_Nombre2 char(31)
 select @CNT = count(1) from DYNAMICS..SY00302

 select  @Indice = inserted.ACTINDX,  
            @Tercero= inserted.ORMSTRID,  
            @Año= inserted.OPENYEAR,   
            @Tercero_Nombre= inserted.ORMSTRNM,   
            @Fecha_TRX= inserted.TRXDATE,   
            @Debito= inserted.DEBITAMT,  
            @Credito= inserted.CRDTAMNT, @TRXSOURCE=inserted.TRXSORCE,
			@JrnEntry = inserted.JRNENTRY, @SEQNUMBR = SEQNUMBR
 from inserted      

 select @Tercero= GL20000.ORMSTRID,  @Tercero_Nombre= GL20000.ORMSTRNM FROM GL20000 WHERE JRNENTRY = @JrnEntry AND SEQNUMBR = @SEQNUMBR AND OPENYEAR = @Año AND ACTINDX = @Indice


 IF @TRXSOURCE= 'BBF' or @TRXSOURCE='BBAL' BEGIN return  END 
/*IF (select count(GL.ORMSTRID) from PM30200 PM, GL20000 GL where PM.VOIDED=1 and PM.VCHRNMBR=GL.ORCTRNUM and PM.DOCTYPE=GL.ORGNATYP ) > 1 
BEGIN	RETURN END*/

IF ( ((@Indice) is not NULL OR (@Tercero_Nombre) is not NULL OR (@Año) is not NULL OR (@Fecha_TRX) is not NULL OR (@Debito) is not NULL OR (@Credito) is not NULL)) BEGIN 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'nsaIF_GL00050')  
  BEGIN 
  IF  EXISTS (select ORMSTRID from nsaIF_GL00050 where ACTINDX = @Indice and nsaIF_YEAR = @Año and ORMSTRID = @Tercero ) 
  BEGIN  
	set @f =  CAST(MONTH(@Fecha_TRX) as int)    
	exec  nsaIF_Update_Table @Indice, @Tercero , @Tercero_Nombre , @Año , @Fecha_TRX ,@Debito, @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType,@ACTNUMST    
  END  
  else  
  BEGIN  
	   SET @Tercero2 = replace(@Tercero,'''','''''')
	   SET @Tercero_Nombre2 = replace(@Tercero_Nombre,'''','''''')
	   SET @ACTNUMST = (SELECT ACTNUMST FROM GL00105 WHERE ACTINDX= @Indice)
	   if  @CNT = 1 
	   begin
		 EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], 
		 [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		 [nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		 [nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		 [nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		 [nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		 [nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		 VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2 +''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,	
		 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
		 set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		 exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
			                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType ,@ACTNUMST   			   
	  end
	  if  @CNT = 2 
	  begin
		EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2],
		[ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2 +''','''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
		set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
		                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType,@ACTNUMST    
     end
	 if  @CNT = 3
	 begin
		EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3],
		[ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2 +''','''','''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
		set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
			                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType,@ACTNUMST
	end
	if  @CNT = 4
	begin
		EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], 
		[ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		 [nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		 VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2 +''','''','''','''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
		 set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		 exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
			                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType,@ACTNUMST
	end
	if  @CNT = 5
	begin
		 EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5], 
		 [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		 [nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		 [nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		 [nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		 [nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		 [nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		 VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''','''','''', '''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
		 set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		 exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
			                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType,@ACTNUMST
	end
	if  @CNT = 6
	begin
		EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5], 
		 [ACTNUMBR_6], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		 [nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		 [nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		 [nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		 [nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		 [nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		 VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''','''','''', '''', '''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
		 set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		 exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
					@Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType,@ACTNUMST
	end
	if  @CNT = 7
	begin
		EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5], 
		[ACTNUMBR_6], [ACTNUMBR_7], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2 +''','''','''','''', '''', '''','''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
        set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
	                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType ,@ACTNUMST   
	end
	if  @CNT = 8
	begin
		EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5], 
		[ACTNUMBR_6], [ACTNUMBR_7], [ACTNUMBR_8], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''','''','''', '''', '''','''','''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
	    set @f=  CAST(MONTH(@Fecha_TRX) as int)    
	 	exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
		                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType ,@ACTNUMST   
	end
	if  @CNT = 9
	begin
		EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5], 
		[ACTNUMBR_6], [ACTNUMBR_7], [ACTNUMBR_8], [ACTNUMBR_9], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''','''','''', '''', '''','''','''', '''', '''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
        set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
	                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL,@PostingType ,@ACTNUMST   
	end
	if  @CNT = 10
	begin
		EXEC('INSERT INTO [nsaIF_GL00050]([nsaIF_YEAR], [ACTINDX], [ORMSTRID], [ORMSTRNM], [ACTNUMBR_1], [ACTNUMBR_2], [ACTNUMBR_3], [ACTNUMBR_4], [ACTNUMBR_5], 
		[ACTNUMBR_6], [ACTNUMBR_7], [ACTNUMBR_8], [ACTNUMBR_9], [ACTNUMBR_10], [ACTNUMST], [nsaIFNit], [nsaIF_Type_Nit], [nsaIF_SDeb01], [nsaIF_SDeb0], [nsaIF_SF0], 
		[nsaIF_SI0], [nsaIF_SCred_1], [nsaIF_SCred_2], [nsaIF_SCred_3], [nsaIF_SCred_4], [nsaIF_SCred_5], [nsaIF_SCred_6], [nsaIF_SCred_7], [nsaIF_SCred_8], 
		[nsaIF_SCred_9], [nsaIF_SCred_10], [nsaIF_SCred_11], [nsaIF_SCred_12], [nsaIF_SDeb_1], [nsaIF_SDeb_2], [nsaIF_SDeb_3], [nsaIF_SDeb_4], [nsaIF_SDeb_5], 
		[nsaIF_SDeb_6], [nsaIF_SDeb_7], [nsaIF_SDeb_8], [nsaIF_SDeb_9], [nsaIF_SDeb_10], [nsaIF_SDeb_11], [nsaIF_SDeb_12], [nsaIF_SF_1], [nsaIF_SF_2], [nsaIF_SF_3],
		[nsaIF_SF_4], [nsaIF_SF_5], [nsaIF_SF_6], [nsaIF_SF_7], [nsaIF_SF_8], [nsaIF_SF_9], [nsaIF_SF_10], [nsaIF_SF_11], [nsaIF_SF_12], [nsaIF_SI_1], [nsaIF_SI_2], 
		[nsaIF_SI_3], [nsaIF_SI_4], [nsaIF_SI_5], [nsaIF_SI_6], [nsaIF_SI_7], [nsaIF_SI_8], [nsaIF_SI_9], [nsaIF_SI_10], [nsaIF_SI_11], [nsaIF_SI_12]) 
		VALUES( '+ @Año +', ' + @Indice + ','''+ @Tercero2 +''', '''+ @Tercero_Nombre2+''','''','''','''', '''', '''','''','''', '''', '''','''', '''+ @ACTNUMST +''', '''',0, 0, 0,0, 0, 0,0,0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)')
        set @f=  CAST(MONTH(@Fecha_TRX) as int)    
		exec nsaIF_Update_Table @Indice, @Tercero ,@Tercero_Nombre , @Año ,@Fecha_TRX ,@Debito,  
	                @Credito , @f ,@deb , @Cred ,@s_f ,@s_i , @SQL ,@PostingType ,@ACTNUMST  
	end
	END  
	END   
END    
GO
/*End_nsaIFAgregar_Datos*/