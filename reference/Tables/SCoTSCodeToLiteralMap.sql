CREATE TABLE [reference].[SCoTSCodeToLiteralMap] (
    [SCoTSCodeToLiteralMapID]   INT            IDENTITY (1, 1) NOT NULL,
    [SCoTSCode]                 INT            NULL,
    [ProductLiteralDescription] NVARCHAR (768) NULL,
    [CodeTableID]               INT            NULL,
    [LanguageCode]              INT            NULL,
    [EffectiveDate]             DATETIME       NULL,
    [ExpirationDate]            DATETIME       NULL,
    CONSTRAINT [PK_SCoTSCodeToLiteralMap] PRIMARY KEY CLUSTERED ([SCoTSCodeToLiteralMapID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_SCoTSCodeToLiteralMap]
    ON [reference].[SCoTSCodeToLiteralMap]([SCoTSCode] ASC, [CodeTableID] ASC, [LanguageCode] ASC, [EffectiveDate] ASC, [ExpirationDate] ASC)
    ON [INDEX];

