CREATE QUEUE [dataflow].[UniverseQueue]
    WITH ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dataflow].[ProcessQueue], MAX_QUEUE_READERS = 1, EXECUTE AS N'dbo')
    ON [DATAFLOW];



