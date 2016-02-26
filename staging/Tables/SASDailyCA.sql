CREATE TABLE [staging].[SASDailyCA] (
    [LineageRowID]          VARCHAR (500) NOT NULL,
    [BusinessID]            BIGINT        NULL,
    [DunsNumber]            VARCHAR (10)  NOT NULL,
    [DataFeedEffectiveDate] INT           NOT NULL,
    [CCSPercentile]         INT           NULL,
    [CCSClass]              INT           NULL,
    [CCSScore]              INT           NULL,
    [FSSPercentile]         INT           NULL,
    [FSSClass]              INT           NULL,
    [FSSScore]              INT           NULL,
    [ExecutionID]           INT           NOT NULL
) ON [STAGING];





