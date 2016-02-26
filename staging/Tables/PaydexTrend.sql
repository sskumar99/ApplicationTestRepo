CREATE TABLE [staging].[PaydexTrend] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [PaydexMonth1]          INT          NULL,
    [PaydexMonth2]          INT          NULL,
    [PaydexMonth3]          INT          NULL,
    [PaydexMonth4]          INT          NULL,
    [PaydexMonth5]          INT          NULL,
    [PaydexMonth6]          INT          NULL,
    [PaydexMonth7]          INT          NULL,
    [PaydexMonth8]          INT          NULL,
    [PaydexMonth9]          INT          NULL,
    [PaydexMonth10]         INT          NULL,
    [PaydexMonth11]         INT          NULL,
    [PaydexMonth12]         INT          NULL,
    [ExecutionID]           INT          NOT NULL,
    CONSTRAINT [PK_PaydexTrend_2] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [STAGING]
);





