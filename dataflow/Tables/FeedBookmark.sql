CREATE TABLE [dataflow].[FeedBookmark] (
    [FeedBookMarkID]   INT           IDENTITY (1, 1) NOT NULL,
    [FeedBookmarkType] VARCHAR (55)  NOT NULL,
    [RowsProcessed]    INT           NULL,
    [LineageRowID]     BIGINT        NOT NULL,
    [FileDir]          VARCHAR (255) NULL,
    [FileName]         VARCHAR (255) NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [CreatedBy]        VARCHAR (55)  NOT NULL,
    CONSTRAINT [PK_FeedBookmark] PRIMARY KEY CLUSTERED ([FeedBookMarkID] DESC)
);



GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UN_FeedBookmark_FeedBookmarkType_LineageRowID]
    ON [dataflow].[FeedBookmark]([FeedBookmarkType] ASC, [LineageRowID] ASC);

