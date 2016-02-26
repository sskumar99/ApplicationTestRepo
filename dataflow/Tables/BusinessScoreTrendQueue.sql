CREATE TABLE [dataflow].[BusinessScoreTrendQueue] (
    [BusinessID] BIGINT      NOT NULL,
    [Priority]   TINYINT     CONSTRAINT [DF_BusinessScoreTrendQueue_Priority] DEFAULT ((1)) NOT NULL,
    [ScoreType]  VARCHAR (6) NOT NULL,
    CONSTRAINT [PK_BusinessScoreTrendQueue] PRIMARY KEY CLUSTERED ([BusinessID] ASC, [ScoreType] ASC) ON [DATAFLOW]
);

