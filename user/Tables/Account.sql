CREATE TABLE [user].[Account] (
    [AccountID]   INT            IDENTITY (1, 1) NOT NULL,
    [AccountName] NVARCHAR (100) NOT NULL,
    [CreatedDate] DATETIME       CONSTRAINT [DF_Account_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]   VARCHAR (50)   NOT NULL,
    [UpdatedDate] DATETIME       NULL,
    [UpdatedBy]   VARCHAR (50)   NULL,
    CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED ([AccountID] ASC)
);

