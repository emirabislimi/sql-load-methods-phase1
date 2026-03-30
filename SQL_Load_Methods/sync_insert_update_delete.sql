CREATE PROCEDURE Sync_Data (@source NVARCHAR(100), @target NVARCHAR(100))
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)

    SET @sql = '
    MERGE ' + @target + ' AS T
    USING ' + @source + ' AS S
    ON T.id = S.id
    WHEN MATCHED THEN
        UPDATE SET T.name = S.name
    WHEN NOT MATCHED THEN
        INSERT (id, name) VALUES (S.id, S.name)
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;'

    EXEC(@sql)
END