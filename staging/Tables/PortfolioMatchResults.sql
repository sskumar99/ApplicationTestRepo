CREATE TABLE [staging].[PortfolioMatchResults] (
    [LineageRowID]          BIGINT         NOT NULL,
    [BusinessID]            BIGINT         NULL,
    [DataFeedEffectiveDate] INT            NOT NULL,
    [DunsNumber]            VARCHAR (9)    NOT NULL,
    [BusinessName]          NVARCHAR (255) NULL,
    [AddressLine1]          NVARCHAR (150) NULL,
    [AddressLine2]          NVARCHAR (150) NULL,
    [City]                  NVARCHAR (125) NULL,
    [StateProvince]         NVARCHAR (50)  NULL,
    [StateProvinceCode]     NVARCHAR (3)   NULL,
    [Country]               NVARCHAR (125) NULL,
    [CountryCode]           NVARCHAR (2)   NOT NULL,
    [CountyCode]            NVARCHAR (50)  NULL,
    [PostalCode]            VARCHAR (25)   NULL,
    [ExecutionID]           INT            NOT NULL
) ON [STAGING];

