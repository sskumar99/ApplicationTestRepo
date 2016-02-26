CREATE TABLE [dataflow].[BusinessWaitingQueue] (
    [BusinessID]  BIGINT   NOT NULL,
    [Stage]       TINYINT  CONSTRAINT [DF_BusinessWaitingQueue_Stage] DEFAULT ((0)) NOT NULL,
    [CreatedDate] DATETIME CONSTRAINT [DF_BusinessWaitingQueue_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_BusinessWaitingQueue] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [DATAFLOW]
);

