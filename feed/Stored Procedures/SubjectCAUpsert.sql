-- =============================================
-- Author:		DR
-- Create date: 08-12-2015
-- Description:	This will upsert Canadian subject data
-- =============================================
CREATE PROCEDURE [feed].[SubjectCAUpsert]
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


	IF OBJECT_ID('tempdb..#tblOOB') IS NOT NULL 
			DROP TABLE #tblOOB;

		

	CREATE TABLE #tblBY(
			BusinessID		bigint PRIMARY KEY CLUSTERED);

    BEGIN TRY

		BEGIN TRANSACTION;
		
		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.SubjectCA pt (nolock) 
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
				'CA',
				0,
				@Now,
				@By
		FROM
				staging.SubjectCA ss (nolock)
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
				staging.SubjectCA ss
		INNER JOIN
				feed.[Identity] i
			ON
				ss.DunsNumber = i.DunsNumber;


		--CIR-11051
		INSERT INTO #tblBY(
				BusinessID)
		SELECT
				ss.BusinessID
		FROM
				staging.SubjectCA ss
		INNER JOIN
				feed.Subject s (nolock)
			ON
				ss.BusinessID = s.BusinessID
			AND ss.ElementID = s.ElementID
			AND ss.ElementValue <> s.ElementValue
		WHERE
				ss.ElementID = 'BB';



		UPDATE
				s
		SET
				DataFeedEffectiveDate	= ss.DataFeedEffectiveDate,
				ElementValue			= ss.ElementValue,
				LineageRowID			= ss.LineageRowID,
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.SubjectCA ss (nolock)
		INNER JOIN
				feed.Subject s 
			ON
				ss.BusinessID = s.BusinessID
			AND ss.ElementID = s.ElementID
			--AND ss.DataFeedEffectiveDate > s.DataFeedEffectiveDate;


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
				staging.SubjectCA ss (nolock)
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
				SELECT
						ss.BusinessID,
						ss.DunsNumber,
						ss.DataFeedEffectiveDate,
						'XZ'															AS ElementID,
						'SevereRisk'													AS ElementDescription,
						ss.ElementValue,
						CASE
							WHEN ss.ElementValue IN ('Y', '1')	THEN 'Insolvency'		
							ELSE NULL
						END																AS RiskIndicatorStatus,
						ss.LineageRowID
				FROM
						staging.SubjectCA ss (nolock)
				WHERE
						ss.ElementID = 'BB'
					AND ss.ElementValue IS NOT NULL) AS Source
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
					@By);


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessRiskIndicatorChangeQueue(
				BusinessID)
		SELECT DISTINCT
				cob.BusinessID
		FROM
				staging.SubjectCA s (nolock)
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

		INSERT INTO dataflow.BusinessScoreChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				#tblBY t (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				t.BusinessID = cob.BusinessID
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessProfileChangeQueue (nolock)
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