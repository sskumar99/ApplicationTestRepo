CREATE TABLE [dataflow].[BusinessRiskIndicatorChangeQueue] (
    [BusinessID] BIGINT  NOT NULL,
    [Priority]   TINYINT CONSTRAINT [DF_BusinessRiskIndicatorChangeQueue_Priority] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_BusinessRiskIndicatorChangeQueue] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [DATAFLOW]
);

