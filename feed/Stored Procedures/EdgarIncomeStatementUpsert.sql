-- =============================================
-- Author:		DR
-- Create date: 10-22-2015
-- Description:	This will upsert Edgar Income Statement data
-- =============================================
CREATE PROCEDURE [feed].[EdgarIncomeStatementUpsert]
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
				staging.EdgarIncomeStatement pt (nolock) 
			ON 
				e.ExecutionID = pt.ExecutionID;


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
				staging.EdgarIncomeStatement eis (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = eis.DunsNumber);


		UPDATE
				eis
		SET
				BusinessID = i.BusinessID
		FROM
				staging.EdgarIncomeStatement eis
		INNER JOIN
				feed.[Identity] i
			ON
				eis.DunsNumber = i.DunsNumber;


		
		UPDATE
				f
		SET
				LineageRowID						= eis.LineageRowID,
      			DataFeedEffectiveDate				= eis.DataFeedEffectiveDate,
				SalesRevenue						= TRY_PARSE(eis.TotalRevenue AS money),
				GrossProfit							= TRY_PARSE(eis.GrossProfit AS money),
				EarningsBeforeInterestAndTaxes		= TRY_PARSE(eis.EarningsBeforeInterestAndTaxes AS money),
				InterestExpense						= TRY_PARSE(eis.InterestExpense AS money),
				EarningBeforeTax					= TRY_PARSE(eis.IncomeBeforeTax AS money),
				OperatingIncome						= TRY_PARSE(eis.OperatingIncome AS money),
				NetIncome							= TRY_PARSE(eis.NetIncome AS money),
				TotalOtherIncomeAndExpensesNet		= TRY_PARSE(eis.TotalOtherIncomeAndExpensesNet AS money),
				ResearchAndDevelopment				= TRY_PARSE(eis.ResearchAndDevelopment AS money),
				SellingGeneralAndAd					= TRY_PARSE( eis.SellingGeneralandAd AS money),
				NonRecurring						= TRY_PARSE(eis.NonRecurring AS money),
				OtherOperatingExpenses				= TRY_PARSE(eis.OtherOperatingExpenses AS money),
				AnnualSales							= TRY_PARSE(eis.TotalRevenue AS money),
				UpdatedDate							= @Now,
				UpdatedBy							= @By
		FROM
				staging.EdgarIncomeStatement eis (nolock)
		INNER JOIN
				feed.Financial f 
			ON
				f.BusinessID = eis.BusinessID
			AND f.DataSource = 'EDGAR'
			AND	f.StatementDate = CAST(eis.StatementDate AS date)
			AND f.StatementType = LTRIM(RTRIM(eis.StatementType)) ;


		INSERT INTO feed.Financial(
				BusinessID,
				DunsNumber,
				DataSource,
				StatementDate,
				StatementType,
				DataFeedEffectiveDate,
				LineageRowID,
				SalesRevenue,
				GrossProfit,
				EarningsBeforeInterestAndTaxes,
				InterestExpense,
				EarningBeforeTax,
				OperatingIncome,
				NetIncome,
				TotalOtherIncomeAndExpensesNet,
				ResearchAndDevelopment,
				SellingGeneralAndAd,
				NonRecurring,
				OtherOperatingExpenses,
				AnnualSales,
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
				TRY_PARSE(eis.TotalRevenue AS money),
				TRY_PARSE(eis.GrossProfit AS money),
				TRY_PARSE(eis.EarningsBeforeInterestAndTaxes AS money),
				TRY_PARSE(eis.InterestExpense AS money),
				TRY_PARSE(eis.IncomeBeforeTax AS money),
				TRY_PARSE(eis.OperatingIncome AS money),
				TRY_PARSE(eis.NetIncome AS money),
				TRY_PARSE(eis.TotalOtherIncomeAndExpensesNet AS money),
				TRY_PARSE(eis.ResearchAndDevelopment AS money),
				TRY_PARSE( eis.SellingGeneralandAd AS money),
				TRY_PARSE(eis.NonRecurring AS money),
				TRY_PARSE(eis.OtherOperatingExpenses AS money),
				TRY_PARSE(eis.TotalRevenue AS money),
				@Now,
				@By
		FROM
				staging.EdgarIncomeStatement  eis (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.Financial
							WHERE
									DunsNumber = eis.DunsNumber
								AND DataSource = 'EDGAR'
								AND	StatementDate = CAST(eis.StatementDate AS date)
								AND StatementType = LTRIM(RTRIM(eis.StatementType)));	
			

		


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessFinancialQueue(
				BusinessID,
				DataSource)
		SELECT DISTINCT
				cob.BusinessID,
				'EDGAR'
		FROM
				staging.EdgarIncomeStatement  eis (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				eis.BusinessID = cob.BusinessID
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