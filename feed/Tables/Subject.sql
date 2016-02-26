CREATE TABLE [feed].[Subject] (
    [BusinessID]            INT            NOT NULL,
    [DunsNumber]            VARCHAR (10)   NOT NULL,
    [ElementID]             NVARCHAR (2)   NOT NULL,
    [ElementDescription]    VARCHAR (500)  NOT NULL,
    [ElementValue]          NVARCHAR (500) NULL,
    [DatafeedEffectiveDate] INT            NOT NULL,
    [LineageRowID]          BIGINT         NOT NULL,
    [CreatedDate]           DATETIME       CONSTRAINT [DF_Subject_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]             VARCHAR (50)   NOT NULL,
    [UpdatedDate]           DATETIME       NULL,
    [UpdatedBy]             VARCHAR (50)   NULL,
	[RiskIndicatorStatus]   NVARCHAR (500) NULL,
    CONSTRAINT [PK_Subject] PRIMARY KEY CLUSTERED ([BusinessID] ASC, [ElementID] ASC) ON [FEED]
);





