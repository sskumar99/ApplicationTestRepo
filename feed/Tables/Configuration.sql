CREATE TABLE [feed].[Configuration] (
    [ConfigurationID]   INT          NOT NULL,
    [FeedName]          VARCHAR (50) NOT NULL,
    [SSISPackageName]   VARCHAR (50) NOT NULL,
    [Settings]          XML          NULL,
    [IsActive]          BIT          CONSTRAINT [DF_Configuration_IsActive] DEFAULT ((0)) NULL,
    [GroupName]         VARCHAR (50) NULL,
    [SortOrder]         INT          CONSTRAINT [DF_Configuration_SortOrder] DEFAULT ((0)) NOT NULL,
    [GroupSortOrder]    INT          CONSTRAINT [DF_Configuration_GroupSortOrder] DEFAULT ((0)) NOT NULL,
    [DWConfigurationID] INT          NULL,
    [CreatedDate]       DATETIME     CONSTRAINT [DF_Configuration_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]         VARCHAR (50) NOT NULL,
    [UpdateDate]        DATETIME     NULL,
    [UpdatedBy]         VARCHAR (50) NULL,
    CONSTRAINT [PK_Configuration] PRIMARY KEY CLUSTERED ([ConfigurationID] ASC) ON [FEED],
    CONSTRAINT [CK_Configuration_EUTrend_AlwaysNotActive] CHECK ([ConfigurationID]<>(24) OR [ConfigurationID]=(24) AND [IsActive]=(0))
) TEXTIMAGE_ON [FEED];








GO
CREATE STATISTICS [SSISPackageName]
    ON [feed].[Configuration]([SSISPackageName]);


GO
CREATE STATISTICS [IsActive]
    ON [feed].[Configuration]([IsActive]);


GO
CREATE STATISTICS [FeedName]
    ON [feed].[Configuration]([FeedName]);

