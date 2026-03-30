INSERT INTO target_table
SELECT * FROM source_table
WHERE id NOT IN (SELECT id FROM target_table);