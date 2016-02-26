﻿CREATE TABLE [feed].[Paydex] (
    [BusinessID]   INT          NOT NULL,
    [DunsNumber]   VARCHAR (10) NOT NULL,
    [Paydex]       INT          NULL,
    [DnBRating]    INT          NULL,
    [RowID]        INT          NOT NULL,
    [RecordNO]     INT          NULL,
    [DataFeedDate] INT          NULL,
    [ScoreType]    INT          NULL,
    [1MonthAgo]    INT          NULL,
    [2MonthAgo]    INT          NULL,
    [3MonthAgo]    INT          NULL,
    [4MonthAgo]    INT          NULL,
    [5MonthAgo]    INT          NULL,
    [6MonthAgo]    INT          NULL,
    [7MonthAgo]    INT          NULL,
    [8MonthAgo]    INT          NULL,
    [9MonthAgo]    INT          NULL,
    [10MonthAgo]   INT          NULL,
    [11MonthAgo]   INT          NULL,
    [12MonthAgo]   INT          NULL,
    [CreatedDate]  DATETIME     CONSTRAINT [DF_Paydex_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]    VARCHAR (50) NOT NULL,
    [UpdateDate]   DATETIME     NULL,
    [UpdatedBy]    VARCHAR (50) NULL,
    CONSTRAINT [PK_Paydex] PRIMARY KEY CLUSTERED ([BusinessID] ASC) ON [FEED]
);

