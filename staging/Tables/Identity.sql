CREATE TABLE [staging].[Identity] (
    [LineageRowID]          BIGINT         NOT NULL,
    [BusinessID]            BIGINT         NULL,
    [DunsNumber]            VARCHAR (10)   NOT NULL,
    [DataFeedEffectiveDate] INT            NOT NULL,
    [City]                  NVARCHAR (100) NULL,
    [Country]               NVARCHAR (100) NULL,
    [Name]                  NVARCHAR (250) NULL,
    [TradeStyle1]           NVARCHAR (250) NULL,
    [TradeStyle2]           NVARCHAR (250) NULL,
    [TradeStyle3]           NVARCHAR (250) NULL,
    [TradeStyle4]           NVARCHAR (250) NULL,
    [TradeStyle5]           NVARCHAR (250) NULL,
    [Street1]               NVARCHAR (125) NULL,
    [Street2]               NVARCHAR (125) NULL,
    [Zip]                   NVARCHAR (100) NULL,
    [Zip4]                  NVARCHAR (100) NULL,
    [State]                 NVARCHAR (100) NULL,
    [AreaCode]              NVARCHAR (100) NULL,
    [Phone]                 NVARCHAR (100) NULL,
    [CEOName]               NVARCHAR (200) NULL,
    [LegalFormCode]         NVARCHAR (100) NULL,
    [LegalFormClassCode]    NVARCHAR (100) NULL,
    [YearStarted]           VARCHAR (50)   NULL,
    [MonthStarted]          VARCHAR (50)   NULL,
    [DayStarted]            VARCHAR (50)   NULL,
    [IncYear]               VARCHAR (50)   NULL,
    [MovedInd]              VARCHAR (50)   NULL,
    [PublicPrivInd]         VARCHAR (50)   NULL,
    [StopDistribInd]        VARCHAR (50)   NULL,
    [ExecutionID]           INT            NOT NULL,
    CONSTRAINT [PK_Identity] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [STAGING]
);









