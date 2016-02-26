CREATE TABLE [reference].[IndustryCodeTypeCodeMap] (
    [IndustryCodeTypeCodeID]      INT           NOT NULL,
    [IndustryCodeTypeCode]        VARCHAR (10)  NULL,
    [IndustryCodeTypeDescription] VARCHAR (256) NULL,
    CONSTRAINT [PK__Industry__B184B364F01468B2] PRIMARY KEY CLUSTERED ([IndustryCodeTypeCodeID] ASC)
);

