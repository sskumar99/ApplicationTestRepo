CREATE TABLE [feed].[Identity] (
    [BusinessID]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [DunsNumber]            VARCHAR (10)   NOT NULL,
    [City]                  NVARCHAR (100) NULL,
    [Country]               CHAR (2)       NOT NULL,
    [Name]                  NVARCHAR (256) NULL,
    [TradeStyle1]           NVARCHAR (256) NULL,
    [TradeStyle2]           NVARCHAR (256) NULL,
    [TradeStyle3]           NVARCHAR (256) NULL,
    [TradeStyle4]           NVARCHAR (256) NULL,
    [TradeStyle5]           NVARCHAR (256) NULL,
    [Street1]               NVARCHAR (150) NULL,
    [Street2]               NVARCHAR (150) NULL,
    [PostalCode]            NVARCHAR (100) NULL,
    [PostalCodePlus]        NVARCHAR (100) NULL,
    [State]                 NVARCHAR (100) NULL,
    [Phone]                 NVARCHAR (100) NULL,
    [CEOName]               NVARCHAR (200) NULL,
    [LegalStructure]        NVARCHAR (500) NULL,
    [LegalFormClassCode]    INT            NULL,
    [LegalFormCode]         INT            NULL,
    [YearStarted]           INT            NULL,
    [MonthStarted]          INT            NULL,
    [DayStarted]            INT            NULL,
    [IncYear]               DATE           NULL,
    [ControlYear]           INT            NULL,
    [MovedInd]              VARCHAR (50)   NULL,
    [LineageRowID]          BIGINT         NULL,
    [DataFeedEffectiveDate] INT            NULL,
    [IsActive]              BIT            CONSTRAINT [DF_Identity_IsActive] DEFAULT ((1)) NOT NULL,
    [CreatedDate]           DATETIME       CONSTRAINT [DF_Identity_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]             VARCHAR (50)   NOT NULL,
    [UpdatedDate]           DATETIME       NULL,
    [UpdatedBy]             VARCHAR (50)   NULL,
    CONSTRAINT [PK_Identity] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [FEED]
);
















GO
CREATE NONCLUSTERED INDEX [IX_Identity_BusinessID]
    ON [feed].[Identity]([BusinessID] ASC)
    INCLUDE([DunsNumber])
    ON [INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Identity_Country]
    ON [feed].[Identity]([Country] ASC)
    INCLUDE([BusinessID])
    ON [INDEX];


GO
CREATE STATISTICS [LegalFormClassCode]
    ON [feed].[Identity]([LegalFormClassCode]);


GO
CREATE STATISTICS [IsActive]
    ON [feed].[Identity]([IsActive]);


GO
CREATE STATISTICS [IncYear]
    ON [feed].[Identity]([IncYear]);


GO
CREATE STATISTICS [DunsNumber]
    ON [feed].[Identity]([DunsNumber]);


GO
CREATE STATISTICS [DataFeedEffectiveDate]
    ON [feed].[Identity]([DataFeedEffectiveDate]);


GO
CREATE STATISTICS [Country]
    ON [feed].[Identity]([Country]);


GO
CREATE STATISTICS [BusinessID]
    ON [feed].[Identity]([BusinessID]);

