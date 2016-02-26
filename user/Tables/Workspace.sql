CREATE TABLE [user].[Workspace] (
    [WorkspaceID] INT          IDENTITY (1, 1) NOT NULL,
    [AccountID]   INT          NOT NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_Workspace_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]   VARCHAR (50) NOT NULL,
    [UpdatedDate] DATETIME     NULL,
    [UppdateBy]   VARCHAR (50) NULL,
    CONSTRAINT [PK_Workspace] PRIMARY KEY CLUSTERED ([WorkspaceID] ASC),
    CONSTRAINT [FK_Workspace_Account] FOREIGN KEY ([AccountID]) REFERENCES [user].[Account] ([AccountID])
);

