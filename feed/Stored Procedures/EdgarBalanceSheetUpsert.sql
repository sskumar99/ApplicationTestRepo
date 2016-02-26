-- =============================================
-- Author:		DR
-- Create date: 10-22-2015
-- Description:	This will upsert Edgar Balance Sheet data
-- =============================================
CREATE PROCEDURE [feed].[EdgarBalanceSheetUpsert]
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
				staging.EdgarBalanceSheet pt (nolock) 
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
				staging.EdgarBalanceSheet clrd (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = clrd.DunsNumber);


		UPDATE
				clrd
		SET
				BusinessID = i.BusinessID
		FROM
				staging.EdgarBalanceSheet clrd
		INNER JOIN
				feed.[Identity] i
			ON
				clrd.DunsNumber = i.DunsNumber;


		
		UPDATE
				f
		SET
				LineageRowID			= ebs.LineageRowID,
      			DataFeedEffectiveDate	= ebs.DataFeedEffectiveDate,
				CashandCashEquivalents	= TRY_PARSE(ebs.CashandCashEquivalents AS money),
				AccountsReceivables		= TRY_PARSE(ebs.NetReceivables AS money),
				TotalCurrentAssets		= TRY_PARSE(ebs.TotalCurrentAssets AS money),
				NetTangibleAssets		= TRY_PARSE(ebs.NetTangibleAssets AS money),
				NetFixedAssets			= TRY_PARSE(ebs.NetFixedAssets AS money),
				Inventory				= TRY_PARSE(ebs.Inventory AS money),
				TotalAssets				= TRY_PARSE(ebs.TotalAssets AS money),
				AccountsPayable			= TRY_PARSE(ebs.AccountsPayable AS money),
				TotalCurrentLiabilities = TRY_PARSE(ebs.TotalCurrentLiabilities AS money),
				TotalLiabilities		= TRY_PARSE(ebs.TotalLiabilities AS money),
				NetWorth				= TRY_PARSE(ebs.NetWorth AS money),
				IntangibleAssets		= TRY_PARSE(ebs.IntangibleAssets AS money),
				Goodwill				= TRY_PARSE(ebs.Goodwill AS money),
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.EdgarBalanceSheet ebs (nolock)
		INNER JOIN
				feed.Financial f 
			ON
				f.BusinessID = ebs.BusinessID
			AND f.DataSource = 'EDGAR'
			AND	f.StatementDate = CAST(ebs.StatementDate AS date)
			AND f.StatementType = LTRIM(RTRIM(ebs.StatementType)) ;


		INSERT INTO feed.Financial(
				BusinessID,
				DunsNumber,
				DataSource,
				StatementDate,
				StatementType,
				DataFeedEffectiveDate,
				LineageRowID,
				CashandCashEquivalents	,
				AccountsReceivables,
				TotalCurrentAssets,
				NetTangibleAssets,
				NetFixedAssets,
				Inventory,
				TotalAssets,
				AccountsPayable,
				TotalCurrentLiabilities,
				TotalLiabilities,
				NetWorth,
				IntangibleAssets,
				Goodwill,
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
				TRY_PARSE(ebs.CashandCashEquivalents AS money),
				TRY_PARSE(ebs.NetReceivables AS money),
				TRY_PARSE(ebs.TotalCurrentAssets AS money),
				TRY_PARSE(ebs.NetTangibleAssets AS money),
				TRY_PARSE(ebs.NetFixedAssets AS money),
				TRY_PARSE(ebs.Inventory AS money),
				TRY_PARSE(ebs.TotalAssets AS money),
				TRY_PARSE(ebs.AccountsPayable AS money),
				TRY_PARSE(ebs.TotalCurrentLiabilities AS money),
				TRY_PARSE(ebs.TotalLiabilities AS money),
				TRY_PARSE(ebs.NetWorth AS money),
				TRY_PARSE(ebs.IntangibleAssets AS money),
				TRY_PARSE(ebs.Goodwill AS money),
				@Now,
				@By
		FROM
				staging.EdgarBalanceSheet ebs (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.Financial
							WHERE
									DunsNumber = ebs.DunsNumber
								AND DataSource = 'EDGAR'
								AND	StatementDate = CAST(ebs.StatementDate AS date)
								AND StatementType = LTRIM(RTRIM(ebs.StatementType)));	
			

		


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessFinancialQueue(
				BusinessID,
				DataSource)
		SELECT DISTINCT
				cob.BusinessID,
				'EDGAR'
		FROM
				staging.EdgarBalanceSheet ebs (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				ebs.BusinessID = cob.BusinessID
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