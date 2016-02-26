CREATE TABLE [staging].[EdgarCashFlow] (
    [LineageRowID]                     BIGINT        NOT NULL,
    [BusinessID]                       BIGINT        NULL,
    [DunsNumber]                       VARCHAR (9)   NOT NULL,
    [DataFeedEffectiveDate]            INT           NOT NULL,
    [StatementType]                    NVARCHAR (50) NOT NULL,
    [StatementDate]                    DATE          NOT NULL,
    [Depreciation]                     NVARCHAR (19) NULL,
    [CashFlowsfromFinancingActivities] NVARCHAR (19) NULL,
    [CashFlowsfromInvestingActivities] NVARCHAR (19) NULL,
    [ChangeinCashandCashEquivalents]   NVARCHAR (19) NULL,
    [CashFlowsfromOperatingActivities] NVARCHAR (19) NULL,
    [CapitalExpenditures]              NVARCHAR (19) NULL,
    [TotalSharesOutstanding]           NVARCHAR (19) NULL,
    [ExecutionID]                      INT           NOT NULL,
    CONSTRAINT [PK_EdgarCashFlow] PRIMARY KEY CLUSTERED ([DunsNumber] ASC, [StatementType] ASC, [StatementDate] ASC) ON [FEED]
);




GO
CREATE STATISTICS [StatementType]
    ON [staging].[EdgarCashFlow]([StatementType]);


GO
CREATE STATISTICS [StatementDate]
    ON [staging].[EdgarCashFlow]([StatementDate]);


GO
CREATE STATISTICS [ExecutionID]
    ON [staging].[EdgarCashFlow]([ExecutionID]);


GO
CREATE STATISTICS [BusinessID]
    ON [staging].[EdgarCashFlow]([BusinessID]);

