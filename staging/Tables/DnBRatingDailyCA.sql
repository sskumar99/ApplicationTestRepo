CREATE TABLE [staging].[DnBRatingDailyCA] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [DnBRating]             VARCHAR (10) NULL,
    [ExecutionID]           INT          NOT NULL
) ON [STAGING];





