CREATE TABLE [feed].[CssFss] (
    [BusinessID]                   INT          NOT NULL,
    [DunsNumber]                   VARCHAR (10) NOT NULL,
    [CommercialCreditScore]        VARCHAR (50) NULL,
    [CommercialCreditScoreClass]   VARCHAR (50) NULL,
    [CommercialCreditScorePercent] VARCHAR (50) NULL,
    [FinancialStressScore]         VARCHAR (50) NULL,
    [FinancialStressScoreClass]    VARCHAR (50) NULL,
    [FinancialStressScorePercent]  VARCHAR (50) NULL,
    [CreatedDate]                  DATETIME     CONSTRAINT [DF_CssFss_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]                    VARCHAR (50) NOT NULL,
    [UpdatedDate]                  DATETIME     NULL,
    [UpdatedBy]                    VARCHAR (50) NULL,
    CONSTRAINT [PK_CssFss] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [FEED]
);

