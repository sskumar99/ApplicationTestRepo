CREATE TABLE [reference].[PCMPacketStore] (
    [BusinessID]  INT          NOT NULL,
    [RowID]       INT          NOT NULL,
    [PacketData]  VARCHAR (50) NOT NULL,
    [PacketCode]  VARCHAR (50) NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_PCMPacketStore_CreatedDate] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]   VARCHAR (50) NOT NULL,
    [UpdatedDate] DATETIME     NULL,
    [UpdatedBy]   VARCHAR (50) NULL,
    CONSTRAINT [PK_PCMPacketStore] PRIMARY KEY CLUSTERED ([BusinessID] ASC, [RowID] ASC)
);

