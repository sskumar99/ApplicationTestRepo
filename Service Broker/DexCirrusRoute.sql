DECLARE @Cmd NVARCHAR(4000);

SET @Cmd = N'USE msdb
CREATE ROUTE DexCirrusRoute
WITH SERVICE_NAME =
       N''UniverseDexService'',
     ADDRESS = N''LOCAL''';

EXEC (@Cmd);
GO