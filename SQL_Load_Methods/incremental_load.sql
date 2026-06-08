CREATE OR ALTER PROCEDURE Staging.Incremental_Students
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @LastLoad DATETIME;
        DECLARE @SQL NVARCHAR(MAX);

        -- Get last load time from config table
        SELECT @LastLoad = LastLoadTime
        FROM Audit.Config
        WHERE TableName = @TableName;

        IF @LastLoad IS NULL
            SET @LastLoad = '1900-01-01';

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
                L.UpdatedAt > @LastLoad
                AND (
                    ISNULL(S.Name, '''') <> ISNULL(L.Name, '''')
                    OR ISNULL(S.Age, 0) <> ISNULL(L.Age, 0)
                    OR S.UpdatedAt <> L.UpdatedAt
                );

            INSERT INTO Staging.' + QUOTENAME(@TableName) + '
            SELECT L.*
            FROM Landing.' + QUOTENAME(@TableName) + ' L
            LEFT JOIN Staging.' + QUOTENAME(@TableName) + ' S
                ON L.Id = S.Id
            WHERE
                S.Id IS NULL
                AND L.UpdatedAt > @LastLoad;
        ';

        EXEC sp_executesql
            @SQL,
            N'@LastLoad DATETIME',
            @LastLoad = @LastLoad;

        -- Update config table
        IF EXISTS (SELECT 1 FROM Audit.Config WHERE TableName = @TableName)
            UPDATE Audit.Config
            SET LastLoadTime = GETDATE()
            WHERE TableName = @TableName;
        ELSE
            INSERT INTO Audit.Config (TableName, LastLoadTime)
            VALUES (@TableName, GETDATE());

        INSERT INTO Audit.Logs
        (
            ProcedureName,
            Status,
            Message
        )
        VALUES
        (
            'Incremental_Students',
            'SUCCESS',
            'Incremental load completed for table ' + @TableName
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
            'Incremental_Students',
            'ERROR',
            ERROR_MESSAGE()
        );

    END CATCH
END;
GO