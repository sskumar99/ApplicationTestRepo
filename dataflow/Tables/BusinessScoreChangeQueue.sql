CREATE TABLE [dataflow].[BusinessScoreChangeQueue] (
    [BusinessID] BIGINT  NOT NULL,
    [Priority]   TINYINT CONSTRAINT [DF_BusinessScoreChangeQueue_Priority] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_BusinessScoreChangeQueue] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [DATAFLOW]
);

