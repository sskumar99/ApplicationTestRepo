CREATE TABLE [reference].[IndustryCode] (
    [BusinessID]              INT          NOT NULL,
    [RowID]                   INT          IDENTITY (1, 1) NOT NULL,
    [IndustryCode]            VARCHAR (50) NOT NULL,
    [IndustryTypeCode]        VARCHAR (50) NOT NULL,
    [IndustryCodeDescription] VARCHAR (50) NULL,
    [CreatedDate]             DATETIME     NOT NULL,
    [CreatedBy]               VARCHAR (50) CONSTRAINT [DF_IndustryCode_CreatedBy] DEFAULT (getutcdate()) NOT NULL,
    [UpdatedDate]             DATETIME     NULL,
    [UpdatedBy]               VARCHAR (50) NULL,
    CONSTRAINT [PK_IndustryCode] PRIMARY KEY CLUSTERED ([BusinessID] ASC, [IndustryCode] ASC, [IndustryTypeCode] ASC)
);

