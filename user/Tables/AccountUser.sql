CREATE TABLE [user].[AccountUser] (
    [AccountID]   INT            NOT NULL,
    [UserID]      INT            IDENTITY (1, 1) NOT NULL,
    [RoleID]      NVARCHAR (100) NOT NULL,
    [CreatedDate] DATETIME       CONSTRAINT [DF_AccountUser_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]   VARCHAR (50)   NOT NULL,
    [UpdatedDate] DATETIME       NULL,
    [UpdatedBy]   VARCHAR (50)   NULL,
    CONSTRAINT [PK_AccountUser] PRIMARY KEY CLUSTERED ([AccountID] ASC, [UserID] ASC),
    CONSTRAINT [FK_AccountUser_Account] FOREIGN KEY ([AccountID]) REFERENCES [user].[Account] ([AccountID])
);

