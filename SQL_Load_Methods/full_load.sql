CREATE OR ALTER PROCEDURE Staging.FullLoad_Students
AS
BEGIN
    BEGIN TRY
        DELETE FROM Staging.Students;

        INSERT INTO Staging.Students (Id, Name, Age, UpdatedAt)
        SELECT Id, Name, Age, UpdatedAt
        FROM Landing.Students;

        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('FullLoad_Students', 'SUCCESS', 'Full load completed');
    END TRY
    BEGIN CATCH
        INSERT INTO Audit.Logs (ProcedureName, Status, Message)
        VALUES ('FullLoad_Students', 'ERROR', ERROR_MESSAGE());
    END CATCH
END;