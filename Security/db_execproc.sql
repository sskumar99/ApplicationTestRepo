CREATE ROLE [db_execproc]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [db_execproc] ADD MEMBER [CREDIBILITY\DB_DEV_ReadOnly];

