CREATE TABLE [dataflow].[BusinessFinancialQueue] (
    [BusinessID] BIGINT      NOT NULL,
    [Priority]   TINYINT     CONSTRAINT [DF_BusinessFinancialQueue_Priority] DEFAULT ((1)) NOT NULL,
    [DataSource] VARCHAR (6) NOT NULL,
    [AATest] NCHAR(10) NULL, 
    [AATest2] NCHAR(10) NULL, 
    CONSTRAINT [PK_BusinessFinancialQueue] PRIMARY KEY CLUSTERED ([BusinessID] ASC, [DataSource] ASC) ON [DATAFLOW]
);


GO
CREATE STATISTICS [DataSource]
    ON [dataflow].[BusinessFinancialQueue]([DataSource])
    WITH NORECOMPUTE;

