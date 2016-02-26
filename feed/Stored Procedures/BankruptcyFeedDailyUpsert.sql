-- =============================================
-- Author:		DR
-- Create date: 09-21-2015
-- Description:	This will upsert bankruptcy subject US data
-- =============================================
CREATE PROCEDURE [feed].[BankruptcyFeedDailyUpsert]
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
				staging.BankruptcyFeedDaily pt (nolock) 
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
		SELECT
				DunsNumber,
				'US',
				0,
				@Now,
				@By
		FROM
				staging.BankruptcyFeedDaily bfd (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = bfd.DunsNumber);


		UPDATE
				bfd
		SET
				BusinessID = i.BusinessID
		FROM
				staging.BankruptcyFeedDaily bfd
		INNER JOIN
				feed.[Identity] i  (nolock)
			ON
				bfd.DunsNumber = i.DunsNumber;


		
		UPDATE
				s
		SET
				DataFeedEffectiveDate	= bfd.DataFeedEffectiveDate,
				ElementValue			= CASE 
											WHEN bfd.Status IN ('OPEN','PLAN CONFIRMED') THEN 'Y'
											WHEN bfd.Status IN ('CLOSED', 'DISMISSED','DISCHARGED','VOID','ARCHIVED') THEN 'N'
											ELSE NULL
										END,
				LineageRowID			= bfd.LineageRowID,
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.BankruptcyFeedDaily bfd (nolock)
		INNER JOIN
				feed.Subject s 
			ON
				bfd.BusinessID = s.BusinessID
			AND s.ElementID = 'BB' 
			AND bfd.Status IS NOT NULL;


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
				bfd.BusinessID,
				bfd.DunsNumber,
				bfd.DataFeedEffectiveDate,
				'BB',
				'BANKRUPTCY_YN',
				 CASE 
					WHEN bfd.Status IN ('OPEN','PLAN CONFIRMED') THEN 'Y'
					WHEN bfd.Status IN ('CLOSED', 'DISMISSED','DISCHARGED','VOID','ARCHIVED') THEN 'N'
					ELSE NULL
				END,
				bfd.LineageRowID,
				@Now,
				@By
		FROM
				staging.BankruptcyFeedDaily bfd (nolock)
		WHERE
				bfd.Status IS NOT NULL
			AND NOT EXISTS (
							SELECT
									1
							FROM
									feed.Subject (nolock)
							WHERE
									BusinessID = bfd.BusinessID
								AND ElementID = 'BB');	
			

		---Severe risk
		MERGE feed.Subject AS Target
		USING	(
				SELECT
						bfd.BusinessID,
						bfd.DunsNumber,
						bfd.DataFeedEffectiveDate,
						'XZ'															AS ElementID,
						'SevereRisk'													AS ElementDescription,
						CASE
							WHEN bb.ElementValue > 0 OR au.ElementValue > 0 THEN 'Y'
							WHEN bb.ElementValue = 0 OR au.ElementValue = 0 THEN 'N'
							ELSE NULL
						END																AS ElementValue,
						COALESCE(bb.LineageRowID,au.LineageRowID)						AS LineageRowID
				FROM
						staging.BankruptcyFeedDaily bfd (nolock)
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
									BusinessID = bfd.BusinessID
								AND ElementID = 'BB') bb
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
									BusinessID = bfd.BusinessID
									AND ElementID = 'AU') au
				
				WHERE
						bfd.Status IS NOT NULL) AS Source
		ON
			Target.BusinessID = Source.BusinessID
		AND Target.ElementID = Source.ElementID
		WHEN MATCHED THEN 
			UPDATE SET
						ElementValue			= Source.ElementValue,
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
					Source.LineageRowID,
					@Now,
					@By);


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessRiskIndicatorChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.BankruptcyFeedDaily bfd (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				bfd.BusinessID = cob.BusinessID
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