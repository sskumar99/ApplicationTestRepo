-- =============================================
-- Author:		DR
-- Create date: 08-12-2015
-- Description:	This will upsert Paydex Daily scores
-- =============================================
CREATE PROCEDURE [feed].[PaydexDailyUpsert]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber	int = 0,
				@ErrorMessage	nvarchar(4000) = 'Success',
				@ErrorSeverity	int,
				@ExecutionID	int,
				@Now			datetime = GETUTCDATE(),
				@By				varchar(50);	

    BEGIN TRY

		BEGIN TRANSACTION;
		
		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.PaydexDaily pt (nolock) 
			ON 
				e.ExecutionID = pt.ExecutionID;


		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';
		
		WITH cte AS (
			SELECT
					LineageRowID,
					ROW_NUMBER() OVER(PARTITION BY DunsNumber ORDER BY DataFeedEffectiveDate DESC) Indx
			FROM
					staging.PaydexDaily)
		DELETE
		FROM
				cte
		WHERE
				Indx > 1;

		--Create BusinessID 
		INSERT INTO feed.[Identity](
				DunsNumber,
				Country,
				IsActive,
				CreatedDate,
				CreatedBy)
		SELECT
				DunsNumber,
				'US',
				0,
				@Now,
				@By
		FROM
				staging.PaydexDaily spd (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = spd.DunsNumber);


		UPDATE
				spd
		SET
				BusinessID = i.BusinessID
		FROM
				staging.PaydexDaily spd
		INNER JOIN
				feed.[Identity] i
			ON
				spd.DunsNumber = i.DunsNumber;

		
		UPDATE
				pd
		SET
				DataFeedEffectiveDate	= spd.DataFeedEffectiveDate,
				Paydex					= 
											CASE
													WHEN TRY_PARSE(CAST(spd.Paydex AS varchar) AS tinyint) BETWEEN 0 AND 100 THEN spd.Paydex
													ELSE NULL
											END,
				LineageRowID			= spd.LineageRowID,
				UpdateDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.PaydexDaily spd (nolock)
		INNER JOIN
				feed.PaydexDaily pd 
			ON
				spd.BusinessID = pd.BusinessID;


		INSERT INTO feed.PaydexDaily(
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				Paydex,
				LineageRowID,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				pd.BusinessID,
				pd.DunsNumber,
				pd.DataFeedEffectiveDate,
				CASE
						WHEN TRY_PARSE(CAST(pd.Paydex AS varchar) AS tinyint) BETWEEN 0 AND 100 THEN pd.Paydex
						ELSE NULL
				END,
				pd.LineageRowID,
				@Now,
				@By
		FROM
				staging.PaydexDaily pd (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.PaydexDaily (nolock)
							WHERE
									BusinessID = pd.BusinessID);	
			

		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessScoreChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.PaydexDaily pd (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				pd.BusinessID = cob.BusinessID
		WHERE
				NOT EXISTS (
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