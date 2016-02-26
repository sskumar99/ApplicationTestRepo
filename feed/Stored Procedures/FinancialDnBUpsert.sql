-- =============================================
-- Author:		DR
-- Create date: 10-23-2015
-- Description:	This will upsert DnB Financial data

-- Modified By:		dr
-- Modified On:		2016-01-04
-- Modified:		CIR-11168 (AnnualSales = SalesRevenue)
-- =============================================
CREATE PROCEDURE [feed].[FinancialDnBUpsert]
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
				staging.DnBFinancial dbf (nolock) 
			ON 
				e.ExecutionID = dbf.ExecutionID;


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
				staging.DnBFinancial dbf (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = dbf.DunsNumber);


		UPDATE
				dbf
		SET
				BusinessID = i.BusinessID
		FROM
				staging.DnBFinancial dbf
		INNER JOIN
				feed.[Identity] i
			ON
				dbf.DunsNumber = i.DunsNumber;


		
		UPDATE
				f
		SET
				LineageRowID							= dbf.LineageRowID,
      			DataFeedEffectiveDate					= dbf.DataFeedEffectiveDate,
				IsPublicCompany							= 
															CASE
																	WHEN LTRIM(RTRIM(dbf.PublicCompanyInd)) IN ('Y', '1') THEN 1
																	WHEN LTRIM(RTRIM(dbf.PublicCompanyInd)) IN ('N', '0') THEN 0
																	ELSE NULL
															END,
				CashAndCashEquivalents					= TRY_PARSE(dbf.CashAndCashEquivalents AS money),
				AccountsReceivables						= TRY_PARSE(dbf.AccountsReceivables AS money),
				TotalCurrentAssets						= TRY_PARSE(dbf.TotalCurrentAssets AS money),
				Inventory								= TRY_PARSE(dbf.Inventory AS money),
				NetFixedAssets							= TRY_PARSE(dbf.FixedAssets AS money),
				TotalAssets								= TRY_PARSE(dbf.TotalAssets AS money),
				AccountsPayable							= TRY_PARSE(dbf.AccountsPayable AS money),
				TotalCurrentLiabilities					= TRY_PARSE(dbf.TotalCurrentLiabilities AS money),
				TotalLiabilities						= TRY_PARSE(dbf.TotalLiabilities AS money),
				NetWorth								= TRY_PARSE(dbf.NetWorth AS money),
				BankDebt								= TRY_PARSE(dbf.BankDebt AS money),
				SalesRevenue							= TRY_PARSE(dbf.SalesRevenue AS money),
				GrossProfit								= TRY_PARSE(dbf.GrossProfit AS money),
				NetIncome								= TRY_PARSE(dbf.NetIncome AS money),
				AnnualSales								= TRY_PARSE(dbf.SalesRevenue AS money), 
				UpdatedDate								= @Now,
				UpdatedBy								= @By
		FROM
				staging.DnBFinancial dbf (nolock)
		INNER JOIN
				feed.Financial f 
			ON
				f.BusinessID = dbf.BusinessID
			AND f.DataSource = 'DNB'
			AND	f.StatementDate = dbf.StatementDate
			AND f.StatementType = dbf.StatementType;


		INSERT INTO feed.Financial(
				BusinessID,
				DunsNumber,
				DataSource,
				StatementDate,
				StatementType,
				StatementTypeCode,
				DataFeedEffectiveDate,
				LineageRowID,
				IsPublicCompany,
				CashAndCashEquivalents,
				AccountsReceivables,
				TotalCurrentAssets,
				Inventory,
				NetFixedAssets,
				TotalAssets,
				AccountsPayable,
				TotalCurrentLiabilities,
				TotalLiabilities,
				NetWorth,
				BankDebt,
				SalesRevenue,
				GrossProfit,
				AnnualSales,
				CreatedDate,
				CreatedBy)
		SELECT
				BusinessID,
				DunsNumber,
				'DNB',
				StatementDate,
				StatementType,
				StatementTypeCode,
				DataFeedEffectiveDate,
				LineageRowID,
				CASE
						WHEN LTRIM(RTRIM(dbf.PublicCompanyInd)) IN ('Y', '1') THEN 1
						WHEN LTRIM(RTRIM(dbf.PublicCompanyInd)) IN ('N', '0') THEN 0
						ELSE NULL
				END,
				TRY_PARSE(dbf.CashAndCashEquivalents AS money),
				TRY_PARSE(dbf.AccountsReceivables AS money),
				TRY_PARSE(dbf.TotalCurrentAssets AS money),
				TRY_PARSE(dbf.Inventory AS money),
				TRY_PARSE(dbf.FixedAssets AS money),
				TRY_PARSE(dbf.TotalAssets AS money),
				TRY_PARSE(dbf.AccountsPayable AS money),
				TRY_PARSE(dbf.TotalCurrentLiabilities AS money),
				TRY_PARSE(dbf.TotalLiabilities AS money),
				TRY_PARSE(dbf.NetWorth AS money),
				TRY_PARSE(dbf.BankDebt AS money),
				TRY_PARSE(dbf.SalesRevenue AS money),
				TRY_PARSE(dbf.GrossProfit AS money),
				TRY_PARSE(dbf.SalesRevenue AS money),
				@Now,
				@By
		FROM
				staging.DnBFinancial  dbf (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.Financial
							WHERE
									DunsNumber = dbf.DunsNumber
								AND DataSource = 'DNB'
								AND	StatementDate = dbf.StatementDate
								AND StatementType = dbf.StatementType);	
			

		


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessFinancialQueue(
				BusinessID,
				DataSource)
		SELECT DISTINCT
				cob.BusinessID,
				'DNB'
		FROM
				staging.DnBFinancial  dbf (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				dbf.BusinessID = cob.BusinessID
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessFinancialQueue (nolock)
							WHERE
									BusinessID = cob.BusinessID
								AND DataSource = 'DNB');

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