CREATE TABLE [feed].[CorporateLinkage] (
    [DunsNumber]                 VARCHAR (9)    NOT NULL,
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
    [DomUltimateCountryCode]     CHAR (2)       NULL,
    [GlobalUltimateDunsNumber]   VARCHAR (9)    NULL,
    [GlobalUltimateName]         NVARCHAR (255) NULL,
    [GlobalUltimateAddressLine1] NVARCHAR (100) NULL,
    [GlobalUltimateAddressLine2] NVARCHAR (100) NULL,
    [GlobalUltimateCity]         NVARCHAR (50)  NULL,
    [GlobalUltimateState]        NVARCHAR (50)  NULL,
    [GlobalUltimatePostalCode]   NVARCHAR (10)  NULL,
    [GlobalUltimateCountryCode]  CHAR (2)       NULL,
    [HQDunsNumber]               VARCHAR (9)    NULL,
    [HQName]                     NVARCHAR (255) NULL,
    [HQAddressLine1]             NVARCHAR (100) NULL,
    [HQAddressLine2]             NVARCHAR (100) NULL,
    [HQCity]                     NVARCHAR (50)  NULL,
    [HQState]                    NVARCHAR (50)  NULL,
    [HQPostalCode]               NVARCHAR (10)  NULL,
    [HQCountryCode]              CHAR (2)       NULL,
    [LineageRowID]               BIGINT         NOT NULL,
    [DataFeedEffectiveDate]      INT            NOT NULL,
    [CreatedDate]                DATETIME       CONSTRAINT [DF_CorporateLinkage_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]                  VARCHAR (50)   NOT NULL,
    [UpdatedDate]                DATETIME       NULL,
    [UpdatedBy]                  VARCHAR (50)   NULL,
    CONSTRAINT [PK_CorporateLinkage] PRIMARY KEY CLUSTERED ([DunsNumber] ASC) ON [FEED]
);









