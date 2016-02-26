-- =============================================
-- Author:		DR
-- Create date: 09-01-2015
-- Description:	This will upsert Canadian SAS Daily scores
-- =============================================
CREATE PROCEDURE [feed].[SASDailyCAUpsert]
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
										staging.SASDailyCA pd (nolock));

		
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
				staging.SASDailyCA ssas (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = ssas.DunsNumber);


		UPDATE
				ssas
		SET
				BusinessID = i.BusinessID
		FROM
				staging.SASDailyCA ssas
		INNER JOIN
				feed.[Identity] i
			ON
				ssas.DunsNumber = i.DunsNumber;


		UPDATE
				fsas
		SET
				DataFeedEffectiveDate	= ssas.DataFeedEffectiveDate,
				CCSPercentile			= ssas.CCSPercentile,
				CCSClass				= ssas.CCSClass,
				CCSScore				= ssas.CCSScore,
				FSSPercentile			= ssas.FSSPercentile,
				FSSClass				= ssas.FSSClass,
				FSSScore				= ssas.FSSScore,
				LineageRowID			= ssas.LineageRowID,
				UpdateDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.SASDailyCA ssas (nolock)
		INNER JOIN
				feed.SASDaily fsas 
			ON
				ssas.BusinessID = fsas.BusinessID;


		
		INSERT INTO feed.SASDaily(
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				CCSPercentile,
				CCSClass,
				CCSScore,
				FSSPercentile,
				FSSClass,
				FSSScore,
				LineageRowID,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				sas.BusinessID,
				sas.DunsNumber,
				sas.DataFeedEffectiveDate,
				sas.CCSPercentile,
				sas.CCSClass,
				sas.CCSScore,
				sas.FSSPercentile,
				sas.FSSClass,
				sas.FSSScore,
				sas.LineageRowID,
				@Now,
				@By
		FROM
				staging.SASDailyCA sas (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.SASDaily (nolock)
							WHERE
									BusinessID = sas.BusinessID);	
			

		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessScoreChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.SASDailyCA sas (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				sas.BusinessID = cob.BusinessID
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