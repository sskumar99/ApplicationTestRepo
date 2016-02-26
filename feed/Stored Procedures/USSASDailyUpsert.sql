-- =============================================
-- Author:		MT
-- Create date: 08-20-2015
-- Description:	This will upsert SAS Daily scores
-- =============================================
CREATE PROCEDURE [feed].[USSASDailyUpsert]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber	int = 0,
				@ErrorMessage	nvarchar(4000) = 'Success',
				@ErrorSeverity	int,
				@ExecutionID	int,
				@Now			datetime = GETUTCDATE(),
				@By				varchar(50)	;	


	
	IF OBJECT_ID('tempdb..#tblSR') IS NOT NULL 
		DROP TABLE #tblSR;


	CREATE TABLE #tblSR(
			BusinessID					bigint,
			PRIMARY KEY CLUSTERED (BusinessID));

    BEGIN TRY

		BEGIN TRANSACTION;
		


		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.USSASDaily pt (nolock) 
			ON 
				e.ExecutionID = pt.ExecutionID;


		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';

		WITH cte AS (
			SELECT
					LineageRowID,
					ROW_NUMBER() OVER(PARTITION BY DunsNumber ORDER BY DataFeedEffectiveDate DESC) Indx
			FROM
					staging.USSASDaily)
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
				staging.USSASDaily ssas (nolock)
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
				staging.USSASDaily ssas
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
				SERScore				= ssas.SERScore,
				LineageRowID			= ssas.LineageRowID,
				UpdateDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.USSASDaily ssas (nolock)
		INNER JOIN
				feed.SASDaily fsas 
			ON
				ssas.BusinessID = fsas.BusinessID
			--AND ssas.DataFeedEffectiveDate > fsas.DataFeedEffectiveDate;


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
				SERScore,
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
				sas.SERScore,
				sas.LineageRowID,
				@Now,
				@By
		FROM
				staging.USSASDaily sas (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.SASDaily (nolock)
							WHERE
									BusinessID = sas.BusinessID);	
			

		---Severe risk
		MERGE feed.Subject AS Target
		USING	(
				SELECT 
						s.BusinessID,
						s.DunsNumber,
						s.DataFeedEffectiveDate,
						'XZ'															AS ElementID,
						'SevereRisk'													AS ElementDescription,
						'Y'																AS ElementValue,	
						'Bankruptcy'													AS RiskIndicatorStatus,
						s.LineageRowID 
				FROM 
						staging.USSASDaily sd (nolock)
				INNER JOIN
						feed.Subject s (nolock)
					ON
						sd.BusinessID = s.BusinessID
					AND s.ElementID = 'BB'
					AND s.ElementValue = 'Y'
				WHERE
						ISNULL(sd.FSSPercentile, 0) = 0
					AND NOT EXISTS(
									SELECT
											1
									FROM
											feed.Subject  (nolock)
									WHERE
											BusinessID = s.BusinessID
										AND ElementID = 'XZ'
										AND ElementValue = 'Y')) AS Source
		ON
			Target.BusinessID = Source.BusinessID
		AND Target.ElementID = Source.ElementID
		WHEN MATCHED THEN 
			UPDATE SET
						ElementValue			= Source.ElementValue,
						DataFeedEffectiveDate	= Source.DataFeedEffectiveDate,
						RiskIndicatorStatus		= Source.RiskIndicatorStatus,
						LineageRowID			= Source.LineageRowID,
						UpdatedDate				= @Now,
						UpdatedBy				= @By
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
					BusinessID,
					DunsNumber,
					DataFeedEffectiveDate,
					ElementID,
					ElementDescription,
					ElementValue,
					RiskIndicatorStatus,
					LineageRowID,
					CreatedDate,
					CreatedBy)
			VALUES	(
					Source.BusinessID,
					Source.DunsNumber,
					Source.DataFeedEffectiveDate,
					Source.ElementID,
					Source.ElementDescription,
					Source.ElementValue,
					Source.RiskIndicatorStatus,
					Source.LineageRowID,
					@Now,
					@By)
		OUTPUT 
				inserted.BusinessID INTO #tblSR;


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessScoreChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.USSASDaily sas (nolock)
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

		INSERT INTO dataflow.BusinessRiskIndicatorChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				#tblSR t (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				t.BusinessID = cob.BusinessID
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