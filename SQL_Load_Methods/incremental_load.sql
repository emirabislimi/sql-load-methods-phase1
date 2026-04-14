-- ENHANCED VERSION

CREATE OR ALTER PROCEDURE Staging.Incremental_Students
    @TableName VARCHAR(50) -- Changed
AS
BEGIN
    BEGIN TRY

        DECLARE @LastLoad DATETIME;

        -- get last load time from config table
        SELECT @LastLoad = LastLoadTime
        FROM Audit.Config
        WHERE TableName = @TableName; -- Changed

        IF @LastLoad IS NULL
            SET @LastLoad = '1900-01-01';

        -- UPDATE 
        UPDATE S
        SET 
            S.Name = L.Name,
            S.Age = L.Age,
            S.UpdatedAt = L.UpdatedAt
        FROM Staging.Students S
        INNER JOIN Landing.Students L
            ON S.Id = L.Id
        WHERE 
            L.UpdatedAt > @LastLoad
            AND (
                ISNULL(S.Name,'') <> ISNULL(L.Name,'') -- handles NULL values so comparison works correctly
                OR ISNULL(S.Age,0) <> ISNULL(L.Age,0) -- replaces NULL with 0 to detect changes
                OR S.UpdatedAt <> L.UpdatedAt
            );

        -- INSERT
        INSERT INTO Staging.Students (Id, Name, Age, UpdatedAt)
        SELECT L.Id, L.Name, L.Age, L.UpdatedAt
        FROM Landing.Students L
        LEFT JOIN Staging.Students S
            ON L.Id = S.Id
        WHERE 
            S.Id IS NULL
            AND L.UpdatedAt > @LastLoad;

        -- SAFE CONFIG UPDATE
        IF EXISTS (SELECT 1 FROM Audit.Config WHERE TableName = @TableName)
            UPDATE Audit.Config
            SET LastLoadTime = GETDATE()
            WHERE TableName = @TableName;
        ELSE
            INSERT INTO Audit.Config (TableName, LastLoadTime)
            VALUES (@TableName, GETDATE());

        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Incremental_Students', 'SUCCESS', 'Incremental load completed');

    END TRY
    BEGIN CATCH
        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Incremental_Students', 'ERROR', ERROR_MESSAGE());
    END CATCH
END;

EXEC Staging.Incremental_Students 'Students';