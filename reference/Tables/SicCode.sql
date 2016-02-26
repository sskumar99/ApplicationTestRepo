CREATE TABLE [reference].[SicCode] (
    [RowID]       INT          IDENTITY (1, 1) NOT NULL,
    [SicCode]     VARCHAR (50) NOT NULL,
    [Description] VARCHAR (50) NULL,
    [CreatedDate] DATETIME     NOT NULL,
    [CreatedBy]   VARCHAR (50) NOT NULL,
    [UpdatedDate] VARCHAR (50) NULL,
    [UpdatedBy]   VARCHAR (50) NULL,
    CONSTRAINT [PK_SicCode] PRIMARY KEY CLUSTERED ([SicCode] ASC)
);

