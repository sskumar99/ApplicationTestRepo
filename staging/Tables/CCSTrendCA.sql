CREATE TABLE [staging].[CCSTrendCA] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [CCSMonth1]             INT          NULL,
    [CCSMonth2]             INT          NULL,
    [CCSMonth3]             INT          NULL,
    [CCSMonth4]             INT          NULL,
    [CCSMonth5]             INT          NULL,
    [CCSMonth6]             INT          NULL,
    [CCSMonth7]             INT          NULL,
    [CCSMonth8]             INT          NULL,
    [CCSMonth9]             INT          NULL,
    [CCSMonth10]            INT          NULL,
    [CCSMonth11]            INT          NULL,
    [CCSMonth12]            INT          NULL,
    [ExecutionID]           INT          NOT NULL,
    CONSTRAINT [PK_CCSTrendCA] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [STAGING]
);







