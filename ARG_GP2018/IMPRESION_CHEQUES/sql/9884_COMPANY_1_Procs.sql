/*Count : 1 */
 
set DATEFORMAT ymd 
GO 
 
/*Begin_AX_Fill_nfMCP_PAYMENT_LINE_TEMP*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AX_Fill_nfMCP_PAYMENT_LINE_TEMP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AX_Fill_nfMCP_PAYMENT_LINE_TEMP]
GO

CREATE PROCEDURE AX_Fill_nfMCP_PAYMENT_LINE_TEMP 
@I_cTableName char(255) = NULL, 
@I_cOriginTable char(255) = NULL, 
@I_cBANACTID char(20) = NULL, 
@I_cCHEKBKID char(15) = NULL, 
@O_SQL_Error_State int = NULL  output 
as declare 
@vInsertStatement1 varchar(3000) 
select @O_SQL_Error_State = 0 
select @vInsertStatement1 = 'insert into ' + rtrim(@I_cTableName) + char(13) + ' SELECT MCPTYPID, NUMBERIE, MEDIOID, BANKID, DOCNUMBR, TITACCT, EMIDATE, DUEDATE, LINEAMNT, AMOUNTO, CURNCYID, STSDESCR, LNSEQNBR, CHEKBKID, BANACTID, CURRNIDX FROM ' + DB_NAME() + '.dbo.' + rtrim(@I_cOriginTable)  + ' WHERE BANACTID = ' + char(39) + rtrim(@I_cBANACTID) + char(39) + ' AND  CHEKBKID = ' + char(39) + rtrim(@I_cCHEKBKID) + char(39) exec (@vInsertStatement1) 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[AX_Fill_nfMCP_PAYMENT_LINE_TEMP] TO [DYNGRP] 
GO 

/*End_AX_Fill_nfMCP_PAYMENT_LINE_TEMP*/

