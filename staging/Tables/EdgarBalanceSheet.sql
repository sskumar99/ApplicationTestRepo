CREATE TABLE [staging].[EdgarBalanceSheet] (
    [LineageRowID]            BIGINT        NOT NULL,
    [BusinessID]              BIGINT        NULL,
    [DunsNumber]              VARCHAR (9)   NOT NULL,
    [DataFeedEffectiveDate]   INT           NOT NULL,
    [StatementType]           VARCHAR (10)  NOT NULL,
    [StatementDate]           DATE          NOT NULL,
    [CashandCashEquivalents]  NVARCHAR (19) NULL,
    [NetReceivables]          NVARCHAR (19) NULL,
    [TotalCurrentAssets]      NVARCHAR (19) NULL,
    [NetTangibleAssets]       NVARCHAR (19) NULL,
    [NetFixedAssets]          NVARCHAR (19) NULL,
    [Inventory]               NVARCHAR (19) NULL,
    [TotalAssets]             NVARCHAR (19) NULL,
    [AccountsPayable]         NVARCHAR (19) NULL,
    [TotalCurrentLiabilities] NVARCHAR (19) NULL,
    [TotalLiabilities]        NVARCHAR (19) NULL,
    [NetWorth]                NVARCHAR (19) NULL,
    [IntangibleAssets]        NVARCHAR (19) NULL,
    [Goodwill]                NVARCHAR (19) NULL,
    [ExecutionID]             INT           NOT NULL,
    CONSTRAINT [PK_EdgarBalanceSheet] PRIMARY KEY CLUSTERED ([DunsNumber] ASC, [StatementType] ASC, [StatementDate] ASC) ON [FEED]
);






GO
CREATE STATISTICS [StatementType]
    ON [staging].[EdgarBalanceSheet]([StatementType]);


GO
CREATE STATISTICS [StatementDate]
    ON [staging].[EdgarBalanceSheet]([StatementDate]);


GO
CREATE STATISTICS [ExecutionID]
    ON [staging].[EdgarBalanceSheet]([ExecutionID]);


GO
CREATE STATISTICS [DunsNumber]
    ON [staging].[EdgarBalanceSheet]([DunsNumber]);


GO
CREATE STATISTICS [BusinessID]
    ON [staging].[EdgarBalanceSheet]([BusinessID]);

