CREATE TABLE [reference].[CountryRiskScoretoRiskBandMap] (
    [CountryRiskScoretoRiskBandMapId] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ISOCountryAlpha2Code]            CHAR (2)      NOT NULL,
    [CountryRiskRating]               VARCHAR (20)  NOT NULL,
    [DerivedCountryRiskLevelName]     VARCHAR (50)  NULL,
    [DerivedCountryRiskLevelText]     VARCHAR (500) NULL,
    [CreatedDate]                     DATETIME      NOT NULL,
    [CreatedBy]                       VARCHAR (50)  NOT NULL,
    [UpdatedDate]                     DATETIME      NULL,
    [UpdatedBy]                       VARCHAR (50)  NULL,
    CONSTRAINT [pk_CountryRiskScoretoRiskBandMap] PRIMARY KEY CLUSTERED ([ISOCountryAlpha2Code] ASC, [CountryRiskRating] ASC)
);

