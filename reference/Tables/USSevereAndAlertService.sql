CREATE TABLE [feed].[USSevereAndAlertService] (
    [BusinessID]            INT          NOT NULL,
    [DunsNumber]            VARCHAR (10) NULL,
    [DatafeedEffictiveDate] INT          NULL,
    [Bancruptcy_YN]         BIT          NULL,
    [CreatedDate]           DATETIME     NULL,
    [CreataedBy]            VARCHAR (50) NULL,
    [UpdatedDate]           DATETIME     NULL,
    [UpdatedBy]             VARCHAR (50) NULL,
    CONSTRAINT [PK_SevereAndAlertService] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [PRIMARY]
) on [PRIMARY];
GO

