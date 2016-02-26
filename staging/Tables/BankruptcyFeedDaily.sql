CREATE TABLE [staging].[BankruptcyFeedDaily] (
    [LineageRowID]          BIGINT       NOT NULL,
    [BusinessID]            BIGINT       NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [StatusCode]            VARCHAR (25) NULL,
    [Status]                VARCHAR (25) NULL,
    [ExecutionID]           INT          NOT NULL,
    CONSTRAINT [PK_BankruptcyFeedDaily] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [STAGING]
);


GO
CREATE NONCLUSTERED INDEX [IX_BankruptcyFeedDaily_BusinessID]
    ON [staging].[BankruptcyFeedDaily]([BusinessID] ASC)
    ON [INDEX];

