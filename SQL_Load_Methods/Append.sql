CREATE PROCEDURE Append_Data (@source NVARCHAR(100), @target NVARCHAR(100))
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)

    SET @sql = '
    INSERT INTO ' + @target + ' (id, name)
    SELECT id, name FROM ' + @source

    EXEC(@sql)
END