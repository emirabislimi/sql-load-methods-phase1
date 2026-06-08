CREATE OR ALTER PROCEDURE Staging.Append_Students
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = '
            INSERT INTO Staging.' + QUOTENAME(@TableName) + '
            SELECT L.*
            FROM Landing.' + QUOTENAME(@TableName) + ' L
            LEFT JOIN Staging.' + QUOTENAME(@TableName) + ' S
                ON L.Id = S.Id
            WHERE S.Id IS NULL
              AND L.UpdatedAt IS NOT NULL;
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
            'Append_Students',
            'SUCCESS',
            'Append completed for table ' + @TableName
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
            'Append_Students',
            'ERROR',
            ERROR_MESSAGE()
        );

    END CATCH
END;
GO