--BASIC 

CREATE PROCEDURE Staging.Sync_Students
AS
BEGIN
    BEGIN TRY
        -- UPDATE
        UPDATE S
        SET 
            S.Name = L.Name,
            S.Age = L.Age,
            S.UpdatedAt = L.UpdatedAt
        FROM Staging.Students S
        INNER JOIN Landing.Students L
            ON S.Id = L.Id;

        -- INSERT
        INSERT INTO Staging.Students (Id, Name, Age, UpdatedAt)
        SELECT L.Id, L.Name, L.Age, L.UpdatedAt
        FROM Landing.Students L
        LEFT JOIN Staging.Students S
            ON L.Id = S.Id
        WHERE S.Id IS NULL;

        -- DELETE
        DELETE S
        FROM Staging.Students S
        LEFT JOIN Landing.Students L
            ON S.Id = L.Id
        WHERE L.Id IS NULL;

        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Sync_Students', 'SUCCESS', 'Sync completed');
    END TRY
    BEGIN CATCH
        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Sync_Students', 'ERROR', ERROR_MESSAGE());
    END CATCH
END;