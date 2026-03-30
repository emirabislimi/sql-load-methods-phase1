CREATE PROCEDURE Append_Data
AS
BEGIN
    INSERT INTO target_table (id, name)
    SELECT id, name FROM source_table;
END