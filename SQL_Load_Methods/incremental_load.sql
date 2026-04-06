INSERT INTO Audit.Config VALUES ('Students', '2000-01-01');

CREATE PROCEDURE Staging.Incremental_Students
AS
BEGIN
    BEGIN TRY
        DECLARE @LastLoad DATETIME;

        SELECT @LastLoad = LastLoadTime
        FROM Audit.Config
        WHERE TableName = 'Students';

        -- UPDATE existing
        UPDATE S
        SET 
            S.Name = L.Name,
            S.Age = L.Age,
            S.UpdatedAt = L.UpdatedAt
        FROM Staging.Students S
        INNER JOIN Landing.Students L
            ON S.Id = L.Id
        WHERE L.UpdatedAt > @LastLoad;

        -- INSERT new
        INSERT INTO Staging.Students (Id, Name, Age, UpdatedAt)
        SELECT L.Id, L.Name, L.Age, L.UpdatedAt
        FROM Landing.Students L
        LEFT JOIN Staging.Students S
            ON L.Id = S.Id
        WHERE S.Id IS NULL
          AND L.UpdatedAt > @LastLoad;

        -- UPDATE config
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