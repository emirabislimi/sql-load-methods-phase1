USE ETL_Project;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Landing')
    EXEC('CREATE SCHEMA Landing');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Staging')
    EXEC('CREATE SCHEMA Staging');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'DW')
    EXEC('CREATE SCHEMA DW');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Audit')
    EXEC('CREATE SCHEMA Audit');
GO

