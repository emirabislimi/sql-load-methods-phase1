CREATE PROCEDURE Full_Load
AS
BEGIN
    INSERT INTO target_table
    SELECT * FROM source_table;
END