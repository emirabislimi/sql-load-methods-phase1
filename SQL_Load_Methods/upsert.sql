-- UPSERT (BASIC)

CREATE OR ALTER PROCEDURE Staging.Upsert_Students
AS
BEGIN
    BEGIN TRY

        UPDATE S
        SET 
            S.Name = L.Name,
            S.Age = L.Age,
            S.UpdatedAt = L.UpdatedAt
        FROM Staging.Students S
        INNER JOIN Landing.Students L
            ON S.Id = L.Id;
        -- basic: updates all rows

        INSERT INTO Staging.Students (Id, Name, Age, UpdatedAt)
        SELECT L.Id, L.Name, L.Age, L.UpdatedAt
        FROM Landing.Students L
        LEFT JOIN Staging.Students S
            ON L.Id = S.Id
        WHERE S.Id IS NULL;

    END TRY
    BEGIN CATCH
        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Upsert_Students', 'ERROR', ERROR_MESSAGE());
    END CATCH
END;