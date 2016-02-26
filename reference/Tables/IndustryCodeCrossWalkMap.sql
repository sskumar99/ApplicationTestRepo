CREATE TABLE [reference].[IndustryCodeCrossWalkMap] (
    [IndustryCodeCrossWalkID]   INT          NOT NULL,
    [FromIndustryCodeTypeCode]  INT          NULL,
    [FromIndustryCode]          VARCHAR (10) NULL,
    [ToIndustryCodeTypeCode]    INT          NULL,
    [ToIndustryCode]            VARCHAR (10) NULL,
    [FromLanguageCode]          INT          NULL,
    [FromDescriptionLengthCode] INT          NULL,
    [ToLanguageCode]            INT          NULL,
    [ToDescrptionLengthCode]    INT          NULL,
    [PreferredMappingIndicator] INT          NULL,
    CONSTRAINT [PK__Industry__BF870BFDB449BE17] PRIMARY KEY CLUSTERED ([IndustryCodeCrossWalkID] ASC)
);

