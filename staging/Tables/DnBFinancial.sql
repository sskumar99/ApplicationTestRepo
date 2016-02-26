CREATE TABLE [staging].[DnBFinancial] (
    [LineageRowID]            BIGINT       NOT NULL,
    [BusinessID]              BIGINT       NULL,
    [DunsNumber]              VARCHAR (9)  NOT NULL,
    [DataFeedEffectiveDate]   INT          NOT NULL,
    [StatementType]           VARCHAR (50) NOT NULL,
    [StatementDate]           DATE         NOT NULL,
    [StatementTypeCode]       CHAR (1)     NOT NULL,
    [CashAndCashEquivalents]  VARCHAR (50) NULL,
    [AccountsReceivables]     VARCHAR (50) NULL,
    [TotalCurrentAssets]      VARCHAR (50) NULL,
    [Inventory]               VARCHAR (50) NULL,
    [FixedAssets]             VARCHAR (50) NULL,
    [TotalAssets]             VARCHAR (50) NULL,
    [AccountsPayable]         VARCHAR (50) NULL,
    [TotalCurrentLiabilities] VARCHAR (50) NULL,
    [TotalLiabilities]        VARCHAR (50) NULL,
    [NetWorth]                VARCHAR (50) NULL,
    [BankDebt]                VARCHAR (50) NULL,
    [SalesRevenue]            VARCHAR (50) NULL,
    [GrossProfit]             VARCHAR (50) NULL,
    [NetIncome]               VARCHAR (50) NULL,
    [PublicCompanyInd]        VARCHAR (50) NULL,
    [ExecutionID]             INT          NOT NULL,
    CONSTRAINT [PK_DnBFinancial] PRIMARY KEY CLUSTERED ([DunsNumber] ASC, [StatementType] ASC, [StatementDate] ASC) ON [FEED]
);



