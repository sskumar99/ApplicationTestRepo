CREATE TABLE [staging].[CCSFSSTrend] (
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
    CONSTRAINT [PK_CCSFSSTrend] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [STAGING]
);







