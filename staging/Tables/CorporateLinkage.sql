CREATE TABLE [staging].[CorporateLinkage] (
    [LineageRowID]               BIGINT         NOT NULL,
    [BusinessID]                 BIGINT         NULL,
    [DunsNumber]                 VARCHAR (9)    NOT NULL,
    [DataFeedEffectiveDate]      INT            NOT NULL,
    [ParentIndicator]            BIT            NULL,
    [SubsidiaryIndicator]        BIT            NULL,
    [HQIndicator]                BIT            NULL,
    [LocationType]               VARCHAR (50)   NULL,
    [DomUltimateDunsNumber]      VARCHAR (9)    NULL,
    [DomUltimateName]            NVARCHAR (255) NULL,
    [DomUltimateAddressLine1]    NVARCHAR (100) NULL,
    [DomUltimateAddressLine2]    NVARCHAR (100) NULL,
    [DomUltimateCity]            NVARCHAR (50)  NULL,
    [DomUltimateState]           NVARCHAR (50)  NULL,
    [DomUltimatePostalCode]      NVARCHAR (10)  NULL,
    [DomUltimateCountryCode]     NVARCHAR (4)   NULL,
    [GlobalUltimateDunsNumber]   VARCHAR (9)    NULL,
    [GlobalUltimateName]         NVARCHAR (255) NULL,
    [GlobalUltimateAddressLine1] NVARCHAR (100) NULL,
    [GlobalUltimateAddressLine2] NVARCHAR (100) NULL,
    [GlobalUltimateCity]         NVARCHAR (50)  NULL,
    [GlobalUltimateState]        NVARCHAR (50)  NULL,
    [GlobalUltimatePostalCode]   NVARCHAR (10)  NULL,
    [GlobalUltimateCountryCode]  NVARCHAR (4)   NULL,
    [HQDunsNumber]               VARCHAR (9)    NULL,
    [HQName]                     NVARCHAR (255) NULL,
    [HQAddressLine1]             NVARCHAR (100) NULL,
    [HQAddressLine2]             NVARCHAR (100) NULL,
    [HQCity]                     NVARCHAR (50)  NULL,
    [HQState]                    NVARCHAR (50)  NULL,
    [HQPostalCode]               NVARCHAR (10)  NULL,
    [HQCountryCode]              NVARCHAR (4)   NULL,
    [ExecutionID]                INT            NOT NULL
);






