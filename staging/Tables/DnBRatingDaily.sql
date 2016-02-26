CREATE TABLE [staging].[DnBRatingDaily] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [DnBRating]             VARCHAR (10) NULL,
    [ExecutionID]           INT          NOT NULL,
    CONSTRAINT [PK_DnBRatingDaily] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [STAGING]
);










GO
CREATE NONCLUSTERED INDEX [IX_STG_DnBRatingDaily_BusinessID]
    ON [staging].[DnBRatingDaily]([BusinessID] ASC)
    INCLUDE([DunsNumber])
    ON [INDEX];

