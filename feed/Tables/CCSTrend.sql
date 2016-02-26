CREATE TABLE [feed].[CCSTrend] (
    [BusinessID]           INT          NULL,
    [DunsNumber]           VARCHAR (10) NOT NULL,
    [InitialMonth]         DATE         NOT NULL,
    [ISOCountryAlpha2Code] CHAR (2)     NOT NULL,
    [CCSMonth1]            INT          NULL,
    [CCSMonth2]            INT          NULL,
    [CCSMonth3]            INT          NULL,
    [CCSMonth4]            INT          NULL,
    [CCSMonth5]            INT          NULL,
    [CCSMonth6]            INT          NULL,
    [CCSMonth7]            INT          NULL,
    [CCSMonth8]            INT          NULL,
    [CCSMonth9]            INT          NULL,
    [CCSMonth10]           INT          NULL,
    [CCSMonth11]           INT          NULL,
    [CCSMonth12]           INT          NULL,
    [LineageRowID]         BIGINT       NOT NULL,
    [ConfigurationID]      INT          NULL,
    [CreatedDate]          DATETIME     CONSTRAINT [DF_CCSTrend_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]            VARCHAR (50) NOT NULL,
    [UpdatedDate]          DATETIME     NULL,
    [UpdatedBy]            VARCHAR (50) NULL,
    CONSTRAINT [PK_CCSTrend] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [FEED]
);






GO
CREATE NONCLUSTERED INDEX [IX_CCSTrend_ISOCountryAlpha2Code]
    ON [feed].[CCSTrend]([ISOCountryAlpha2Code] ASC)
    ON [INDEX];

