CREATE TABLE [reference].[GEOUnitToISOCountryCodeMap] (
    [GEOUnitToISOCountryCodeMap] INT          IDENTITY (1, 1) NOT NULL,
    [GEOUnitID]                  VARCHAR (10) NULL,
    [ISOCountryAlpha2Code]       CHAR (2)     NULL,
    [EffectiveDate]              DATE         NULL,
    [ExpiredDate]                DATE         NULL
);

