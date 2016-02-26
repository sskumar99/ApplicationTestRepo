CREATE TABLE [feed].[ExecutionStatus] (
    [ExecutionStatusID] TINYINT      NOT NULL,
    [ExecutionStatus]   VARCHAR (50) NOT NULL,
    [StoppageFlag]      BIT          CONSTRAINT [DF_ExecutionStatus_StoppageFlag] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ExecutionStatus] PRIMARY KEY CLUSTERED ([ExecutionStatusID] ASC) ON [FEED]
);



