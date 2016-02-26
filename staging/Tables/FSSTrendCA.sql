CREATE TABLE [staging].[FSSTrendCA] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [FSSMonth1]             INT          NULL,
    [FSSMonth2]             INT          NULL,
    [FSSMonth3]             INT          NULL,
    [FSSMonth4]             INT          NULL,
    [FSSMonth5]             INT          NULL,
    [FSSMonth6]             INT          NULL,
    [FSSMonth7]             INT          NULL,
    [FSSMonth8]             INT          NULL,
    [FSSMonth9]             INT          NULL,
    [FSSMonth10]            INT          NULL,
    [FSSMonth11]            INT          NULL,
    [FSSMonth12]            INT          NULL,
    [ExecutionID]           INT          NOT NULL,
    CONSTRAINT [PK_FSSTrendCA] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [STAGING]
);







