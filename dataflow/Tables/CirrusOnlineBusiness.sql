CREATE TABLE [dataflow].[CirrusOnlineBusiness] (
    [CirrusOnlineBusinessID] INT           IDENTITY (1, 1) NOT NULL,
    [BusinessID]             BIGINT        NOT NULL,
    [DunsNumber]             VARCHAR (10)  NOT NULL,
    [ActivityDetailLogID]    BIGINT        NULL,
    [ISOCountryAlpha2Code]   CHAR (2)      NOT NULL,
    [FirstTimeProcessedDate] DATETIME2 (7) NULL,
    [CreatedDate]            DATETIME2 (7) CONSTRAINT [DF_CirrusOnlineBusiness_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]              VARCHAR (50)  NOT NULL,
    [UpdateDate]             DATETIME2 (7) NULL,
    [UpdatedBy]              VARCHAR (50)  NULL,
    CONSTRAINT [PK_CirrusOnlineBusiness] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [DATAFLOW],
    CONSTRAINT [CK_CirrusOnlineBusiness_ISOCountryAlpha2Code] CHECK ([ISOCountryAlpha2Code]='BE' OR [ISOCountryAlpha2Code]='NL' OR [ISOCountryAlpha2Code]='LU' OR [ISOCountryAlpha2Code]='IE' OR [ISOCountryAlpha2Code]='GB' OR [ISOCountryAlpha2Code]='US' OR [ISOCountryAlpha2Code]='CA')
);














GO
CREATE NONCLUSTERED INDEX [IX_CirrusOnlineBusiness_CirrusOnlineBusiness]
    ON [dataflow].[CirrusOnlineBusiness]([ISOCountryAlpha2Code] ASC)
    INCLUDE([BusinessID])
    ON [INDEX];


GO
CREATE STATISTICS [DunsNumber]
    ON [dataflow].[CirrusOnlineBusiness]([DunsNumber]);


GO
CREATE STATISTICS [FirstTimeProcessedDate]
    ON [dataflow].[CirrusOnlineBusiness]([FirstTimeProcessedDate]);

