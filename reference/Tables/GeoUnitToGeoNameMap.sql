CREATE TABLE [reference].[GeoUnitToGeoNameMap] (
    [GEOUnitID]            VARCHAR (10)   NOT NULL,
    [ISOCountryAlpha2Code] CHAR (2)       NOT NULL,
    [GeoName]              NVARCHAR (192) NOT NULL,
    [LanguageCode]         INT            NOT NULL,
    CONSTRAINT [PK__GeoUnitT__0E9DCE17900B213A] PRIMARY KEY CLUSTERED ([GEOUnitID] ASC, [ISOCountryAlpha2Code] ASC, [GeoName] ASC, [LanguageCode] ASC)
);

