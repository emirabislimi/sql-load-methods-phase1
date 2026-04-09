USE ETL_Project;
GO

CREATE OR ALTER PROCEDURE Staging.Incremental_Students
AS
BEGIN
    BEGIN TRY

        DECLARE @LastLoad DATETIME;

        SELECT @LastLoad = LastLoadTime
        FROM Audit.Config
        WHERE TableName = 'Students';

        -- load everything firts time
        IF @LastLoad IS NULL
            SET @LastLoad = '1900-01-01';

        -- update only changed or newer
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
                S.Name <> L.Name
                OR S.Age <> L.Age
                OR S.UpdatedAt <> L.UpdatedAt
            );

        -- insert new records
        INSERT INTO Staging.Students (Id, Name, Age, UpdatedAt)
        SELECT L.Id, L.Name, L.Age, L.UpdatedAt
        FROM Landing.Students L
        LEFT JOIN Staging.Students S
            ON L.Id = S.Id
        WHERE 
            S.Id IS NULL
            AND L.UpdatedAt > @LastLoad;

        -- update last load time
        UPDATE Audit.Config
        SET LastLoadTime = GETDATE()
        WHERE TableName = 'Students';

        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Incremental_Students', 'SUCCESS', 'Incremental load completed');

    END TRY
    BEGIN CATCH
        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Incremental_Students', 'ERROR', ERROR_MESSAGE());
    END CATCH
END;
GO