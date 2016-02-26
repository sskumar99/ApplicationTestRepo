CREATE TABLE [dataflow].[BusinessProfileChangeQueue] (
    [BusinessID] BIGINT  NOT NULL,
    [Priority]   TINYINT CONSTRAINT [DF_BusinessProfileChangeQueue_Priority] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_BusinessProfileChangeQueue] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [DATAFLOW]
);

