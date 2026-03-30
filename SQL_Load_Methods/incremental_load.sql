CREATE PROCEDURE Incremental_Load (@source NVARCHAR(100), @target NVARCHAR(100))
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)

    SET @sql = '
    INSERT INTO ' + @target + '
    SELECT * FROM ' + @source + '
    WHERE id NOT IN (SELECT id FROM ' + @target + ')'

    EXEC(@sql)
END 