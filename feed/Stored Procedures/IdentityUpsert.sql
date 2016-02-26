-- =============================================
-- Author:		DR
-- Create date: 09-16-2015
-- Description:	This will upsert identity  data
-- =============================================
CREATE PROCEDURE [feed].[IdentityUpsert]
(
	@DDRFlag	bit 
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber		int = 0,
				@ErrorMessage		nvarchar(4000) = 'Success',
				@ErrorSeverity		int,
				@ExecutionID		int,
				@Now				datetime2	= GETUTCDATE(),
				@By					varchar(50);	

    BEGIN TRY

		BEGIN TRANSACTION;
		
		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.[Identity] si (nolock) 
			ON 
				e.ExecutionID = si.ExecutionID;
		
		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';


		IF @DDRFlag = 1
			BEGIN
				UPDATE
						i
				SET
						DataFeedEffectiveDate	= si.DataFeedEffectiveDate,
						LineageRowID			= si.LineageRowID,
						City					= si.City,
						Name					= si.Name,
						TradeStyle1				= si.TradeStyle1,
						TradeStyle2				= si.TradeStyle2,
						TradeStyle3				= si.TradeStyle3,
						TradeStyle4				= si.TradeStyle4,
						TradeStyle5				= si.TradeStyle5,
						Street1					= si.Street1,
						Street2					= si.Street2,
						PostalCode				= si.Zip,
						PostalCodePlus			= si.Zip4,
						State					= si.State,
						Phone					= ISNULL(si.AreaCode, '') + ISNULL(si.Phone, ''),
						CEOName					= si.CEOName,
						LegalStructure			= feed.fn_GetLegalStructureByLegalFormCodes(si.LegalFormCode, si.LegalFormClassCode, @Now),
						LegalFormClassCode		= si.LegalFormClassCode,
						LegalFormCode			= si.LegalFormCode,
						YearStarted				= TRY_PARSE(si.YearStarted AS int),
						MonthStarted			= TRY_PARSE(si.MonthStarted AS int),
						DayStarted				= TRY_PARSE(si.DayStarted AS int),
						IncYear					= TRY_PARSE(si.IncYear AS date),
						IsActive				= 1,
						UpdatedDate				= @Now,
						UpdatedBy				= @By
				FROM
						staging.[Identity] si (nolock)
				INNER JOIN
						feed.[Identity] i 
					ON
						si.DunsNumber = i.DunsNumber;
			
	
				--OUTER APPLY	(
				--			SELECT TOP 1
				--					LegalStructure
				--			FROM	(
				--					SELECT 
				--							ProductLiteralDescription	AS LegalStructure,
				--							1							AS Pos
				--					FROM
				--							reference.SCoTSCodeToLiteralMap
				--					WHERE
				--							LanguageCode = 39
				--						AND CodeTableID = 197
				--						AND @Now BETWEEN EffectiveDate AND ExpirationDate 
				--						AND SCoTSCode = si.LegalFormClassCode
				--					UNION ALL
				--					SELECT 
				--							ProductLiteralDescription,
				--							2 AS Pos
				--					FROM
				--							reference.SCoTSCodeToLiteralMap
				--					WHERE
				--							LanguageCode = 39
				--						AND CodeTableID = 4
				--						AND @Now BETWEEN EffectiveDate AND ExpirationDate 
				--						AND SCoTSCode = si.LegalFormCode) a
				--			ORDER BY
				--					Pos	) l;

							
				INSERT INTO feed.[Identity](
						DunsNumber,
						DataFeedEffectiveDate,
						LineageRowID,
						City,
						Country,
						Name,
						TradeStyle1,
						TradeStyle2,
						TradeStyle3,
						TradeStyle4,
						TradeStyle5,
						Street1,
						Street2,
						PostalCode,
						PostalCodePlus,
						State,
						Phone,
						CEOName,
						LegalStructure,
						LegalFormClassCode,
						LegalFormCode,
						YearStarted,
						MonthStarted,
						DayStarted,
						IncYear,
						CreatedDate,
						CreatedBy)
				SELECT DISTINCT
						si.DunsNumber,
						si.DataFeedEffectiveDate,
						si.LineageRowID,
						si.City,
						gccm.ISOCountryAlpha2Code,
						si.Name,
						si.TradeStyle1,
						si.TradeStyle2,
						si.TradeStyle3,
						si.TradeStyle4,
						si.TradeStyle5,
						si.Street1,
						si.Street2,
						si.Zip,
						si.Zip4,
						si.State,
						ISNULL(si.AreaCode, '') + ISNULL(si.Phone, ''),
						si.CEOName,
						feed.fn_GetLegalStructureByLegalFormCodes(si.LegalFormCode, si.LegalFormClassCode, @Now),
						si.LegalFormClassCode,
						si.LegalFormCode,
						TRY_PARSE(si.YearStarted AS int),
						TRY_PARSE(si.MonthStarted AS int),
						TRY_PARSE(si.DayStarted AS int),
						TRY_PARSE(si.IncYear AS date),					
						@Now,
						@By
				FROM
						staging.[Identity] si (nolock)
				INNER JOIN
						reference.GEOUnitToISOCountryCodeMap gccm (nolock)
					ON
						si.Country = gccm.GEOUnitID
				--OUTER APPLY	(
				--			SELECT TOP 1
				--					LegalStructure
				--			FROM	(
				--					SELECT 
				--							ProductLiteralDescription	AS LegalStructure,
				--							1							AS Pos
				--					FROM
				--							reference.SCoTSCodeToLiteralMap
				--					WHERE
				--							LanguageCode = 39
				--						AND CodeTableID = 197
				--						AND @Now BETWEEN EffectiveDate AND ExpirationDate 
				--						AND SCoTSCode = si.LegalFormClassCode
				--					UNION ALL
				--					SELECT 
				--							ProductLiteralDescription,
				--							2 AS Pos
				--					FROM
				--							reference.SCoTSCodeToLiteralMap
				--					WHERE
				--							LanguageCode = 39
				--						AND CodeTableID = 4
				--						AND @Now BETWEEN EffectiveDate AND ExpirationDate 
				--						AND SCoTSCode = si.LegalFormCode) a
				--			ORDER BY
				--					Pos	) l
				WHERE
						NOT EXISTS (
									SELECT
											1
									FROM
											feed.[Identity] (nolock)
									WHERE
											DunsNumber = si.DunsNumber);	
			END	
		ELSE
			BEGIN
				UPDATE
						i
				SET
						DataFeedEffectiveDate	= si.DataFeedEffectiveDate,
						LineageRowID			= si.LineageRowID,
						City					= si.City,
						Name					= si.Name,
						TradeStyle1				= si.TradeStyle1,
						TradeStyle2				= si.TradeStyle2,
						TradeStyle3				= si.TradeStyle3,
						TradeStyle4				= si.TradeStyle4,
						TradeStyle5				= si.TradeStyle5,
						Street1					= si.Street1,
						Street2					= si.Street2,
						PostalCode				= si.Zip,
						State					= si.State,
						Phone					= ISNULL(si.AreaCode, '') + ISNULL(si.Phone, ''),
						CEOName					= si.CEOName,
						IsActive				= 1,
						UpdatedDate				= @Now,
						UpdatedBy				= @By
				FROM
						staging.[Identity] si (nolock)
				INNER JOIN
						feed.[Identity] i 
					ON
						si.DunsNumber = i.DunsNumber;
			END

		---PrimarySICCodeType
		INSERT INTO feed.Subject(
				BusinessID,
				DunsNumber,
				ElementID,
				ElementValue,
				ElementDescription,
				DatafeedEffectiveDate,
				LineageRowID,
				CreatedDate,
				CreatedBy)
		SELECT
				i.BusinessID,
				i.DunsNumber,
				'XY',
				CASE gccm.ISOCountryAlpha2Code
					WHEN 'US' THEN	'399'
					WHEN 'CA' THEN '2831'
					ELSE NULL
				END,
				'PrimarySICCodeType',
				si.DataFeedEffectiveDate,
				si.LineageRowID,
				@Now,
				@By
		FROM
				staging.[Identity] si
		INNER JOIN
				feed.[Identity] i
			ON
				si.DunsNumber = i.DunsNumber
		LEFT JOIN
				reference.GEOUnitToISOCountryCodeMap gccm (nolock)
			ON
				si.Country = gccm.GEOUnitID
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.Subject
							WHERE
									BusinessID = i.BusinessID
								AND ElementID = 'XY');


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessProfileChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.[Identity] si
		INNER JOIN
				feed.[Identity] i
			ON
				si.DunsNumber = i.DunsNumber
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				i.BusinessID = cob.BusinessID
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessProfileChangeQueue (nolock)
							WHERE
									BusinessID = cob.BusinessID);

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT 
				@ErrorNumber = ERROR_NUMBER(),
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY();

		RAISERROR(@ErrorMessage, @ErrorSeverity, 1);


	END CATCH

END