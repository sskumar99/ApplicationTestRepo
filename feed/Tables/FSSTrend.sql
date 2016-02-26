CREATE TABLE [feed].[FSSTrend] (
    [BusinessID]           INT          NULL,
    [DunsNumber]           VARCHAR (10) NOT NULL,
    [InitialMonth]         DATE         NOT NULL,
    [ISOCountryAlpha2Code] CHAR (2)     NOT NULL,
    [FSSMonth1]            INT          NULL,
    [FSSMonth2]            INT          NULL,
    [FSSMonth3]            INT          NULL,
    [FSSMonth4]            INT          NULL,
    [FSSMonth5]            INT          NULL,
    [FSSMonth6]            INT          NULL,
    [FSSMonth7]            INT          NULL,
    [FSSMonth8]            INT          NULL,
    [FSSMonth9]            INT          NULL,
    [FSSMonth10]           INT          NULL,
    [FSSMonth11]           INT          NULL,
    [FSSMonth12]           INT          NULL,
    [LineageRowID]         BIGINT       NOT NULL,
    [ConfigurationID]      INT          NULL,
    [CreatedDate]          DATETIME     CONSTRAINT [DF_FSSTrend_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]            VARCHAR (50) NOT NULL,
    [UpdatedDate]          DATETIME     NULL,
    [UpdatedBy]            VARCHAR (50) NULL,
    CONSTRAINT [PK_FSSTrend] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [FEED]
);








GO
CREATE NONCLUSTERED INDEX [IX_FSSTrend_ISOCountryAlpha2Code]
    ON [feed].[FSSTrend]([ISOCountryAlpha2Code] ASC)
    ON [FEED];

