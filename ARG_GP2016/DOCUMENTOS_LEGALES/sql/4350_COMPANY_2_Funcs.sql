/*Count : 1 */ 

set DATEFORMAT ymd 
GO 

/*Begin_SSRSMultiDDL_to_table*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SSRSMultiDDL_to_table]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[SSRSMultiDDL_to_table]
GO

CREATE FUNCTION dbo.SSRSMultiDDL_to_table

(@list ntext,

@delimiter nchar(1) = N',')

RETURNS @tbl TABLE (listpos int IDENTITY(1, 1) NOT NULL,

str varchar(4000),

nstr nvarchar(2000)) AS

BEGIN

	DECLARE @pos int,

	@textpos int,

	@chunklen smallint,

	@tmpstr nvarchar(4000),

	@leftover nvarchar(4000),

	@tmpval nvarchar(4000)

	SET @textpos = 1

	SET @leftover = ''

	WHILE @textpos <= datalength(@list) / 2

	BEGIN

		SET @chunklen = 4000 - datalength(@leftover) / 2

		SET @tmpstr = @leftover + substring(@list, @textpos, @chunklen)

		SET @textpos = @textpos + @chunklen

		SET @pos = charindex(@delimiter, @tmpstr)

		WHILE @pos > 0

		BEGIN

			SET @tmpval = ltrim(rtrim(left(@tmpstr, @pos - 1)))

			INSERT @tbl (str, nstr) VALUES(@tmpval, @tmpval)

			SET @tmpstr = substring(@tmpstr, @pos + 1, len(@tmpstr))

			SET @pos = charindex(@delimiter, @tmpstr)

		END

		SET @leftover = @tmpstr

	END

	INSERT @tbl(str, nstr) VALUES (ltrim(rtrim(@leftover)),

	ltrim(rtrim(@leftover)))

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT SELECT ON [dbo].[SSRSMultiDDL_to_table] TO [DYNGRP] 
GO

/*End_SSRSMultiDDL_to_table*/