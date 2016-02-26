
-- =============================================
-- Author:		DR
-- Create date: 08-31-2015
-- Description:	This will upsert Canadian DnB Rating Daily scores
-- =============================================
CREATE PROCEDURE [feed].[DnBRatingDailyCAUpsert]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber		int = 0,
				@ErrorMessage		nvarchar(4000) = 'Success',
				@ErrorSeverity		int,
				@ExecutionID		int,
				@Now				datetime = GETUTCDATE(),
				@By					varchar(50);	

    BEGIN TRY

		BEGIN TRANSACTION;
		
		SET @ExecutionID	= (SELECT DISTINCT 
										ExecutionID
								FROM 
										staging.DnBRatingDailyCA pd (nolock));

		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';

		--Create BusinessID 
		INSERT INTO feed.[Identity](
				DunsNumber,
				Country,
				IsActive,
				CreatedDate,
				CreatedBy)
		SELECT
				DunsNumber,
				'CA',
				0,
				@Now,
				@By
		FROM
				staging.DnBRatingDailyCA sdrd (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = sdrd.DunsNumber);


		UPDATE
				sdrd
		SET
				BusinessID = i.BusinessID
		FROM
				staging.DnBRatingDailyCA sdrd
		INNER JOIN
				feed.[Identity] i
			ON
				sdrd.DunsNumber = i.DunsNumber;


		UPDATE
				drd
		SET
				DataFeedEffectiveDate	= sdrd.DataFeedEffectiveDate,
				DnBRating				= sdrd.DnBRating,
				LineageRowID			= sdrd.LineageRowID,
				UpdateDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.DnBRatingDailyCA sdrd (nolock)
		INNER JOIN
				feed.DnBRatingDaily drd 
			ON
				sdrd.BusinessID = drd.BusinessID;


		INSERT INTO feed.DnBRatingDaily(
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				DnBRating,
				LineageRowID,
				CreatedDate,
				CreatedBy)
		SELECT
				drd.BusinessID,
				drd.DunsNumber,
				drd.DataFeedEffectiveDate,
				drd.DnBRating,
				drd.LineageRowID,
				@Now,
				@By
		FROM
				staging.DnBRatingDailyCA drd (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.DnBRatingDaily (nolock)
							WHERE
									BusinessID = drd.BusinessID);	
			

		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessScoreChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.DnBRatingDailyCA drd (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				drd.BusinessID = cob.BusinessID
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