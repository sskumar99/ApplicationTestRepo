-- =============================================
-- Author:		DR
-- Create date: 10-23-2015
-- Description:	This will upsert Acxiom Score data
-- =============================================
CREATE PROCEDURE [feed].[DailyScoresAcxiomUpsert]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber		int = 0,
				@ErrorMessage		nvarchar(4000)	= 'Success',
				@ErrorSeverity		int,
				@ExecutionID		int,
				@Now				datetime		= GETUTCDATE(),
				@By					varchar(50);	

    BEGIN TRY


		IF NOT EXISTS(
						SELECT
								1
						FROM
								staging.SubjectAcxiom (nolock)
						WHERE
								CcsFss = 1 OR Paydex = 1)
			RETURN;

		BEGIN TRANSACTION;
		
		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.SubjectAcxiom ssa (nolock) 
			ON 
				e.ExecutionID = ssa.ExecutionID;


		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';



		UPDATE
				ssa
		SET
				BusinessID = i.BusinessID
		FROM
				staging.SubjectAcxiom ssa
		INNER JOIN
				feed.[Identity] i
			ON
				ssa.DunsNumber = i.DunsNumber;
	
		--Paydex
		UPDATE
				pd
		SET
				LineageRowID						= ssa.LineageRowID,
      			DataFeedEffectiveDate				= ssa.DataFeedEffectiveDate,
				Paydex								= TRY_CAST(ssa.DnBPaydex AS tinyint),
				UpdateDate							= @Now,
				UpdatedBy							= @By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				feed.PaydexDaily pd 
			ON
				pd.BusinessID = ssa.BusinessID
			
		WHERE
				ssa.Paydex = 1;

		

		INSERT INTO feed.PaydexDaily(
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				Paydex,
				LineageRowID,
				CreatedDate,
				CreatedBy)
		SELECT
				ssa.BusinessID,
				ssa.DunsNumber,
				ssa.DataFeedEffectiveDate,
				TRY_CAST(ssa.DnBPaydex AS tinyint),
				ssa.LineageRowID,
				@Now,
				@By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		WHERE
				ssa.Paydex = 1
			AND ssa.BusinessID IS NOT NULL
			AND NOT EXISTS(
							SELECT 
									1
							FROM
									feed.PaydexDaily (nolock)
							WHERE
									BusinessID = ssa.BusinessID);

		--DnBRating
		UPDATE
				drd
		SET
				LineageRowID						= ssa.LineageRowID,
      			DataFeedEffectiveDate				= ssa.DataFeedEffectiveDate,
				DnBRating							= IIF(ssa.DnBRatingRiskIndicator='13200' OR ssa.DnBRatingFinancialStrength IN ('2832','2833','2834', '2835','2836','2837'), NULL, CAST(lp1.ProductLiteralDescription + lp2.ProductLiteralDescription AS varchar(10))),
				RiskIndicator						= IIF(ssa.DnBRatingRiskIndicator='13200', NULL,CAST(lp2.ProductLiteralDescription AS nvarchar(15))),
				FinancialStrength					= IIF(ssa.DnBRatingFinancialStrength IN ('2832','2833','2834', '2835','2836','2837'), NULL,CAST(lp1.ProductLiteralDescription AS nvarchar(15))),
				UpdateDate							= @Now,
				UpdatedBy							= @By
		FROM
				staging.SubjectAcxiom ssa (nolock)
			INNER JOIN
					feed.DnBRatingDaily drd 
				ON
					drd.BusinessID = ssa.BusinessID
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap lp1 (nolock)
			ON
				lp1.LanguageCode = 39
			AND lp1.CodeTableID = 39
			AND	lp1.SCoTSCode = ssa.DnBRatingFinancialStrength
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap lp2 (nolock)
			ON
				lp2.LanguageCode = 39
			AND lp2.CodeTableID = 40
			AND	lp2.SCoTSCode = ssa.DnBRatingRiskIndicator	
		WHERE
				ssa.Paydex = 1;

		INSERT INTO feed.DnBRatingDaily(
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				DnBRating,
				LineageRowID,
				RiskIndicator,
				FinancialStrength,
				CreatedDate,
				CreatedBy)
		SELECT
				ssa.BusinessID,
				ssa.DunsNumber,
				ssa.DataFeedEffectiveDate,
				CAST(lp1.ProductLiteralDescription + lp2.ProductLiteralDescription AS nvarchar(10)),
				ssa.LineageRowID,
				CAST(lp2.ProductLiteralDescription AS nvarchar(15))	AS DnBRatingRiskIndicator,
				CAST(lp1.ProductLiteralDescription AS nvarchar(15))	AS DnBRatingFinancialStrength,
				@Now,
				@By
		FROM
				staging.SubjectAcxiom ssa 
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap lp1 (nolock)
			ON
				lp1.LanguageCode = 39
			AND lp1.CodeTableID = 39
			AND	lp1.SCoTSCode = ssa.DnBRatingFinancialStrength
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap lp2 (nolock)
			ON
				lp2.LanguageCode = 39
			AND lp2.CodeTableID = 40
			AND	lp2.SCoTSCode = ssa.DnBRatingRiskIndicator
		WHERE
				ssa.Paydex = 1
			AND ssa.BusinessID IS NOT NULL
			AND NOT EXISTS(
							SELECT 
									1
							FROM
									feed.DnBRatingDaily (nolock)
							WHERE
									BusinessID = ssa.BusinessID); 
			

		----SASDaily
		UPDATE
				sd
		SET
				LineageRowID						= ssa.LineageRowID,
      			DataFeedEffectiveDate				= ssa.DataFeedEffectiveDate,
				CCSPercentile						= TRY_CAST(ssa.DnBDelinquencyScore AS tinyint),
				FSSPercentile						= TRY_CAST(ssa.DnBFailureScore AS tinyint),
				UpdateDate							= @Now,
				UpdatedBy							= @By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				feed.SASDaily sd 
			ON
				sd.BusinessID = ssa.BusinessID
			
		WHERE
				ssa.CcsFss = 1;

		

		INSERT INTO feed.SASDaily(
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				CCSPercentile,
				FSSPercentile,
				LineageRowID,
				CreatedDate,
				CreatedBy)
		SELECT
				ssa.BusinessID,
				ssa.DunsNumber,
				ssa.DataFeedEffectiveDate,
				TRY_CAST(ssa.DnBDelinquencyScore AS tinyint),
				TRY_CAST(ssa.DnBFailureScore AS tinyint),
				ssa.LineageRowID,
				@Now,
				@By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		WHERE
				ssa.CcsFss = 1
			AND ssa.BusinessID IS NOT NULL
			AND NOT EXISTS(
							SELECT 
									1
							FROM
									feed.SASDaily (nolock)
							WHERE
									BusinessID = ssa.BusinessID);

		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessScoreChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				ssa.BusinessID = cob.BusinessID
		WHERE
				(ssa.Paydex = 1 OR ssa.CcsFss = 1)
			AND	NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessScoreChangeQueue (nolock)
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