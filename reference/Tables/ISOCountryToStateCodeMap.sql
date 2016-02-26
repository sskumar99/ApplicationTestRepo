CREATE TABLE [reference].[ISOCountryToStateCodeMap] (
    [ISOCountryToStateMapID] INT           NOT NULL,
    [ISOStateProvinceCode]   VARCHAR (10)  NULL,
    [ISOStateProvinceName]   VARCHAR (256) NULL,
    [ISOPrimaryLevalName]    VARCHAR (64)  NULL,
    [ISOCountryAlpha2Code]   CHAR (2)      NULL,
    [ISOCountryAlpha3Code]   CHAR (3)      NULL,
    CONSTRAINT [PK__ISOCount__27C380760B3221F9] PRIMARY KEY CLUSTERED ([ISOCountryToStateMapID] ASC)
);

