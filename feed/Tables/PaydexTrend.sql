CREATE TABLE [feed].[PaydexTrend] (
    [BusinessID]           INT          NULL,
    [DunsNumber]           VARCHAR (10) NOT NULL,
    [InitialMonth]         DATE         NOT NULL,
    [ISOCountryAlpha2Code] CHAR (2)     NOT NULL,
    [PaydexMonth1]         TINYINT      NULL,
    [PaydexMonth2]         TINYINT      NULL,
    [PaydexMonth3]         TINYINT      NULL,
    [PaydexMonth4]         TINYINT      NULL,
    [PaydexMonth5]         TINYINT      NULL,
    [PaydexMonth6]         TINYINT      NULL,
    [PaydexMonth7]         TINYINT      NULL,
    [PaydexMonth8]         TINYINT      NULL,
    [PaydexMonth9]         TINYINT      NULL,
    [PaydexMonth10]        TINYINT      NULL,
    [PaydexMonth11]        TINYINT      NULL,
    [PaydexMonth12]        TINYINT      NULL,
    [LineageRowID]         BIGINT       NOT NULL,
    [ConfigurationID]      INT          NOT NULL,
    [CreatedDate]          DATETIME     CONSTRAINT [DF_PaydexTrend_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]            VARCHAR (50) NOT NULL,
    [UpdatedDate]          DATETIME     NULL,
    [UpdatedBy]            VARCHAR (50) NULL,
    CONSTRAINT [PK_PaydexTrend_1] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [FEED]
);








GO
CREATE NONCLUSTERED INDEX [IX_PaydexTrend_ISOCountryAlpha2Code]
    ON [feed].[PaydexTrend]([ISOCountryAlpha2Code] ASC)
    ON [INDEX];


GO
CREATE STATISTICS [ConfigurationID]
    ON [feed].[PaydexTrend]([ConfigurationID]);


GO
CREATE STATISTICS [BusinessID]
    ON [feed].[PaydexTrend]([BusinessID]);

