CREATE TABLE [reference].[IndustryCodeToDescMap] (
    [IndustryCodeDescMapID] INT         NOT NULL,
    [IndustryCode]          NCHAR (48)  NULL,
    [IndustryCodeDigits]    TINYINT     NULL,
    [IndustryCodeTypeCode]  INT         NULL,
    [LanguageCode]          INT         NULL,
    [DescriptionText]       NCHAR (786) NULL,
    [DescriptionLengthCode] INT         NULL,
    CONSTRAINT [PK__Industry__400DFADB93E825D1] PRIMARY KEY CLUSTERED ([IndustryCodeDescMapID] ASC)
);

