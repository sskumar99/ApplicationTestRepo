CREATE TABLE [reference].[CountryCode] (
    [CountryCode] VARCHAR (50) NOT NULL,
    [RowID]       INT          IDENTITY (1, 1) NOT NULL,
    [CountryName] VARCHAR (50) NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_CountryCode_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]   VARCHAR (50) NOT NULL,
    [UpdatedDate] DATETIME     NULL,
    [UpdatedBy]   VARCHAR (50) NULL,
    CONSTRAINT [PK_CountryCode] PRIMARY KEY CLUSTERED ([CountryCode] ASC)
);

