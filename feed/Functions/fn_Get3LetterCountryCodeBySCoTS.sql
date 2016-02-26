
CREATE FUNCTION [feed].[fn_Get3LetterCountryCodeBySCoTS]
/*
purpose
	returns 3 letter country code

test
	select feed.fn_Get3LetterCountryCodeBySCoTS( 7978, NULL )

history
	2015.11.20 dr  created.

*/
(
		@ScotsCode				varchar(10),
		@Date					date	
)
RETURNS char(3)
AS
BEGIN
		RETURN (
				SELECT
						AltSchemaCodeVal
				FROM
						reference.SCoTSCodeToAltCodeMap (nolock)
				WHERE
						SCoTSCode = @ScotsCode
					AND ISNULL(@Date,GETUTCDATE()) BETWEEN EffectiveDate AND ExpirationDate);

END