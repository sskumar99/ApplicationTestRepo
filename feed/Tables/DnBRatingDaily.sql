CREATE TABLE [feed].[DnBRatingDaily] (
    [BusinessID]            BIGINT        NOT NULL,
    [DunsNumber]            VARCHAR (10)  NOT NULL,
    [DataFeedEffectiveDate] INT           NOT NULL,
    [DnBRating]             VARCHAR (10)  NULL,
    [LineageRowID]          BIGINT        NOT NULL,
    [RiskIndicator]         NVARCHAR (15) NULL,
    [FinancialStrength]     NVARCHAR (15) NULL,
    [CreatedDate]           DATETIME      CONSTRAINT [DF_DnBRatingDaily_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]             VARCHAR (50)  NOT NULL,
    [UpdateDate]            DATETIME      NULL,
    [UpdatedBy]             VARCHAR (50)  NULL,
    CONSTRAINT [PK_DnBRatingDaily] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [FEED]
);














GO
CREATE STATISTICS [DunsNumber]
    ON [feed].[DnBRatingDaily]([DunsNumber]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DnbRatingDaily_DunsNumber]
    ON [feed].[DnBRatingDaily]([DunsNumber] ASC)
    INCLUDE([BusinessID])
    ON [INDEX];

