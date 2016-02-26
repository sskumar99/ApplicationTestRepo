CREATE TABLE [staging].[EdgarIncomeStatement] (
    [LineageRowID]                   BIGINT        NOT NULL,
    [BusinessID]                     BIGINT        NULL,
    [DunsNumber]                     VARCHAR (9)   NOT NULL,
    [DataFeedEffectiveDate]          INT           NOT NULL,
    [StatementType]                  VARCHAR (10)  NOT NULL,
    [StatementDate]                  DATE          NOT NULL,
    [TotalRevenue]                   NVARCHAR (19) NOT NULL,
    [GrossProfit]                    NVARCHAR (19) NOT NULL,
    [EarningsBeforeInterestAndTaxes] NVARCHAR (19) NULL,
    [InterestExpense]                NVARCHAR (19) NULL,
    [IncomeBeforeTax]                NVARCHAR (19) NULL,
    [OperatingIncome]                NVARCHAR (19) NULL,
    [NetIncome]                      NVARCHAR (19) NULL,
    [TotalOtherIncomeAndExpensesNet] NVARCHAR (19) NULL,
    [ResearchAndDevelopment]         NVARCHAR (19) NULL,
    [SellingGeneralandAd]            NVARCHAR (19) NULL,
    [NonRecurring]                   NVARCHAR (19) NULL,
    [OtherOperatingExpenses]         NVARCHAR (19) NULL,
    [ExecutionID]                    INT           NOT NULL,
    CONSTRAINT [PK_EdgarIncomeStatement] PRIMARY KEY CLUSTERED ([DunsNumber] ASC, [StatementType] ASC, [StatementDate] ASC) ON [FEED]
);




GO
CREATE STATISTICS [StatementType]
    ON [staging].[EdgarIncomeStatement]([StatementType]);


GO
CREATE STATISTICS [StatementDate]
    ON [staging].[EdgarIncomeStatement]([StatementDate]);


GO
CREATE STATISTICS [ExecutionID]
    ON [staging].[EdgarIncomeStatement]([ExecutionID]);


GO
CREATE STATISTICS [BusinessID]
    ON [staging].[EdgarIncomeStatement]([BusinessID]);

