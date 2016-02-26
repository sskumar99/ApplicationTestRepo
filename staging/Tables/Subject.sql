CREATE TABLE [staging].[Subject] (
    [LineageRowID]          BIGINT         NOT NULL,
    [BusinessID]            BIGINT         NULL,
    [DunsNumber]            VARCHAR (10)   NOT NULL,
    [DataFeedEffectiveDate] INT            NOT NULL,
    [ElementID]             NVARCHAR (2)   NOT NULL,
    [ElementDescription]    VARCHAR (500)  NULL,
    [ElementValue]          NVARCHAR (500) NULL,
    [ExecutionID]           INT            NULL,
    CONSTRAINT [PK_Subject] PRIMARY KEY CLUSTERED ([DunsNumber] ASC, [ElementID] ASC) ON [STAGING]
);








GO
CREATE NONCLUSTERED INDEX [IX_STG_Subject_BusinessIDElementID]
    ON [staging].[Subject]([BusinessID] ASC, [ElementID] ASC)
    INCLUDE([DunsNumber])
    ON [INDEX];


GO
CREATE STATISTICS [ElementID]
    ON [staging].[Subject]([ElementID])
    WITH NORECOMPUTE;

