-- =============================================
-- Author:		DR
-- Create date: 10-23-2015
-- Description:	This will upsert Acxiom Financial data
-- =============================================
CREATE PROCEDURE [feed].[FinancialAcxiomUpsert]
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
								Financial = 1)
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

		--Create BusinessID 
		INSERT INTO feed.[Identity](
				DunsNumber,
				Country,
				IsActive,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				DunsNumber,
				gccm.ISOCountryAlpha2Code,
				0,
				@Now,
				@By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				reference.GEOUnitToISOCountryCodeMap gccm (nolock)
			ON
				ssa.CountryCode = gccm.GEOUnitID
		WHERE
				ssa.Financial = 1
			AND (ssa.StatementDate IS NOT NULL OR ssa.PreviousStatementDate IS NOT NULL)
			AND	NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = ssa.DunsNumber);


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
	
		
		UPDATE
				f
		SET
				LineageRowID						= ssa.LineageRowID,
      			DataFeedEffectiveDate				= ssa.DataFeedEffectiveDate,
				TotalCurrentAssets					= ssa.TotalCurrentAssets,
				NetFixedAssets						= ssa.FixedAssets,
				TotalAssets							= ssa.TotalAssets,
				TotalCurrentLiabilities				= ssa.TotalCurrentLiabilities,
				TotalLiabilities					= ssa.TotalLiabilities,
				IntangibleAssets					= ssa.IntangibleAssets,
				IssuedCapital						= ssa.IssuedCapital,
				IssuedCapitalCurrencyCode			= feed.fn_Get3LetterCountryCodeBySCoTS(ssa.IssuedCapitalCurrencyCode, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)),
				TangibleNetWorth					= ssa.TangibleNetWorth,
				CurrencyCode						= feed.fn_Get3LetterCountryCodeBySCoTS(ssa.CurrencyCode1, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)),
				EarningBeforeTax					= ssa.ProfitBeforeTax,
				CostofSales							= ssa.CostofSales,
				NetProfit							= ssa.NetProfit,
				NetLoss								= ssa.NetLoss,
				NetIncome							= CASE
														WHEN ssa.NetLoss IS NOT NULL AND ssa.NetProfit IS NULL THEN
															CASE
																WHEN ssa.NetLoss > 0 THEN -1 * ssa.NetLoss
																WHEN ssa.NetLoss < 0 THEN ssa.NetLoss
															END
														WHEN ssa.NetProfit IS NOT NULL AND ssa.NetLoss IS NULL THEN ssa.NetProfit
													END,
				AnnualSales							= ssa.Sales,
				UpdatedDate							= @Now,
				UpdatedBy							= @By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				feed.Financial f 
			ON
				f.BusinessID = ssa.BusinessID
			AND f.DataSource = 'ACXIOM'
			AND	f.StatementDate = ssa.StatementDate
			AND f.StatementType = 'UNKNOWN'
		
		WHERE
				ssa.Financial = 1;



		UPDATE
				f
		SET
				LineageRowID						= ssa.LineageRowID,
      			DataFeedEffectiveDate				= ssa.DataFeedEffectiveDate,
				TotalCurrentAssets					= ssa.PreviousCurrentAssets,
				TotalAssets							= ssa.TotalAssetsYear2,
				TotalCurrentLiabilities				= ssa.PreviousCurrentLiaiblities,
				TotalLiabilities					= ssa.TotalLiabilitiesYear2,
				TangibleNetWorth					= ssa.PreviousNetWorth,
				CurrencyCode						= feed.fn_Get3LetterCountryCodeBySCoTS(ssa.CurrencyCode2, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)),
				UpdatedDate							= @Now,
				UpdatedBy							= @By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				feed.Financial f 
			ON
				f.BusinessID = ssa.BusinessID
			AND f.DataSource = 'ACXIOM'
			AND	f.StatementDate = ssa.PreviousStatementDate
			AND f.StatementType = 'UNKNOWN'
		WHERE
				ssa.Financial = 1;


		INSERT INTO feed.Financial(
				BusinessID,
				DunsNumber,
				DataSource,
				StatementDate,
				StatementType,
				DataFeedEffectiveDate,
				LineageRowID,
				TotalCurrentAssets,
				NetFixedAssets,
				TotalAssets,
				TotalCurrentLiabilities,
				TotalLiabilities,
				IntangibleAssets,
				IssuedCapital,
				IssuedCapitalCurrencyCode,
				TangibleNetWorth,
				CurrencyCode,
				EarningBeforeTax,
				CostofSales,
				NetProfit,
				NetLoss,
				NetIncome,
				AnnualSales,
				CreatedDate,
				CreatedBy)
		SELECT
				BusinessID,
				DunsNumber,
				'ACXIOM',
				StatementDate,
				'UNKNOWN',
				DataFeedEffectiveDate,
				LineageRowID,
				ssa.TotalCurrentAssets,
				ssa.FixedAssets,
				ssa.TotalAssets,
				ssa.TotalCurrentLiabilities,
				ssa.TotalLiabilities,
				ssa.IntangibleAssets,
				ssa.IssuedCapital,
				feed.fn_Get3LetterCountryCodeBySCoTS(ssa.IssuedCapitalCurrencyCode, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)),
				ssa.TangibleNetWorth,
				feed.fn_Get3LetterCountryCodeBySCoTS(ssa.CurrencyCode1, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)),
				ssa.ProfitBeforeTax,
				ssa.CostofSales,
				ssa.NetProfit,
				ssa.NetLoss,
				CASE
					WHEN ssa.NetLoss IS NOT NULL AND ssa.NetProfit IS NULL THEN
						CASE
							WHEN ssa.NetLoss > 0 THEN -1 * ssa.NetLoss
							WHEN ssa.NetLoss < 0 THEN ssa.NetLoss
						END
					WHEN ssa.NetProfit IS NOT NULL AND ssa.NetLoss IS NULL THEN ssa.NetProfit
				END,
				ssa.Sales,
				@Now,
				@By
		FROM
				staging.SubjectAcxiom  ssa (nolock)
		
		WHERE
				ssa.Financial = 1
			AND ssa.StatementDate IS NOT NULL
			AND	NOT EXISTS (
							SELECT
									1
							FROM
									feed.Financial
							WHERE
									DunsNumber = ssa.DunsNumber
								AND DataSource = 'ACXIOM'
								AND	StatementDate = ssa.StatementDate
								AND StatementType = 'UNKNOWN');	
			

		INSERT INTO feed.Financial(
				BusinessID,
				DunsNumber,
				DataSource,
				StatementDate,
				StatementType,
				DataFeedEffectiveDate,
				LineageRowID,
				TotalCurrentAssets,
				TotalAssets,
				TotalCurrentLiabilities,
				TotalLiabilities,
				TangibleNetWorth,
				CurrencyCode,
				CreatedDate,
				CreatedBy)
		SELECT
				BusinessID,
				DunsNumber,
				'ACXIOM',
				PreviousStatementDate,
				'UNKNOWN',
				DataFeedEffectiveDate,
				LineageRowID,
				ssa.PreviousCurrentAssets,
				ssa.TotalAssetsYear2,
				ssa.PreviousCurrentLiaiblities,
				ssa.TotalLiabilitiesYear2,
				ssa.PreviousNetWorth,
				feed.fn_Get3LetterCountryCodeBySCoTS(ssa.CurrencyCode2, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)),
				@Now,
				@By
		FROM
				staging.SubjectAcxiom  ssa (nolock)
		WHERE
				ssa.Financial = 1
			AND ssa.PreviousStatementDate IS NOT NULL
			AND	NOT EXISTS (
							SELECT
									1
							FROM
									feed.Financial
							WHERE
									DunsNumber = ssa.DunsNumber
								AND DataSource = 'ACXIOM'
								AND	StatementDate = ssa.PreviousStatementDate
								AND StatementType = 'UNKNOWN');	


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessFinancialQueue(
				BusinessID,
				DataSource)
		SELECT DISTINCT
				cob.BusinessID,
				'ACXIOM'
		FROM
				staging.SubjectAcxiom  ssa (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				ssa.BusinessID = cob.BusinessID
		WHERE
				ssa.Financial = 1
			AND NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessFinancialQueue (nolock)
							WHERE
									BusinessID = cob.BusinessID
								AND DataSource = 'ACXIOM');

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