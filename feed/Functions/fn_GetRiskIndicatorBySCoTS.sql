
CREATE FUNCTION feed.fn_GetRiskIndicatorBySCoTS
/*
purpose
	returns Y/N indicator based on Scots Code

test
	select portfolio.fn_HasDailyOrTrendScore( 50000020, 'FR' )

history
	2015.09.21 dr  created.

*/
(
		@ScotsIndicatorID		int,
		@ScotsCode				varchar(10)
)
RETURNS varchar(1)
AS
BEGIN
		RETURN (
				SELECT
					CASE
							WHEN a.YNIndicator = '1' THEN 'Y'
							WHEN a.YNIndicator = '0' THEN 'N'
							ELSE NULL
					END		AS YNIndicator
				FROM	(
					SELECT
							'Y'				AS ScotsCode,
							'1'				AS YNIndicator
					UNION ALL
					SELECT
							'1',
							'1'
					UNION ALL
					SELECT
							'N',
							'0'
					UNION ALL
					SELECT
							'0',
							'0'
					UNION ALL
					SELECT 
							CAST(ScotsCode	AS varchar(10)),	
							YNIndicator
					FROM 
							reference.ScotsCodeValues (nolock)
					WHERE 
							ScotsIndicatorID = @ScotsIndicatorID) a
				WHERE
						a.ScotsCode = @ScotsCode);

END