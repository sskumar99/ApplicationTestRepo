CREATE TABLE [feed].[SASDaily] (
    [BusinessID]            INT           NOT NULL,
    [DunsNumber]            VARCHAR (10)  NOT NULL,
    [DataFeedEffectiveDate] INT           NOT NULL,
    [CCSPercentile]         INT           NULL,
    [CCSClass]              INT           NULL,
    [CCSScore]              INT           NULL,
    [FSSPercentile]         INT           NULL,
    [FSSClass]              INT           NULL,
    [FSSScore]              INT           NULL,
    [SERScore]              INT           NULL,
    [LineageRowID]          VARCHAR (500) NOT NULL,
    [CreatedDate]           DATETIME      CONSTRAINT [DF_SASDaily_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]             VARCHAR (50)  NOT NULL,
    [UpdateDate]            DATETIME      NULL,
    [UpdatedBy]             VARCHAR (50)  NULL,
    CONSTRAINT [PK_SASDaily] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [FEED]
);



