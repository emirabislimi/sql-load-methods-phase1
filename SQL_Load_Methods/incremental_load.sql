-- BASIC INCREMENTAL (HARDCODED DATE)

CREATE OR ALTER PROCEDURE Staging.Incremental_Students
AS
BEGIN
    BEGIN TRY

        -- HARDCODED DATE (BASIC)
        DECLARE @LastLoad DATETIME = '2020-01-01'; -- CHANGED

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
            L.UpdatedAt > @LastLoad;

        -- INSERT
        INSERT INTO Staging.Students (Id, Name, Age, UpdatedAt)
        SELECT L.Id, L.Name, L.Age, L.UpdatedAt
        FROM Landing.Students L
        LEFT JOIN Staging.Students S
            ON L.Id = S.Id
        WHERE 
            S.Id IS NULL
            AND L.UpdatedAt > @LastLoad;

        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Incremental_Students', 'SUCCESS', 'Basic incremental load completed');

    END TRY
    BEGIN CATCH
        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Incremental_Students', 'ERROR', ERROR_MESSAGE());
    END CATCH
END;