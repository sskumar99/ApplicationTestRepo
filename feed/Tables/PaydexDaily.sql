CREATE TABLE [feed].[PaydexDaily] (
    [BusinessID]            INT          NOT NULL,
    [DunsNumber]            VARCHAR (10) NOT NULL,
    [DataFeedEffectiveDate] INT          NOT NULL,
    [Paydex]                TINYINT      NULL,
    [LineageRowID]          BIGINT       NOT NULL,
    [CreatedDate]           DATETIME     CONSTRAINT [DF_PaydexDaily_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]             VARCHAR (50) NOT NULL,
    [UpdateDate]            DATETIME     NULL,
    [UpdatedBy]             VARCHAR (50) NULL,
    CONSTRAINT [PK_PaydexDaily] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [FEED]
);










GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PaydexDaily_DunsNumber]
    ON [feed].[PaydexDaily]([DunsNumber] ASC)
    INCLUDE([BusinessID])
    ON [INDEX];

