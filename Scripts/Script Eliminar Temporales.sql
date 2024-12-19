SELECT 'DROP TABLE '+s.name+'.'+t.name
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.name LIKE 'temfac%'