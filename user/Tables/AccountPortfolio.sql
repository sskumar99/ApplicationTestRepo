CREATE TABLE [user].[AccountPortfolio] (
    [PortfolioID]    INT            IDENTITY (1, 1) NOT NULL,
    [AccountID]      INT            NOT NULL,
    [PortfolioTitle] NVARCHAR (100) NOT NULL,
    [CreatedDate]    DATETIME       CONSTRAINT [DF_AccountPortfolio_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)   NOT NULL,
    [UpdatedDate]    DATETIME       NULL,
    [UpdatedBy]      VARCHAR (50)   NULL,
    CONSTRAINT [PK_AccountPortfolio] PRIMARY KEY CLUSTERED ([PortfolioID] ASC),
    CONSTRAINT [FK_AccountPortfolio_Account] FOREIGN KEY ([AccountID]) REFERENCES [user].[Account] ([AccountID])
);

