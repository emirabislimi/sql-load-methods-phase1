CREATE OR ALTER PROCEDURE Staging.Upsert_Students
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = '
            UPDATE S
            SET
                S.Name = L.Name,
                S.Age = L.Age,
                S.UpdatedAt = L.UpdatedAt
            FROM Staging.' + QUOTENAME(@TableName) + ' S
            INNER JOIN Landing.' + QUOTENAME(@TableName) + ' L
                ON S.Id = L.Id
            WHERE
                S.Name <> L.Name
                OR S.Age <> L.Age
                OR S.UpdatedAt <> L.UpdatedAt;

            INSERT INTO Staging.' + QUOTENAME(@TableName) + '
            SELECT L.*
            FROM Landing.' + QUOTENAME(@TableName) + ' L
            LEFT JOIN Staging.' + QUOTENAME(@TableName) + ' S
                ON L.Id = S.Id
            WHERE S.Id IS NULL;
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
            'Upsert_Students',
            'SUCCESS',
            'Upsert completed for table ' + @TableName
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
            'Upsert_Students',
            'ERROR',
            ERROR_MESSAGE()
        );

    END CATCH
END;
GO