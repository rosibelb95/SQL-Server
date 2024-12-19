



BACKUP LOG [IntBase] TO  DISK = N'D:\RespaldoLog\IntBase.bak'


USE [IntBase]
 GO 
 DBCC SHRINKFILE (N'IntBase', 0, TRUNCATEONLY)
 GO 