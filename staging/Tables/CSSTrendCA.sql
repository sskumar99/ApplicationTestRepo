CREATE TABLE [staging].[CSSTrendCA] (
    [LineageRowID]          INT          NOT NULL,
    [BusinessID]            BIGINT       NOT NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [CSSMonth1]             INT          NULL,
    [CSSMonth2]             INT          NULL,
    [CSSMonth3]             INT          NULL,
    [CSSMonth4]             INT          NULL,
    [CSSMonth5]             INT          NULL,
    [CSSMonth6]             INT          NULL,
    [CSSMonth7]             INT          NULL,
    [CSSMonth8]             INT          NULL,
    [CSSMonth9]             INT          NULL,
    [CSSMonth10]            INT          NULL,
    [CSSMonth11]            INT          NULL,
    [CSSMonth12]            INT          NULL,
    [ExecutionID]           INT          NOT NULL
) ON [STAGING];

