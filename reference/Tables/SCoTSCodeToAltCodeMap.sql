CREATE TABLE [reference].[SCoTSCodeToAltCodeMap] (
    [SCoTSCodeToAltCodeMapID] INT          IDENTITY (1, 1) NOT NULL,
    [SCoTSCode]               INT          NULL,
    [AltSchemaCodeVal]        VARCHAR (10) NULL,
    [EffectiveDate]           DATETIME     NULL,
    [ExpirationDate]          DATETIME     NULL,
    CONSTRAINT [PK_SCoTSCodeToAltCodeMap] PRIMARY KEY CLUSTERED ([SCoTSCodeToAltCodeMapID] ASC)
);




GO
CREATE STATISTICS [ExpirationDate]
    ON [reference].[SCoTSCodeToAltCodeMap]([ExpirationDate]);


GO
CREATE STATISTICS [EffectiveDate]
    ON [reference].[SCoTSCodeToAltCodeMap]([EffectiveDate]);

