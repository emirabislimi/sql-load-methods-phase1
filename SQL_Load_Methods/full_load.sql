CREATE OR ALTER PROCEDURE Staging.FullLoad_Students
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = '
            TRUNCATE TABLE Staging.' + QUOTENAME(@TableName) + ';

            INSERT INTO Staging.' + QUOTENAME(@TableName) + '
            SELECT *
            FROM Landing.' + QUOTENAME(@TableName) + ';
        ';

        EXEC sp_executesql @SQL;

        INSERT INTO Audit.Logs
        (
            ProcedureName,
            Status,
            Message
        )
        VALUES
        (
            'FullLoad',
            'SUCCESS',
            'Full load completed for table ' + @TableName
        );

    END TRY
    BEGIN CATCH

        INSERT INTO Audit.Logs
        (
            ProcedureName,
            Status,
            Message
        )
        VALUES
        (
            'FullLoad',
            'ERROR',
            ERROR_MESSAGE()
        );

    END CATCH
END;
GO