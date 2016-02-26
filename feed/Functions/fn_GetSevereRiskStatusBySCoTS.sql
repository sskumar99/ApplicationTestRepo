
CREATE FUNCTION [feed].[fn_GetSevereRiskStatusBySCoTS]
/*
purpose
	returns Severe Risk Status


history
	2016.01.05 dr  created.

*/
(
		@ScotsIndicatorID		int,
		@ScotsCode				varchar(10)
)
RETURNS nvarchar(500)
AS
BEGIN
		RETURN (
					
					SELECT 
							ScotsDescription
					FROM 
							reference.ScotsCodeValues (nolock)
					WHERE 
							ScotsIndicatorID = @ScotsIndicatorID
						AND ScotsCode = @ScotsCode);

END