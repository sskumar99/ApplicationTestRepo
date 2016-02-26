
CREATE FUNCTION [feed].[fn_GetLegalStructureByLegalFormCodes]
/*
purpose
	returns Legal Structure based on Scots Code

test
	SELECT [feed].[fn_GetLegalStructureByLegalFormCodes](1869, null, '2015-10-06')

history
	2015.10.09 dr  created.

*/
(
		@LegalFormCode			nvarchar(200)	= NULL,
		@LegalFormClassCode		nvarchar(200)	= NULL,
		@Now					date
		
)
RETURNS nvarchar(2000)
AS
BEGIN
		DECLARE 
				@Result		nvarchar(2000) = NULL;


		IF @LegalFormCode IS NOT NULL OR @LegalFormClassCode IS NOT NULL
			BEGIN


				SET @Result = (
								SELECT 
										ProductLiteralDescription	AS LegalStructure
								FROM
										reference.SCoTSCodeToLiteralMap
								WHERE
										LanguageCode = 39
									AND CodeTableID = 197
									AND @Now BETWEEN EffectiveDate AND ExpirationDate 
									AND SCoTSCode = @LegalFormClassCode);
							
							
				IF @Result IS NULL
						SET @Result = (
								SELECT 
										ProductLiteralDescription
								FROM
										reference.SCoTSCodeToLiteralMap
								WHERE
										LanguageCode = 39
									AND CodeTableID = 4
									AND @Now BETWEEN EffectiveDate AND ExpirationDate 
									AND SCoTSCode = @LegalFormCode);

			END
		
		RETURN @Result;
	

END