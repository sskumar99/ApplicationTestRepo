CREATE TABLE [reference].[ScotCode] (
    [ScotCode]       INT          NOT NULL,
    [RowID]          INT          IDENTITY (1, 1) NOT NULL,
    [Transformation] VARCHAR (50) NULL,
    [CreatedDate]    DATETIME     CONSTRAINT [DF_ScotCode_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50) NOT NULL,
    [UpdatedDate]    DATETIME     NULL,
    [UpdatedBy]      VARCHAR (50) NULL,
    CONSTRAINT [PK_ScotCode] PRIMARY KEY CLUSTERED ([ScotCode] ASC)
);

