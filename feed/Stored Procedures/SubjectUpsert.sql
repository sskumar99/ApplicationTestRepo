-- =============================================
-- Author:		DR
-- Create date: 08-12-2015
-- Description:	This will upsert US subject data
-- =============================================
CREATE PROCEDURE [feed].[SubjectUpsert]
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
		
		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.Subject pt (nolock) 
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
				staging.Subject ss(nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = ss.DunsNumber);


		UPDATE
				ss
		SET
				BusinessID = i.BusinessID
		FROM
				staging.Subject ss
		INNER JOIN
				feed.[Identity] i
			ON
				ss.DunsNumber = i.DunsNumber;
		
		UPDATE
				s
		SET
				DataFeedEffectiveDate	= ss.DataFeedEffectiveDate,
				ElementValue			= ss.ElementValue,
				LineageRowID			= ss.LineageRowID,
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.Subject ss (nolock)
		INNER JOIN
				feed.Subject s 
			ON
				ss.BusinessID = s.BusinessID
			AND ss.ElementID = s.ElementID;


		INSERT INTO feed.Subject(
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				ElementID,
				ElementDescription,
				ElementValue,
				LineageRowID,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				ss.BusinessID,
				ss.DunsNumber,
				ss.DataFeedEffectiveDate,
				ss.ElementID,
				ss.ElementDescription,
				ss.ElementValue,
				ss.LineageRowID,
				@Now,
				@By
		FROM
				staging.Subject ss (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.Subject (nolock)
							WHERE
									BusinessID = ss.BusinessID
								AND ElementID = ss.ElementID);	
			

		---Severe risk
		MERGE feed.Subject AS Target
		USING	(
				SELECT DISTINCT
						ss.BusinessID,
						ss.DunsNumber,
						ss.DataFeedEffectiveDate,
						'XZ'															AS ElementID,
						'SevereRisk'													AS ElementDescription,
						CASE
							WHEN bb.ElementValue > 0 OR au.ElementValue > 0 THEN 'Y'
							WHEN bb.ElementValue = 0 OR au.ElementValue = 0 THEN 'N'
							ELSE NULL
						END																AS ElementValue,
						CASE
							WHEN bb.ElementValue > 0 OR au.ElementValue > 0 THEN 'Bankruptcy'
							ELSE NULL
						END																AS RiskIndicatorStatus,
						COALESCE(bb.LineageRowID,au.LineageRowID)						AS LineageRowID
				FROM
						staging.Subject ss (nolock)
				OUTER APPLY	(
							SELECT 
								CASE
										WHEN s.ElementValue IN ('y', '1') THEN 1
										WHEN s.ElementValue IN ('n', '0') THEN 0
										ELSE NULL
								END		AS ElementValue,
								s.LineageRowID
							FROM 
									feed.Subject s (nolock)	
							INNER JOIN
									feed.SASDaily sd (nolock)
								ON
									s.BusinessID = sd.BusinessID
								AND ISNULL(sd.FSSPercentile, 0) = 0
							WHERE
									s.BusinessID = ss.BusinessID
								AND s.ElementID = 'BB') bb
				OUTER APPLY	(
							SELECT 
									CASE
										WHEN ElementValue IN ('y', '1') THEN 1
										WHEN ElementValue IN ('n', '0') THEN 0
										ELSE NULL
									END		AS ElementValue,
									LineageRowID
							FROM 
									feed.Subject (nolock)	
							WHERE
									BusinessID = ss.BusinessID
									AND ElementID = 'AU') au
				
				WHERE
						ss.ElementID IN ('BB', 'AU')
					AND ss.ElementValue IS NOT NULL) AS Source
		ON
			Target.BusinessID = Source.BusinessID
		AND Target.ElementID = Source.ElementID
		WHEN MATCHED THEN 
			UPDATE SET
						ElementValue			= Source.ElementValue,
						RiskIndicatorStatus		= Source.RiskIndicatorStatus,
						DataFeedEffectiveDate	= Source.DataFeedEffectiveDate,
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
					@By);


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessRiskIndicatorChangeQueue(
				BusinessID)
		SELECT DISTINCT
				cob.BusinessID
		FROM
				staging.Subject s (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				s.BusinessID = cob.BusinessID
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessRiskIndicatorChangeQueue (nolock)
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