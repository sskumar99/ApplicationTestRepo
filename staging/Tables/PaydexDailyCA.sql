CREATE TABLE [staging].[PaydexDailyCA] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [Paydex]                INT          NULL,
    [ExecutionID]           INT          NOT NULL
) ON [STAGING];





