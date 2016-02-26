CREATE TABLE [MetaData].[EUSevereNegativeIndicator]
(
	[EUSevereNegativeIndicatorCode] INT NOT NULL  PRIMARY KEY
	,RatingText						Varchar(100) 
	,SevereNegativeDescription		Varchar(500)
	,SevereNegativeYN				Char(1)
	,[CreatedDate]					DATETIME     NULL,
    [CreatedBy]						VARCHAR (50) NULL,
    [UpdatedDate]					DATETIME     NULL,
    [UpdatedBy]						VARCHAR (50) NULL
)
on [PRIMARY]
;

GO