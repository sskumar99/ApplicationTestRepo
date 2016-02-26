Create table reference.ScotsCodeValues
(
	ScotsCode			INT Not NULL
	,ScotsIndicatorID	INT	Not NULL
	,RatingText			Varchar(100)
	,YNIndicator		bit
	,ScotsDescription	Varchar(500)
	,CreatedDate					datetime	Not NULL
	,CreatedBy						Varchar(50) Not NULL
	,UpdatedDate					datetime
	,UpdatedBy						Varchar(50) 
	,Constraint pk_ScotsCodeValues	Primary Key (ScotsCode,ScotsIndicatorID)
	
)
