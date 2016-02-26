Create Table reference.ScotsIndicator
(
	ScotsIndicatorId				Int Not NULL Identity(1,1) Primary Key
	,ScotsIndicatorName				Varchar(100) Not Null
	,CreatedDate					datetime	Not NULL
	,CreatedBy						Varchar(50) Not NULL
	,UpdatedDate					datetime
	,UpdatedBy						Varchar(50)
)
