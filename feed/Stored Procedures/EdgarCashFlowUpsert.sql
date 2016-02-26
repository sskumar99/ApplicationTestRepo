-- =============================================
-- Author:		DR
-- Create date: 10-22-2015
-- Description:	This will upsert Edgar Cash Flow data
-- =============================================
CREATE PROCEDURE [feed].[EdgarCashFlowUpsert]
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

		BEGIN TRANSACTION;
		
		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.EdgarCashFlow ecf (nolock) 
			ON 
				e.ExecutionID = ecf.ExecutionID;


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
				'US',
				0,
				@Now,
				@By
		FROM
				staging.EdgarCashFlow ecf (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = ecf.DunsNumber);


		UPDATE
				ecf
		SET
				BusinessID = i.BusinessID
		FROM
				staging.EdgarCashFlow ecf
		INNER JOIN
				feed.[Identity] i
			ON
				ecf.DunsNumber = i.DunsNumber;


		
		UPDATE
				f
		SET
				LineageRowID							= ecf.LineageRowID,
      			DataFeedEffectiveDate					= ecf.DataFeedEffectiveDate,
				NetDepreciationAndAmortizationExpense	= TRY_PARSE(ecf.Depreciation AS money),
				CashFlowFromFinancingActivities			= TRY_PARSE(ecf.CashFlowsfromFinancingActivities AS money),
				CashFlowFromInvestingActivities			= TRY_PARSE(ecf.CashFlowsfromInvestingActivities AS money),
				ChangeinCashandCashEquivalents			= TRY_PARSE(ecf.ChangeinCashandCashEquivalents AS money),
				CashFlowFromOperatingActivities			= TRY_PARSE(ecf.CashFlowsfromOperatingActivities AS money),
				CapitalExpenditure						= TRY_PARSE(ecf.CapitalExpenditures AS money),
				TotalSharesOutstanding					= TRY_PARSE(ecf.TotalSharesOutstanding AS money),
				UpdatedDate								= @Now,
				UpdatedBy								= @By
		FROM
				staging.EdgarCashFlow ecf (nolock)
		INNER JOIN
				feed.Financial f 
			ON
				f.BusinessID = ecf.BusinessID
			AND f.DataSource = 'EDGAR'
			AND	f.StatementDate = CAST(ecf.StatementDate AS date)
			AND f.StatementType = LTRIM(RTRIM(ecf.StatementType)) ;


		INSERT INTO feed.Financial(
				BusinessID,
				DunsNumber,
				DataSource,
				StatementDate,
				StatementType,
				DataFeedEffectiveDate,
				LineageRowID,
				NetDepreciationAndAmortizationExpense,
				CashFlowFromFinancingActivities,
				CashFlowFromInvestingActivities,
				ChangeinCashandCashEquivalents,
				CashFlowFromOperatingActivities,
				CapitalExpenditure,
				TotalSharesOutstanding,
				CreatedDate,
				CreatedBy)
		SELECT
				BusinessID,
				DunsNumber,
				'EDGAR',
				StatementDate,
				LTRIM(RTRIM(StatementType)),
				DataFeedEffectiveDate,
				LineageRowID,
				TRY_PARSE(ecf.Depreciation AS money),
				TRY_PARSE(ecf.CashFlowsfromFinancingActivities AS money),
				TRY_PARSE(ecf.CashFlowsfromInvestingActivities AS money),
				TRY_PARSE(ecf.ChangeinCashandCashEquivalents AS money),
				TRY_PARSE(ecf.CashFlowsfromOperatingActivities AS money),
				TRY_PARSE(ecf.CapitalExpenditures AS money),
				TRY_PARSE(ecf.TotalSharesOutstanding AS money),
				@Now,
				@By
		FROM
				staging.EdgarCashFlow  ecf (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.Financial
							WHERE
									DunsNumber = ecf.DunsNumber
								AND DataSource = 'EDGAR'
								AND	StatementDate = CAST(ecf.StatementDate AS date)
								AND StatementType = LTRIM(RTRIM(ecf.StatementType)));	
			

		


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessFinancialQueue(
				BusinessID,
				DataSource)
		SELECT DISTINCT
				cob.BusinessID,
				'EDGAR'
		FROM
				staging.EdgarCashFlow  ecf (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				ecf.BusinessID = cob.BusinessID
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessFinancialQueue (nolock)
							WHERE
									BusinessID = cob.BusinessID
								AND DataSource = 'EDGAR');

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