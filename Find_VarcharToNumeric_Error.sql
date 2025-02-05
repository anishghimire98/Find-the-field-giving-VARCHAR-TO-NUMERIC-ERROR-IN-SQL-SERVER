USE [SuperMarket DB]
GO
/****** Object:  StoredProcedure [dbo].[find_varcharToNumericErr]    Script Date: 7/9/2024 11:05:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROC [dbo].[find_varcharToNumericErr](@table1 varchar(50), @table2 varchar(50))
AS
DROP TABLE IF EXISTS #decimalVal
DECLARE @dboTableName varchar(50), @clTableName varchar(50)
SET @dboTableName = @table1 
SET @clTableName = @table2

-- create temp table to store values with decimal fields
CREATE TABLE #decimalVal (
  column_name varchar(50)
)

-- insert the columns with decimal values into the temp table
INSERT INTO #decimalVal
SELECT column_name 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = @clTableName 
  AND DATA_TYPE = 'decimal' 
  AND TABLE_SCHEMA = 'cl'

SELECT * FROM #decimalVal

-- loop into the #decimalVal table
DECLARE @nonNumericval varchar(50)
DECLARE @sql nvarchar(MAX) -- Change the data type to nvarchar(MAX)
DECLARE nonNumericValCursor CURSOR FOR
SELECT column_name 
FROM #decimalVal

OPEN nonNumericValCursor
FETCH NEXT FROM nonNumericValCursor INTO @nonNumericval;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @sql = 'IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@dboTableName) + ' WHERE ISNUMERIC(' + QUOTENAME(@nonNumericval) + ') = 0 AND ' + QUOTENAME(@nonNumericval) + ' IS NOT NULL) SELECT ''' + @nonNumericval + ''' AS column_name';

  EXEC sp_executesql @sql;
  FETCH NEXT FROM nonNumericValCursor INTO @nonNumericval
END

CLOSE nonNumericValCursor;
DEALLOCATE nonNumericValCursor;
