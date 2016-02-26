CREATE TABLE [reference].[DescriptionLength] (
    [DescriptionLengthCodeID]          INT            NOT NULL,
    [DescriptionLengthCode]            INT            NULL,
    [DescriptionLengthCodeDescription] NVARCHAR (256) NULL,
    CONSTRAINT [PK_DescriptionLength] PRIMARY KEY CLUSTERED ([DescriptionLengthCodeID] ASC)
);

