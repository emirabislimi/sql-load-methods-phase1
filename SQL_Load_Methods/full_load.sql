-- FULL LOAD (IMPROVED- parameter+performace)

CREATE OR ALTER PROCEDURE Staging.FullLoad_Students
    @TableName VARCHAR(50) -- CHANGED: added parameter
AS
BEGIN
    BEGIN TRY

        TRUNCATE TABLE Staging.Students; -- CHANGED: better performance

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