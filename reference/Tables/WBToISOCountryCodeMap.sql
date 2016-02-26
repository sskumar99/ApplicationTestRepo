CREATE TABLE [reference].[WBToISOCountryCodeMap] (
    [WBToISOCountryCodeMapID] INT           NOT NULL,
    [WorldBase3NumericCode]   CHAR (3)      NULL,
    [WorldBaseAlpha2Code]     CHAR (2)      NULL,
    [WorldBaseCountryName]    VARCHAR (128) NULL,
    [ISOCountryNumericCode]   CHAR (3)      NULL,
    [ISOCountryAlpha3Code]    CHAR (3)      NULL,
    [ISOCountryAlpha2Code]    CHAR (2)      NULL,
    [ISOCountryName]          VARCHAR (128) NULL,
    [FIPSAlpha2Code]          CHAR (2)      NULL,
    [Comments]                VARCHAR (200) NULL,
    [CreatedDate]             DATETIME      NULL,
    [CreatedBy]               VARCHAR (50)  NULL,
    [UpdatedDate]             DATETIME      NULL,
    [UpdatedBy]               VARCHAR (50)  NULL,
    CONSTRAINT [PK_WBToISOCountryCodeMap] PRIMARY KEY CLUSTERED ([WBToISOCountryCodeMapID] ASC)
);

