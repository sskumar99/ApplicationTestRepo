CREATE TABLE [staging].[SubjectCA] (
    [LineageRowID]          BIGINT         NOT NULL,
    [BusinessID]            BIGINT         NULL,
    [DunsNumber]            VARCHAR (10)   NOT NULL,
    [DataFeedEffectiveDate] INT            NOT NULL,
    [ElementID]             NVARCHAR (2)   NULL,
    [ElementDescription]    VARCHAR (500)  NULL,
    [ElementValue]          NVARCHAR (500) NULL,
    [ExecutionID]           INT            NULL
) ON [STAGING];





