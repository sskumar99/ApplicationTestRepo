CREATE TABLE [staging].[PaydexDaily] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [Paydex]                INT          NULL,
    [ExecutionID]           INT          NOT NULL,
    CONSTRAINT [PK_PaydexDaily] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [STAGING]
);












GO
CREATE NONCLUSTERED INDEX [IX_STG_PaydexDaily_BusinessID]
    ON [staging].[PaydexDaily]([BusinessID] ASC)
    INCLUDE([DunsNumber])
    ON [INDEX];

