CREATE TABLE [feed].[Execution] (
    [ExecutionID]             INT           IDENTITY (1, 1) NOT NULL,
    [ConfigurationID]         INT           NOT NULL,
    [ExecutionStartTime]      DATETIME2 (7) NOT NULL,
    [ExecutionEndTime]        DATETIME2 (7) NULL,
    [ExecutionStartLineageID] BIGINT        NULL,
    [ExecutionEndLineageID]   BIGINT        NULL,
    [ExecutionStatusID]       TINYINT       NOT NULL,
    [Notes]                   VARCHAR (MAX) NULL,
    [DWExecutionID]           INT           NULL,
    [ExecutionOutput]         XML           NULL,
    [CreatedDate]             DATETIME2 (7) CONSTRAINT [DF_Execution_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]               VARCHAR (50)  NOT NULL,
    [UpdatedDate]             DATETIME2 (7) NULL,
    [UpdatedBy]               VARCHAR (50)  NULL,
    CONSTRAINT [PK_Execution] PRIMARY KEY CLUSTERED ([ExecutionID] ASC) ON [FEED],
    CONSTRAINT [FK_Execution_Configuration] FOREIGN KEY ([ConfigurationID]) REFERENCES [feed].[Configuration] ([ConfigurationID]),
    CONSTRAINT [FK_Execution_ExecutionStatus] FOREIGN KEY ([ExecutionStatusID]) REFERENCES [feed].[ExecutionStatus] ([ExecutionStatusID])
) TEXTIMAGE_ON [FEED];








GO
CREATE STATISTICS [ExecutionStatusID]
    ON [feed].[Execution]([ExecutionStatusID]);


GO
CREATE STATISTICS [DWExecutionID]
    ON [feed].[Execution]([DWExecutionID]);


GO
CREATE STATISTICS [ConfigurationID]
    ON [feed].[Execution]([ConfigurationID]);

