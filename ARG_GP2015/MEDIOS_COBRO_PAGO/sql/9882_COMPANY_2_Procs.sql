/*Count : 33 */
 
set DATEFORMAT ymd 
GO 
 
/*Begin_MCP_DC_Fill_Table_AWDC_Applied_Documents_Proc*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MCP_DC_Fill_Table_AWDC_Applied_Documents_Proc]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MCP_DC_Fill_Table_AWDC_Applied_Documents_Proc]
GO

CREATE    PROCEDURE MCP_DC_Fill_Table_AWDC_Applied_Documents_Proc 
( 
 @MINDOCAMNT AS NUMERIC(19,5) , 
 @CUSTNMBR_FROM   AS CHAR(15)  , 
 @CUSTNMBR_TO   AS CHAR(15)  ,   
 @APPLY_DATE_FROM  AS DATETIME  , 
 @APPLY_DATE_TO   AS DATETIME  , 
 @DOCID_FROM   AS CHAR(15)  , 
 @DOCID_TO   AS CHAR(15) 
) 
AS 
BEGIN 
 DELETE FROM AWDC10100  
 INSERT INTO AWDC10100  
 SELECT * FROM 
  (SELECT dbo.RM20201.APTODCNM, dbo.RM20201.APTODCTY ,  
   dbo.RM20201.APTODCDT, dbo.RM20201.APFRDCNM ,   
   dbo.RM20201.APFRDCTY, dbo.RM20201.APFRDCDT ,  
   dbo.RM20201.CUSTNMBR, dbo.RM20201.DATE1  ,  
   dbo.RM20201.RLGANLOS, dbo.SOP30200.DOCID , 
   dbo.SOP30200.TAXSCHID 
  FROM         dbo.RM20201 INNER JOIN 
                        dbo.SOP30200 ON dbo.RM20201.APTODCNM = dbo.SOP30200.SOPNUMBE AND dbo.RM20201.APTODCTY = 1 AND dbo.SOP30200.SOPTYPE = 3 AND  
                        dbo.RM20201.CUSTNMBR = dbo.SOP30200.CUSTNMBR 
  WHERE      dbo.RM20201.CUSTNMBR>=@CUSTNMBR_FROM AND dbo.RM20201.CUSTNMBR<= @CUSTNMBR_TO AND 
    dbo.RM20201.GLPOSTDT>=@APPLY_DATE_FROM AND dbo.RM20201.GLPOSTDT<=@APPLY_DATE_TO AND 
    dbo.SOP30200.DOCID>=@DOCID_FROM AND dbo.SOP30200.DOCID<=@DOCID_TO AND ABS(dbo.RM20201.RLGANLOS)>=@MINDOCAMNT AND ABS(dbo.RM20201.RLGANLOS)>=0 
  UNION   
  SELECT     dbo.RM30201.APTODCNM, dbo.RM30201.APTODCTY, dbo.RM30201.APTODCDT, dbo.RM30201.APFRDCNM, dbo.RM30201.APFRDCTY, dbo.RM30201.APFRDCDT, dbo.RM30201.CUSTNMBR,  
                        dbo.RM30201.DATE1, dbo.RM30201.RLGANLOS, dbo.SOP30200.DOCID, dbo.SOP30200.TAXSCHID 
  FROM         dbo.RM30201 INNER JOIN 
                        dbo.SOP30200 ON dbo.RM30201.APTODCNM = dbo.SOP30200.SOPNUMBE AND dbo.RM30201.APTODCTY = 1 AND dbo.SOP30200.SOPTYPE = 3 AND  
                        dbo.RM30201.CUSTNMBR = dbo.SOP30200.CUSTNMBR 
  WHERE      dbo.RM30201.CUSTNMBR>=@CUSTNMBR_FROM AND dbo.RM30201.CUSTNMBR<= @CUSTNMBR_TO AND 
    dbo.RM30201.GLPOSTDT>=@APPLY_DATE_FROM AND dbo.RM30201.GLPOSTDT<=@APPLY_DATE_TO AND 
    dbo.SOP30200.DOCID>=@DOCID_FROM AND dbo.SOP30200.DOCID<=@DOCID_TO AND ABS(dbo.RM30201.RLGANLOS)>=@MINDOCAMNT AND ABS(dbo.RM30201.RLGANLOS)>=0 
  ) RM_APPLY_FILTER 
 WHERE  
 RM_APPLY_FILTER.CUSTNMBR IN (SELECT CUSTNMBR FROM AWDC10000) AND  
 NOT EXISTS (SELECT APTODCNM, APTODCTY, APFRDCNM, APFRDCTY FROM AWDC30000  
 WHERE APTODCNM = RM_APPLY_FILTER.APTODCNM AND APTODCTY = RM_APPLY_FILTER.APTODCTY   
 AND APFRDCNM = RM_APPLY_FILTER.APFRDCNM AND APFRDCTY = RM_APPLY_FILTER.APFRDCTY)  
END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[MCP_DC_Fill_Table_AWDC_Applied_Documents_Proc] TO [DYNGRP] 
GO 

/*End_MCP_DC_Fill_Table_AWDC_Applied_Documents_Proc*/
/*Begin_MCPCleanupFilesBeforeLogin*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MCPCleanupFilesBeforeLogin]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MCPCleanupFilesBeforeLogin]
GO

 create  procedure dbo.MCPCleanupFilesBeforeLogin 
  @I_iSQLSessionID int  = NULL, @I_cUserID char(15) = NULL, @I_cCompanyName char(64) = NULL, 
  @I_tCleanupEmailStmtStatusReport tinyint = NULL,  @I_tProcessed tinyint output,
  @O_sRecovered smallint = NULL output, @O_tReceivingBatchRecovered tinyint  = NULL output, 
  @O_tICReceivingBatchRecovered tinyint  = NULL output, 
  @O_tPMTrxRecovered tinyint  = NULL output, @O_tRMTrxRecovered tinyint  = NULL output, 
  @O_tSOPTrxRecovered tinyint  = NULL output, @O_iErrorState int  = NULL output 
 as 
 declare @cBatchNumber char(15), @cBatchSource char(15), @sBatchStatus smallint, @sTempStatus smallint, 
  @cBatchActivityKey char(50), @tTransaction tinyint, @tLoop tinyint, @iError int, @iStatus int,  
  @cTransactionSource varchar(255), @cXXPM_Payment varchar(255), @cnfMCP_Payment varchar(255),@cPM_Payment varchar(255), 
  @cRM_Cash varchar(255),@cXRM_Cash varchar(255), @cnfMCP_Cash varchar(255),   
  @iSQLSessionID int, @TRUE tinyint, @FALSE tinyint, @TRACKING_ERROR smallint,  
  @POSTED smallint, @BATCH_RECOVERED smallint, @REALTIME_RECOVERED smallint, @BATCH_AVAILABLE smallint, 
  @BATCH_POSTING smallint, @BATCH_PRINTING smallint, @BATCH_UPDATING smallint, @BATCH_RECEIVING smallint, 
  @BATCH_POSTING_INCOMPLETE smallint, @BATCH_PRINTING_INCOMPLETE smallint, @BATCH_UPDATING_INCOMPLETE smallint, 
  @CHECK_PROCESSING smallint,  @CHECK_ALIGNMENT smallint,  @CHECK_PRINTING smallint,  @CHECK_REPRINT_ALIGNMENT smallint,  
  @CHECK_VOIDING smallint,  @CHECK_REPRINTING smallint,  @REMITTANCE_PROCESSING smallint,  @REMITTANCE_ALIGNMENT smallint, 
  @REMITTANCE_PRINTING smallint,  @CHECK_PROCESSING_INTERRUPTED smallint,  @CHECK_ALIGNMENT_INTERRUPTED smallint, 
  @CHECK_PRINTING_INTERRUPTED smallint,  @CHK_REPRINT_ALIGNMENT_INTERR smallint,  @CHECK_VOIDING_INTERRUPTED smallint, 
  @CHECK_REPRINTING_INTERRUPTED smallint,  @REMITTANCE_PROCESSING_INTERR smallint,  @REMITTANCE_ALIGNMENT_INTERR smallint, 
  @REMITTANCE_PRINTING_INTERR smallint,  @PURCHASING smallint,  @SALES smallint, @sSeries smallint, @sPurchasing smallint, 
  @sWinType smallint,  @sCompanyID smallint,  @tPosting    tinyint,  @cUserID char(15), @iRowCount integer,@ctemptableName char(240) 
 select  @O_sRecovered = 0, @O_iErrorState = 0, @tTransaction = 0, @O_tPMTrxRecovered = 0, 
  @O_tRMTrxRecovered = 0, @sCompanyID = (select  CMPANYID  from  DYNAMICS..SY01500  where  CMPNYNAM = @I_cCompanyName) 
 if @I_iSQLSessionID is NULL or @I_cUserID is NULL or @I_cCompanyName is NULL  
 begin   
   select @O_iErrorState = 20648  
   return  
 end  
 select @tLoop = 0 
 while (@tLoop = 0) 
 begin  
   select @tLoop = 1 
   SET @cnfMCP_Payment='nfMCP_Payment' 
   SET @cnfMCP_Payment=ltrim(rtrim(@cnfMCP_Payment)) 
   SET @cnfMCP_Cash = 'nfMCP_Cash' 
   SET @cnfMCP_Cash=ltrim(rtrim(@cnfMCP_Cash)) 
   exec @iStatus = DYNAMICS..smGetConstantString 'XXPM_PAYMENT_STR', @cXXPM_Payment output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0  break  
   exec @iStatus = DYNAMICS..smGetConstantString 'PM_PAYMENT_STR', @cPM_Payment output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0   break 
 end  
 if @iStatus = 0 and @iError <> 0  select @iStatus = @iError 
 if @iStatus <> 0 or @O_iErrorState <> 0  return(@iStatus) 
 select @cUserID=ltrim(rtrim(@I_cUserID)) 
 if @I_tCleanupEmailStmtStatusReport =  1 
 begin 
 exec ('insert into DYNAMICS.dbo.MCP00800  select WINTYPE,USERID,CMPNYNAM,BCHSOURC,BACHNUMB,POSTING,TRXSOURC from DYNAMICS.dbo.SY00800 where 
  USERID = ''' + @I_cUserID + ''' and CMPNYNAM = ''' + @I_cCompanyName + ''' and BCHSOURC in (''' + @cnfMCP_Payment + ''',''' + @cnfMCP_Cash + ''') ') 
 return  
 end 
 select @tLoop = 0 
 while (@tLoop = 0) 
 begin 
   select  @TRUE = 1, @FALSE = 0,  @tLoop = 1 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_AVAILABLE', @BATCH_AVAILABLE output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0     break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'TRACKING_ERROR', @TRACKING_ERROR output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0    break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_POSTING', @BATCH_POSTING output,@O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0  break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_PRINTING', @BATCH_PRINTING output,  @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_UPDATING', @BATCH_UPDATING output,  @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_RECEIVING', @BATCH_RECEIVING output,  @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_POSTING_INCOMPLETE', @BATCH_POSTING_INCOMPLETE output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_PRINTING_INCOMPLETE', @BATCH_PRINTING_INCOMPLETE output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_UPDATING_INCOMPLETE', @BATCH_UPDATING_INCOMPLETE output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'POSTED', @POSTED output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0   break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'BATCH_RECOVERED', @BATCH_RECOVERED output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break  
   exec @iStatus = DYNAMICS..smGetConstantInt  'REALTIME_RECOVERED',  @REALTIME_RECOVERED output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break  
   exec @iStatus = DYNAMICS..smGetConstantInt  'CHECK_PROCESSING', @CHECK_PROCESSING output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break  
   exec @iStatus = DYNAMICS..smGetConstantInt  'CHECK_ALIGNMENT', @CHECK_ALIGNMENT output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break  
   exec @iStatus = DYNAMICS..smGetConstantInt  'CHECK_PRINTING', @CHECK_PRINTING output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break  
   exec @iStatus = DYNAMICS..smGetConstantInt  'CHECK_REPRINT_ALIGNMENT', @CHECK_REPRINT_ALIGNMENT output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break  
   exec @iStatus = DYNAMICS..smGetConstantInt  'CHECK_VOIDING', @CHECK_VOIDING output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt  'CHECK_REPRINTING', @CHECK_REPRINTING output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break  
   exec @iStatus = DYNAMICS..smGetConstantInt 'REMITTANCE_PROCESSING', @REMITTANCE_PROCESSING output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break  
   exec @iStatus = DYNAMICS..smGetConstantInt 'REMITTANCE_ALIGNMENT', @REMITTANCE_ALIGNMENT output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'REMITTANCE_PRINTING', @REMITTANCE_PRINTING output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'CHECK_PROCESSING_INTERRUPTED', @CHECK_PROCESSING_INTERRUPTED output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'CHECK_ALIGNMENT_INTERRUPTED', @CHECK_ALIGNMENT_INTERRUPTED output,  @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'CHECK_PRINTING_INTERRUPTED', @CHECK_PRINTING_INTERRUPTED output, @O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'CHECK_REPRINT_ALIGNMENT_INTERRUPTED', @CHK_REPRINT_ALIGNMENT_INTERR output,@O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'CHECK_VOIDING_INTERRUPTED', @CHECK_VOIDING_INTERRUPTED output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'CHECK_REPRINTING_INTERRUPTED', @CHECK_REPRINTING_INTERRUPTED output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'REMITTANCE_PROCESSING_INTERRUPTED', @REMITTANCE_PROCESSING_INTERR output,@O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'REMITTANCE_ALIGNMENT_INTERRUPTED',@REMITTANCE_ALIGNMENT_INTERR output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'REMITTANCE_PRINTING_INTERRUPTED',@REMITTANCE_PRINTING_INTERR output, @O_iErrorState output  
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0  break  
   exec @iStatus = DYNAMICS..smGetConstantInt 'PURCHASING', @PURCHASING output, @O_iErrorState output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
   exec @iStatus = DYNAMICS..smGetConstantInt 'SALES', @SALES output,@O_iErrorState  output 
   select @iError = @@error 
   if @iStatus <> 0 or @iError <> 0 or @O_iErrorState <> 0 break 
 end  
 if @iStatus = 0 and @iError <> 0  select @iStatus = @iError 
 if @iStatus <> 0 or @O_iErrorState <> 0 return(@iStatus) 
 exec('declare Batch_Activity_Cursor insensitive cursor for 
  select  WINTYPE, BACHNUMB,  BCHSOURC, POSTING from DYNAMICS.dbo.MCP00800 where  
  USERID = ''' + @I_cUserID + ''' and CMPNYNAM = ''' + @I_cCompanyName + ''' and BCHSOURC in (''' + @cnfMCP_Payment + ''',''' + @cnfMCP_Cash + ''',''' + @cXXPM_Payment + ''',''' + @cPM_Payment + ''') ') 
 open Batch_Activity_Cursor 
 fetch next from  Batch_Activity_Cursor into @sWinType, @cBatchNumber,  @cBatchSource, @tPosting 
 while @@fetch_status = 0 
 begin  
   select @tLoop = NULL  
   if @@trancount = 0  
   begin  
    select @tTransaction = 1 
    begin transaction  
   end 
   if @cBatchSource in (@cRM_Cash,@cnfMCP_Cash) 
    select @cUserID  =  @I_cUserID  
   else 
    select @cUserID = '' 
   while (@tLoop is NULL) 
   begin 
    select @tLoop = 1 
    if  @cBatchSource in (@cPM_Payment,@cnfMCP_Payment) 
    begin 
     select @sSeries = @PURCHASING  
     if @cBatchSource = @cnfMCP_Payment 
     begin  
      exec @iStatus = DYNAMICS..smGetConstantString  'TRX_SOURCE_PM_MANUAL', @cTransactionSource output, @O_iErrorState output 
      select @iError = @@error 
     end 
     else if @cBatchSource = @cPM_Payment      
     begin 
      exec @iStatus = DYNAMICS..smGetConstantString  'TRX_SOURCE_PM_MANUAL', @cTransactionSource output, @O_iErrorState output 
      select @iError = @@error 
     end 
    end 
    else if @cBatchSource in (@cRM_Cash,@cnfMCP_Cash) 
    begin  
     select @sSeries = @SALES 
     if @cBatchSource = @cRM_Cash 
     begin 
      exec @iStatus = DYNAMICS..smGetConstantString  'TRX_SOURCE_RM_CASH_ENTRY', @cTransactionSource output, @O_iErrorState output 
      select @iError = @@error 
     end 
     else if @cBatchSource = @cnfMCP_Cash 
     begin 
      exec @iStatus = DYNAMICS..smGetConstantString  'TRX_SOURCE_RM_CASH_ENTRY', @cTransactionSource output, @O_iErrorState output 
      select @iError = @@error 
     end 
    end 
    if @iStatus <> 0 or @O_iErrorState <> 0 or @iError <> 0  break 
    select  @sBatchStatus = BCHSTTUS from SY00500 where BCHSOURC = @cBatchSource and BACHNUMB = @cBatchNumber 
    select @iRowCount = @@rowcount  
    if @iRowCount = 1 
    begin  
     if @tPosting = @TRUE 
     begin 
      if @cBatchSource in (@cRM_Cash,@cnfMCP_Cash,@cnfMCP_Payment) 
      begin 
       if @sBatchStatus = 0 or @sBatchStatus = @BATCH_POSTING_INCOMPLETE 
       begin 
        exec @iStatus = smAddPostingSecurityRecord 
        @sSeries, 
        @cTransactionSource, 
        @cBatchNumber, 
        @I_cUserID, 
        @I_cCompanyName, 
        @FALSE, 
        1, 
        @I_iSQLSessionID, 
        @O_iErrorState  output 
        select @iError = @@error 
        if @iStatus <> 0 or @O_iErrorState <> 0 or @iError <> 0  break 
       end 
      end 
     end 
     if (@cBatchSource = @cnfMCP_Payment) or (@cBatchSource = @cnfMCP_Cash)  or (@cBatchSource = @cXXPM_Payment) 
     or (@cBatchSource = @cPM_Payment) or (@cBatchSource = @cRM_Cash) or (@cBatchSource = @cXRM_Cash) 
     begin 
      if @tPosting = @TRUE 
      begin 
       update  SY00500 
       set BCHSTTUS = (case @sBatchStatus 
       when @CHECK_PROCESSING then 
       @CHECK_PROCESSING_INTERRUPTED 
       when @CHECK_ALIGNMENT then 
       @CHECK_ALIGNMENT_INTERRUPTED 
       when @CHECK_PRINTING then 
       @CHECK_PRINTING_INTERRUPTED 
       when @CHECK_REPRINT_ALIGNMENT then 
       @CHK_REPRINT_ALIGNMENT_INTERR 
       when @CHECK_VOIDING then 
       @CHECK_VOIDING_INTERRUPTED 
       when @CHECK_REPRINTING then 
       @CHECK_REPRINTING_INTERRUPTED 
       when @REMITTANCE_PROCESSING then 
       @REMITTANCE_PROCESSING_INTERR 
       when @REMITTANCE_ALIGNMENT then 
       @REMITTANCE_ALIGNMENT_INTERR 
       when @REMITTANCE_PRINTING then 
       @REMITTANCE_PRINTING_INTERR 
       when @BATCH_POSTING then 
       @BATCH_POSTING_INCOMPLETE 
       when @BATCH_PRINTING then 
       @BATCH_PRINTING_INCOMPLETE 
       when @BATCH_UPDATING then 
       @BATCH_UPDATING_INCOMPLETE 
       when @BATCH_RECEIVING then 
       @BATCH_AVAILABLE 
       else 
       @BATCH_POSTING_INCOMPLETE 
       end), MKDTOPST = @FALSE, 
       USERID = @cUserID where 
       BCHSOURC = @cBatchSource and BACHNUMB = @cBatchNumber 
       if @@rowcount <> 1 
       begin 
        select @O_iErrorState = 20650  break 
       end  
       if (@cBatchSource = @cXXPM_Payment) 
       select @O_tPMTrxRecovered = 1 
       if (@cBatchSource = @cXRM_Cash) 
       select @O_tRMTrxRecovered = 1 
      if (@cBatchSource <> @cXRM_Cash) and (@cBatchSource <> @cXXPM_Payment) 
       select @O_sRecovered = @BATCH_RECOVERED 
       if (@cBatchSource <> @cXRM_Cash) and (@cBatchSource <> @cXXPM_Payment) 
       begin 
        exec @iStatus = smAddPostingSecurityRecord 
        @sSeries, 
        @cTransactionSource, 
        @cBatchNumber, 
        @I_cUserID, 
        @I_cCompanyName, 
        @FALSE, 
        @TRACKING_ERROR, 
        @I_iSQLSessionID, 
        @O_iErrorState  output 
        select @iError = @@error 
        if @iStatus <> 0 or @O_iErrorState <> 0 or @iError <> 0 break 
       end 
      end 
      else  
      begin  
       update  SY00500 
       set BCHSTTUS = (case @sBatchStatus 
       when @CHECK_PROCESSING then 
       @CHECK_PROCESSING_INTERRUPTED 
       when @CHECK_ALIGNMENT then 
       @CHECK_ALIGNMENT_INTERRUPTED 
       when @CHECK_PRINTING then 
       @CHECK_PRINTING_INTERRUPTED 
       when @CHECK_REPRINT_ALIGNMENT then 
       @CHK_REPRINT_ALIGNMENT_INTERR 
       when @CHECK_VOIDING then 
       @CHECK_VOIDING_INTERRUPTED 
       when @CHECK_REPRINTING then 
       @CHECK_REPRINTING_INTERRUPTED 
       when @REMITTANCE_PROCESSING then 
       @REMITTANCE_PROCESSING_INTERR  
       when @REMITTANCE_ALIGNMENT then 
       @REMITTANCE_ALIGNMENT_INTERR 
       when @REMITTANCE_PRINTING then 
       @REMITTANCE_PRINTING_INTERR 
       when @BATCH_POSTING then 
       @BATCH_POSTING_INCOMPLETE 
       when @BATCH_PRINTING then 
       @BATCH_PRINTING_INCOMPLETE 
       when @BATCH_UPDATING then 
       @BATCH_UPDATING_INCOMPLETE 
       else 
       @BATCH_AVAILABLE 
       end), MKDTOPST = @FALSE, 
       USERID = @cUserID where 
       BCHSOURC = @cBatchSource and BACHNUMB = @cBatchNumber 
       if @@rowcount <> 1 
       begin 
        select @O_iErrorState = 20650  break 
       end 
       if @sBatchStatus = @CHECK_PROCESSING or @sBatchStatus = @CHECK_ALIGNMENT or @sBatchStatus = @CHECK_PRINTING or  
       @sBatchStatus = @CHECK_REPRINT_ALIGNMENT or @sBatchStatus = @CHECK_VOIDING or @sBatchStatus = @CHECK_REPRINTING or 
       @sBatchStatus = @REMITTANCE_PROCESSING or @sBatchStatus = @REMITTANCE_ALIGNMENT or @sBatchStatus = @REMITTANCE_PRINTING 
       begin  
        select @O_sRecovered = @BATCH_RECOVERED  
       end 
      end  
     end  
    end  
    exec('delete DYNAMICS.dbo.MCP00800  where USERID = '''+@I_cUserID+''' and CMPNYNAM = '''+@I_cCompanyName +'''and 
    BACHNUMB  = '''+@cBatchNumber+''' and BCHSOURC = '''+@cBatchSource+''' and WINTYPE  ='+ @sWinType+' ')  
    if @@rowcount <> 1 
    begin  
     select @O_iErrorState = 20651  break 
    end 
   end  
   if @iStatus = 0 and @iError <> 0 
   select @iStatus = @iError 
   if @tTransaction = 1  
   begin  
    select  @tTransaction = 0 
    if (@O_iErrorState <> 0) or (@iStatus <> 0) 
    begin  
     rollback transaction  break  
    end  
    else  
    begin  
     commit transaction 
    end 
   end  
   else if (@O_iErrorState <> 0) or (@iStatus <> 0) 
   return(@iStatus) 
   fetch next from  Batch_Activity_Cursor into @sWinType, @cBatchNumber, @cBatchSource,@tPosting 
 end  
 close Batch_Activity_Cursor  
 deallocate Batch_Activity_Cursor 
 if @O_iErrorState <> 0 or @iStatus <> 0  
  return(@iStatus) 
 update PM00400 set DCSTATUS = -1 from PM00400 join PM10000 on CNTRLNUM = VCHNUMWK where  
  PM00400.BCHSOURC = @cnfMCP_Payment and PM00400.DCSTATUS = 0 and PM00400.USERID = @I_cUserID and PM00400.CNTRLTYP = 0 
 if @@Rowcount > 0 
  select @O_tPMTrxRecovered = 1  
 delete PM00400 where (BCHSOURC = @cnfMCP_Payment) and 
  DCSTATUS = 0 and USERID = @I_cUserID and CNTRLTYP = 0 and CNTRLNUM not in (select CCAMPYNM 
  from PM10000 where CCAMPYNM = CNTRLNUM and CARDNAME in (select  CARDNAME  from SY03100  
  where PYBLGRBX = 0 and CBPAYBLE = 1))  
 delete PM00400 where (BCHSOURC = @cnfMCP_Payment) and DCSTATUS = 0 and 
  USERID = @I_cUserID and CNTRLTYP = 1 and CNTRLNUM not in  (select  CAMPYNBR  from PM10000 
  where CNTRLNUM = CAMPYNBR) and  CNTRLNUM not in  (select  CAMPMTNM  from PM10000 where  
  CNTRLNUM = CAMPMTNM) and  CNTRLNUM not in  (select  CCAMPYNM from PM10000 where CNTRLNUM = CCAMPYNM  and 
  CARDNAME in (select  CARDNAME  from SY03100 where PYBLGRBX = 1 and CBPAYBLE = 1)) 
 return  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[MCPCleanupFilesBeforeLogin] TO [DYNGRP] 
GO 

/*End_MCPCleanupFilesBeforeLogin*/
/*Begin_mcpCLExpensesBatchTrx*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLExpensesBatchTrx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLExpensesBatchTrx]
GO




CREATE PROCEDURE mcpCLExpensesBatchTrx 
 @USERID CHAR(15),
 @O_SQL_Error_State int = NULL  output
AS

BEGIN
    

 
  
INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)
SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',BACHNUMB,6,0 
FROM nfMCP_PM10000 
WHERE BACHNUMB NOT IN (SELECT BACHNUMB FROM SY00500 WHERE BCHSOURC = 'nfMCP_Payment')

   
if not exists (select * from nfMCP_PM10000 A,PM10200 B where  A.NUMBERIE=B.APFRDCNM and B. APPLDAMT>B.ORAPPAMT)
begin

INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'Batch_Headers [SY00500]',A.BACHNUMB,7,1  FROM SY00500 A WHERE A.BCHSOURC = 'nfMCP_Payment' AND A.BACHNUMB 
IN(SELECT BACHNUMB FROM nfMCP_PM10000 group by BACHNUMB)
Group by A.BACHNUMB HAVING Sum(A.BCHTOTAL) NOT IN 
(SELECT SUM(DOCAMNT) FROM nfMCP_PM10000 
WHERE BACHNUMB = A.BACHNUMB)
	 

UPDATE SY00500 set BCHTOTAL = (SELECT SUM(DOCAMNT) FROM nfMCP_PM10000 
WHERE nfMCP_PM10000.BACHNUMB = SY00500.BACHNUMB )
WHERE BACHNUMB IN (SELECT A.BACHNUMB FROM SY00500 A 
WHERE A.BCHSOURC = 'nfMCP_Payment' AND A.BACHNUMB IN(SELECT BACHNUMB FROM nfMCP_PM10000 group by BACHNUMB)
GROUP BY A.BACHNUMB HAVING Sum(A.BCHTOTAL) NOT IN 
(SELECT SUM(DOCAMNT) FROM nfMCP_PM10000 WHERE BACHNUMB = A.BACHNUMB))

end   
 
INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'Batch_Headers [SY00500]',A.BACHNUMB,5,1 
FROM SY00500 A WHERE A.BCHSOURC = 'nfMCP_Payment' AND A.BACHNUMB IN (
SELECT BACHNUMB FROM nfMCP_PM10000 group by BACHNUMB)
AND A.NUMOFTRX NOT IN (SELECT Count(NUMBERIE) FROM nfMCP_PM10000 
WHERE BACHNUMB = A.BACHNUMB) Group by A.BACHNUMB 
 
UPDATE SY00500 set NUMOFTRX = (
SELECT Count(NUMBERIE) FROM nfMCP_PM10000 WHERE 
nfMCP_PM10000.BACHNUMB = SY00500.BACHNUMB ) 
WHERE BACHNUMB IN (SELECT A.BACHNUMB FROM 
SY00500 A WHERE A.BCHSOURC = 'nfMCP_Payment' AND A.BACHNUMB IN(SELECT BACHNUMB FROM nfMCP_PM10000 group by BACHNUMB)
AND A.NUMOFTRX NOT IN (SELECT Count(NUMBERIE) FROM nfMCP_PM10000 
WHERE BACHNUMB = A.BACHNUMB) Group by A.BACHNUMB)
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLExpensesBatchTrx] TO [DYNGRP] 
GO 

/*End_mcpCLExpensesBatchTrx*/
/*Begin_mcpCLExpensesRetentionOpenTrx*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLExpensesRetentionOpenTrx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLExpensesRetentionOpenTrx]
GO

CREATE  PROCEDURE mcpCLExpensesRetentionOpenTrx
 @USERID CHAR(15),
 @O_SQL_Error_State int = NULL  output
AS

BEGIN
 
if not exists(select * from PM30300 A,nfMCP_PM20000 B where A.APFRDCNM=B.DOCNUMBR  and A.APPLDAMT>A.ORAPPAMT)
BEGIN

INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_OPEN [nfMCP_PM20000]',A.NUMBERIE,3,1 FROM nfMCP_PM20000 A
WHERE A.NUMBERIE IN(SELECT APFRDCNM FROM PM30300 GROUP by APFRDCNM)  
 GROUP by A.NUMBERIE 
HAVING Sum(A.APPLDAMT) NOT IN (SELECT SUM(APPLDAMT) FROM PM30300 WHERE APFRDCNM = A.NUMBERIE AND APPLDAMT <= 		 ORAPPAMT  )
		
		
UPDATE nfMCP_PM20000 set APPLDAMT = (SELECT SUM(APPLDAMT) FROM PM30300 WHERE PM30300.APFRDCNM = 		 nfMCP_PM20000.NUMBERIE )
,DOCAMNT = CURTRXAM + (SELECT SUM(APPLDAMT) FROM PM30300 WHERE PM30300.APFRDCNM = nfMCP_PM20000.NUMBERIE ) 
WHERE NUMBERIE IN(SELECT A.NUMBERIE FROM nfMCP_PM20000 A
WHERE A.NUMBERIE IN(SELECT APFRDCNM FROM PM30300 GROUP by APFRDCNM) 
GROUP by A.NUMBERIE HAVING Sum(A.APPLDAMT) NOT IN (SELECT SUM(APPLDAMT) FROM PM30300 WHERE APFRDCNM = A.NUMBERIE AND APPLDAMT <= ORAPPAMT))

END

INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_OPEN [nfMCP_PM20000]',A.NUMBERIE,1,0 FROM nfMCP_PM20000 A
WHERE A.NUMBERIE IN(SELECT APFRDCNM FROM PM30300 GROUP by APFRDCNM)  
GROUP by A.NUMBERIE 
HAVING Sum(A.APPLDAMT) NOT IN (SELECT SUM(APPLDAMT) FROM PM30300 
WHERE APFRDCNM = A.NUMBERIE AND APPLDAMT > ORAPPAMT  )

       
 
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_OPEN [nfMCP_PM20000]',A.NUMBERIE,22,0 FROM nfMCP_PM20000 A 
WHERE A.CURNCYID = (SELECT FUNLCURR FROM MC40000) AND A.NUMBERIE IN 
(SELECT APFRDCNM  FROM nfRET_GL10020 GROUP by APFRDCNM)
GROUP by A.NUMBERIE  HAVING Sum(A.nfRET_Importe_Retencion) 
NOT IN (SELECT SUM(nfRET_Importe_Retencion) FROM nfRET_GL10020 WHERE APFRDCNM = A.NUMBERIE)

       
if not exists(select * from PM30300 A,nfMCP_PM20000 B where A.APFRDCNM=B.DOCNUMBR  and A.APPLDAMT>A.ORAPPAMT)
BEGIN

INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_OPEN [nfMCP_PM20000]',A.NUMBERIE,26,0  FROM nfMCP_PM20000 A 
WHERE A.CURNCYID = (SELECT FUNLCURR FROM MC40000) AND 
A.NUMBERIE IN (SELECT nfMCP_PM20000.NUMBERIE FROM nfMCP_PM20000
INNER JOIN nfRET_GL10020 ON nfMCP_PM20000.NUMBERIE = nfRET_GL10020.APFRDCNM 
INNER JOIN  nfMCP_PM20100 ON nfMCP_PM20000.NUMBERIE = nfMCP_PM20100.NUMBERIE 
GROUP BY nfMCP_PM20000.NUMBERIE)
GROUP BY A.NUMBERIE HAVING sum(A.APPLDAMT)- Sum(A.nfRET_Importe_Retencion) 
NOT IN(SELECT sum(LINEAMNT)
FROM nfMCP_PM20100 WHERE NUMBERIE = A.NUMBERIE)

END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLExpensesRetentionOpenTrx] TO [DYNGRP] 
GO 

/*End_mcpCLExpensesRetentionOpenTrx*/
/*Begin_mcpCLExpensesOpenTrx*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLExpensesOpenTrx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLExpensesOpenTrx]
GO


CREATE   PROCEDURE mcpCLExpensesOpenTrx 
 @USERID CHAR(15), 
 @O_SQL_Error_State int = NULL  output 
AS 
 
BEGIN 
   
   
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'PM_Transaction_OPEN [PM20000]',DOCNUMBR,17,1 FROM PM20000  
WHERE DOCNUMBR IN (SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE  
NOT IN (SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM PM20000 WHERE DOCNUMBR IN   
(SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN  
(SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PM_Distribution_WORK_OPEN [nfMCP_PM10101]',VCHRNMBR,17,1 FROM nfMCP_PM10101 
WHERE VCHRNMBR IN (SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE  
NOT IN (SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM nfMCP_PM10101 WHERE VCHRNMBR IN  
(SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE  
NOT IN (SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'PM_Distribution_WORK_OPEN [PM10100]',VCHRNMBR,17,1 FROM PM10100  
WHERE VCHRNMBR IN (SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE  
NOT IN (SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM PM10100 WHERE VCHRNMBR IN  
(SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN  
(SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'PM_Reprint_Distribution [PM80600]',VCHRNMBR,17,1 FROM PM80600  
WHERE VCHRNMBR IN (SELECT NUMBERIE FROM nfMCP_PM20000  
WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM PM80600 WHERE VCHRNMBR IN  
(SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN  
(SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'nfMCP_PAYMENT_LINE_OPEN [nfMCP_PM20100]',NUMBERIE,17,1 FROM nfMCP_PM20100 
WHERE NUMBERIE IN (SELECT NUMBERIE FROM nfMCP_PM20000  
WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM nfMCP_PM20100  
WHERE NUMBERIE IN (SELECT NUMBERIE FROM nfMCP_PM20000 WHERE  
NUMBERIE NOT IN (SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'GL_TRX_LINE_WORK [GL10001]',ORDOCNUM,17,1   
FROM GL10001 WHERE ORDOCNUM IN ( 
SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE  
NOT IN (SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM GL10001 WHERE ORDOCNUM IN  
(SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN 
(SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'PM_Apply_To_HIST [PM30300]',APFRDCNM,17,1  FROM PM30300  
WHERE APFRDCNM IN (SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN  
(SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM PM30300 WHERE APFRDCNM IN  
(SELECT NUMBERIE FROM nfMCP_PM20000  
WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'PM_Apply_To_OPEN_OPEN [PM20100]',APFRDCNM,17,1  FROM PM20100  
WHERE APFRDCNM IN (SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN  
(SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM PM20100 WHERE APFRDCNM IN  
(SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN  
(SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'PM_Paid_Transaction_HIST [PM30200]',VCHRNMBR,17,1  FROM PM30200  
WHERE VCHRNMBR IN (SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN  
(SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM PM30200 WHERE VCHRNMBR IN  
(SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE  
NOT IN (SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'nfRET_CARTERA_WORK [nfRET_GL10020]',DOCNUMBR,17,1  FROM nfRET_GL10020  
WHERE DOCNUMBR IN (SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE NOT IN  
(SELECT DOCNUMBR FROM PM00400)) 
  
DELETE FROM nfRET_GL10020 WHERE DOCNUMBR IN  
(SELECT NUMBERIE FROM nfMCP_PM20000 WHERE NUMBERIE  
NOT IN (SELECT DOCNUMBR FROM PM00400)) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_OPEN [nfMCP_PM20000]',NUMBERIE,17,1 FROM nfMCP_PM20000  
WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM PM00400) 
  
DELETE FROM nfMCP_PM20000  
WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM PM00400) 

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'nfMCP_PM_Distribution_WORK_OPEN [nfMCP_PM10101]',A.VCHRNMBR,10,0  
FROM nfMCP_PM10101 A WHERE A.VCHRNMBR IN (SELECT nfMCP_PM20000.NUMBERIE 
FROM nfMCP_PM20000 INNER JOIN nfMCP_PM10101 ON  
nfMCP_PM20000.NUMBERIE = nfMCP_PM10101.VCHRNMBR  
GROUP BY nfMCP_PM20000.NUMBERIE)GROUP by A.VCHRNMBR  
HAVING Sum(A.CRDTAMNT) NOT IN  
(SELECT Sum(DEBITAMT) FROM nfMCP_PM10101 WHERE VCHRNMBR =A.VCHRNMBR) 

if not exists(select * from PM30300 A,nfMCP_PM20000 B where A.APFRDCNM=B.DOCNUMBR  and A.APPLDAMT>A.ORAPPAMT)
BEGIN

INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'nfMCP_PM_Distribution_WORK_OPEN [nfMCP_PM10101]',B.NUMBERIE,30,0 
FROM nfMCP_PM20000 B WHERE B.NUMBERIE IN(SELECT A.VCHRNMBR FROM nfMCP_PM10101 A 
WHERE A.VCHRNMBR IN(SELECT nfMCP_PM20000.NUMBERIE FROM  
nfMCP_PM20000 INNER JOIN nfMCP_PM10101 ON  
nfMCP_PM20000.NUMBERIE = nfMCP_PM10101.VCHRNMBR  
GROUP BY nfMCP_PM20000.NUMBERIE) 
GROUP by A.VCHRNMBR HAVING Sum(A.CRDTAMNT)IN  
(SELECT Sum(DEBITAMT) FROM nfMCP_PM10101 WHERE VCHRNMBR =A.VCHRNMBR) 
)GROUP by B.NUMBERIE  
HAVING sum(B.DOCAMNT)+ sum(B.DISTKNAM) NOT IN 
(SELECT Sum(CRDTAMNT) FROM nfMCP_PM10101 WHERE VCHRNMBR = B.NUMBERIE) 

END
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_OPEN [nfMCP_PM20000]',MCPTYPID,14,0 FROM nfMCP_PM20000  
WHERE MCPTYPID NOT IN (SELECT MCPTYPID FROM nfMCP00600)  

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_OPEN [nfMCP_PM20000]',VENDORID,28,0 FROM nfMCP_PM20000 
WHERE VENDORID <> '' AND  VENDORID NOT IN (SELECT VENDORID FROM PM00200)  

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_OPEN [nfMCP_PM20000]',MEDIOID,15,0 FROM nfMCP_PM20100  
WHERE MEDIOID <> '' AND  MEDIOID NOT IN (SELECT MEDIOID FROM nfMCP00700)  

  
  
INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
SELECT @USERID,'nfMCP_CARTERA_WORK [nfMCP10200]',nfMCP10200.EGRNUMB,19,1   
FROM   nfMCP10200 INNER JOIN PM00400  
ON nfMCP10200.EGRNUMB = PM00400.DOCNUMBR AND PM00400.BCHSOURC = 'nfMCP_Payment'  
AND PM00400.DCSTATUS = 3  
AND  nfMCP10200.EGRNUMB NOT IN (SELECT NUMBERIE FROM nfMCP_PM20000) 
  
UPDATE nfMCP10200 set EGRTYPE = '',EGRNUMB ='',CARTSTAT = 1,VENDORID = '' 
WHERE EGRNUMB IN(SELECT nfMCP10200.EGRNUMB  FROM   nfMCP10200 INNER JOIN PM00400  
ON nfMCP10200.EGRNUMB = PM00400.DOCNUMBR AND PM00400.BCHSOURC = 'nfMCP_Payment'  
AND PM00400.DCSTATUS = 3  
AND  nfMCP10200.EGRNUMB NOT IN (SELECT NUMBERIE FROM nfMCP_PM20000)) 

  
 exec mcpCLExpensesRetentionOpenTrx @USERID 
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLExpensesOpenTrx] TO [DYNGRP] 
GO 

/*End_mcpCLExpensesOpenTrx*/
/*Begin_mcpCLExpensesRetentionWorkTrx*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLExpensesRetentionWorkTrx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLExpensesRetentionWorkTrx]
GO


CREATE  PROCEDURE mcpCLExpensesRetentionWorkTrx  
 @USERID CHAR(15),
 @O_SQL_Error_State int = NULL  output
AS

BEGIN
 
if exists (select * from nfMCP_PM10000 A,PM10200 B where  A.NUMBERIE=B.APFRDCNM and B. APPLDAMT<=B.ORAPPAMT)
Begin	

INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',A.NUMBERIE,3,1 
FROM nfMCP_PM10000 A
WHERE A.NUMBERIE IN(SELECT APFRDCNM FROM PM10200 GROUP by APFRDCNM)  
GROUP by A.NUMBERIE 
HAVING Sum(A.APPLDAMT) NOT IN
(SELECT SUM(APPLDAMT) FROM PM10200 WHERE APFRDCNM = A.NUMBERIE
AND APPLDAMT <= ORAPPAMT  )
end

if  exists (select * from nfMCP_PM10000 A,PM10200 B where  A.NUMBERIE=B.APFRDCNM and B. APPLDAMT<=B.ORAPPAMT)
Begin	

UPDATE nfMCP_PM10000 SET APPLDAMT = (
SELECT SUM(APPLDAMT) FROM PM10200 WHERE PM10200.APFRDCNM = nfMCP_PM10000.NUMBERIE )
,DOCAMNT = CURTRXAM + (SELECT SUM(APPLDAMT) FROM PM10200 WHERE 
PM10200.APFRDCNM = nfMCP_PM10000.NUMBERIE ) WHERE NUMBERIE IN (
SELECT A.NUMBERIE FROM nfMCP_PM10000 A  WHERE A.NUMBERIE IN(
SELECT APFRDCNM FROM PM10200 GROUP by APFRDCNM)  
GROUP by A.NUMBERIE HAVING Sum(A.APPLDAMT) NOT IN (
SELECT SUM(APPLDAMT) FROM PM10200 WHERE APFRDCNM = A.NUMBERIE AND APPLDAMT <= ORAPPAMT))

end
 
if not exists (select * from nfMCP_PM10000 A,PM10200 B where  A.NUMBERIE=B.APFRDCNM and B. APPLDAMT<=B.ORAPPAMT)
Begin
	
INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',A.NUMBERIE,2,0 FROM nfMCP_PM10000 A
WHERE A.NUMBERIE IN(SELECT APFRDCNM FROM PM10200 GROUP by APFRDCNM)  
GROUP by A.NUMBERIE 
HAVING Sum(A.APPLDAMT) NOT IN (SELECT SUM(APPLDAMT) FROM PM10200 WHERE 
APFRDCNM = A.NUMBERIE AND APPLDAMT >= ORAPPAMT  )
end
 
if exists (select * from nfMCP_PM10000 A,PM10200 B where  A.NUMBERIE=B.APFRDCNM and B. APPLDAMT<=B.ORAPPAMT)
Begin

INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',A.NUMBERIE,23,0 FROM nfMCP_PM10000 A 
WHERE A.CURNCYID = (SELECT FUNLCURR FROM MC40000) AND A.NUMBERIE IN 
(SELECT APFRDCNM  FROM nfRET_GL70020 GROUP by APFRDCNM)
GROUP by A.NUMBERIE  HAVING Sum(A.nfRET_Importe_Retencion) 
NOT IN (SELECT SUM(nfRET_Importe_Retencion) FROM nfRET_GL70020 WHERE APFRDCNM = A.NUMBERIE)

      
 
INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',A.NUMBERIE,27,0  FROM nfMCP_PM10000 A 
WHERE A.CURNCYID = (SELECT FUNLCURR FROM MC40000) AND A.NUMBERIE IN 
(SELECT nfMCP_PM10000.NUMBERIE FROM nfMCP_PM10000 INNER JOIN nfRET_GL70020 ON
nfMCP_PM10000.NUMBERIE = nfRET_GL70020.APFRDCNM 
INNER JOIN  nfMCP_PM10100 ON nfMCP_PM10000.NUMBERIE = nfMCP_PM10100.NUMBERIE 
GROUP BY nfMCP_PM10000.NUMBERIE)
GROUP BY A.NUMBERIE HAVING (sum(A.APPLDAMT)- Sum(A.nfRET_Importe_Retencion))
NOT IN(SELECT sum(LINEAMNT)
FROM nfMCP_PM10100 WHERE NUMBERIE = A.NUMBERIE)

      
 
 
INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',A.VCHRNMBR,11,0 
FROM PM10100 A WHERE A.VCHRNMBR IN (SELECT  nfMCP_PM10000.NUMBERIE FROM 
nfMCP_PM10000 INNER JOIN PM10100 ON nfMCP_PM10000.NUMBERIE = PM10100.VCHRNMBR 
INNER JOIN PM10200 ON nfMCP_PM10000.NUMBERIE = PM10200.APFRDCNM 
GROUP BY nfMCP_PM10000.NUMBERIE) GROUP by A.VCHRNMBR 
HAVING Sum(A.CRDTAMNT) NOT IN 
(SELECT Sum(DEBITAMT) FROM PM10100 WHERE VCHRNMBR =A.VCHRNMBR)

 
INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',B.NUMBERIE,13,0 FROM nfMCP_PM10000 B 
WHERE B.NUMBERIE IN(SELECT A.VCHRNMBR FROM PM10100 A WHERE A.VCHRNMBR IN 
(SELECT  nfMCP_PM10000.NUMBERIE FROM nfMCP_PM10000 INNER JOIN PM10100 ON 
nfMCP_PM10000.NUMBERIE = PM10100.VCHRNMBR INNER JOIN PM10200 ON 
nfMCP_PM10000.NUMBERIE = PM10200.APFRDCNM GROUP BY nfMCP_PM10000.NUMBERIE
)GROUP by A.VCHRNMBR HAVING Sum(A.CRDTAMNT)IN (SELECT Sum(DEBITAMT) 
FROM PM10100 WHERE VCHRNMBR =A.VCHRNMBR)
)GROUP by B.NUMBERIE HAVING sum(B.DOCAMNT)+ sum(B.DISTKNAM) NOT IN(
SELECT Sum(CRDTAMNT) FROM PM10100 WHERE VCHRNMBR = B.NUMBERIE)
end
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLExpensesRetentionWorkTrx] TO [DYNGRP] 
GO 

/*End_mcpCLExpensesRetentionWorkTrx*/
/*Begin_mcpCLExpensesWorkTrx*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLExpensesWorkTrx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLExpensesWorkTrx]
GO

CREATE  PROCEDURE mcpCLExpensesWorkTrx  
 @USERID CHAR(15),
 @O_SQL_Error_State int = NULL  output
AS

BEGIN
   

 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',NUMBERIE,17,1
 FROM nfMCP_PM10000 
 WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM PM00400)
 
 DELETE FROM nfMCP_PM10000 WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM PM00400)

 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)
 SELECT @USERID,'PM_Key_MSTR [PM00400]',DOCNUMBR,20,0 
 FROM PM00400 
 WHERE BCHSOURC = 'nfMCP_Payment' AND DCSTATUS = 1 AND DOCNUMBR NOT IN 
 (SELECT NUMBERIE FROM nfMCP_PM10000)

 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)
 SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',MCPTYPID,14,0 
 FROM nfMCP_PM10000 
 WHERE MCPTYPID NOT IN (SELECT MCPTYPID FROM nfMCP00600) 

 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)
 SELECT @USERID,'nfMCP_PAYMENT_HDR_WORK [nfMCP_PM10000]',VENDORID,28,0 
 FROM nfMCP_PM10000 
 WHERE VENDORID <> '' AND  VENDORID NOT IN (SELECT VENDORID FROM PM00200) 

 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'nfRET_CARTERA_WORK_Temp [nfRET_GL70020]',APFRDCNM,20,1 FROM nfRET_GL70020 WHERE APFRDCNM 
 NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000) 
 
 DELETE FROM nfRET_GL70020 WHERE APFRDCNM NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000)

 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'PM_Apply_To_WORK_OPEN [PM10200]',PM10200.APFRDCNM,20,1  
 FROM   PM10200 
 INNER JOIN PM00400 
 ON PM10200.APFRDCNM = PM00400.DOCNUMBR 
        AND PM00400.BCHSOURC = 'nfMCP_Payment' AND PM00400.DCSTATUS = 1 
        AND  PM10200.APFRDCNM NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000)
 
 DELETE FROM PM10200 WHERE APFRDCNM IN(SELECT PM10200.APFRDCNM FROM   PM10200 INNER JOIN
 PM00400 ON PM10200.APFRDCNM = PM00400.DOCNUMBR AND PM00400.BCHSOURC = 'nfMCP_Payment' 
 AND PM00400.DCSTATUS = 1 AND  PM10200.APFRDCNM NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000))

 
  
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)
 SELECT @USERID,'PM_Apply_To_OPEN_OPEN [PM20100]',PM20100.APFRDCNM,20,1  
 FROM   PM20100 
 INNER JOIN PM00400 ON PM20100.APFRDCNM = PM00400.DOCNUMBR 
 AND PM00400.BCHSOURC = 'nfMCP_Payment' AND PM00400.DCSTATUS = 1 AND
 PM20100.APFRDCNM NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000)
 
 DELETE FROM PM20100 
 WHERE APFRDCNM IN 
 (SELECT PM20100.APFRDCNM  FROM   PM20100
 INNER JOIN PM00400 ON PM20100.APFRDCNM = PM00400.DOCNUMBR AND 
 PM00400.BCHSOURC = 'nfMCP_Payment' AND PM00400.DCSTATUS = 1 AND
 PM20100.APFRDCNM NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000))

 
  
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'nfRET_CARTERA_WORK [nfRET_GL10020]',nfRET_GL10020.APFRDCNM,20,1  
 FROM   nfRET_GL10020 
 INNER JOIN PM00400 ON nfRET_GL10020.APFRDCNM = PM00400.DOCNUMBR AND PM00400.BCHSOURC = 'nfMCP_Payment' 
 AND PM00400.DCSTATUS = 1 AND  nfRET_GL10020.APFRDCNM NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000)
 
 DELETE FROM nfRET_GL10020 WHERE APFRDCNM IN (SELECT nfRET_GL10020.APFRDCNM 
 FROM nfRET_GL10020 
 INNER JOIN PM00400 ON nfRET_GL10020.APFRDCNM = PM00400.DOCNUMBR AND 
 PM00400.BCHSOURC = 'nfMCP_Payment'  AND PM00400.DCSTATUS = 1 AND  
 nfRET_GL10020.APFRDCNM NOT IN 
 (SELECT NUMBERIE FROM nfMCP_PM10000))

 
  
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'nfMCP_CARTERA_WORK [nfMCP10200]',nfMCP10200.EGRNUMB,20,1  
 FROM   nfMCP10200 
 INNER JOIN PM00400 
 ON nfMCP10200.EGRNUMB = PM00400.DOCNUMBR AND PM00400.BCHSOURC = 'nfMCP_Payment' AND PM00400.DCSTATUS = 1 
 AND  nfMCP10200.EGRNUMB NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000)
 
 Update nfMCP10200 set EGRTYPE = '',EGRNUMB ='',CARTSTAT = 1,VENDORID = ''
 WHERE EGRNUMB IN(SELECT nfMCP10200.EGRNUMB  FROM   nfMCP10200 INNER JOIN PM00400 
 ON nfMCP10200.EGRNUMB = PM00400.DOCNUMBR AND PM00400.BCHSOURC = 'nfMCP_Payment' AND 
 PM00400.DCSTATUS = 1 AND  nfMCP10200.EGRNUMB NOT IN 
 (SELECT NUMBERIE FROM nfMCP_PM10000))

 
  
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'nfMCP_PAYMENT_LINE_WORK [nfMCP_PM10100]',NUMBERIE,20,1 
 FROM nfMCP_PM10100 
 WHERE NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000)
 
 DELETE FROM nfMCP_PM10100 
 WHERE NUMBERIE NOT IN 
 (SELECT NUMBERIE FROM nfMCP_PM10000)

 
  
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'nfRET_CARTERA_WORK [nfRET_GL10020]',TII_MC_PM10100.NUMBERIE,20,1  
 FROM   TII_MC_PM10100 INNER JOIN PM00400 
 ON TII_MC_PM10100.NUMBERIE = PM00400.DOCNUMBR AND PM00400.BCHSOURC = 'nfMCP_Payment' AND 
 PM00400.DCSTATUS = 1 AND  TII_MC_PM10100.NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000)
 
 DELETE FROM nfRET_GL10020 WHERE APFRDCNM IN (SELECT TII_MC_PM10100.NUMBERIE 
 FROM TII_MC_PM10100
 INNER JOIN PM00400 ON TII_MC_PM10100.NUMBERIE = PM00400.DOCNUMBR AND 
 PM00400.BCHSOURC = 'nfMCP_Payment' 
 AND PM00400.DCSTATUS = 1 AND  TII_MC_PM10100.NUMBERIE NOT IN 
 (SELECT NUMBERIE FROM nfMCP_PM10000))

 
  
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)
 SELECT @USERID,'nfMCP_CARTERA_WORK [nfMCP10200]',BANACTID,29,0 FROM nfMCP10200 
 WHERE BANACTID <> '' AND  BANACTID NOT IN 
 (SELECT BANACTID FROM nfMCP00400) 

 
  
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)
 SELECT @USERID,'nfMCP_CARTERA_WORK [nfMCP10200]',MEDIOID,15,0 
 FROM nfMCP10200 
 WHERE MEDIOID <> '' AND  MEDIOID NOT IN 
 (SELECT MEDIOID FROM nfMCP00700) 

 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'PM_Distribution_WORK_OPEN [PM10100]',PM10100.VCHRNMBR,20,1  
 FROM   PM10100 INNER JOIN PM00400 ON 
 PM10100.VCHRNMBR = PM00400.DOCNUMBR 
 AND PM00400.BCHSOURC = 'nfMCP_Payment' AND PM00400.DCSTATUS = 1 
 AND PM10100.VCHRNMBR NOT IN (SELECT NUMBERIE FROM nfMCP_PM10000)
 
 DELETE FROM PM10100 WHERE VCHRNMBR IN (SELECT PM10100.VCHRNMBR FROM PM10100 
 INNER JOIN PM00400 
 ON PM10100.VCHRNMBR = PM00400.DOCNUMBR AND PM00400.BCHSOURC = 'nfMCP_Payment' AND 
 PM00400.DCSTATUS = 1 AND  PM10100.VCHRNMBR NOT IN 
 (SELECT NUMBERIE FROM nfMCP_PM10000))

 
   exec mcpCLExpensesRetentionWorkTrx @USERID

end
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLExpensesWorkTrx] TO [DYNGRP] 
GO 

/*End_mcpCLExpensesWorkTrx*/
/*Begin_mcpCLReceiptsBatchTrx*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLReceiptsBatchTrx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLReceiptsBatchTrx]
GO

CREATE  PROCEDURE mcpCLReceiptsBatchTrx 
 @USERID CHAR(15),
 @O_SQL_Error_State int = NULL  output
AS


BEGIN
    

 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'Batch_Headers [SY00500]',A.BACHNUMB,7,1  FROM SY00500 A WHERE A.BCHSOURC = 'nfMCP_Cash' AND A.BACHNUMB 
 IN(SELECT BACHNUMB FROM nfMCP10000 group by BACHNUMB)
 Group by A.BACHNUMB HAVING Sum(A.BCHTOTAL) NOT IN 
 (SELECT SUM(TOTAMNT) FROM nfMCP10000 
 WHERE BACHNUMB = A.BACHNUMB)
 
 UPDATE SY00500 set BCHTOTAL = (SELECT SUM(TOTAMNT) FROM nfMCP10000 
 WHERE nfMCP10000.BACHNUMB = SY00500.BACHNUMB )
 WHERE BACHNUMB IN (SELECT A.BACHNUMB FROM SY00500 A 
 WHERE A.BCHSOURC = 'nfMCP_Cash' AND A.BACHNUMB IN(SELECT BACHNUMB FROM nfMCP10000 group by BACHNUMB)
 GROUP BY A.BACHNUMB HAVING Sum(A.BCHTOTAL) NOT IN 
 (SELECT SUM(TOTAMNT) FROM nfMCP10000 WHERE BACHNUMB = A.BACHNUMB))

    
 
 
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID,'Batch_Headers [SY00500]',A.BACHNUMB,5,1 
 FROM SY00500 A WHERE A.BCHSOURC = 'nfMCP_Cash' AND A.BACHNUMB IN (
 SELECT BACHNUMB FROM nfMCP10000 group by BACHNUMB)
 AND A.NUMOFTRX NOT IN (SELECT Count(NUMBERIE) FROM nfMCP10000 
 WHERE BACHNUMB = A.BACHNUMB) Group by A.BACHNUMB 
 
 UPDATE SY00500 set NUMOFTRX = (
 SELECT Count(NUMBERIE) FROM nfMCP10000 WHERE 
 nfMCP10000.BACHNUMB = SY00500.BACHNUMB ) 
 WHERE BACHNUMB IN (SELECT A.BACHNUMB FROM 
 SY00500 A WHERE A.BCHSOURC = 'nfMCP_Cash' AND A.BACHNUMB IN(SELECT BACHNUMB FROM nfMCP10000 group by BACHNUMB)
 AND A.NUMOFTRX NOT IN (SELECT Count(NUMBERIE) FROM nfMCP10000 
 WHERE BACHNUMB = A.BACHNUMB) Group by A.BACHNUMB) 
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLReceiptsBatchTrx] TO [DYNGRP] 
GO 

/*End_mcpCLReceiptsBatchTrx*/
/*Begin_mcpCLReceiptsOpenTrx*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLReceiptsOpenTrx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLReceiptsOpenTrx]
GO

CREATE  PROCEDURE mcpCLReceiptsOpenTrx  
  @USERID CHAR(15),  
  @O_SQL_Error_State INT = NULL  output  
AS  
   
 BEGIN  
      

    
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
  SELECT @USERID, 
  'nfMCP_CASH_HDR_OPEN [nfMCP20000]' ,NUMBERIE, 21,1 from nfMCP20000   
  where nfMCP20000.NUMBERIE NOT IN (SELECT DOCNUMBR FROM RM00401) AND nfMCP20000.ENTITY =1  
    
  DELETE FROM nfMCP20000 where nfMCP20000.NUMBERIE NOT IN (SELECT DOCNUMBR FROM RM00401)  
   AND nfMCP20000.ENTITY =1  

   
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
  SELECT @USERID, 
  'nfMCP_CASH_HDR_OPEN [nfMCP20000]' ,NUMBERIE, 8,0 FROM nfMCP20000   
  where nfMCP20000.NFENTID NOT IN (SELECT CUSTNMBR FROM RM00101) AND nfMCP20000.ENTITY =1  

   
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)    
  SELECT 'sa','RM_Distribution_WORK [RM10101]' ,DOCNUMBR, 16,1  from RM10101 WHERE    
  RM10101.DOCNUMBR IN 
		(
		SELECT NUMBERIE 
		FROM nfMCP20100
		WHERE NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP20000 GROUP BY NUMBERIE)
		GROUP BY NUMBERIE
		)    
      
  Delete  FROM RM10101 WHERE RM10101.DOCNUMBR IN
		(
		SELECT NUMBERIE 
		FROM nfMCP20100
		WHERE NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP20000 GROUP BY NUMBERIE)
		GROUP BY NUMBERIE
		)  

   
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
  SELECT @USERID, 
  'nfMCP_CASH_HDR_OPEN [nfMCP20000]' ,NUMBERIE, 24,0 FROM nfMCP20000 A WHERE  
   A.NUMBERIE IN (SELECT NUMBERIE FROM nfMCP20100)AND A.TOTAMNT != (SELECT SUM(LINEAMNT)   
  FROM nfMCP20100 WHERE NUMBERIE = A.NUMBERIE)  

   
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
  SELECT @USERID, 
  'nfMCP_CASH_LINE_OPEN [nfMCP20100]' ,NUMBERIE, 15,0 FROM nfMCP20100   
  where MEDIOID NOT IN (SELECT MEDIOID FROM nfMCP00700)  

   
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
  SELECT @USERID, 
  'nfMCP_CASH_LINE_OPEN [nfMCP20100]' ,NUMBERIE, 16,1 FROM nfMCP20100   
  where nfMCP20100.NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP20000) 
    
  DELETE FROM nfMCP20100 where nfMCP20100.NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP20000)  

   
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
  SELECT @USERID, 
  'nfMCP_CASH_LINE_OPEN [nfMCP20100]' ,NUMBERIE, 4,0 FROM nfMCP20100 where BANKID  
  NOT IN (select BANKID from SY04100) AND BANKID != ' '  

  
    
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
  SELECT @USERID,
  'nfMCP_CARTERA_WORK [nfMCP10200]',nfMCP10200.EGRNUMB,16,1   
  FROM   nfMCP10200 INNER JOIN RM00401  
  ON nfMCP10200.EGRNUMB = RM00401.DOCNUMBR AND RM00401.BCHSOURC = 'nfMCP_Cash'  
  AND RM00401.DCSTATUS = 2 
  AND  nfMCP10200.EGRNUMB NOT IN (SELECT NUMBERIE FROM nfMCP20000) 
   
  UPDATE nfMCP10200 set EGRTYPE = '',EGRNUMB ='',CARTSTAT = 1,VENDORID = '' 
  WHERE EGRNUMB IN(SELECT nfMCP10200.EGRNUMB  FROM   nfMCP10200 INNER JOIN RM00401  
  ON nfMCP10200.EGRNUMB = RM00401.DOCNUMBR AND RM00401.BCHSOURC = 'nfMCP_Cash'  
  AND RM00401.DCSTATUS = 2   
  AND  nfMCP10200.EGRNUMB NOT IN (SELECT NUMBERIE FROM nfMCP20000)) 

   
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
  SELECT @USERID, 
  'nfMCP_CARTERA_WORK [nfMCP10200]' ,DOCNUMBR, 15,0 FROM  nfMCP10200   
  WHERE MEDIOID NOT IN (SELECT MEDIOID FROM nfMCP00700)  

   
  INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
  SELECT @USERID, 
  'nfMCP_CARTERA_WORK [nfMCP10200]' ,DOCNUMBR, 4,0 FROM nfMCP10200 WHERE  
   BANKID NOT IN (SELECT BANKID FROM SY04100)  
END  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLReceiptsOpenTrx] TO [DYNGRP] 
GO 

/*End_mcpCLReceiptsOpenTrx*/
/*Begin_mcpCLReceiptsWorkTrx*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLReceiptsWorkTrx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLReceiptsWorkTrx]
GO

CREATE  PROCEDURE mcpCLReceiptsWorkTrx  
 @USERID CHAR(15),  
 @O_SQL_Error_State INT = NULL  output  
AS  
   
BEGIN  

  
   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
 SELECT @USERID, 
 'nfMCP_CASH_HDR_WORK [nfMCP10000]' ,BACHNUMB,6,0 FROM nfMCP10000   
 WHERE BACHNUMB NOT IN (SELECT BACHNUMB FROM SY00500)   

  
   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)   
 SELECT @USERID, 
 'nfMCP_CASH_HDR_WORK [nfMCP10000]',NUMBERIE,21,1 from nfMCP10000   
 WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM RM00401)  
   
 DELETE nfMCP10000 WHERE NUMBERIE NOT IN (SELECT DOCNUMBR FROM RM00401) 

  
   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP) 
 SELECT @USERID, 
 'nfMCP_CASH_HDR_WORK [nfMCP10000]',NUMBERIE,8,1 FROM nfMCP10000  
 WHERE NFENTID <> '' and NFENTID NOT IN (SELECT CUSTNMBR FROM RM00101)  
  
 Delete From nfMCP10000 where NFENTID <> '' and  NFENTID NOT IN  
 (SELECT CUSTNMBR FROM RM00101) 

  
    
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)   
 SELECT @USERID, 
 'nfMCP_CASH_LINE_WORK [nfMCP10100]',NUMBERIE,18,1 from nfMCP10100   
 WHERE NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP10000)  
   
 DELETE from nfMCP10100 WHERE NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP10000)  

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
 SELECT @USERID, 
 'nfMCP_CASH_HDR_WORK [nfMCP10000]',A.NUMBERIE,25,0 from   
 nfMCP10000 A WHERE A.TOTAMNT != (SELECT sum(LINEAMNT)from nfMCP10100 B  WHERE   
 A.NUMBERIE = B.NUMBERIE)  

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
 SELECT @USERID,
 'RM_Distribution_WORK [RM10101]', DOCNUMBR,18,1 FROM RM10101   
  WHERE RM10101.DOCNUMBR IN (SELECT DOCNUMBR from RM00401 where BCHSOURC = 'nfMCP_Cash') 
        and DOCNUMBR  NOT IN (SELECT NUMBERIE FROM nfMCP10000) and DOCNUMBR  NOT IN (SELECT NUMBERIE FROM nfMCP20000)  
    
 Delete  FROM RM10101 WHERE RM10101.DOCNUMBR IN(SELECT DOCNUMBR from RM10101 WHERE  DOCNUMBR 
 IN (SELECT DOCNUMBR from RM00401 where BCHSOURC = 'nfMCP_Cash') and DOCNUMBR  NOT IN     
 (SELECT NUMBERIE FROM nfMCP10000) and DOCNUMBR  NOT IN (SELECT NUMBERIE FROM nfMCP20000)) 

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
 SELECT @USERID,
  'nfMCP_CASH_LINE_WORK [nfMCP10100]', NUMBERIE,4,0  FROM nfMCP10100 WHERE BANKID <> '' and BANKID NOT IN (  
 SELECT BANKID FROM SY04100 WHERE SY04100.BANKID = nfMCP10100.BANKID)  

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
 SELECT @USERID, 
 'nfMCP_CASH_LINE_WORK [nfMCP10100]' ,NUMBERIE,15,0 FROM nfMCP10100  
  WHERE MEDIOID NOT IN (SELECT MEDIOID FROM nfMCP00700)  

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP) 
 SELECT @USERID,  
 'RM_Distribution_WORK [RM10101]' ,A.NUMBERIE,9,0    
 FROM nfMCP10100 A  WHERE A.NUMBERIE IN  
 (SELECT DOCNUMBR FROM RM10101  GROUP BY DOCNUMBR HAVING SUM(DEBITAMT)  = SUM(CRDTAMNT)) 
 GROUP BY A.NUMBERIE 
 HAVING SUM(A.LINEAMNT) NOT IN (SELECT SUM(DEBITAMT)FROM RM10101 WHERE DOCNUMBR = A.NUMBERIE)  
 OR SUM(A.LINEAMNT) NOT IN (SELECT SUM(CRDTAMNT)FROM RM10101 WHERE DOCNUMBR = A.NUMBERIE)  

  
   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)  
 SELECT @USERID,'nfMCP_CARTERA_WORK [nfMCP10200]',nfMCP10200.EGRNUMB,18,1   
 FROM   nfMCP10200 INNER JOIN RM00401  
 ON nfMCP10200.EGRNUMB = RM00401.DOCNUMBR AND RM00401.BCHSOURC = 'nfMCP_Cash'  
 AND RM00401.DCSTATUS = 1 
 AND  nfMCP10200.EGRNUMB NOT IN (SELECT NUMBERIE FROM nfMCP10000) 
  
 UPDATE nfMCP10200 set EGRTYPE = '',EGRNUMB ='',CARTSTAT = 1,VENDORID = '' 
 WHERE EGRNUMB IN(SELECT nfMCP10200.EGRNUMB  FROM   nfMCP10200 INNER JOIN RM00401  
 ON nfMCP10200.EGRNUMB = RM00401.DOCNUMBR AND RM00401.BCHSOURC = 'nfMCP_Cash'  
 AND RM00401.DCSTATUS = 1   
 AND  nfMCP10200.EGRNUMB NOT IN (SELECT NUMBERIE FROM nfMCP10000)) 

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
 SELECT @USERID, 
 'nfMCP_CARTERA_WORK [nfMCP10200]' ,DOCNUMBR, 15,0 from nfMCP10200 WHERE  nfMCP10200.MEDIOID  
 NOT IN (SELECT MEDIOID FROM nfMCP00700)  

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
 SELECT @USERID, 
 'nfMCP_CASH_LINE_CARTERA_WORK[nfMCP10110]' ,NUMBERIE, 18,1 from nfMCP10110  
  WHERE nfMCP10110.NUMBERIE NOT IN  (SELECT NUMBERIE FROM nfMCP10000)  
    
 DELETE FROM nfMCP10110 WHERE nfMCP10110.NUMBERIE NOT IN (SELECT NUMBERIE FROM nfMCP10000)  

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
 SELECT @USERID, 
 'nfMCP_CASH_LINE_CARTERA_WORK[nfMCP10110]' ,NUMBERIE, 15,0 FROM  
  nfMCP10110 WHERE nfMCP10110.MEDIOID NOT IN (SELECT MEDIOID FROM nfMCP00700)  

   
 INSERT INTO MCP3400(USERID,  MCPTBL , ERMSGTXT, MCPERMSG, MCPERTYP)  
 SELECT @USERID, 
 'nfMCP_CASH_LINE_CARTERA_WORK[nfMCP10110]' ,NUMBERIE, 4,0   
 FROM nfMCP10110 WHERE nfMCP10110.BANKID NOT IN (SELECT BANKID FROM SY04100)  
END  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLReceiptsWorkTrx] TO [DYNGRP] 
GO 

/*End_mcpCLReceiptsWorkTrx*/
/*Begin_nfMCP_Own_Checks_Control_Report_Print*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfMCP_Own_Checks_Control_Report_Print]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfMCP_Own_Checks_Control_Report_Print]
GO

CREATE  PROCEDURE nfMCP_Own_Checks_Control_Report_Print 
@IDBANACT AS CHAR(22),
@IDCHEKBK AS CHAR(15),
@TableName as varchar(50) ,
@DOCNUMBRTO AS CHAR(22), 
@DOCNUMBRFROM AS CHAR(22)  
AS 
BEGIN 
    set nocount on
    DECLARE @count AS INTEGER 
    DECLARE @DOCNUMBRFROM_TEMP AS CHAR(22)
    DECLARE @DOCNUMBRFROM1 AS CHAR(22)
    DECLARE @ExecString AS VARCHAR (8000)
    DECLARE @UsedNo AS CHAR(22) 
    DECLARE @UsedNo1 AS CHAR(22) 
    DECLARE @Temp2 AS INTEGER 
    exec('truncate table ' + @TableName)
    IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name =  '##CHKTEMP')
     DROP TABLE ##CHKTEMP
    select CHEKBKID,FROMNUMB,TONUMBER,BANACTID into ##CHKTEMP from nfMCP00500 where 1 <> 1
    IF  len(ltrim(rtrim(@IDCHEKBK))) = 0 
    begin 
     INSERT INTO ##CHKTEMP
     select CHEKBKID,FROMNUMB,TONUMBER,BANACTID from  nfMCP00500  
     WHERE BANACTID = @IDBANACT
     set @Temp2 = 1
    end 
    ELSE IF len(ltrim(rtrim(@IDCHEKBK))) <> 0  AND len(ltrim(rtrim(@DOCNUMBRFROM))) = 0  AND len(ltrim(rtrim(@DOCNUMBRTO))) = 0
    begin 
     INSERT INTO ##CHKTEMP
     SELECT  CHEKBKID, FROMNUMB, TONUMBER,BANACTID from  nfMCP00500  
      WHERE BANACTID = @IDBANACT AND CHEKBKID = @IDCHEKBK
     set @Temp2 = 1
    end 
    ELSE IF len(ltrim(rtrim(@IDCHEKBK))) <> 0  AND len(ltrim(rtrim(@DOCNUMBRFROM))) <> 0  AND len(ltrim(rtrim(@DOCNUMBRTO))) = 0
    begin 
     SELECT  @DOCNUMBRFROM1 = FROMNUMB from  nfMCP00500  
      WHERE BANACTID = @IDBANACT AND CHEKBKID = @IDCHEKBK
     if len(ltrim(rtrim(@DOCNUMBRFROM1))) > len(ltrim(rtrim(@DOCNUMBRFROM)))
     begin
       set @count = len(ltrim(rtrim(@DOCNUMBRFROM1))) - len(ltrim(rtrim(@DOCNUMBRFROM)))
       WHILE (@count <> 0)
       BEGIN 
          set @DOCNUMBRFROM = '0' + @DOCNUMBRFROM
          set @count = @count -1  
       END
     end
     if len(ltrim(rtrim(@DOCNUMBRFROM))) > len(ltrim(rtrim(@DOCNUMBRFROM1)))
     begin
      set @count = len(ltrim(rtrim(@DOCNUMBRFROM))) - len(ltrim(rtrim(@DOCNUMBRFROM1))) 
      set @DOCNUMBRFROM = SUBSTRING(@DOCNUMBRFROM,@count + 1, len(ltrim(rtrim(@DOCNUMBRFROM1))))
     end
     INSERT INTO ##CHKTEMP
     SELECT  CHEKBKID, @DOCNUMBRFROM, TONUMBER,BANACTID from  nfMCP00500  
      WHERE BANACTID = @IDBANACT AND CHEKBKID = @IDCHEKBK
     set @Temp2 = 1
    end 
    ELSE IF len(ltrim(rtrim(@IDCHEKBK))) <> 0  AND len(ltrim(rtrim(@DOCNUMBRFROM))) = 0  AND len(ltrim(rtrim(@DOCNUMBRTO))) <> 0
    begin 
     SELECT  @DOCNUMBRFROM1 = TONUMBER from  nfMCP00500  
      WHERE BANACTID = @IDBANACT AND CHEKBKID = @IDCHEKBK
     if len(ltrim(rtrim(@DOCNUMBRFROM1))) > len(ltrim(rtrim(@DOCNUMBRTO)))
     begin
       set @count = len(ltrim(rtrim(@DOCNUMBRFROM1))) - len(ltrim(rtrim(@DOCNUMBRTO)))
       WHILE (@count <> 0)
       BEGIN 
          set @DOCNUMBRTO = '0' + @DOCNUMBRTO
          set @count = @count -1  
       END
     end
     if len(ltrim(rtrim(@DOCNUMBRTO))) > len(ltrim(rtrim(@DOCNUMBRFROM1)))
     begin
      set @count = len(ltrim(rtrim(@DOCNUMBRTO))) - len(ltrim(rtrim(@DOCNUMBRFROM1))) 
      set @DOCNUMBRTO = SUBSTRING(@DOCNUMBRTO,@count + 1, len(ltrim(rtrim(@DOCNUMBRFROM1))))
     end 
     INSERT INTO ##CHKTEMP
     SELECT  CHEKBKID, FROMNUMB, @DOCNUMBRTO,BANACTID from  nfMCP00500  
      WHERE BANACTID = @IDBANACT AND CHEKBKID = @IDCHEKBK
    end 
    else
    begin
     SELECT  @DOCNUMBRFROM1 = FROMNUMB from  nfMCP00500  
      WHERE BANACTID = @IDBANACT AND CHEKBKID = @IDCHEKBK
     if len(ltrim(rtrim(@DOCNUMBRFROM1))) > len(ltrim(rtrim(@DOCNUMBRFROM)))
     begin
       set @count = len(ltrim(rtrim(@DOCNUMBRFROM1))) - len(ltrim(rtrim(@DOCNUMBRFROM)))
       WHILE (@count <> 0)
       BEGIN 
          set @DOCNUMBRFROM = '0' + @DOCNUMBRFROM
          set @DOCNUMBRTO = '0' + @DOCNUMBRTO
          set @count = @count -1  
       END
     end
     if len(ltrim(rtrim(@DOCNUMBRFROM))) > len(ltrim(rtrim(@DOCNUMBRFROM1)))
     begin
      set @count = len(ltrim(rtrim(@DOCNUMBRFROM))) - len(ltrim(rtrim(@DOCNUMBRFROM1))) 
      set @DOCNUMBRFROM = SUBSTRING(@DOCNUMBRFROM,@count + 1, len(ltrim(rtrim(@DOCNUMBRFROM1))))
     end
     SELECT  @DOCNUMBRFROM1 = TONUMBER from  nfMCP00500  
      WHERE BANACTID = @IDBANACT AND CHEKBKID = @IDCHEKBK
     if len(ltrim(rtrim(@DOCNUMBRFROM1))) > len(ltrim(rtrim(@DOCNUMBRTO)))
     begin
      set @count = len(ltrim(rtrim(@DOCNUMBRFROM1))) - len(ltrim(rtrim(@DOCNUMBRTO)))
      WHILE (@count <> 0)
      BEGIN 
         set @DOCNUMBRTO = '0' + @DOCNUMBRTO
         set @count = @count -1  
      END
     end
     if len(ltrim(rtrim(@DOCNUMBRTO))) > len(ltrim(rtrim(@DOCNUMBRFROM1)))
     begin
      set @count = len(ltrim(rtrim(@DOCNUMBRTO))) - len(ltrim(rtrim(@DOCNUMBRFROM1))) 
      set @DOCNUMBRTO = SUBSTRING(@DOCNUMBRTO,@count + 1, len(ltrim(rtrim(@DOCNUMBRFROM1))))
     end 
     insert into ##CHKTEMP values (@IDCHEKBK,@DOCNUMBRFROM,@DOCNUMBRTO,@IDBANACT)
    end
    if @Temp2 = 1 
    begin
     DECLARE GET_CHECKBOOKID CURSOR FOR 
     select CHEKBKID,FROMNUMB,TONUMBER,BANACTID from  ##CHKTEMP  
     ORDER BY BANACTID,CHEKBKID
     OPEN GET_CHECKBOOKID 
     FETCH NEXT FROM GET_CHECKBOOKID INTO @IDCHEKBK,@DOCNUMBRFROM,@DOCNUMBRTO,@IDBANACT
     WHILE (@@FETCH_STATUS=0) 
     BEGIN 
       select @UsedNo = ISNULL(MAX(DOCNUMBR),'1') from nfMCP_PM10100 
        where CHEKBKID = @IDCHEKBK and BANACTID = @IDBANACT and 
         len(ltrim(rtrim(NUMBERIE))) <> 0 
       select @UsedNo1 =ISNULL(MAX(DOCNUMBR),'1') from nfMCP_PM20100 
          where CHEKBKID = @IDCHEKBK and BANACTID = @IDBANACT and len(ltrim(rtrim(NUMBERIE))) <> 0 
       if CONVERT(integer,@UsedNo1) >= CONVERT(integer, @UsedNo)
            set @UsedNo = @UsedNo1
       if CONVERT(integer,@DOCNUMBRFROM) > CONVERT(integer, @UsedNo)
       begin
        CLOSE GET_CHECKBOOKID 
        DEALLOCATE GET_CHECKBOOKID
        return 1
       end
       UPDATE ##CHKTEMP SET TONUMBER = @UsedNo WHERE (CHEKBKID = @IDCHEKBK and BANACTID = @IDBANACT)
       FETCH NEXT FROM GET_CHECKBOOKID INTO @IDCHEKBK,@DOCNUMBRFROM,@DOCNUMBRTO,@IDBANACT
     END
     CLOSE GET_CHECKBOOKID 
     DEALLOCATE GET_CHECKBOOKID
    end
    DECLARE GET_CHECKBOOKID CURSOR FOR 
     select CHEKBKID,FROMNUMB,TONUMBER,BANACTID from  ##CHKTEMP  
     ORDER BY CHEKBKID
     OPEN GET_CHECKBOOKID 
    FETCH NEXT FROM GET_CHECKBOOKID INTO @IDCHEKBK,@DOCNUMBRFROM,@DOCNUMBRTO,@IDBANACT
    WHILE (@@FETCH_STATUS=0) 
    BEGIN 
     set @DOCNUMBRFROM_TEMP = @DOCNUMBRFROM
     WHILE (CONVERT(INT,@DOCNUMBRFROM) <> CONVERT(INT, @DOCNUMBRTO) + 1 )
     BEGIN
      select @ExecString = 'insert into ' + @TableName + '(CHEKBKID,DOCNUMBR,BANACTID,FROMNUMB,TONUMBER,DUEDATE,EMIDATE,VOIDDATE,NUMBERIE,BACHNUMB,LINEAMNT,CURNCYID,VENDORID,VOIDED) 
       values (''' + @IDCHEKBK + ''',''' + @DOCNUMBRFROM + ''',''' + @IDBANACT + ''',''' + @DOCNUMBRFROM_TEMP + ''',''' + @DOCNUMBRTO + ''','' 2005-11-15 '','' 2005-11-15 '','' 2005-11-15 '',''t1'',''t1'',''00.00'',''t1'',''t1'',''0'')'
      EXEC (@ExecString)
      set @DOCNUMBRFROM = @DOCNUMBRFROM + 1
      if len(ltrim(rtrim(@DOCNUMBRTO))) > len(ltrim(rtrim(@DOCNUMBRFROM)))
      begin
       set @count = len(ltrim(rtrim(@DOCNUMBRTO))) - len(ltrim(rtrim(@DOCNUMBRFROM)))
       WHILE (@count <> 0)
       BEGIN 
          set @DOCNUMBRFROM = '0' + @DOCNUMBRFROM
          set @count = @count -1  
       END
      end
     END
     FETCH NEXT FROM GET_CHECKBOOKID INTO @IDCHEKBK,@DOCNUMBRFROM,@DOCNUMBRTO,@IDBANACT
    END
    CLOSE GET_CHECKBOOKID 
    DEALLOCATE GET_CHECKBOOKID
    exec ('update  ' + @TableName + ' set DOCNUMBR = nfMCP_PM10100.DOCNUMBR ,
     DUEDATE = nfMCP_PM10100.DUEDATE,EMIDATE = nfMCP_PM10100.EMIDATE ,
     VOIDDATE = nfMCP_PM10100.VOIDDATE,NUMBERIE = nfMCP_PM10100.NUMBERIE ,
     BACHNUMB = nfMCP_PM10000.BACHNUMB,LINEAMNT = nfMCP_PM10100.LINEAMNT ,
     CURNCYID = nfMCP_PM10100.CURNCYID,VENDORID = nfMCP_PM10000.VENDORID,
     CHEKBKID = nfMCP_PM10100.CHEKBKID,BANACTID = nfMCP_PM10100.BANACTID,
     VOIDED =  nfMCP_PM10100.VOIDED
     from nfMCP_PM10100,nfMCP_PM10000,##CHKTEMP,'+ @TableName + ' 
     where nfMCP_PM10100.MCPTYPID = nfMCP_PM10000.MCPTYPID AND 
     nfMCP_PM10100.NUMBERIE = nfMCP_PM10000.NUMBERIE and 
     nfMCP_PM10100.CHEKBKID = ##CHKTEMP.CHEKBKID and 
     nfMCP_PM10100.DOCNUMBR >= ##CHKTEMP.FROMNUMB and
     nfMCP_PM10100.DOCNUMBR <= ##CHKTEMP.TONUMBER and
     nfMCP_PM10100.CHEKBKID = '+ @TableName + '.CHEKBKID and '
     + @TableName + '.DOCNUMBR = nfMCP_PM10100.DOCNUMBR  and
     ##CHKTEMP.CHEKBKID = '+ @TableName + '.CHEKBKID ')
    exec ('update ' + @TableName + ' set DOCNUMBR = nfMCP_PM20100.DOCNUMBR,
      DUEDATE = nfMCP_PM20100.DUEDATE,
      EMIDATE = nfMCP_PM20100.EMIDATE,VOIDDATE = nfMCP_PM20100.VOIDDATE,
      NUMBERIE = nfMCP_PM20100.NUMBERIE,BACHNUMB = '''' ,
      LINEAMNT = nfMCP_PM20100.LINEAMNT,CURNCYID = nfMCP_PM20100.CURNCYID,
             VENDORID = nfMCP_PM20000.VENDORID,CHEKBKID = nfMCP_PM20100.CHEKBKID,
      BANACTID = nfMCP_PM20100.BANACTID,VOIDED =  nfMCP_PM20100.VOIDED
     from nfMCP_PM20100,nfMCP_PM20000,##CHKTEMP,'+ @TableName + '
            where nfMCP_PM20100.MCPTYPID = nfMCP_PM20000.MCPTYPID AND 
     nfMCP_PM20100.NUMBERIE = nfMCP_PM20000.NUMBERIE and 
     nfMCP_PM20100.CHEKBKID = ##CHKTEMP.CHEKBKID and 
     nfMCP_PM20100.DOCNUMBR >= ##CHKTEMP.FROMNUMB and
     nfMCP_PM20100.DOCNUMBR <= ##CHKTEMP.TONUMBER and 
     nfMCP_PM20100.CHEKBKID = '+ @TableName + '.CHEKBKID and 
     '+ @TableName + '.DOCNUMBR = nfMCP_PM20100.DOCNUMBR  and
     ##CHKTEMP.CHEKBKID = '+ @TableName + '.CHEKBKID ')
    set nocount off
  end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfMCP_Own_Checks_Control_Report_Print] TO [DYNGRP] 
GO 

/*End_nfMCP_Own_Checks_Control_Report_Print*/
/*Begin_nfMCP_RunReportOPMedio_SaveTrans*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfMCP_RunReportOPMedio_SaveTrans]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfMCP_RunReportOPMedio_SaveTrans]
GO

CREATE PROCEDURE nfMCP_RunReportOPMedio_SaveTrans  
  @nCOUNTER int,@cVCHRNMBR char(21),@cVENDORID char(15), @cUSERID char(15) AS
declare @cDOCNUMBR char(21),@dDUEDATE datetime,@cMEDIOID char(21),@cBANKID char(15),@cCURNCYID char(15),
@nCURRNIDX smallint, @nLINEAMNT numeric(19,5), @nAMOUNTO numeric(19,5),@cTITACCT1 char(31), @cTITACCT2 char(31) 
SET DATEFORMAT mdy 
DECLARE APPDOC CURSOR FOR select B.DOCNUMBR, '','','','',B.DOCAMNT, A.APPLDAMT,B.DUEDATE, '','' 
 from PM10200 A ,PM20000 B where A.APFRDCNM = @cVCHRNMBR and B.VENDORID= @cVENDORID
  and B.VOIDED = 0 and A.APTVCHNM = B.VCHRNMBR and A.POSTED = 0 
OPEN APPDOC 
FETCH NEXT FROM APPDOC INTO @cMEDIOID, @cBANKID, @cDOCNUMBR, @cCURNCYID, @nCURRNIDX,  @nLINEAMNT, @nAMOUNTO, @dDUEDATE, @cTITACCT1, @cTITACCT2 
WHILE (@@FETCH_STATUS=0)     
BEGIN  
 INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
 STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
 STRTemporal_8,STRTemporal_9,STRTemporal_10,
 CURTemporal_1,CURTemporal_2,CURTemporal_3, 
 CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
 CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
 DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
 USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
 VALUES (@cVCHRNMBR,6,'Facturas',@nCOUNTER,@cMEDIOID,
 @cBANKID,@cDOCNUMBR,@cCURNCYID,@cTITACCT1,@cTITACCT2,'',
 '','','',@nLINEAMNT,@nAMOUNTO,0,0,0,0,0,0,@nCURRNIDX,0, @cVENDORID, 
 @dDUEDATE,'1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
 '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
 SELECT @nCOUNTER = @nCOUNTER + 1 
 FETCH NEXT FROM APPDOC INTO @cMEDIOID, @cBANKID, @cDOCNUMBR, @cCURNCYID, @nCURRNIDX, @nLINEAMNT, @nAMOUNTO, @dDUEDATE, @cTITACCT1, @cTITACCT2 
END 
CLOSE  APPDOC  
DEALLOCATE APPDOC
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfMCP_RunReportOPMedio_SaveTrans] TO [DYNGRP] 
GO 

/*End_nfMCP_RunReportOPMedio_SaveTrans*/
/*Begin_nfMCP_RunReportOPMedio*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfMCP_RunReportOPMedio]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfMCP_RunReportOPMedio]
GO

CREATE PROCEDURE nfMCP_RunReportOPMedio 
@nCOMPANYID smallint, @cVCHRNMBR char(21), @cVENDORID char(15), @nPRNTJE smallint, @cUSERID char(15), @nRGPRNT smallint AS
declare @cINTERID char (5),  @cAPTVCHNM char(21), @nAPTODCTY smallint, @nAPPLDAMT numeric(19,5), 
 @nRLGANLOS numeric(19,5), @cDOCNUMBR char(21), @dDUEDATE datetime, @nDOCAMNT numeric(19,5), 
 @nCOUNTER int, @nDIFCBIO numeric(19,5), @cMEDIOID char(21), @cBANKID char(15), 
 @cCURNCYID char(15), @nCURRNIDX smallint, @nLINEAMNT numeric(19,5), @nAMOUNTO numeric(19,5), 
 @nDSTINDX INT, @nDEBITAMT numeric(19,5), @nCRDTAMNT numeric(19,5), @nORDBTAMT numeric(19,5),  
 @nORCRDAMT numeric(19,5) , @nDSTSQNUM int, @cACTNUMST char(41), @cACTDESCR char(31), @cTITACCT1 char(31), @cTITACCT2 char(31) 
SET DATEFORMAT mdy 
SELECT @nDIFCBIO = 0  
 
BEGIN  
 DELETE nfMCP_PM70200 WHERE VCHRNMBR = @cVCHRNMBR AND USERID = @cUSERID 
 insert into nfMCP_PM70200 (CMPANYID, VCHRNMBR, USERID, DOCDATE, nfMCP_Printing_Number, 
  TRXDSCRN, ENTITY, VOIDSTTS, Status, PRINTED, VENDORID, BANACTID, VENDNAME) 
  SELECT @nCOMPANYID COMPANYID, NUMBERIE, @cUSERID USERID, DOCDATE, nfMCP_Printing_Number,  
   TRXDSCRN, ENTITY, VOIDSTTS, 2 AS Status, PRINTED,   
   CASE ENTITY WHEN 1 THEN NFENTID ELSE '' END VENDORID,  
   CASE ENTITY WHEN 3 THEN NFENTID ELSE '' END BANACTID,  
   CASE ENTITY WHEN 1 THEN VENDNAME WHEN 2 THEN 'Pagos Varios'  
   ELSE nfMCP00400.DSCRIPTN END VENDNAME
  FROM nfMCP_PM20000 LEFT OUTER JOIN PM00200 
   ON nfMCP_PM20000.NFENTID = PM00200.VENDORID  
   LEFT OUTER JOIN nfMCP00400 
   ON nfMCP_PM20000.NFENTID = nfMCP00400.BANACTID  
  WHERE nfMCP_PM20000.NUMBERIE = @cVCHRNMBR    
 IF NOT EXISTS (SELECT VCHRNMBR FROM nfMCP_PM70200 WHERE VCHRNMBR = @cVCHRNMBR AND USERID = @cUSERID) 
 BEGIN 
  insert into nfMCP_PM70200 (CMPANYID, VCHRNMBR, USERID, DOCDATE, nfMCP_Printing_Number, 
   TRXDSCRN, ENTITY, VOIDSTTS, Status, PRINTED, VENDORID, BANACTID, VENDNAME) 
   SELECT @nCOMPANYID COMPANYID, NUMBERIE, @cUSERID USERID, DOCDATE, nfMCP_Printing_Number,  
    TRXDSCRN, ENTITY, 0 AS VOIDSTTS, 1 AS Status, PRINTED,  
    CASE ENTITY WHEN 1 THEN NFENTID ELSE '' END VENDORID,  
    CASE ENTITY WHEN 3 THEN NFENTID ELSE '' END BANACTID, 
    CASE ENTITY WHEN 1 THEN VENDNAME WHEN 2 THEN 'Pagos Varios'  
    ELSE nfMCP00400.DSCRIPTN END VENDNAME
   FROM nfMCP_PM10000 LEFT OUTER JOIN PM00200 
    ON nfMCP_PM10000.NFENTID = PM00200.VENDORID 
    LEFT OUTER JOIN nfMCP00400 
    ON nfMCP_PM10000.NFENTID = nfMCP00400.BANACTID 
   WHERE nfMCP_PM10000.NUMBERIE = @cVCHRNMBR  
 END 
 UPDATE nfMCP_PM20000 SET PRINTED = 1 WHERE NUMBERIE = @cVCHRNMBR   
 UPDATE nfMCP_PM10000 SET PRINTED = 1 WHERE NUMBERIE = @cVCHRNMBR   
 DELETE nfMCP_PM70300 WHERE VCHRNMBR = @cVCHRNMBR AND USERID = @cUSERID 
 SELECT @nCOUNTER = 0 
 DECLARE FACTURAS CURSOR FOR SELECT APTVCHNM, APTODCTY, APPLDAMT, RLGANLOS, DOCNUMBR, 
 DUEDATE, DOCAMNT FROM nfMCP_PM_ALL_Applied  
 WHERE nfMCP_PM_ALL_Applied.VENDORID = @cVENDORID AND nfMCP_PM_ALL_Applied.VCHRNMBR = @cVCHRNMBR 
 OPEN FACTURAS 
 FETCH NEXT FROM FACTURAS INTO @cAPTVCHNM, @nAPTODCTY, @nAPPLDAMT, @nRLGANLOS, @cDOCNUMBR, 
 @dDUEDATE, @nDOCAMNT 
 WHILE (@@FETCH_STATUS=0)     
 BEGIN  
  SELECT @nDIFCBIO = @nDIFCBIO + @nRLGANLOS 
  INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
  STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
  STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
  CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
  CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
  DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
  USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
  VALUES (@cVCHRNMBR,6,'Facturas',@nCOUNTER,@cDOCNUMBR,'','','','','','','','','', 
  @nDOCAMNT,@nAPPLDAMT, 0,0,0,0,0,0,0,0, @cVENDORID, 
  @dDUEDATE,'1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
  '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
  SELECT @nCOUNTER = @nCOUNTER + 1 
  FETCH NEXT FROM FACTURAS INTO @cAPTVCHNM, @nAPTODCTY, @nAPPLDAMT, @nRLGANLOS, @cDOCNUMBR, 
  @dDUEDATE, @nDOCAMNT 
 END 
 CLOSE  FACTURAS  
 DEALLOCATE FACTURAS 
 DECLARE MEDIOS CURSOR FOR SELECT * FROM (SELECT MEDIOID, BANKID, DOCNUMBR, CURNCYID, CURRNIDX, 
   LINEAMNT, AMOUNTO, DUEDATE, SUBSTRING(TITACCT, 1, 31) TITACCT1, SUBSTRING(TITACCT, 32, 30) TITACCT2 FROM nfMCP_PM20100  
   WHERE nfMCP_PM20100.NUMBERIE = @cVCHRNMBR and nfMCP_PM20100.VOIDED = 0  
  UNION ALL 
  SELECT MEDIOID, BANKID, DOCNUMBR, CURNCYID, CURRNIDX, 
   LINEAMNT, AMOUNTO, DUEDATE, SUBSTRING(TITACCT, 1, 31) TITACCT1, SUBSTRING(TITACCT, 32, 30) TITACCT2 FROM nfMCP_PM10100  
   WHERE nfMCP_PM10100.NUMBERIE = @cVCHRNMBR and nfMCP_PM10100.VOIDED = 0) D 
 OPEN MEDIOS 
 FETCH NEXT FROM MEDIOS INTO @cMEDIOID, @cBANKID, @cDOCNUMBR, @cCURNCYID, @nCURRNIDX,  @nLINEAMNT, @nAMOUNTO, @dDUEDATE, @cTITACCT1, @cTITACCT2 
 WHILE (@@FETCH_STATUS=0)     
 BEGIN  
  INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
  STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
  STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
  CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
  CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
  DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
  USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
  VALUES (@cVCHRNMBR,6,'Medios',@nCOUNTER,@cMEDIOID,@cBANKID,@cDOCNUMBR,@cCURNCYID,@cTITACCT1,@cTITACCT2,'','','','', 
  0,@nLINEAMNT,@nAMOUNTO,0,0,0,0,0,@nCURRNIDX,0, @cVENDORID, 
  '1/1/1900',@dDUEDATE,'1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
  '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
  SELECT @nCOUNTER = @nCOUNTER + 1 
  FETCH NEXT FROM MEDIOS INTO @cMEDIOID, @cBANKID, @cDOCNUMBR, @cCURNCYID, @nCURRNIDX, @nLINEAMNT, @nAMOUNTO, @dDUEDATE, @cTITACCT1, @cTITACCT2 
 END 
 CLOSE  MEDIOS  
 DEALLOCATE MEDIOS  
 DECLARE RETENCIONES CURSOR FOR SELECT  MEDIO, SUM(nfRET_Importe_Retencion) AS SUMRET 
 FROM (SELECT ISNULL(nfRET_GL00030.MEDIOID,nfRET_GL10020.nfRET_Retencion_ID) AS MEDIO,  
 nfRET_Importe_Retencion, nfRET_GL10020.nfRET_Retencion_ID 
 FROM nfRET_GL10020 LEFT OUTER JOIN nfRET_GL00030 
 ON nfRET_GL10020.nfRET_Retencion_ID = nfRET_GL00030.nfRET_Retencion_ID 
 WHERE nfRET_GL10020.APFRDCNM = @cVCHRNMBR  AND nfRET_GL10020.nfRET_Importe_Retencion <>0) AS RET  
 GROUP BY MEDIO 
 OPEN RETENCIONES 
 FETCH NEXT FROM RETENCIONES INTO @cMEDIOID, @nLINEAMNT 
 WHILE (@@FETCH_STATUS=0)      
 BEGIN  
  IF @nLINEAMNT <> 0 
  BEGIN 
   INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
   STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
   STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
   CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
   CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
   DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
   USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
   VALUES (@cVCHRNMBR,6,'Retenciones',@nCOUNTER,@cMEDIOID,'','','','','','','','','', 
   0,@nLINEAMNT,0,0,0,0,0,0,0,0, @cVENDORID, 
   '1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900',  
   '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
   SET @nCOUNTER = @nCOUNTER + 1 
  END 
  FETCH NEXT FROM RETENCIONES INTO @cMEDIOID, @nLINEAMNT 
 END 
 CLOSE  RETENCIONES 
 DEALLOCATE RETENCIONES  
 IF @nDIFCBIO <> 0 
 BEGIN 
  INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
  STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
  STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
  CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
  CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
  DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
  USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
  VALUES (@cVCHRNMBR,6,'XDiferent',@nCOUNTER,'','','','','','','','','','', 
  0,@nDIFCBIO,0,0,0,0,0,0,0,0, @cVENDORID, 
  '1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
  '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
  SELECT @nCOUNTER = @nCOUNTER + 1 
 END 
 ELSE 
 BEGIN 
  SELECT @nCOUNTER = @nCOUNTER 
 END 
 SELECT @nDIFCBIO = 0  
 IF @nPRNTJE = 1  
 BEGIN 
  SELECT @nCOUNTER = 0 
  DECLARE ASIENTO CURSOR FOR SELECT DSTSQNUM, CURNCYID, DSTINDX, DEBITAMT, CRDTAMNT, ORDBTAMT,  
   ORCRDAMT, ACTNUMST, ACTDESCR 
   FROM PM30600 INNER JOIN GL00105 
   ON PM30600.DSTINDX = GL00105.ACTINDX INNER JOIN GL00100 
   ON PM30600.DSTINDX = GL00100.ACTINDX  
   WHERE VCHRNMBR= @cVCHRNMBR AND DOCTYPE = 6 
  OPEN ASIENTO 
  FETCH NEXT FROM ASIENTO INTO @nDSTSQNUM, @cCURNCYID, @nDSTINDX, @nDEBITAMT, @nCRDTAMNT, @nORDBTAMT, 
  @nORCRDAMT, @cACTNUMST, @cACTDESCR 
  WHILE (@@FETCH_STATUS=0)     
  BEGIN  
   SELECT @nCOUNTER = @nCOUNTER + 1 
   INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
   STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
   STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
   CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
   CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
   DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
   USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
   VALUES (@cVCHRNMBR,6,'zDistri',@nCOUNTER,'','','',@cCURNCYID,'','','','', @cACTNUMST, @cACTDESCR, 
   0,0,0,0,0,0,0,0,0,0, @cVENDORID,  
   '1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
   '1/1/1900','1/1/1900',@cUSERID,@nDSTINDX,@nDEBITAMT,@nCRDTAMNT, @nORDBTAMT,@nORCRDAMT) 
   SELECT @nCOUNTER = @nCOUNTER + 1 
   FETCH NEXT FROM ASIENTO INTO @nDSTSQNUM, @cCURNCYID, @nDSTINDX, @nDEBITAMT, @nCRDTAMNT,  
    @nORDBTAMT, @nORCRDAMT, @cACTNUMST, @cACTDESCR 
  END 
  CLOSE  ASIENTO  
  DEALLOCATE ASIENTO 
  IF @nCOUNTER = 0 
  BEGIN 
   DECLARE ASIENTO CURSOR FOR SELECT DSTSQNUM, CURNCYID, DSTINDX, DEBITAMT, CRDTAMNT, ORDBTAMT,  
    ORCRDAMT, ACTNUMST, ACTDESCR 
    FROM PM10100  INNER JOIN GL00105 
    ON PM10100.DSTINDX = GL00105.ACTINDX INNER JOIN GL00100 
    ON PM10100.DSTINDX = GL00100.ACTINDX  
    WHERE VCHRNMBR= @cVCHRNMBR  
   OPEN ASIENTO 
   FETCH NEXT FROM ASIENTO INTO @nDSTSQNUM, @cCURNCYID, @nDSTINDX, @nDEBITAMT, @nCRDTAMNT, @nORDBTAMT, 
   @nORCRDAMT, @cACTNUMST, @cACTDESCR 
   WHILE (@@FETCH_STATUS=0)     
   BEGIN  
    INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
    STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
    STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
    CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
    CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
    DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
    USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
    VALUES (@cVCHRNMBR,6,'zDistri',@nCOUNTER,'','','',@cCURNCYID,'','','','', @cACTNUMST, @cACTDESCR, 
    0,0,0,0,0,0,0,0,0,0, @cVENDORID, 
    '1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
    '1/1/1900','1/1/1900',@cUSERID,@nDSTINDX,@nDEBITAMT,@nCRDTAMNT, @nORDBTAMT,@nORCRDAMT) 
    SELECT @nCOUNTER = @nCOUNTER + 1 
    FETCH NEXT FROM ASIENTO INTO @nDSTSQNUM, @cCURNCYID, @nDSTINDX, @nDEBITAMT, @nCRDTAMNT,   
     @nORDBTAMT, @nORCRDAMT, @cACTNUMST, @cACTDESCR 
   END 
   CLOSE  ASIENTO  
   DEALLOCATE ASIENTO 
  END  
 END
 exec nfMCP_RunReportOPMedio_SaveTrans @nCOUNTER,@cVCHRNMBR,@cVENDORID,@cUSERID  
END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfMCP_RunReportOPMedio] TO [DYNGRP] 
GO 

/*End_nfMCP_RunReportOPMedio*/
/*Begin_nfMCP_RunReportOP*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfMCP_RunReportOP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfMCP_RunReportOP]
GO

CREATE PROCEDURE nfMCP_RunReportOP 
@nCOMPANYID smallint, @cVCHRNMBR char(21), @cVENDORID char(15), @nPRNTJE smallint, @cUSERID char(15), @nRGPRNT smallint AS
declare @cINTERID char (5),  @cAPTVCHNM char(21), @nAPTODCTY smallint, @nAPPLDAMT numeric(19,5), 
 @nRLGANLOS numeric(19,5), @cDOCNUMBR char(21), @dDUEDATE datetime, @nDOCAMNT numeric(19,5), 
 @nCOUNTER int, @nDIFCBIO numeric(19,5), @cMEDIOID char(21),@cRETID char(21), @cBANKID char(15), 
 @cCURNCYID char(15), @nCURRNIDX smallint, @nLINEAMNT numeric(19,5), @nAMOUNTO numeric(19,5), 
 @nDSTINDX INT, @nDEBITAMT numeric(19,5), @nCRDTAMNT numeric(19,5), @nORDBTAMT numeric(19,5),  
 @nORCRDAMT numeric(19,5) , @nDSTSQNUM int, @cACTNUMST char(41), @cACTDESCR char(31), @cTITACCT1 char(31), @cTITACCT2 char(31) 
SET DATEFORMAT mdy 
SELECT @nDIFCBIO = 0  
 
BEGIN  
 DELETE nfMCP_PM70200 WHERE VCHRNMBR = @cVCHRNMBR AND USERID = @cUSERID 
 insert into nfMCP_PM70200 (CMPANYID, VCHRNMBR, USERID, DOCDATE, nfMCP_Printing_Number, 
  TRXDSCRN, ENTITY, VOIDSTTS, Status, PRINTED, VENDORID, BANACTID, VENDNAME) 
  SELECT @nCOMPANYID COMPANYID, NUMBERIE, @cUSERID USERID, DOCDATE, nfMCP_Printing_Number,  
   TRXDSCRN, ENTITY, VOIDSTTS, 2 AS Status, PRINTED,   
   CASE ENTITY WHEN 1 THEN NFENTID ELSE '' END VENDORID,  
   CASE ENTITY WHEN 3 THEN NFENTID ELSE '' END BANACTID,  
   CASE ENTITY WHEN 1 THEN VENDNAME WHEN 2 THEN 'Pagos Varios'  
   ELSE nfMCP00400.DSCRIPTN END VENDNAME
  FROM nfMCP_PM20000 LEFT OUTER JOIN PM00200 
   ON nfMCP_PM20000.NFENTID = PM00200.VENDORID  
   LEFT OUTER JOIN nfMCP00400 
   ON nfMCP_PM20000.NFENTID = nfMCP00400.BANACTID  
  WHERE nfMCP_PM20000.NUMBERIE = @cVCHRNMBR    
 IF NOT EXISTS (SELECT VCHRNMBR FROM nfMCP_PM70200 WHERE VCHRNMBR = @cVCHRNMBR AND USERID = @cUSERID) 
 BEGIN 
  insert into nfMCP_PM70200 (CMPANYID, VCHRNMBR, USERID, DOCDATE, nfMCP_Printing_Number, 
   TRXDSCRN, ENTITY, VOIDSTTS, Status, PRINTED, VENDORID, BANACTID, VENDNAME) 
   SELECT @nCOMPANYID COMPANYID, NUMBERIE, @cUSERID USERID, DOCDATE, nfMCP_Printing_Number,  
    TRXDSCRN, ENTITY, 0 AS VOIDSTTS, 1 AS Status, PRINTED,  
    CASE ENTITY WHEN 1 THEN NFENTID ELSE '' END VENDORID,  
    CASE ENTITY WHEN 3 THEN NFENTID ELSE '' END BANACTID, 
    CASE ENTITY WHEN 1 THEN VENDNAME WHEN 2 THEN 'Pagos Varios'  
    ELSE nfMCP00400.DSCRIPTN END VENDNAME
   FROM nfMCP_PM10000 LEFT OUTER JOIN PM00200 
    ON nfMCP_PM10000.NFENTID = PM00200.VENDORID 
    LEFT OUTER JOIN nfMCP00400 
    ON nfMCP_PM10000.NFENTID = nfMCP00400.BANACTID 
   WHERE nfMCP_PM10000.NUMBERIE = @cVCHRNMBR  
 END 
 UPDATE nfMCP_PM20000 SET PRINTED = 1 WHERE NUMBERIE = @cVCHRNMBR   
 UPDATE nfMCP_PM10000 SET PRINTED = 1 WHERE NUMBERIE = @cVCHRNMBR   
 DELETE nfMCP_PM70300 WHERE VCHRNMBR = @cVCHRNMBR AND USERID = @cUSERID 
 SELECT @nCOUNTER = 0 
 DECLARE FACTURAS CURSOR FOR SELECT APTVCHNM, APTODCTY, APPLDAMT, RLGANLOS, DOCNUMBR, 
 DUEDATE, DOCAMNT FROM nfMCP_PM_ALL_Applied  
 WHERE nfMCP_PM_ALL_Applied.VENDORID = @cVENDORID AND nfMCP_PM_ALL_Applied.VCHRNMBR = @cVCHRNMBR 
 OPEN FACTURAS 
 FETCH NEXT FROM FACTURAS INTO @cAPTVCHNM, @nAPTODCTY, @nAPPLDAMT, @nRLGANLOS, @cDOCNUMBR, 
 @dDUEDATE, @nDOCAMNT 
 WHILE (@@FETCH_STATUS=0)     
 BEGIN  
  SELECT @nDIFCBIO = @nDIFCBIO + @nRLGANLOS 
  INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
  STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
  STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
  CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
  CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
  DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
  USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
  VALUES (@cVCHRNMBR,6,'Facturas',@nCOUNTER,@cDOCNUMBR,'','','','','','','','','', 
  @nDOCAMNT,@nAPPLDAMT, 0,0,0,0,0,0,0,0, @cVENDORID, 
  @dDUEDATE,'1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
  '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
  SELECT @nCOUNTER = @nCOUNTER + 1 
  FETCH NEXT FROM FACTURAS INTO @cAPTVCHNM, @nAPTODCTY, @nAPPLDAMT, @nRLGANLOS, @cDOCNUMBR, 
  @dDUEDATE, @nDOCAMNT 
 END 
 CLOSE  FACTURAS  
 DEALLOCATE FACTURAS 
 DECLARE MEDIOS CURSOR FOR SELECT * FROM (SELECT MEDIOID, BANKID, DOCNUMBR, CURNCYID, CURRNIDX, 
   LINEAMNT, AMOUNTO, DUEDATE, SUBSTRING(TITACCT, 1, 31) TITACCT1, SUBSTRING(TITACCT, 32, 30) TITACCT2 FROM nfMCP_PM20100  
   WHERE nfMCP_PM20100.NUMBERIE = @cVCHRNMBR AND nfMCP_PM20100.VOIDED = 0  
  UNION ALL 
  SELECT MEDIOID, BANKID, DOCNUMBR, CURNCYID, CURRNIDX, 
   LINEAMNT, AMOUNTO, DUEDATE, SUBSTRING(TITACCT, 1, 31) TITACCT1, SUBSTRING(TITACCT, 32, 30) TITACCT2 FROM nfMCP_PM10100  
   WHERE nfMCP_PM10100.NUMBERIE = @cVCHRNMBR AND nfMCP_PM10100.VOIDED = 0 ) D 
 OPEN MEDIOS 
 FETCH NEXT FROM MEDIOS INTO @cMEDIOID, @cBANKID, @cDOCNUMBR, @cCURNCYID, @nCURRNIDX,  @nLINEAMNT, @nAMOUNTO, @dDUEDATE, @cTITACCT1, @cTITACCT2 
 WHILE (@@FETCH_STATUS=0)     
 BEGIN  
  INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
  STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
  STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
  CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
  CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
  DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
  USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
  VALUES (@cVCHRNMBR,6,'Medios',@nCOUNTER,@cMEDIOID,@cBANKID,@cDOCNUMBR,@cCURNCYID,@cTITACCT1,@cTITACCT2,'','','','', 
  0,@nLINEAMNT,@nAMOUNTO,0,0,0,0,0,@nCURRNIDX,0, @cVENDORID, 
  '1/1/1900',@dDUEDATE,'1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
  '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
  SELECT @nCOUNTER = @nCOUNTER + 1 
  FETCH NEXT FROM MEDIOS INTO @cMEDIOID, @cBANKID, @cDOCNUMBR, @cCURNCYID, @nCURRNIDX, @nLINEAMNT, @nAMOUNTO, @dDUEDATE, @cTITACCT1, @cTITACCT2 
 END 
 CLOSE  MEDIOS  
 DEALLOCATE MEDIOS  
 DECLARE RETENCIONES CURSOR FOR SELECT  MEDIO, SUM(nfRET_Importe_Retencion) AS SUMRET 
 FROM (SELECT ISNULL(nfRET_GL10020.nfRET_Retencion_ID,0) AS MEDIO,  
 nfRET_Importe_Retencion, nfRET_GL10020.nfRET_Retencion_ID 
 FROM nfRET_GL10020 LEFT OUTER JOIN nfRET_GL00030 
 ON nfRET_GL10020.nfRET_Retencion_ID = nfRET_GL00030.nfRET_Retencion_ID 
 WHERE nfRET_GL10020.APFRDCNM = @cVCHRNMBR  AND nfRET_GL10020.nfRET_Importe_Retencion <>0) AS RET  
 GROUP BY MEDIO 
 OPEN RETENCIONES 
 FETCH NEXT FROM RETENCIONES INTO @cRETID, @nLINEAMNT 
 WHILE (@@FETCH_STATUS=0)      
 BEGIN  
  IF @nLINEAMNT <> 0 
  BEGIN 
   INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
   STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
   STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
   CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
   CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
   DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
   USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
   VALUES (@cVCHRNMBR,6,'Retenciones',@nCOUNTER,@cRETID,'','','','','','','','','', 
   0,@nLINEAMNT,0,0,0,0,0,0,0,0, @cVENDORID, 
   '1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900',  
   '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
   SET @nCOUNTER = @nCOUNTER + 1 
  END 
  FETCH NEXT FROM RETENCIONES INTO @cRETID, @nLINEAMNT 
 END 
 CLOSE  RETENCIONES 
 DEALLOCATE RETENCIONES  
 IF @nDIFCBIO <> 0 
 BEGIN 
  INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
  STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
  STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
  CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
  CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
  DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
  USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
  VALUES (@cVCHRNMBR,6,'XDiferent',@nCOUNTER,'','','','','','','','','','', 
  0,@nDIFCBIO,0,0,0,0,0,0,0,0, @cVENDORID, 
  '1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
  '1/1/1900','1/1/1900',@cUSERID,0,0,0,0,0) 
  SELECT @nCOUNTER = @nCOUNTER + 1 
 END 
 ELSE 
 BEGIN 
  SELECT @nCOUNTER = @nCOUNTER 
 END 
 SELECT @nDIFCBIO = 0  
 IF @nPRNTJE = 1  
 BEGIN 
  SELECT @nCOUNTER = 0 
  DECLARE ASIENTO CURSOR FOR SELECT DSTSQNUM, CURNCYID, DSTINDX, DEBITAMT, CRDTAMNT, ORDBTAMT,  
   ORCRDAMT, ACTNUMST, ACTDESCR 
   FROM PM30600 INNER JOIN GL00105 
   ON PM30600.DSTINDX = GL00105.ACTINDX INNER JOIN GL00100 
   ON PM30600.DSTINDX = GL00100.ACTINDX  
   WHERE VCHRNMBR= @cVCHRNMBR AND DOCTYPE = 6 
  OPEN ASIENTO 
  FETCH NEXT FROM ASIENTO INTO @nDSTSQNUM, @cCURNCYID, @nDSTINDX, @nDEBITAMT, @nCRDTAMNT, @nORDBTAMT, 
  @nORCRDAMT, @cACTNUMST, @cACTDESCR 
  WHILE (@@FETCH_STATUS=0)     
  BEGIN  
   SELECT @nCOUNTER = @nCOUNTER + 1 
   INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
   STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
   STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
   CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
   CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
   DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
   USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
   VALUES (@cVCHRNMBR,6,'zDistri',@nCOUNTER,'','','',@cCURNCYID,'','','','', @cACTNUMST, @cACTDESCR, 
   0,0,0,0,0,0,0,0,0,0, @cVENDORID,  
   '1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
   '1/1/1900','1/1/1900',@cUSERID,@nDSTINDX,@nDEBITAMT,@nCRDTAMNT, @nORDBTAMT,@nORCRDAMT) 
   SELECT @nCOUNTER = @nCOUNTER + 1 
   FETCH NEXT FROM ASIENTO INTO @nDSTSQNUM, @cCURNCYID, @nDSTINDX, @nDEBITAMT, @nCRDTAMNT,  
    @nORDBTAMT, @nORCRDAMT, @cACTNUMST, @cACTDESCR 
  END 
  CLOSE  ASIENTO  
  DEALLOCATE ASIENTO 
  IF @nCOUNTER = 0 
  BEGIN 
   DECLARE ASIENTO CURSOR FOR SELECT DSTSQNUM, CURNCYID, DSTINDX, DEBITAMT, CRDTAMNT, ORDBTAMT,  
    ORCRDAMT, ACTNUMST, ACTDESCR 
    FROM PM10100  INNER JOIN GL00105 
    ON PM10100.DSTINDX = GL00105.ACTINDX INNER JOIN GL00100 
    ON PM10100.DSTINDX = GL00100.ACTINDX  
    WHERE VCHRNMBR= @cVCHRNMBR  
   OPEN ASIENTO 
   FETCH NEXT FROM ASIENTO INTO @nDSTSQNUM, @cCURNCYID, @nDSTINDX, @nDEBITAMT, @nCRDTAMNT, @nORDBTAMT, 
   @nORCRDAMT, @cACTNUMST, @cACTDESCR 
   WHILE (@@FETCH_STATUS=0)     
   BEGIN  
    INSERT INTO nfMCP_PM70300 (VCHRNMBR,DOCTYPE,TypeTemporal,TYPEID, STRTemporal_1, 
    STRTemporal_2, STRTemporal_3, STRTemporal_4,STRTemporal_5,STRTemporal_6,STRTemporal_7, 
    STRTemporal_8,STRTemporal_9,STRTemporal_10,CURTemporal_1,CURTemporal_2,CURTemporal_3, 
    CURTemporal_4,CURTemporal_5,CURTemporal_6,CURTemporal_7,CURTemporal_8,CURTemporal_9, 
    CURTemporal_10,VENDORID,DATETemporal_1,DATETemporal_2,DATETemporal_3,DATETemporal_4, 
    DATETemporal_5,DATETemporal_6,DATETemporal_7,DATETemporal_8,DATETemporal_9,DATETemporal_10, 
    USERID,ACTINDX,DEBITAMT,CRDTAMNT,ORDBTAMT,ORCRDAMT) 
    VALUES (@cVCHRNMBR,6,'zDistri',@nCOUNTER,'','','',@cCURNCYID,'','','','', @cACTNUMST, @cACTDESCR, 
    0,0,0,0,0,0,0,0,0,0, @cVENDORID, 
    '1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900','1/1/1900', 
    '1/1/1900','1/1/1900',@cUSERID,@nDSTINDX,@nDEBITAMT,@nCRDTAMNT, @nORDBTAMT,@nORCRDAMT) 
    SELECT @nCOUNTER = @nCOUNTER + 1 
    FETCH NEXT FROM ASIENTO INTO @nDSTSQNUM, @cCURNCYID, @nDSTINDX, @nDEBITAMT, @nCRDTAMNT,   
     @nORDBTAMT, @nORCRDAMT, @cACTNUMST, @cACTDESCR 
   END 
   CLOSE  ASIENTO  
   DEALLOCATE ASIENTO 
  END  
 END  
END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfMCP_RunReportOP] TO [DYNGRP] 
GO 

/*End_nfMCP_RunReportOP*/
/*Begin_nfMCP_RunMassReportOP*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfMCP_RunMassReportOP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfMCP_RunMassReportOP]
GO

CREATE PROCEDURE nfMCP_RunMassReportOP 
@cRPRTNAME char(31), @cUSERID char(15), @nCOMPANYID smallint AS 
declare @cTRXDSCRN char(31),  @cPRNTNUM char(15), @nAPTODCTY smallint, @nAPPLDAMT numeric(19,5), 
 @nRLGANLOS numeric(19,5), @cDOCNUMBR char(21), @dDOCDATE datetime, @nDOCAMNT numeric(19,5), 
 @nCOUNTER int, @nDIFCBIO numeric(19,5), @cMEDIOID char(21), @cBANKID char(15), @cVCHRNMBR char(21), 
 @cCURNCYID char(15), @nCURRNIDX smallint, @nLINEAMNT numeric(19,5), @nAMOUNTO numeric(19,5), 
 @nDSTINDX INT, @nDEBITAMT numeric(19,5), @nCRDTAMNT numeric(19,5), @nORDBTAMT numeric(19,5),  
 @nORCRDAMT numeric(19,5), @nEstadoSelec smallint, @nRGPRINT smallint, @nIMPASI tinyint, @cVENDORID char(15), 
 @nAllowRprt tinyint, @nRPRTTXT char(31), @nUNPSTDTXT char(31), @cFrmBchNum char(15), 
 @cFrmVendID char(15), @dFrmDate datetime, @nFrmEntTyp smallint, @cFrmNbrIE char(21),  
 @cFrmTypIE char(21), @cToBchNum char(15), @cToVendID char(15), @dToDate datetime,  
 @nToEntTyp smallint, @cToNbrIE char(21), @cToTypIE char(21), @nFrmStatus smallint, 
 @nToStatus smallint, @nMCPStatus smallint, @cPrevVoucher char(21), @MediosOrRetencion smallint  
SET DATEFORMAT mdy 
SELECT @nCOUNTER = 0 
DECLARE PARAMETROS CURSOR FOR SELECT EstadoSeleccionado, RGPRINT, IMPASIENTO,  
 HabilitarReimpresion, TextoReimpresion, TextoNoContabilizados, FromBatchNumber,  
 FROMVENID, TII_MCP_From_Date, FromEntityType, FromNumberIE,  
 FromTypeIE, To_Batch_Number, TOVENDID, ToEntityType, ToNumberIE, ToTypeIE,  
 TII_MCP_TO_DATE, MediosOrRetencion FROM TII_MCP_GL70100 WHERE @cRPRTNAME = rtrim(RPRTNAME) 
OPEN PARAMETROS 
FETCH NEXT FROM PARAMETROS INTO @nEstadoSelec, @nRGPRINT, @nIMPASI,  
 @nAllowRprt, @nRPRTTXT, @nUNPSTDTXT, @cFrmBchNum, 
 @cFrmVendID, @dFrmDate, @nFrmEntTyp, @cFrmNbrIE,  
 @cFrmTypIE, @cToBchNum, @cToVendID, @nToEntTyp, @cToNbrIE, @cToTypIE, @dToDate, @MediosOrRetencion  
WHILE (@@FETCH_STATUS=0)     
BEGIN   
 FETCH NEXT FROM PARAMETROS INTO @nEstadoSelec, @nRGPRINT, @nIMPASI,  
  @nAllowRprt, @nRPRTTXT, @nUNPSTDTXT, @cFrmBchNum, 
  @cFrmVendID, @dFrmDate, @nFrmEntTyp, @cFrmNbrIE,  
  @cFrmTypIE, @cToBchNum, @cToVendID, @nToEntTyp, @cToNbrIE, @cToTypIE, @dToDate, @MediosOrRetencion 
END 
CLOSE PARAMETROS 
DEALLOCATE PARAMETROS 
DELETE nfMCP_PM70200 WHERE USERID = @cUSERID 
DELETE nfMCP_PM70300 WHERE USERID = @cUSERID 
SELECT @nFrmStatus = case @nEstadoSelec WHEN 0 THEN 2 ELSE 1 END 
SELECT @nToStatus = case @nEstadoSelec WHEN 1 THEN 1 ELSE 2 END
IF @cToBchNum = '' 
BEGIN 
SELECT @cToBchNum = REPLICATE('z',15)   
END 
IF @cToVendID = ''  
BEGIN 
SELECT @cToVendID = REPLICATE('z',15) 
END 
IF @nToEntTyp = 0  
BEGIN 
SELECT @nToEntTyp = 3  
END 
IF @cToNbrIE = ''  
BEGIN  
SELECT @cToNbrIE = REPLICATE('z',21)  
END 
IF @cToTypIE = ''  
BEGIN 
SELECT @cToTypIE = REPLICATE('z',21) 
END 
IF @dToDate = '1/1/1900'   
BEGIN  
SELECT @dToDate = '12/31/2099'  
END 

BEGIN 
 DECLARE PAGOS CURSOR FOR SELECT NUMBERIE, VENDORID FROM (SELECT 2 AS MCPSTATUS, NUMBERIE, DOCDATE, nfMCP_Printing_Number,  
   TRXDSCRN, ENTITY, VOIDSTTS, 0 AS Status, PRINTED,  
   CASE ENTITY WHEN 1 THEN NFENTID ELSE '' END AS VENDORID, 
   CASE ENTITY WHEN 3 THEN NFENTID ELSE '' END AS BANACTID, 
   CASE ENTITY WHEN 1 THEN VENDNAME WHEN 2 THEN 'Pagos Varios'  
   ELSE C.DSCRIPTN END AS VENDNAME, BACHNUMB, MCPTYPID 
  FROM nfMCP_PM20000 A LEFT OUTER JOIN PM00200 B 
   ON A.NFENTID = B.VENDORID 
   LEFT OUTER JOIN nfMCP00400 C 
   ON A.NFENTID = C.BANACTID  
  UNION 
  SELECT 1 AS MCPSTATUS, NUMBERIE, DOCDATE, nfMCP_Printing_Number,  
   TRXDSCRN, ENTITY, 0 AS VOIDSTTS, 0 AS Status, PRINTED,  
   CASE ENTITY WHEN 1 THEN NFENTID ELSE '' END AS VENDORID, 
   CASE ENTITY WHEN 3 THEN NFENTID ELSE '' END AS BANACTID, 
   CASE ENTITY WHEN 1 THEN VENDNAME WHEN 2 THEN 'Pagos Varios'  
   ELSE C.DSCRIPTN END AS VENDNAME, BACHNUMB, MCPTYPID 
  FROM nfMCP_PM10000 A LEFT OUTER JOIN PM00200 B 
   ON A.NFENTID = B.VENDORID 
   LEFT OUTER JOIN nfMCP00400 C 
   ON A.NFENTID = C.BANACTID) D 
  WHERE NUMBERIE >= @cFrmNbrIE AND NUMBERIE <= @cToNbrIE AND  
   MCPSTATUS >= @nFrmStatus AND MCPSTATUS <= @nToStatus AND 
   BACHNUMB >= @cFrmBchNum AND BACHNUMB <= @cToBchNum AND 
   VENDORID >= @cFrmVendID AND VENDORID <= @cToVendID AND  
   ENTITY >= @nFrmEntTyp AND ENTITY <= @nToEntTyp AND 
   MCPTYPID >= @cFrmTypIE AND MCPTYPID <= @cToTypIE AND 
   DOCDATE >= @dFrmDate AND DOCDATE <= @dToDate AND 
   PRINTED <= @nAllowRprt  
 SELECT @cPrevVoucher = '' 
 OPEN PAGOS 
 FETCH NEXT FROM PAGOS INTO @cVCHRNMBR, @cVENDORID 
 WHILE (@@FETCH_STATUS=0)     
  BEGIN  
   SELECT @nCOUNTER = @nCOUNTER + 1 
   if @cVCHRNMBR <> @cPrevVoucher 
   BEGIN 
    IF @MediosOrRetencion = 0
    BEGIN
     EXECUTE nfMCP_RunReportOPMedio @nCOMPANYID, @cVCHRNMBR, @cVENDORID, @nIMPASI,   @cUSERID, @nRGPRINT 
    END
    ELSE
    BEGIN
     EXECUTE nfMCP_RunReportOP @nCOMPANYID, @cVCHRNMBR, @cVENDORID, @nIMPASI,   @cUSERID, @nRGPRINT 
    END
    SELECT @cPrevVoucher = @cVCHRNMBR 
   END 
   FETCH NEXT FROM PAGOS INTO @cVCHRNMBR, @cVENDORID 
  END 
 CLOSE  PAGOS  
 DEALLOCATE PAGOS 
END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfMCP_RunMassReportOP] TO [DYNGRP] 
GO 

/*End_nfMCP_RunMassReportOP*/
/*Begin_nfMCP_Update_nfRET_GL10020_PRNT*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfMCP_Update_nfRET_GL10020_PRNT]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfMCP_Update_nfRET_GL10020_PRNT]
GO

CREATE PROCEDURE [dbo].[nfMCP_Update_nfRET_GL10020_PRNT]  
@cVCHRNMBR char(21) AS 
UPDATE nfRET_GL10020 
 SET PRINTED = 1 
 WHERE APFRDCNM = @cVCHRNMBR 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfMCP_Update_nfRET_GL10020_PRNT] TO [DYNGRP] 
GO 

/*End_nfMCP_Update_nfRET_GL10020_PRNT*/
/*Begin_nfMCP_Update_nfRET_GL70031*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfMCP_Update_nfRET_GL70031]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfMCP_Update_nfRET_GL70031]
GO

CREATE PROCEDURE [dbo].[nfMCP_Update_nfRET_GL70031]  
@cVCHRNMBR char(21), @cUSERID char(15) AS 
IF @cVCHRNMBR = '' 
BEGIN 
 UPDATE nfRET_GL70031 
  SET VOIDSTTS = p.VOIDSTTS, Status = 2 
  FROM nfMCP_PM20000 p, nfRET_GL70031 r  
  WHERE p.NUMBERIE = r.APFRDCNM AND r.USERID = @cUSERID 
 UPDATE nfRET_GL70031 
  SET nfRET_GL70031.VOIDSTTS = 0,  nfRET_GL70031.Status = 1  
  FROM nfMCP_PM10000 p, nfRET_GL70031 r 
  WHERE p.NUMBERIE = r.APFRDCNM AND r.USERID = @cUSERID 
END 
ELSE 
 IF EXISTS (SELECT NUMBERIE FROM nfMCP_PM20000 INNER JOIN nfRET_GL70031  
   ON nfRET_GL70031.APFRDCNM = nfMCP_PM20000.NUMBERIE  
   WHERE nfRET_GL70031.APFRDCNM = @cVCHRNMBR AND nfRET_GL70031.USERID = @cUSERID) 
  UPDATE nfRET_GL70031 
   SET VOIDSTTS = p.VOIDSTTS, Status = 2 
   FROM nfMCP_PM20000 p, nfRET_GL70031 r 
   WHERE p.NUMBERIE = r.APFRDCNM AND r.USERID = @cUSERID 
 ELSE 
  UPDATE nfRET_GL70031 
   SET nfRET_GL70031.VOIDSTTS = 0,  nfRET_GL70031.Status = 1 
   FROM nfRET_GL70031 r 
   WHERE r.USERID = @cUSERID AND r.APFRDCNM = @cVCHRNMBR 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfMCP_Update_nfRET_GL70031] TO [DYNGRP] 
GO 

/*End_nfMCP_Update_nfRET_GL70031*/
/*Begin_spFill_Cartera_Cliente_TEMP*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spFill_Cartera_Cliente_TEMP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spFill_Cartera_Cliente_TEMP]
GO

CREATE PROCEDURE spFill_Cartera_Cliente_TEMP @I_cCustomer char(15) = NULL, @I_cMedioID char(20) = NULL, @I_cTableName char(25) = NULL, @O_SQL_Error_State int = NULL  output as declare @vInsertStatement1 varchar(255) select @O_SQL_Error_State = 0 if exists (select * from sysobjects where id =   Object_id('#MyTempTable') and type in ('U','S')) begin drop table #MyTempTable end create table #MyTempTable (MEDIOID char(21), LNSEQNBR numeric(19,5), BANKID char(15), DOCNUMBR char(21), BANACTID char(21), INDATE datetime, DUEDATE datetime, EMIDATE datetime, OUTDATE datetime, IMPORTE numeric(19,5), INGTYPE char(21), INGNUMB char(21), EGRTYPE char(21), EGRNUMB char(21), CARTSTAT smallint, CUSTNMBR char(15), VENDORID char(15), LOCATNNM char(31), DIFPOST tinyint, ORDOCAMT numeric(19,5), Process_Date datetime, TII_MCP_Clearing smallint, TII_ORIGCH smallint, TII_DESTCH smallint, ORGTRXAMT char(25), CURRID varchar(15), TII_SucursalBancoID varchar(15)) INSERT INTO #MyTempTable  SELECT nfMCP10200.MEDIOID, nfMCP10200.LNSEQNBR, nfMCP10200.BANKID, nfMCP10200.DOCNUMBR, nfMCP10200.BANACTID, nfMCP10200.INDATE, nfMCP10200.DUEDATE, nfMCP10200.EMIDATE, nfMCP10200.OUTDATE, nfMCP10200.IMPORTE, nfMCP10200.INGTYPE, nfMCP10200.INGNUMB, nfMCP10200.EGRTYPE, nfMCP10200.EGRNUMB, nfMCP10200.CARTSTAT, nfMCP10200.CUSTNMBR, nfMCP10200.VENDORID, nfMCP10200.LOCATNNM, nfMCP10200.DIFPOST, nfMCP10200.ORDOCAMT, nfMCP10200.Process_Date, nfMCP10200.TII_MCP_Clearing, nfMCP10200.TII_ORIGCH, nfMCP10200.TII_DESTCH, nfMCP10200.ORDOCAMT, 0 as CURRID,' '  TII_SucursalBancoID/*nfMCP10200.TII_SucursalBancoID*/  FROM dbo.nfMCP10200 WHERE nfMCP10200.CARTSTAT <= 2 AND nfMCP10200.CUSTNMBR = @I_cCustomer AND nfMCP10200.MEDIOID = @I_cMedioID select @vInsertStatement1 = 'insert into ' + @I_cTableName + ' SELECT * from #MyTempTable'  exec (@vInsertStatement1) 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[spFill_Cartera_Cliente_TEMP] TO [DYNGRP] 
GO 

/*End_spFill_Cartera_Cliente_TEMP*/
/*Begin_spFill_nfMCP_Select_Cartera_TEMP*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spFill_nfMCP_Select_Cartera_TEMP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spFill_nfMCP_Select_Cartera_TEMP]
GO

CREATE PROCEDURE spFill_nfMCP_Select_Cartera_TEMP 
@I_cMedioID varchar(21) = NULL, 
@iENTTYP int, 
@I_cMonedaID varchar(15) = NULL, 
@I_cTableName varchar(25) = NULL,
@I_UserID varchar(25),
@O_SQL_Error_State int = NULL  output as 
declare @vInsertStatement1 varchar(8000) 
select @vInsertStatement1 = 'delete from ' + @I_cTableName + ' '
exec (@vInsertStatement1)
select @O_SQL_Error_State = 0  
select @vInsertStatement1 = 'declare @FUNLCURR char(15) '
select @vInsertStatement1 = @vInsertStatement1 + 'select @FUNLCURR = FUNLCURR from MC40000 '
select @vInsertStatement1 = @vInsertStatement1 + 'INSERT INTO ' + @I_cTableName + ' ' 
select @vInsertStatement1 = @vInsertStatement1 + 'SELECT A.MEDIOID, A.LNSEQNBR, A.BANKID, A.DOCNUMBR, A.BANACTID,  A.INDATE, A.DUEDATE, A.EMIDATE, A.OUTDATE, A.IMPORTE, A.INGTYPE, 
A.INGNUMB, A.EGRTYPE, A.EGRNUMB, case when A.USERID = ''' + @I_UserID + ''' then ''2'' else ''1''    END AS CARTSTAT , A.CUSTNMBR,  A.VENDORID, 
A.LOCATNNM,  A.DIFPOST, A.ORDOCAMT, A.Process_Date, A.TII_MCP_Clearing,  A.TII_ORIGCH, A.TII_DESTCH,  '
select @vInsertStatement1 = @vInsertStatement1 + 'ORCTRXAM = case when ltrim(rtrim(@FUNLCURR)) <> ''' + @I_cMonedaID + ''' then A.ORDOCAMT else A.IMPORTE end,'
select @vInsertStatement1 = @vInsertStatement1 + 'B.CURNCYID, '
select @vInsertStatement1 = @vInsertStatement1 + 'A.TII_SucursalBancoID   FROM '
select @vInsertStatement1 = @vInsertStatement1 + 'dbo.nfMCP10200 A inner join nfMCP00700 B on A.MEDIOID = B.MEDIOID '
select @vInsertStatement1 = @vInsertStatement1 + 'WHERE A.MEDIOID = ''' + @I_cMedioID + ''' AND (A.CARTSTAT = 1 or (A.CARTSTAT = 2 and A.USERID <> '''') ) '
exec (@vInsertStatement1)
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[spFill_nfMCP_Select_Cartera_TEMP] TO [DYNGRP] 
GO 

/*End_spFill_nfMCP_Select_Cartera_TEMP*/
/*Begin_TII_FILL_TEMP_TABLE_DIFFERED_CHECKS*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TII_FILL_TEMP_TABLE_DIFFERED_CHECKS]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TII_FILL_TEMP_TABLE_DIFFERED_CHECKS]
GO

CREATE PROCEDURE TII_FILL_TEMP_TABLE_DIFFERED_CHECKS 
@TableName char(9), @FechaDesde datetime, @FechaHasta datetime  AS 
EXEC ('DELETE FROM ' + @TableName)
EXEC ('INSERT INTO ' + @TableName + ' SELECT nfMCP10200.MEDIOID, nfMCP10200.LNSEQNBR, nfMCP10200.BANKID, nfMCP10200.DOCNUMBR, nfMCP10200.BANACTID, INDATE, nfMCP10200.DUEDATE, nfMCP10200.EMIDATE, 
OUTDATE, IMPORTE, INGTYPE, INGNUMB, EGRTYPE, EGRNUMB, CARTSTAT, CUSTNMBR, VENDORID, LOCATNNM, DIFPOST, ORDOCAMT, 
Process_Date, TII_MCP_Accrued_Unrealiz, TII_MCP_Last_Revaluation, TII_MCP_Last_RevalTime, TII_MCP_Last_Unrealized_, 
nfMCP10200.TII_MCP_Clearing, TII_MCP_Comp_Canje, nfMCP10200.TXRGNNUM, TII_ORIGCH, TII_DESTCH, TII_SucursalBancoID, 0, nfMCP_PM20100.CURNCYID , nfMCP_PM20100.CHEKBKID, nfMCP_PM20100.CURRNIDX 
FROM nfMCP10200 INNER JOIN nfMCP_PM20100 ON nfMCP10200.MEDIOID = nfMCP_PM20100.MEDIOID  AND nfMCP10200.DOCNUMBR = nfMCP_PM20100.DOCNUMBR AND nfMCP10200.BANACTID = nfMCP_PM20100.BANACTID AND
nfMCP10200.CHEKBKID = nfMCP_PM20100.CHEKBKID WHERE CARTSTAT = 5 AND (nfMCP10200.DUEDATE >=''' + @FechaDesde + ''') AND 
nfMCP10200.DUEDATE <= ''' + @FechaHasta + '''') 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[TII_FILL_TEMP_TABLE_DIFFERED_CHECKS] TO [DYNGRP] 
GO 

/*End_TII_FILL_TEMP_TABLE_DIFFERED_CHECKS*/
/*Begin_TII_MARK_UNMARK_DIFFERED_CHECKS*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TII_MARK_UNMARK_DIFFERED_CHECKS]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TII_MARK_UNMARK_DIFFERED_CHECKS]
GO

CREATE PROCEDURE TII_MARK_UNMARK_DIFFERED_CHECKS 
@TableName char(9), @Option smallint, @FechaProceso datetime , @Query smallint, @Where varchar(4000) AS 
DECLARE @Fecha as char(10) 
SET DATEFORMAT mdy 
IF (@Option = 0) 
 BEGIN 
  IF(@Query = 1) 
   BEGIN 
    EXEC  ('UPDATE ' + @TableName +  
     ' SET ' + @TableName + '.Marcado = 1, ' + @TableName + '.CURNCYID = nfMCP_PM20100.CURNCYID  
     FROM nfMCP_PM20100 INNER JOIN ' + @TableName + ' ON  
     (nfMCP_PM20100.MCPTYPID = ' + @TableName + '.EGRTYPE AND 
      nfMCP_PM20100.NUMBERIE = ' + @TableName + '.EGRNUMB AND 
      nfMCP_PM20100.MEDIOID = ' + @TableName + '.MEDIOID AND 
      nfMCP_PM20100.LNSEQNBR = ' + @TableName + '.LNSEQNBR)') 
   END 
  ELSE 
   BEGIN 
    EXEC  ('UPDATE ' + @TableName +  
     ' SET ' + @TableName + '.Marcado = 1, ' + @TableName + '.CURNCYID = nfMCP_PM20100.CURNCYID  
     FROM nfMCP_PM20100 INNER JOIN ' + @TableName + ' ON  
     (nfMCP_PM20100.MCPTYPID = ' + @TableName + '.EGRTYPE AND 
      nfMCP_PM20100.NUMBERIE = ' + @TableName + '.EGRNUMB AND 
      nfMCP_PM20100.MEDIOID = ' + @TableName + '.MEDIOID AND 
      nfMCP_PM20100.LNSEQNBR = ' + @TableName + '.LNSEQNBR) where ' + @Where ) 
   END 
  SET @Fecha = CONVERT (CHAR(10), @FechaProceso,101) 
  EXEC (' UPDATE nfMCP10200 
          SET nfMCP10200.DIFPOST = 1, nfMCP10200.Process_Date = ''' + @Fecha +   
       ''' FROM ' + @TableName + ' INNER JOIN nfMCP10200 ON  
       ( ' + @TableName + '.EGRTYPE = nfMCP10200.EGRTYPE AND ' 
       + @TableName + '.EGRNUMB = nfMCP10200.EGRNUMB AND ' 
       + @TableName + '.MEDIOID = nfMCP10200.MEDIOID AND ' 
       + @TableName + '.LNSEQNBR = nfMCP10200.LNSEQNBR) 
       WHERE ' + @TableName + '.Marcado = 1')  
 END 
ELSE 
 BEGIN 
  EXEC ('UPDATE nfMCP10200 
         SET nfMCP10200.DIFPOST = 0, nfMCP10200.Process_Date = 0  
      FROM ' + @TableName + ' INNER JOIN nfMCP10200 ON  
      ( ' + @TableName + '.EGRTYPE = nfMCP10200.EGRTYPE AND ' 
      + @TableName + '.EGRNUMB = nfMCP10200.EGRNUMB AND ' 
      + @TableName + '.MEDIOID = nfMCP10200.MEDIOID AND ' 
      + @TableName + '.LNSEQNBR = nfMCP10200.LNSEQNBR) 
      WHERE ' + @TableName + '.Marcado = 1')  
  IF(@Query = 1) 
   BEGIN 
    EXEC ('UPDATE ' + @TableName + 
          ' SET ' + @TableName + '.Marcado = 0 
          FROM nfMCP_PM20100 INNER JOIN ' + @TableName +' ON  
       (nfMCP_PM20100.MCPTYPID = ' + @TableName +'.EGRTYPE AND 
       nfMCP_PM20100.NUMBERIE = ' + @TableName + '.EGRNUMB AND 
       nfMCP_PM20100.MEDIOID = ' + @TableName + '.MEDIOID AND 
       nfMCP_PM20100.LNSEQNBR = ' + @TableName + '.LNSEQNBR)   
          WHERE ' + @TableName + '.Marcado = 1') 
   END 
  ELSE 
   BEGIN 
    EXEC ('UPDATE ' + @TableName + 
          ' SET ' + @TableName + '.Marcado = 0 
          FROM nfMCP_PM20100 INNER JOIN ' + @TableName +' ON  
       (nfMCP_PM20100.MCPTYPID = ' + @TableName +'.EGRTYPE AND 
       nfMCP_PM20100.NUMBERIE = ' + @TableName + '.EGRNUMB AND 
       nfMCP_PM20100.MEDIOID = ' + @TableName + '.MEDIOID AND 
       nfMCP_PM20100.LNSEQNBR = ' + @TableName + '.LNSEQNBR)   
         WHERE ' + @TableName + '.Marcado = 1 and ' + @Where  ) 
   END 
 END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[TII_MARK_UNMARK_DIFFERED_CHECKS] TO [DYNGRP] 
GO 

/*End_TII_MARK_UNMARK_DIFFERED_CHECKS*/
/*Begin_TII_MCP_Filtrar2_Cartera*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TII_MCP_Filtrar2_Cartera]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TII_MCP_Filtrar2_Cartera]
GO

CREATE PROCEDURE TII_MCP_Filtrar2_Cartera
@I_IDMedio char(21) = NULL, 
@I_cTableName char(25) = NULL,
@I_entitytype smallint, 
@I_desdedate datetime, 
@I_hastadate datetime, 
@I_desdedate1 datetime, 
@I_hastadate1 datetime, 
@I_desdedate2 datetime, 
@I_hastadate2 datetime, 
@I_desdebank char(15), 
@I_hastabank char(15), 
@I_desdeimporte numeric(19,5), 
@I_hastaimporte numeric(19,5), 
@I_desdeimporte1 numeric(19,5), 
@I_hastaimporte1 numeric(19,5), 
@I_desdecliente char(15), 
@I_hastacliente char(15), 
@I_desdecheque smallint, 
@I_hastacheque smallint, 
@I_desdesucursal char(15), 
@I_hastasucursal char(15), 
@I_IDMoneda char(15), 
@I_docdate datetime, 
@desdeclearing smallint,
@hastaclearing smallint,
@I_UserID varchar(25),
@O_SQL_Error_State int = NULL  output 
as 
DECLARE @Consulta varchar(8000) 
 SET @Consulta = 'DECLARE @FUNLCURR char(15) '

 SET @Consulta = @Consulta + ' select @FUNLCURR = FUNLCURR from MC40000' + char(13)
SET DATEFORMAT mdy 
 SET @Consulta = @Consulta + 'DECLARE @I_entitytype2 as smallint ' 
 SET @Consulta = @Consulta + 'SET @I_entitytype2 = ' + CAST(@I_entitytype AS CHAR(1)) + char(13)
 SET @Consulta = @Consulta + 'SET DATEFORMAT mdy ' 
 SET @Consulta = @Consulta + ' INSERT INTO ' +  @I_cTableName 
 SET @Consulta = @Consulta + ' Select A.MEDIOID, A.LNSEQNBR, A.BANKID, A.DOCNUMBR, A.BANACTID, A.INDATE, '  
 SET @Consulta = @Consulta + 'A.DUEDATE, A.EMIDATE, A.OUTDATE, A.IMPORTE, A.INGTYPE, A.INGNUMB, A.EGRTYPE, A.EGRNUMB, case when A.USERID = ''' + @I_UserID + ''' then ''2'' else ''1''    END AS CARTSTAT, ' 
 SET @Consulta = @Consulta + 'A.CUSTNMBR, A.VENDORID, A.LOCATNNM, A.DIFPOST, A.ORDOCAMT, A.Process_Date, A.TII_MCP_Clearing, ' 
 SET @Consulta = @Consulta + 'A.TII_ORIGCH, A.TII_DESTCH, CASE WHEN @FUNLCURR = ''' + @I_IDMoneda + ''' then A.IMPORTE else A.ORDOCAMT end,   CASE WHEN @FUNLCURR = ''' + @I_IDMoneda + ''' then @FUNLCURR else ''' + @I_IDMoneda + ''' end, A.TII_SucursalBancoID ' 
 SET @Consulta = @Consulta + ' from nfMCP10200 A  INNER JOIN nfMCP00700 D ON A.MEDIOID = D.MEDIOID' 
 SET @Consulta = @Consulta + '  where (A.CARTSTAT = 1 or (A.CARTSTAT = 2 and A.USERID <> '''') ) and ' 
 SET @Consulta = @Consulta + ' convert (varbinary(21),A.MEDIOID) = ''' +  @I_IDMedio + ''' and ' 
 SET @Consulta = @Consulta + ' A.DUEDATE >= ''' + convert(varchar(10), @I_desdedate ,101) + ''' and ' 
 SET @Consulta = @Consulta + ' A.DUEDATE <= ''' + convert(varchar(10), @I_hastadate ,101) + ''' and ' 
 SET @Consulta = @Consulta + ' A.INDATE >= ''' + convert(varchar(10), @I_desdedate1,101) + ''' and ' 
 SET @Consulta = @Consulta + ' A.INDATE  <= ''' + convert(varchar(10), @I_hastadate1,101) + ''' and ' 
 SET @Consulta = @Consulta + ' A.EMIDATE >= ''' + convert(varchar(10), @I_desdedate2,101) + ''' and ' 
 SET @Consulta = @Consulta + ' A.EMIDATE <= ''' + convert(varchar(10), @I_hastadate2,101) + ''' and ' 
 SET @Consulta = @Consulta + ' convert(varbinary(15),A.BANKID) >= '''  +  @I_desdebank  + ''' and ' 
 SET @Consulta = @Consulta + ' convert(varbinary(15),A.BANKID) <= ''' +  @I_hastabank + ''' and ' 
 SET @Consulta = @Consulta + ' convert(varbinary(15),A.CUSTNMBR) >= '''  +  @I_desdecliente  + ''' and ' 
 SET @Consulta = @Consulta + ' convert(varbinary(15),A.CUSTNMBR) <= ''' +  @I_hastacliente + ''' and ' 
 SET @Consulta = @Consulta + ' convert(varbinary(15),A.TII_SucursalBancoID) >= '''  +  @I_desdesucursal  + ''' and ' 
 SET @Consulta = @Consulta + ' convert(varbinary(15),A.TII_SucursalBancoID) <= ''' +  @I_hastasucursal + ''' and ' 
 SET @Consulta = @Consulta + ' A.IMPORTE >= ' + cast(@I_desdeimporte as varchar(70)) + ' and A.IMPORTE <= ' +  cast(@I_hastaimporte as varchar(70)) + ' and ' 
 SET @Consulta = @Consulta + ' CASE WHEN @FUNLCURR = ''' + @I_IDMoneda + ''' then A.IMPORTE else A.ORDOCAMT end  >= ' + cast (@I_desdeimporte1 as varchar(70)) + ' and  CASE WHEN @FUNLCURR = ''' + @I_IDMoneda + ''' then A.IMPORTE else A.ORDOCAMT end <= ' +  cast(@I_hastaimporte1 as varchar(70)) + ' and ' 
 SET @Consulta = @Consulta + ' A.TII_ORIGCH >= ' + RTRIM(CAST(@I_desdecheque AS CHAR(5))) + ' and A.TII_ORIGCH <= ' +  RTRIM(CAST(@I_hastacheque AS CHAR(5))) + ' and ' 
 SET @Consulta = @Consulta + ' A.TII_MCP_Clearing >=  '+ str(@desdeclearing) +'  and A.TII_MCP_Clearing <= ' +  str(@hastaclearing) + ' and ' 
 SET @Consulta = @Consulta + ' CASE WHEN @FUNLCURR = ''' + @I_IDMoneda + ''' then @FUNLCURR else ''' + @I_IDMoneda + ''' end  = ''' + @I_IDMoneda + ''''
 SET @Consulta = @Consulta + ' AND ((@I_entitytype2=3 AND A.DUEDATE <= ''' + convert(varchar(10), @I_docdate ,101) + ''' AND '
 SET @Consulta = @Consulta + ' D.TII_Diferido = 1) OR D.TII_Diferido = 0 OR '
 SET @Consulta = @Consulta + ' @I_entitytype2 <> 3) '
 EXEC(@Consulta); 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[TII_MCP_Filtrar2_Cartera] TO [DYNGRP] 
GO 

/*End_TII_MCP_Filtrar2_Cartera*/
/*Begin_TII_PMCheckLinks_AFTER*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TII_PMCheckLinks_AFTER]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TII_PMCheckLinks_AFTER]
GO

 CREATE PROCEDURE TII_PMCheckLinks_AFTER AS
DELETE PM10400 WHERE BCHSOURC = 'TII_Delete' 
DELETE PM00400 WHERE BCHSOURC = 'TII_Delete' 
DELETE PM20000 WHERE BCHSOURC = 'TII_Delete' 
 
UPDATE PM20100  
SET KEYSOURC = RTRIM(A.VCHRNMBR) + '6' 
FROM PM20100 A, nfMCP_PM10000 B 
WHERE A.VCHRNMBR = B.NUMBERIE AND A.DOCTYPE = B.DOCTYPE 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[TII_PMCheckLinks_AFTER] TO [DYNGRP] 
GO 

/*End_TII_PMCheckLinks_AFTER*/
/*Begin_TII_PMCheckLinks_BEFORE*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TII_PMCheckLinks_BEFORE]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TII_PMCheckLinks_BEFORE]
GO

 CREATE PROCEDURE TII_PMCheckLinks_BEFORE AS

INSERT INTO PM10400  
SELECT A.BACHNUMB, 'TII_Delete' AS BCHSOURC, A.NUMBERIE, CASE A.NFENTID WHEN '' THEN 'VARIOS' ELSE A.NFENTID END, A.NUMBERIE, 9, 
A.DOCAMNT, A.DOCDATE, A.PSTGDATE, 0, 0, '',  A.CURNCYID, '', A.TRXDSCRN, A.DISAMTAV, A.DISTKNAM, A.WROFAMNT,   
A.CURTRXAM, A.APPLDAMT, A.PMWRKMSG, CONVERT(binary,'') AS PMWRKMS2, A.PMDSTMSG, A.GSTDSAMT, A.PPSAMDED,  
A.PPSTAXRT, A.PGRAMSBJ, A.NOTEINDX, A.NUMBERIE, A.CNTRLTYP, A.MODIFDT, A.MDFUSRID, A.POSTEDDT, A.PTDUSRID, 0, 0, '' 
FROM    nfMCP_PM10000 A LEFT OUTER JOIN PM10400 C  
ON A.NUMBERIE = C.PMNTNMBR   
WHERE C.PMNTNMBR IS NULL  
 
INSERT INTO PM00400 
SELECT A.NUMBERIE, 1 AS CNTRLTYP, 2 AS DCSTATUS, A.DOCTYPE, A.NFENTID, A.NUMBERIE AS DOCNUMBR, B.TRXSORCE,   
'' AS CHEKBKID, 0 AS DUEDATE, 0 AS DISCDATE,  'TII_Delete' AS BCHSOURC, A.DOCDATE, A.MDFUSRID   
FROM   nfMCP_PM20000 A INNER JOIN (SELECT VCHRNMBR, CNTRLTYP, TRXSORCE FROM PM10100 GROUP BY VCHRNMBR, CNTRLTYP, TRXSORCE) B  
ON A.NUMBERIE = B.VCHRNMBR AND A.CNTRLTYP = B.CNTRLTYP      
LEFT OUTER JOIN PM00400 C ON A.NUMBERIE = C.CNTRLNUM AND C.CNTRLTYP = 1    
WHERE C.CNTRLTYP IS NULL AND A.ENTITY <> 1 
 
INSERT INTO PM20000(VCHRNMBR,VENDORID,DOCTYPE,DOCDATE,DOCNUMBR,DOCAMNT,CURTRXAM,
DISTKNAM,DISCAMNT,DSCDLRAM,BACHNUMB,TRXSORCE,BCHSOURC,DISCDATE,DUEDATE,PORDNMBR,
TEN99AMNT,WROFAMNT,DISAMTAV,TRXDSCRN,UN1099AM,BKTPURAM,BKTFRTAM,BKTMSCAM,VOIDED,
HOLD,CHEKBKID,DINVPDOF,PPSAMDED,PPSTAXRT,PGRAMSBJ,GSTDSAMT,POSTEDDT,PTDUSRID,MODIFDT,
MDFUSRID,PYENTTYP,CARDNAME,PRCHAMNT,TRDISAMT,MSCCHAMT,FRTAMNT,TAXAMNT,TTLPYMTS,CURNCYID,
PYMTRMID,SHIPMTHD,TAXSCHID,PCHSCHID,FRTSCHID,MSCSCHID,PSTGDATE,DISAVTKN,CNTRLTYP,NOTEINDX,
PRCTDISC,RETNAGAM,ICTRX,Tax_Date,PRCHDATE,CORRCTN,SIMPLIFD,BNKRCAMT,APLYWITH,Electronic,
ECTRX,DocPrinted,TaxInvReqd,VNDCHKNM,BackoutTradeDisc) 
SELECT A.NUMBERIE,  
CASE A.NFENTID WHEN '' THEN 'VARIOS' ELSE A.NFENTID END,  
A.DOCTYPE, A.DOCDATE, A.NUMBERIE AS DOCNUMBR, A.DOCAMNT, A.CURTRXAM,   
A.DISTKNAM, 0 AS DISCAMNT, 0 AS DSCDLRAM, A.BACHNUMB, B.TRXSORCE, 'TII_Delete' AS BCHSOURC,    
0 AS DISCDATE, 0 AS DUEDATE, '' AS PORDNMBR, 0 AS TEN99AMNT,    
A.WROFAMNT, A.DISAMTAV, A.TRXDSCRN, 0 AS UN1099AM, 0 AS BKTPURAM, 0 AS BKTFRTAM, 0 AS BKTMSCAM,  
A.VOIDSTTS, 0 AS HOLD, '' AS CHEKBKID, 0 DINVPDOF, A.PPSAMDED, A.PPSTAXRT, A.PGRAMSBJ,    
A.GSTDSAMT, A.POSTEDDT, A.PTDUSRID, A.MODIFDT, A.MDFUSRID, A.PYENTTYP, '' AS CARDNAME, 0 AS PRCHAMNT,  
0 AS TRDISAMT, 0 AS MSCCHAMT, 0 AS FRTAMNT, 0 AS TAXAMNT, 0 AS TTLPYMTS, A.CURNCYID,    
'' AS PYMTRMID, '' AS SHIPMTHD, '' AS TAXSCHID, '' AS PCHSCHID, '' AS FRTSCHID, '' AS MSCSCHID,  
A.PSTGDATE, 0 AS DISAVTKN, A.CNTRLTYP, A.NOTEINDX, 0 AS PRCTDISC, 0 AS RETNAGAM, 0 AS ICTRX,   
0 AS Tax_Date, 0 AS PRCHDATE, 0 AS CORRCTN, 0 AS SIMPLIFD, 0 AS BNKRCAMT, 0 AS APLYWITH,    
0 AS Electronic, 0 AS ECTRX, 0 AS DocPrinted, 0 AS TaxInvReqd, '' AS VNDCHKNM, 0 AS BackoutTradeDisc   
FROM nfMCP_PM20000 A INNER JOIN  
(SELECT VCHRNMBR, CNTRLTYP, TRXSORCE FROM PM10100 GROUP BY VCHRNMBR, CNTRLTYP, TRXSORCE) B  
ON A.NUMBERIE = B.VCHRNMBR AND A.CNTRLTYP = B.CNTRLTYP   
LEFT OUTER JOIN PM20000 C ON C.DOCTYPE = A.DOCTYPE AND C.DOCNUMBR = A.NUMBERIE   
WHERE C.VENDORID IS NULL AND A.ENTITY <> 1 
 AND A.VOIDSTTS <> 1 
 
UPDATE PM20100  
SET KEYSOURC = 'REMITTANCE' 
FROM PM20100 A, nfMCP_PM10000 B 
WHERE A.VCHRNMBR = B.NUMBERIE AND A.DOCTYPE = B.DOCTYPE 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[TII_PMCheckLinks_BEFORE] TO [DYNGRP] 
GO 

/*End_TII_PMCheckLinks_BEFORE*/
/*Begin_TII_RMCheckLinks_AFTER*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TII_RMCheckLinks_AFTER]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TII_RMCheckLinks_AFTER]
GO

 CREATE PROCEDURE TII_RMCheckLinks_AFTER AS
DELETE RM10201 WHERE BCHSOURC = 'nfMCP_Cash' 
DELETE RM00401 WHERE BCHSOURC = 'TII_Delete' 
DELETE RM20101 WHERE BCHSOURC = 'TII_Delete' 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[TII_RMCheckLinks_AFTER] TO [DYNGRP] 
GO 

/*End_TII_RMCheckLinks_AFTER*/
/*Begin_TII_RMCheckLinks_BEFORE*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TII_RMCheckLinks_BEFORE]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TII_RMCheckLinks_BEFORE]
GO

 CREATE PROCEDURE TII_RMCheckLinks_BEFORE AS
INSERT INTO RM10201 (BACHNUMB,BCHSOURC,DOCNUMBR,CUSTNMBR,RMDTYPAL,DOCDATE,CSHRCTYP,CHEKNMBR,CHEKBKID,CRCARDID,DISAMCHK,CURNCYID,NDSTAMNT,TRXDSCRN,
ONHOLD,POSTED,NOTEINDX,LSTEDTDT,LSTUSRED,ORTRXAMT,CURTRXAM,WROFAMNT,DISTKNAM,DISAVTKN,PPSAMDED,GSTDSAMT,RMTREMSG,RMDPEMSG,GLPOSTDT,RMTREMSG2,PSTGSTUS)
SELECT A.BACHNUMB, A.BCHSOURC, NUMBERIE, NFENTID, A.RMDTYPAL, A.DOCDATE, 0 AS CSHRCTYP, 
'' AS CHEKNMBR, '' AS CHEKBKID, '' AS CRCARDID, 0 AS DISAMCHK, A.CURNCYID, 0 AS NDSTAMNT, 
'' AS TRXDSCRN, 0 AS ONHOLD, 0 AS POSTED, 0 AS NOTEINDX, A.LSTEDTDT, A.LSTUSRED,  
TOTAMNT AS ORTRXAMT, A.CURTRXAM, A.WROFAMNT, A.DISTKNAM, A.DISAVTKN, 0 AS PPSAMDED, 
0 AS GSTDSAMT, A.RMTREMSG, A.RMDPEMSG, A.GLPOSTDT, CONVERT(binary,'') AS RMTREMSG2, 20 AS PSTGSTUS  
FROM nfMCP10000 A 
LEFT OUTER JOIN RM10201 B ON A.NUMBERIE = B.DOCNUMBR AND A.RMDTYPAL = B.RMDTYPAL 
WHERE B.DOCNUMBR IS NULL 
INSERT INTO RM00401(DOCNUMBR,RMDTYPAL,DCSTATUS,BCHSOURC,TRXSORCE,CUSTNMBR,CHEKNMBR,DOCDATE)
SELECT NUMBERIE, A.RMDTYPAL, 2 AS DCSTAUS, 'TII_Delete' AS BCHSOURC, B.TRXSORCE,  
'VARIOS', '' AS CHEKNMBR, A.DOCDATE 
FROM nfMCP20000 A  
INNER JOIN (SELECT TRXSORCE, DOCNUMBR, RMDTYPAL FROM RM10101 GROUP BY TRXSORCE, 
DOCNUMBR, RMDTYPAL) B 
ON A.NUMBERIE = B.DOCNUMBR AND A.RMDTYPAL = B.RMDTYPAL  
LEFT OUTER JOIN RM00401 C ON A.NUMBERIE = C.DOCNUMBR AND A.RMDTYPAL = C.RMDTYPAL  
WHERE C.DOCNUMBR IS NULL  

INSERT INTO RM20101(CUSTNMBR,CPRCSTNM,DOCNUMBR,CHEKNMBR,BACHNUMB,BCHSOURC,TRXSORCE,
RMDTYPAL,CSHRCTYP,CBKIDCRD,CBKIDCSH,CBKIDCHK,DUEDATE,DOCDATE,POSTDATE,PSTUSRID,GLPOSTDT,
LSTEDTDT,LSTUSRED,ORTRXAMT,CURTRXAM,SLSAMNT,COSTAMNT,FRTAMNT,MISCAMNT,TAXAMNT,COMDLRAM,
CASHAMNT,DISTKNAM,DISAVAMT,DISAVTKN,DISCRTND,DISCDATE,DSCDLRAM,DSCPCTAM,WROFAMNT,TRXDSCRN,
CSPORNBR,SLPRSNID,SLSTERCD,DINVPDOF,PPSAMDED,GSTDSAMT,DELETE1,AGNGBUKT,VOIDSTTS,VOIDDATE,
TAXSCHID,CURNCYID,PYMTRMID,SHIPMTHD,TRDISAMT,SLSCHDID,FRTSCHID,MSCSCHID,NOTEINDX,Tax_Date,
APLYWITH,SALEDATE,CORRCTN,SIMPLIFD,Electronic,ECTRX,BKTSLSAM,BKTFRTAM,BKTMSCAM,BackoutTradeDisc,
Factoring)   
SELECT 'VARIOS', '' AS CPRCSTNM, NUMBERIE, '' AS CHEKNMBR, A.BACHNUMB,   
'TII_Delete' AS BCHSOURC, B.TRXSORCE, A.RMDTYPAL, 0 AS CSHRCTYP, '' AS CBKIDCRD,   
'' AS CBKIDCSH, '' AS CBKIDCHK, 0 AS DUEDATE, A.DOCDATE, A.DOCDATE AS POSTDATE,   
A.LSTUSRED AS PSTUSRID, A.GLPOSTDT, A.LSTEDTDT, A.LSTUSRED, TOTAMNT AS ORTRXAMT,   
A.CURTRXAM, 0 AS SLSAMNT, 0 AS COSTAMNT, 0 AS FRTAMNT, 0 AS MISCAMNT, 0 AS TAXAMNT,   
0 AS COMDLRAM, 0 AS CASHAMNT, A.DISTKNAM, 0 AS DISAVAMT, A.DISAVTKN, 0 AS DISCRTND,   
0 AS DISCDATE, 0 AS DSCLDRAM, 0 AS DSCPCTAM, A.WROFAMNT, '' AS TRXDSCRN, '' AS CSPORNBR,   
'' AS SLPRSNID, '' AS SLSTERCD, 0 AS DINVPDOF, 0 AS PPSAMDED, 0 AS GSTDSAMT, 0 AS DELETE1, 1 AS AGNGBUKT,   
A.VOIDSTTS, A.VOIDDATE, '' AS TAXSCHID, A.CURNCYID, '' AS PYMTRMID, '' AS SHIPMTHD,   
0 AS TRDISAMT, '' AS SLSCHDID, '' AS FRTSCHID, '' AS MSCSCHID, 0 AS NOTEINDX, 0 AS Tax_Date,  
0 AS APLYWITH, 0 AS SALEDATE, 0 AS CORRCTN, 0 AS SIMPLIFD, 0 AS Electronic, 0 AS ECTRX,   
0 AS BKTSLSAM, 0 AS BKTFRTAM, 0 AS BKTMSCAM, 0 AS BackoutTradeDisc, 0 AS Factoring  
FROM nfMCP20000 A   
INNER JOIN (SELECT TRXSORCE, DOCNUMBR, RMDTYPAL FROM RM10101 GROUP BY TRXSORCE,  
DOCNUMBR, RMDTYPAL) B  
ON A.NUMBERIE = B.DOCNUMBR AND A.RMDTYPAL = B.RMDTYPAL   
LEFT OUTER JOIN RM20101 C ON A.NUMBERIE = C.DOCNUMBR AND A.RMDTYPAL = C.RMDTYPAL   
WHERE C.DOCNUMBR IS NULL   
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[TII_RMCheckLinks_BEFORE] TO [DYNGRP] 
GO 

/*End_TII_RMCheckLinks_BEFORE*/
/*Begin_mcpCLPMDistributionsCopy*/
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mcpCLPMDistributionsCopy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mcpCLPMDistributionsCopy]
GO


CREATE   PROCEDURE mcpCLPMDistributionsCopy   
 @USERID CHAR(15),   
 @O_SQL_Error_State int = NULL  output   
AS   
   
BEGIN   
	INSERT INTO MCP3400(USERID, MCPTBL , ERMSGTXT,MCPERMSG,MCPERTYP)    
	SELECT @USERID,'PM_Distribution_WORK_OPEN [PM10100]',A.VCHRNMBR,31,0     
	FROM PM10100 A
	INNER JOIN nfMCP_PM20000 B ON A.VCHRNMBR = B.NUMBERIE
	GROUP BY A.VCHRNMBR

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[mcpCLPMDistributionsCopy] TO [DYNGRP] 
GO 

/*End_mcpCLPMDistributionsCopy*/
/*Begin_nfRETMCPUpdateWithholdTax*/
set quoted_identifier off 
go 
set ansi_nulls off 
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfRETMCPUpdateWithholdTax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfRETMCPUpdateWithholdTax]
go

create  procedure nfRETMCPUpdateWithholdTax 
@iFileName char(100),
@iFileFromDate	char(8),
@iFileToDate	char(8),
@iFromDate		DateTime,
@iToDate	DateTime,
@iFileLocation	char(150),
@ProcessType smallint,
 @O_SQL_Error_State int = NULL  output

as
begin
	DECLARE @TAXDTLID char(16)
	DECLARE	@PubDate	DateTime
	DECLARE @DefPerc   float
	begin transaction T1;
	begin
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp1')
			DROP TABLE ##nfRETMCPTemp1 
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp2')
			DROP TABLE ##nfRETMCPTemp2
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp3')
			DROP TABLE ##nfRETMCPTemp3
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp4')
			DROP TABLE ##nfRETMCPTemp4
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp5')
			DROP TABLE ##nfRETMCPTemp5
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp6')
			DROP TABLE ##nfRETMCPTemp6
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp7')
			DROP TABLE ##nfRETMCPTemp7

		create table ##nfRETMCPTemp5 (TaxIDCode char(11))
		if @ProcessType=1 or @ProcessType=3 or @ProcessType=4/*Monthly Tax or Quarterly Tax*/
		BEGIN
			if @ProcessType=1
			EXEC(' create table ##nfRETMCPTemp1 (PubDate char(8),DueDateFrm char(8),DueDateTo char(8),TaxIDCode char(11),TypeTaxIDCode char(1),
			 StatInd char(1),StatusOfChange char(1),PercPer char(4),RetPer char(4),PerCa int,RetCat int)')
			if @ProcessType=3 or @ProcessType=4
			EXEC(' create table ##nfRETMCPTemp1 (PubDate char(8),DueDateFrm char(8),DueDateTo char(8),TaxIDCode char(11),TypeTaxIDCode char(1),
			 StatInd char(1),StatusOfChange char(1),PercPer char(4),RetPer char(4),PerCa int,RetCat int,Name char(250))')
			EXEC('BULK INSERT dbo.##nfRETMCPTemp1 FROM '''+	@iFileLocation +''' WITH 
				  (
					 FIELDTERMINATOR ='';'',
					 ROWTERMINATOR =''\n''
				  )')
			if @@error<>0
			begin
				rollback transaction
				return
			end
		
			/*Code used to avoid the dates that are not matching with the date range*/			
			insert into ##nfRETMCPTemp5 
			select TaxIDCode from ##nfRETMCPTemp1 where DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate
			delete from  ##nfRETMCPTemp1 where DueDateFrm<>@iFileFromDate or DueDateTo<>@iFileToDate
			set @PubDate=(select top 1 convert(datetime,substring(PubDate,1,2)+'-'+
			case when( substring(PubDate,3,2))='01' then 'Jan'
			 when ( substring(PubDate,3,2))='02' then 'Feb'
			 when ( substring(PubDate,3,2))='03' then 'Mar'
			 when ( substring(PubDate,3,2))='04' then 'Apr'
			 when ( substring(PubDate,3,2))='05' then 'May'
			 when ( substring(PubDate,3,2))='06' then 'Jun'
			 when ( substring(PubDate,3,2))='07' then 'Jul'
			 when ( substring(PubDate,3,2))='08' then 'Aug'
			 when ( substring(PubDate,3,2))='09' then 'Sep'
			 when ( substring(PubDate,3,2))='10' then 'Oct'
			 when ( substring(PubDate,3,2))='11' then 'Nov'
			 when ( substring(PubDate,3,2))='12' then 'Dec'
			END
			+'-'+substring(PubDate,5,4))from ##nfRETMCPTemp1)
			if @@error<>0
			begin
				rollback transaction
				return
			end
		END/*Process Type*/
		/* This is to copy all unwanted records from the Table since we are doing insertion only for the particular period 
		and before this insertion we need to remove any records that lies in this period.This copied records we are using for report display.*/
		if @ProcessType=1 or @ProcessType=2/*Monthly Tax or Default Tax*/
		begin
			select * into ##nfRETMCPTemp2 from  (select [VENDORID] ,[nfRET_Tipo_ID] ,[TII_MCP_From_Date],[TII_MCP_TO_DATE] ,
				[nfRET_CalType] ,	[PRCNTAGE]  from nfRET_PM00201 
			where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and VENDORID in(select PM00200.VENDORID from  PM00200 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
				and PM00200.VENDORID=nfRET_PM00201.VENDORID)
			and ((TII_MCP_From_Date<@iFromDate and TII_MCP_TO_DATE>=@iFromDate)  or( TII_MCP_From_Date>@iFromDate and TII_MCP_From_Date<@iToDate and TII_MCP_TO_DATE>@iToDate)
							 or( TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate)))as t1
			if @@error<>0
			begin
				rollback transaction
				return
			end
		end
		/*To update the End Date for the Dates like 15-Feb-01 to 15-Mar-01*/
		if @ProcessType=1 or @ProcessType=2
		begin
			update nfRET_PM00201 set TII_MCP_TO_DATE=DATEADD(day,-1,@iFromDate)
			 where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and VENDORID in(select PM00200.VENDORID from  PM00200 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
			 and PM00200.VENDORID=nfRET_PM00201.VENDORID) and (TII_MCP_From_Date<@iFromDate and TII_MCP_TO_DATE>=@iFromDate) 
			if @@error<>0
			begin
				rollback transaction
				return
			end		
			/*To update the From Date for the Dates like 15-Mar-01 to 15-Apr-01*/
			update nfRET_PM00201 set TII_MCP_From_Date=DATEADD(day,1,@iToDate)
			where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and VENDORID in(select PM00200.VENDORID from  PM00200 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
			and PM00200.VENDORID=nfRET_PM00201.VENDORID)and (TII_MCP_From_Date<=@iToDate and TII_MCP_TO_DATE>@iToDate) 
			if @@error<>0
			begin
				rollback transaction
				return
			end
			/*Delete these records  since we are doing insertion for these deleted records also*/
			delete from nfRET_PM00201
			where  nfRET_CalType=2 and nfRET_Tipo_ID in(select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)
			and TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate
			 and VENDORID in(select PM00200.VENDORID from  PM00200 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5) and PM00200.VENDORID=nfRET_PM00201.VENDORID)
			if @@error<>0
			begin
				rollback transaction
				return
			end
		end/*Process Type*/
		set @DefPerc=isnull((select PRCNTAGE from nfRET_PM00040),1.75)
		if @ProcessType=1 or @ProcessType=2
		BEGIN
			 
			 DECLARE TAXDETAILS CURSOR FOR 
			 select TAXDTLID from nfRET_PM40011 where NAME=@iFileName
			 OPEN TAXDETAILS 
			 FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
			 WHILE (@@FETCH_STATUS=0) 
			 BEGIN 
				if @ProcessType=1 
				begin
				   /*To insert the records into the table with the Tax from the Imported file*/
					insert  into nfRET_PM00201(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE,
						nfRET_CalType,PRCNTAGE,DATE1,HR)  select PM00200.VENDORID,
						@TAXDTLID,@iFromDate,@iToDate,2,CAST(REPLACE(##nfRETMCPTemp1.RetPer,',','.') AS decimal(4,2))as RetPer,@PubDate,1 from PM00200 inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode and substring(PM00200.TXRGNNUM,24,2)<>''
					if @@error<>0
					begin
						rollback transaction
						CLOSE TAXDETAILS 
						DEALLOCATE TAXDETAILS
						return
					end
					/*To insert the Default Tax if this CUIT number not in the Text file*/
					insert into nfRET_PM00201(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE,
						nfRET_CalType,PRCNTAGE) select PM00200.VENDORID,@TAXDTLID,@iFromDate,@iToDate,2,@DefPerc from PM00200
					 where substring(TXRGNNUM,24,2)<>''and substring(PM00200.TXRGNNUM,1,11)
					not in (select ##nfRETMCPTemp1.TaxIDCode from ##nfRETMCPTemp1 where ##nfRETMCPTemp1.TaxIDCode=substring(PM00200.TXRGNNUM,1,11))
					and substring(PM00200.TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)
					if @@error<>0
					begin
						rollback transaction
						CLOSE TAXDETAILS 
						DEALLOCATE TAXDETAILS
						return
					end	
				end
				if  @ProcessType=2
				begin
					/*To insert the Default Tax if this CUIT number not in the Text file*/
					insert into nfRET_PM00201(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE,
						nfRET_CalType,PRCNTAGE) select PM00200.VENDORID,@TAXDTLID,@iFromDate,@iToDate,2,@DefPerc from PM00200
					 where substring(TXRGNNUM,24,2)<>''
					if @@error<>0
					begin
						rollback transaction
						CLOSE TAXDETAILS 
						DEALLOCATE TAXDETAILS
						return
					end	
				end	     
				FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
			END
			CLOSE TAXDETAILS 
			DEALLOCATE TAXDETAILS
			if @@error<>0
			begin
				rollback transaction
				return
			end
		END

		if @ProcessType=3 or @ProcessType=4
		BEGIN
			if @ProcessType=4
			BEGIN
				set @DefPerc=isnull((select PRCNTAGE from nfRET_PM00041),2.00)
				create table ##nfRETMCPTemp6 (VENDORID char(15),nfRET_Tipo_ID char(11),	TII_MCP_From_Date datetime,TII_MCP_TO_DATE datetime,nfRET_CalType char(2),RetPer char(9),DATE1 datetime)
				create table ##nfRETMCPTemp7 (VENDORID char(15),nfRET_Tipo_ID char(11),	TII_MCP_From_Date datetime,TII_MCP_TO_DATE datetime,nfRET_CalType char(2),RetPer char(9),DATE1 datetime)
			END
			create table ##nfRETMCPTemp3 (VENDORID char(15),nfRET_Tipo_ID char(11),	TII_MCP_From_Date datetime,TII_MCP_TO_DATE datetime,nfRET_CalType char(2),RetPer char(9),DATE1 datetime)

			 DECLARE TAXDETAILS CURSOR FOR 
			 select TAXDTLID from nfRET_PM40011 where NAME=@iFileName
			 OPEN TAXDETAILS 
			 FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
			 WHILE (@@FETCH_STATUS=0) 
			 BEGIN 
			   /*To insert the records into the table with the Tax from the Imported file*/

				if @ProcessType=3
					insert into ##nfRETMCPTemp3(VENDORID,nfRET_Tipo_ID,	TII_MCP_From_Date ,TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)
						(select PM00200.VENDORID as VENDORID,
						@TAXDTLID as nfRET_Tipo_ID,@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,CAST(REPLACE(##nfRETMCPTemp1.RetPer,',','.') AS decimal(4,2))as RetPer,@PubDate as DATE1 from PM00200 inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode) 
				if @ProcessType=4
				BEGIN	
					insert into ##nfRETMCPTemp3(VENDORID,nfRET_Tipo_ID,	TII_MCP_From_Date ,TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)
					(select PM00200.VENDORID as VENDORID,
					@TAXDTLID as nfRET_Tipo_ID,@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,@DefPerc as RetPer,@PubDate as DATE1 from PM00200 inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode and PM00200.VENDORID in(select VENDORID from nfRET_PM00200 where nfRET_PM00200.VENDORID=PM00200.VENDORID and nfRET_PM00200.nfRET_MonoVend=1 and
					nfRET_plan_de_retencione IN (select nfRET_plan_de_retencione from nfRET_GL00020 where nfRET_Retencion_ID IN (select nfRET_Retencion_ID from nfRET_GL00030 where nfRET_Tipo_ID = @TAXDTLID))))
					
					insert into ##nfRETMCPTemp6(VENDORID,nfRET_Tipo_ID,	TII_MCP_From_Date ,TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)
					(select PM00200.VENDORID as VENDORID,
					@TAXDTLID as nfRET_Tipo_ID,@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,@DefPerc as RetPer,@PubDate as DATE1 from PM00200 inner join ##nfRETMCPTemp1 on substring(PM00200.TXRGNNUM,1,11)=##nfRETMCPTemp1.TaxIDCode /*and PM00200.VENDORID in(select VENDORID from nfRET_PM00200 where nfRET_PM00200.VENDORID=PM00200.VENDORID and nfRET_PM00200.nfRET_MonoVend=0)*/)

					insert into ##nfRETMCPTemp7(VENDORID,nfRET_Tipo_ID,	TII_MCP_From_Date ,TII_MCP_TO_DATE,nfRET_CalType,RetPer,DATE1)
					(select PM00200.VENDORID as VENDORID,
					@TAXDTLID as nfRET_Tipo_ID,@iFromDate as TII_MCP_From_Date,@iToDate as TII_MCP_TO_DATE,2 as nfRET_CalType,@DefPerc as RetPer,@PubDate as DATE1 from PM00200 where PM00200.VENDORID in(select VENDORID from nfRET_PM00200 where nfRET_PM00200.nfRET_MonoVend=1 and nfRET_PM00200.nfRET_MonoHighRisk=1))
				END	



				if @@error<>0
				begin
					rollback transaction
					CLOSE TAXDETAILS 
					DEALLOCATE TAXDETAILS
					return
				end
				FETCH NEXT FROM TAXDETAILS INTO @TAXDTLID
			END
			CLOSE TAXDETAILS 
			DEALLOCATE TAXDETAILS
			if @@error<>0
			begin
				rollback transaction
				return
			end
			/*Copying the existing records to be updated to display in the report*/
			select * into ##nfRETMCPTemp4 from  (select [VENDORID] ,[nfRET_Tipo_ID] ,[TII_MCP_From_Date],[TII_MCP_TO_DATE] ,
				[nfRET_CalType] ,	[PRCNTAGE]  from nfRET_PM00201 
			where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID )
			and ((TII_MCP_From_Date<@iFromDate and TII_MCP_TO_DATE>=@iFromDate)  or( TII_MCP_From_Date>@iFromDate and TII_MCP_From_Date<@iToDate and TII_MCP_TO_DATE>@iToDate)
							 or( TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate)))as t1
			if @@error<>0
			begin
				rollback transaction
				return
			end
			/*To update the From Date for the Dates like 15-Feb-01 to 15-Mar-01*/
			update nfRET_PM00201 set TII_MCP_TO_DATE=DATEADD(day,-1,@iFromDate)
			 where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and nfRET_PM00201.VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)
			and (nfRET_PM00201.TII_MCP_From_Date<@iFromDate and nfRET_PM00201.TII_MCP_TO_DATE>=@iFromDate) 
			if @@error<>0
			begin
				rollback transaction
				return
			end		
			/*To update the From Date for the Dates like 15-Mar-01 to 15-Apr-01*/
			update nfRET_PM00201 set TII_MCP_From_Date=DATEADD(day,1,@iToDate)
			where nfRET_CalType=2 and nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)
			and (TII_MCP_From_Date<=@iToDate and TII_MCP_TO_DATE>@iToDate) 
			if @@error<>0
			begin
				rollback transaction
				return
			end
			/*Delete these records  since we are doing insertion for these deleted records also*/
			delete from nfRET_PM00201
			where  nfRET_CalType=2 and nfRET_Tipo_ID in(select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)
			and TII_MCP_From_Date>=@iFromDate and TII_MCP_TO_DATE<=@iToDate
			 and VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID)
			if @@error<>0
			begin
				rollback transaction
				return
			end
			/*To insert the records into the table with the Tax from the Imported file*/
			insert  into nfRET_PM00201(VENDORID,nfRET_Tipo_ID,TII_MCP_From_Date,TII_MCP_TO_DATE,
				nfRET_CalType,PRCNTAGE,DATE1)  select ##nfRETMCPTemp3.VENDORID,
				##nfRETMCPTemp3.nfRET_Tipo_ID,@iFromDate,@iToDate,2,RetPer,DATE1 from ##nfRETMCPTemp3
					/*RF8538*/
					if @ProcessType=3  
					BEGIN
    						update nfRET_PM00201 set HR=1 	
					END 

			/*For RF7162 To Update nfRET_MonoHighRisk to 1 */
			if @ProcessType=4 
				BEGIN
				update nfRET_PM00200 set nfRET_MonoHighRisk=0 where nfRET_PM00200.nfRET_MonoVend=1
				update nfRET_PM00200 set nfRET_MonoHighRisk=1 where nfRET_PM00200.VENDORID 
					in (select VENDORID from ##nfRETMCPTemp3 where ##nfRETMCPTemp3.VENDORID= nfRET_PM00200.VENDORID) and  nfRET_PM00200.nfRET_MonoVend=1
				END
			if @@error<>0
			begin
				rollback transaction
				CLOSE TAXDETAILS 
				DEALLOCATE TAXDETAILS
				return
			end
		END
		if @ProcessType=1 or @ProcessType=2
		Begin
			/*This Query is to insert the new Tax Percentages and the old tax percentages to display in the Report*/
			delete from nfRET_PM40012
			insert into nfRET_PM40012(VENDORID,VENDNAME,CUIT_Pais,nfRET_Tipo_ID, nfRET_OldPercentage,PRCNTAGE,From_Date,TODATE)
			select nfRET_PM00201.VENDORID,VENDNAME=(select VENDNAME  from  PM00200 where substring(TXRGNNUM,24,2)<>'' and PM00200.VENDORID=nfRET_PM00201.VENDORID),CUIT_Pais=(select substring(TXRGNNUM,1,11)  from  PM00200 where substring(TXRGNNUM,24,2)<>'' and PM00200.VENDORID=nfRET_PM00201.VENDORID),
			nfRET_PM00201.nfRET_Tipo_ID,
			isnull(##nfRETMCPTemp2.PRCNTAGE,0),nfRET_PM00201.PRCNTAGE,@iFromDate,@iToDate from nfRET_PM00201 left outer join ##nfRETMCPTemp2 on 
				nfRET_PM00201.VENDORID=##nfRETMCPTemp2.VENDORID and nfRET_PM00201.nfRET_Tipo_ID=##nfRETMCPTemp2.nfRET_Tipo_ID
			and nfRET_PM00201.nfRET_CalType=##nfRETMCPTemp2.nfRET_CalType
			where nfRET_PM00201.nfRET_CalType=2 and nfRET_PM00201.nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName) 
			and  nfRET_PM00201.VENDORID in(select VENDORID  from  PM00200 where substring(TXRGNNUM,24,2)<>'' and substring(TXRGNNUM,1,11) not in(select TaxIDCode from ##nfRETMCPTemp5)and PM00200.VENDORID=nfRET_PM00201.VENDORID)
			and  nfRET_PM00201.TII_MCP_From_Date=@iFromDate and nfRET_PM00201.TII_MCP_TO_DATE=@iToDate  
			if @@error<>0
			begin
				rollback transaction
				return
			end
			delete from nfRET_PM40013
			insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)
			select VENDORID,VENDNAME,1 from PM00200 where substring(TXRGNNUM,24,2)=''

			insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)
			select VENDORID,VENDNAME,2 from PM00200 where substring(TXRGNNUM,24,2)<>'' 
					and substring(TXRGNNUM,1,11) in (select TaxIDCode from ##nfRETMCPTemp5)
			if @@error<>0
			begin
				rollback transaction
				return
			end
		End
		if @ProcessType=3 OR @ProcessType=4
		begin
			delete from nfRET_PM40012
			delete from nfRET_PM40013
			insert into nfRET_PM40012(VENDORID,VENDNAME,CUIT_Pais,nfRET_Tipo_ID, nfRET_OldPercentage,PRCNTAGE,From_Date,TODATE)
			select nfRET_PM00201.VENDORID,VENDNAME=(select VENDNAME  from  PM00200 where substring(TXRGNNUM,24,2)<>'' and PM00200.VENDORID=nfRET_PM00201.VENDORID),CUIT_Pais=(select substring(TXRGNNUM,1,11)  from  PM00200 where substring(TXRGNNUM,24,2)<>'' and PM00200.VENDORID=nfRET_PM00201.VENDORID),
			nfRET_PM00201.nfRET_Tipo_ID,
			isnull(##nfRETMCPTemp4.PRCNTAGE,0),nfRET_PM00201.PRCNTAGE,@iFromDate,@iToDate from nfRET_PM00201 left outer join ##nfRETMCPTemp4 on 
				nfRET_PM00201.VENDORID=##nfRETMCPTemp4.VENDORID and nfRET_PM00201.nfRET_Tipo_ID=##nfRETMCPTemp4.nfRET_Tipo_ID
			and nfRET_PM00201.nfRET_CalType=##nfRETMCPTemp4.nfRET_CalType
			where nfRET_PM00201.nfRET_CalType=2 and nfRET_PM00201.nfRET_Tipo_ID in (select TAXDTLID from nfRET_PM40011 where NAME=@iFileName)
				and nfRET_PM00201.TII_MCP_From_Date=@iFromDate and nfRET_PM00201.TII_MCP_TO_DATE=@iToDate
				and nfRET_PM00201.VENDORID in(select ##nfRETMCPTemp3.VENDORID from  ##nfRETMCPTemp3 where  ##nfRETMCPTemp3.VENDORID=nfRET_PM00201.VENDORID) 
			if @@error<>0
			begin
				rollback transaction
				return
			end
			if @ProcessType=3
			BEGIN
				insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)
				select VENDORID,VENDNAME,2 from PM00200 where substring(TXRGNNUM,24,2)<>'' 
						and substring(TXRGNNUM,1,11) in (select TaxIDCode from ##nfRETMCPTemp5)
				if @@error<>0
				begin
					rollback transaction
					return
				end
			END
			if @ProcessType=4
			BEGIN
				insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)
				select DISTINCT(PM00200.VENDORID),VENDNAME,3 from PM00200, ##nfRETMCPTemp6 where PM00200.VENDORID = ##nfRETMCPTemp6.VENDORID and
					##nfRETMCPTemp6.VENDORID in (select VENDORID from nfRET_PM00200 where  nfRET_MonoVend=0) 
				
				/*insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)
				select PM00200.VENDORID,VENDNAME,3 from PM00200, ##nfRETMCPTemp6 where ##nfRETMCPTemp6.VENDORID = PM00200.VENDORID and ##nfRETMCPTemp6.VENDORID
					not in (select nfRET_PM00200.VENDORID from nfRET_PM00200/*,PM00200 where PM00200.VENDORID= nfRET_PM00200.VENDORID*/) 
				*/
				insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)
				select DISTINCT(PM00200.VENDORID),VENDNAME,3 from PM00200, ##nfRETMCPTemp6 where PM00200.VENDORID = ##nfRETMCPTemp6.VENDORID and
					##nfRETMCPTemp6.VENDORID not in (select VENDORID from nfRET_PM00200) 
	
				insert into nfRET_PM40013(VENDORID,VENDNAME,nfRET_Reason)
				/*(select PM00200.VENDORID,VENDNAME,4 from PM00200,##nfRETMCPTemp7 where PM00200.VENDORID = ##nfRETMCPTemp7.VENDORID
				and PM00200.VENDORID in (select VENDORID from nfRET_PM00200 where nfRET_HighRisk=0))*/
				(select VENDORID,VENDNAME,4 from PM00200 where
				PM00200.VENDORID in (select VENDORID from nfRET_PM00200 where nfRET_MonoVend = 1 and nfRET_MonoHighRisk=0)) 
 

				if @@error<>0
				begin
					rollback transaction
					return
				end
			END
		end
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp1')
			DROP TABLE ##nfRETMCPTemp1 
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp2')
			DROP TABLE ##nfRETMCPTemp2
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp3')
			DROP TABLE ##nfRETMCPTemp3
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp4')
			DROP TABLE ##nfRETMCPTemp4
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp5')
			DROP TABLE ##nfRETMCPTemp5
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp6')
			DROP TABLE ##nfRETMCPTemp6
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name = '##nfRETMCPTemp7')
			DROP TABLE ##nfRETMCPTemp7

		commit transaction T1;
	end
end 
go
set quoted_identifier on
go
set ansi_nulls on 
go

grant execute on [dbo].[nfRETMCPUpdateWithholdTax] to [DYNGRP] 
go 

/*End_nfRETMCPUpdateWithholdTax*/
/*Begin_nfRET_Display_FA_Price*/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfRET_Display_FA_Price]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfRET_Display_FA_Price]
GO

CREATE PROCEDURE nfRET_Display_FA_Price 
 @CallingWin int,
 @VendorID varchar(40),
 @VCHRNMBR varchar(40),
 @IsValid int OUTPUT
As
BEGIN
 DECLARE @TempACTINDX int

 IF @CallingWin = 1 
 BEGIN
 select  @TempACTINDX = ACTINDX from 
 (select VENDORID,VCHRNMBR,DSTINDX from  PM10100 where DISTTYPE = 6 and VENDORID = @VendorID and VCHRNMBR = @VCHRNMBR) TempPM10100 
 inner join (select VENDORID,ACTINDX from 
 nfRET_PM00200  inner join nfRET_GL00020 on nfRET_PM00200.nfRET_plan_de_retencione = nfRET_GL00020.nfRET_plan_de_retencione 
 inner join nfRET_GL00100 on nfRET_GL00100.nfRET_Retencion_ID = nfRET_GL00020.nfRET_Retencion_ID 
 inner join nfRET_GL00101 on nfRET_GL00100.nfRET_Retencion_ID = nfRET_GL00101.nfRET_Retencion_ID 
 and nfRET_GL00100.nfRET_Prof_Asset = nfRET_GL00101.nfRETAsset_Prof
 where nfRET_GL00100.nfRET_Prof_Asset = 2 and VENDORID = @VendorID) TempRETAcc 
 on TempPM10100.VENDORID = TempRETAcc.VENDORID and TempPM10100.DSTINDX = TempRETAcc.ACTINDX
 END
 ELSE
 BEGIN
 select  @TempACTINDX = TempPOP10390.ACTINDX from 
 (select VENDORID,POPRCTNM,ACTINDX from  POP10390 where DISTTYPE = 1 and VENDORID = @VendorID and POPRCTNM = @VCHRNMBR) TempPOP10390 
 inner join (select VENDORID,ACTINDX from 
 nfRET_PM00200  inner join nfRET_GL00020 on nfRET_PM00200.nfRET_plan_de_retencione = nfRET_GL00020.nfRET_plan_de_retencione 
 inner join nfRET_GL00100 on nfRET_GL00100.nfRET_Retencion_ID = nfRET_GL00020.nfRET_Retencion_ID 
 inner join nfRET_GL00101 on nfRET_GL00100.nfRET_Retencion_ID = nfRET_GL00101.nfRET_Retencion_ID 
 and nfRET_GL00100.nfRET_Prof_Asset = nfRET_GL00101.nfRETAsset_Prof
 where nfRET_GL00100.nfRET_Prof_Asset = 2 and VENDORID = @VendorID) TempRETAcc 
 on TempPOP10390.VENDORID = TempRETAcc.VENDORID and TempPOP10390.ACTINDX = TempRETAcc.ACTINDX
 END

 IF @TempACTINDX IS NULL
 SET @IsValid = 0
 ELSE
 SET @IsValid = 1

END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfRET_Display_FA_Price] TO [DYNGRP] 
GO 

/*End_nfRET_Display_FA_Price*/
/*Begin_nfRET_IsValid_Transaction*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfRET_IsValid_Transaction]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfRET_IsValid_Transaction]
GO

CREATE PROCEDURE nfRET_IsValid_Transaction
    @Asset_Prof smallint, 
    @VendorID varchar(40),
    @VCHRNMBR varchar(40),
    @DetailID varchar(40),
    @IsValid int OUTPUT
As
BEGIN
	DECLARE @TempVCHRNMBR varchar(40)

	SELECT  @TempVCHRNMBR =  VCHRNMBR from nfRET_IsValid_Invoices where  VENDORID = @VendorID
	and nfRETAsset_Prof = @Asset_Prof and VCHRNMBR = @VCHRNMBR and nfRET_Retencion_ID = @DetailID
	
	IF @TempVCHRNMBR IS NULL
		SET @IsValid = 0
	ELSE
		SET @IsValid = 1
	
END	
	

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfRET_IsValid_Transaction] TO [DYNGRP] 
GO 

/*End_nfRET_IsValid_Transaction*/
/*Begin_nfRET_PurchAmt_WTH*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfRET_PurchAmt_WTH]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfRET_PurchAmt_WTH]
GO

CREATE PROCEDURE nfRET_PurchAmt_WTH
 @Asset_Prof smallint, 
 @VendorID varchar(40),
 @VCHRNMBR varchar(40),
 @DetailID varchar(40),
 @PURCHAMT money OUTPUT
As
BEGIN

 SELECT  @PURCHAMT = sum(PURCHAMT) 
 from nfRET_Invoices_Opn_WTH where VENDORID = @VendorID and VCHRNMBR = @VCHRNMBR 
 and nfRETAsset_Prof = @Asset_Prof and nfRET_Retencion_ID = @DetailID
 
END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfRET_PurchAmt_WTH] TO [DYNGRP] 
GO 

/*End_nfRET_PurchAmt_WTH*/
/*Begin_nfRET_Threshold_Amt*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfRET_Threshold_Amt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfRET_Threshold_Amt]
GO

CREATE PROCEDURE nfRET_Threshold_Amt 
 @Asset_Prof smallint, 
 @BasedOn int,
 @PeriodType int,
 @Periods int,
 @InclCurr smallint,
 @ExclCurr smallint,
 @ExclPeriods int,
 @VendorID varchar(40),
 @Date datetime,
 @IsVAT smallint,
 @TaxID varchar(40),
 @DetailID varchar(40),
 @PURCHAMT money OUTPUT,
 @TRDISAMT money OUTPUT,
 @FRTAMNT money OUTPUT,
 @MSCCHAMT money OUTPUT,
 @TAXAMNT money OUTPUT,
 @PAYAMT money OUTPUT
AS 
BEGIN

 Declare @StartDate datetime
 Declare @EndDate datetime

 IF @PeriodType = 1 
 BEGIN
	 IF @InclCurr = 0
	 BEGIN
		 select @StartDate = dateadd(dd,-@Periods,dateadd(dd,-1,@Date)) 
		 select @EndDate = dateadd(dd,-1,@Date)
	 END
	 IF @InclCurr = 1
	 BEGIN
		 select @StartDate = dateadd(dd,-@Periods,@Date) 
		 select @EndDate = @Date 
	 END
	 ELSE IF @ExclCurr = 1
	 BEGIN
		 select @StartDate = dateadd(dd,-(@Periods+@ExclPeriods),dateadd(dd,-1,@Date)) 
		 select @EndDate = dateadd(dd,-@ExclPeriods,dateadd(dd,-1,@Date))
	 END
 END
 IF @PeriodType = 2
 BEGIN
	 IF @InclCurr = 0
	 BEGIN
		 select @StartDate = dateadd(mm,-@Periods,str(year(@Date)) + '-' + str(month(@Date))+ '-01') 
		 select @EndDate = dateadd(dd,-1,str(year(@Date)) + '-' + str(month(@Date))+ '-01')
	 END
	 IF @InclCurr = 1
	 BEGIN
		 select @StartDate = dateadd(mm,-@Periods,dateadd(mm,1,str(year(@Date)) + '-' + str(month(@Date))+ '-01'))
		 select @EndDate = dateadd(dd,-1,dateadd(mm,1,str(year(@Date)) + '-' + str(month(@Date))+ '-01')) 
	 END
	 ELSE IF @ExclCurr = 1
	 BEGIN
		 select @StartDate = dateadd(mm,-(@Periods+@ExclPeriods),str(year(@Date)) + '-' + str(month(@Date))+ '-01') 
		 select @EndDate = dateadd(mm,-@ExclPeriods,dateadd(dd,-1,str(year(@Date)) + '-' + str(month(@Date))+ '-01'))
	 END
 END

 IF @IsVAT = 0
 BEGIN
 IF @BasedOn = 0
 BEGIN
 SELECT @TRDISAMT = sum(TRDISAMT)  ,@MSCCHAMT = sum(MSCCHAMT) ,@FRTAMNT = sum(FRTAMNT) ,@TAXAMNT = sum(TAXAMNT) ,
 @PURCHAMT = sum(PURCHAMT) 
 from nfRET_Invoices where DOCDATE between @StartDate and @EndDate and VENDORID = @VendorID
 and nfRETAsset_Prof = @Asset_Prof and nfRET_Retencion_ID = @DetailID
 END

 IF @BasedOn = 1
 BEGIN
 SELECT @TRDISAMT = sum(TRDISAMT)  ,@MSCCHAMT = sum(MSCCHAMT) ,@FRTAMNT = sum(FRTAMNT) ,@TAXAMNT = sum(TAXAMNT) ,
 @PURCHAMT = sum(PURCHAMT) 
 from nfRET_Invoices_Opn where DOCDATE between @StartDate and @EndDate and VENDORID = @VendorID
 and nfRETAsset_Prof = @Asset_Prof and nfRET_Retencion_ID = @DetailID
 END
 END
 ELSE
 BEGIN
 IF @BasedOn = 0
 BEGIN
 SELECT @TRDISAMT = sum(TRDISAMT)  ,@MSCCHAMT = sum(MSCCHAMT) ,@FRTAMNT = sum(FRTAMNT) ,@TAXAMNT = sum(TAXAMNT) ,
 @PURCHAMT = sum(PURCHAMT) 
 from nfRET_Invoices_VAT where DOCDATE between @StartDate and @EndDate and VENDORID = @VendorID
 and nfRETAsset_Prof = @Asset_Prof and TAXDTLID = @TaxID and nfRET_Retencion_ID = @DetailID
 END

 IF @BasedOn = 1
 BEGIN
 SELECT @TRDISAMT = sum(TRDISAMT)  ,@MSCCHAMT = sum(MSCCHAMT) ,@FRTAMNT = sum(FRTAMNT) ,@TAXAMNT = sum(TAXAMNT) ,
 @PURCHAMT = sum(PURCHAMT) 
 from nfRET_Invoices_Opn_VAT where DOCDATE between @StartDate and @EndDate and VENDORID = @VendorID
 and nfRETAsset_Prof = @Asset_Prof and  TAXDTLID = @TaxID and nfRET_Retencion_ID = @DetailID
 END
 END
 
 IF @BasedOn = 2
 BEGIN
 SELECT @PAYAMT = sum(PAYAMT)  from nfRET_Payments where DOCDATE between @StartDate and @EndDate and VENDORID = @VendorID
 END

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfRET_Threshold_Amt] TO [DYNGRP] 
GO 

/*End_nfRET_Threshold_Amt*/
/*Begin_nfRET_Shipment_PurchAmt_WTH*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nfRET_Shipment_PurchAmt_WTH]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nfRET_Shipment_PurchAmt_WTH]
GO

CREATE PROCEDURE nfRET_Shipment_PurchAmt_WTH
	@Asset_Prof smallint, 
	@VendorID varchar(40),
	@VCHRNMBR varchar(40),
    @DetailID varchar(40),
    @PURCHAMT money OUTPUT
As
BEGIN
		SELECT 	@PURCHAMT = sum(PURCHAMT)  
		from nfRET_Shipment_Opn_WTH where VENDORID = @VendorID and VCHRNMBR = @VCHRNMBR 
		and nfRETAsset_Prof = @Asset_Prof and nfRET_Retencion_ID = @DetailID
	
END	

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[nfRET_Shipment_PurchAmt_WTH] TO [DYNGRP] 
GO 

/*End_nfRET_Shipment_PurchAmt_WTH*/

 