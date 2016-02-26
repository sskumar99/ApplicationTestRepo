CREATE TABLE [user].[PortfolioBusiness] (
    [PortfolioID] INT          NOT NULL,
    [BusinessID]  INT          NOT NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_PortfolioBusiness_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]   VARCHAR (50) NOT NULL,
    [UpdatedDate] DATETIME     NULL,
    [UpdatedBy]   VARCHAR (50) NULL,
    CONSTRAINT [PK_PortfolioBusiness] PRIMARY KEY CLUSTERED ([PortfolioID] ASC, [BusinessID] ASC),
    CONSTRAINT [FK_PortfolioBusiness_AccountPortfolio] FOREIGN KEY ([PortfolioID]) REFERENCES [user].[AccountPortfolio] ([PortfolioID])
);

