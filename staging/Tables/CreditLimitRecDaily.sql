CREATE TABLE [staging].[CreditLimitRecDaily] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [PrimarySIC]            VARCHAR (4)  NULL,
    [EmpTotal]              VARCHAR (9)  NULL,
    [OBIndicator]           VARCHAR (1)  NULL,
    [BankruptcyIndicator]   VARCHAR (1)  NULL,
    [BDIndicator]           VARCHAR (1)  NULL,
    [BDDate]                VARCHAR (8)  NULL,
    [ExecutionID]           INT          NOT NULL
) ON [STAGING];



