CREATE TABLE [reference].[GEOCountryCodeMapping] (
    [GEOCountryCodeID]     INT          IDENTITY (1, 1) NOT NULL,
    [GEOUnitCode]          VARCHAR (10) NULL,
    [GEOUnitID]            VARCHAR (10) NULL,
    [GEOCodeTypeCode]      VARCHAR (10) NULL,
    [ISOCountryAlpha2Code] CHAR (2)     NULL,
    [DataPRVDCode]         VARCHAR (10) NULL,
    [EffectiveDate]        DATE         NULL,
    [EXPN_Date]            DATE         NULL,
    [ExpiredDate]          DATE         NULL,
    [CreatedBy]            VARCHAR (50) NULL,
    [CreatedDate]          DATETIME     DEFAULT (getdate()) NULL,
    [UpdatedBy]            VARCHAR (50) NULL,
    [UpdatedDate]          DATETIME     NULL
) on [PRIMARY];
GO

