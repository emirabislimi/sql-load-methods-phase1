CREATE OR ALTER PROCEDURE Staging.Append_Students
AS
BEGIN
    BEGIN TRY

        INSERT INTO Staging.Students (Id, Name, Age, UpdatedAt)
        SELECT L.Id, L.Name, L.Age, L.UpdatedAt
        FROM Landing.Students L
        LEFT JOIN Staging.Students S
            ON L.Id = S.Id
        WHERE S.Id IS NULL;

        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Append_Students', 'SUCCESS', 'Append completed');

    END TRY
    BEGIN CATCH
        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('Append_Students', 'ERROR', ERROR_MESSAGE());
    END CATCH
END;