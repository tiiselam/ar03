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

