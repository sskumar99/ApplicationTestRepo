-- =============================================
-- Author:		DR
-- Create date: 08-12-2015
-- Description:	This will upsert EU subject data
-- =============================================
CREATE PROCEDURE [feed].[SubjectAcxiomUpsert]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber		int = 0,
				@ErrorMessage		nvarchar(4000) = 'Success',
				@ErrorSeverity		int,
				@ExecutionID		int,
				@Now				datetime		= GETUTCDATE(),
				@By					varchar(50);		

    BEGIN TRY

		
		IF NOT EXISTS(
						SELECT
								1
						FROM
								staging.SubjectAcxiom
						WHERE
								Subject = 1)
				RETURN;

		
		IF OBJECT_ID('tempdb..#tblSubjectAcxiom') IS NOT NULL 
			DROP TABLE #tblSubjectAcxiom;
		
		IF OBJECT_ID('tempdb..#tblOOB') IS NOT NULL 
			DROP TABLE #tblOOB;

		CREATE TABLE #tblSubjectAcxiom(
				BusinessID				bigint,
				DunsNumber				varchar(10),
				DataFeedEffectiveDate	int,
				LineageRowID			bigint,
				ElementID				varchar(10),
				ElementValue			nvarchar(500),
				ElementDescription		nvarchar(500),
				RiskIndicatorStatus		nvarchar(500) NULL,
				PRIMARY KEY CLUSTERED (BusinessID, ElementID));


		CREATE TABLE #tblOOB(
				BusinessID		bigint PRIMARY KEY CLUSTERED);


		INSERT INTO #tblSubjectAcxiom(
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				LineageRowID,
				ElementID,
				ElementValue,
				ElementDescription,
				RiskIndicatorStatus)
		SELECT
				b.BusinessID,
				b.DunsNumber,
				b.DataFeedEffectiveDate,
				b.LineageRowID,
				b.ElementID,
				b.ElementValue,
				CASE 
					WHEN b.ElementID = 'XX' THEN b.SevereNegativeInformation
					WHEN b.ElementID = 'XZ' THEN b.SevereNegativeInformation
					ELSE sfem.SubjFeedElememtDesc 
				END	AS ElementDescription,
				CASE
					WHEN b.ElementID = 'XZ' THEN
												CASE
													WHEN b.ElementValue = 'Y' THEN	CAST(feed.fn_GetSevereRiskStatusBySCoTS(1, b.SevereNegativeInformation) AS nvarchar(500)) -- CIR-11230 RiskIndicatorStatus
													ELSE NULL
												END
					ELSE
						NULL
					END AS RiskIndicatorStatus
		FROM		(
					SELECT
							BusinessID,
							DunsNumber,
							DataFeedEffectiveDate,
							LineageRowID,
							ElementID,
							ElementValue,
							SevereNegativeInformation
					FROM	(
							SELECT
									ssa.BusinessID,
									ssa.DunsNumber,
									ssa.DataFeedEffectiveDate,
									ssa.LineageRowID,
									CAST(feed.fn_GetRiskIndicatorBySCoTS(2, ssa.OutOfBusinessIndicator) AS nvarchar(500))		AS AD,
									CAST(feed.fn_GetRiskIndicatorBySCoTS(3, ssa.NarrationCode) AS nvarchar(500))				AS AU,
									CAST(ssa.EmployeeQuantity AS nvarchar(500))													AS AE,
									CAST(ssa.PrimarySIC AS nvarchar(500))														AS AF,
									CAST(ssa.PrimarySICType AS nvarchar(500))													AS XY,
									CAST(feed.fn_GetRiskIndicatorBySCoTS(1, ssa.SevereNegativeInformation) AS nvarchar(500))	AS XX,
									CAST(feed.fn_GetRiskIndicatorBySCoTS(1, ssa.SevereNegativeInformation) AS nvarchar(500))	AS XZ,
									ssa.SevereNegativeInformation
							FROM
									staging.SubjectAcxiom ssa
							WHERE
									ssa.Subject = 1
								AND ssa.BusinessID IS NOT NULL) p
					UNPIVOT	(
							ElementValue FOR ElementID IN (AD,AU,AE,AF,XY,XX,XZ)) AS up) b
		LEFT JOIN
				reference.SubjectFeedElementsMap sfem
			ON
				b.ElementID = sfem.SubjFeedElememtCode;


		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.SubjectAcxiom sa (nolock) 
			ON 
				e.ExecutionID = sa.ExecutionID;



		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';
		BEGIN TRANSACTION;
		



		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.SubjectAcxiom sa (nolock) 
			ON 
				e.ExecutionID = sa.ExecutionID;


		INSERT INTO #tblOOB(
				BusinessID)
		SELECT
				t.BusinessID
		FROM
				#tblSubjectAcxiom t
		INNER JOIN
				feed.Subject s (nolock)
			ON
				t.BusinessID = s.BusinessID
			AND t.ElementID = s.ElementID
			AND t.ElementValue <> s.ElementValue
		WHERE
				t.ElementID = 'AD';


		UPDATE
				s
		SET
				DataFeedEffectiveDate	= t.DataFeedEffectiveDate,
				ElementValue			= t.ElementValue,
				LineageRowID			= t.LineageRowID,
				RiskIndicatorStatus		= t.RiskIndicatorStatus,
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				#tblSubjectAcxiom t
		INNER JOIN
				feed.Subject s
			ON
				t.BusinessID = s.BusinessID
			AND t.ElementID = s.ElementID;


		UPDATE
				s
		SET
				DataFeedEffectiveDate	= 19000101,
				ElementValue			= NULL,
				RiskIndicatorStatus		= NULL,
				LineageRowID			= -1,
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				feed.Subject s
		INNER JOIN
				#tblSubjectAcxiom t
			ON
				s.BusinessID = t.BusinessID
		WHERE
				s.ElementValue IS NOT NULL	
			AND NOT EXISTS (
							SELECT
									1
							FROM
									#tblSubjectAcxiom 
							WHERE
									BusinessID = s.BusinessID
								AND ElementID = s.ElementID) ;
		

		INSERT INTO feed.Subject(
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
		SELECT
				BusinessID,
				DunsNumber,
				DataFeedEffectiveDate,
				ElementID,
				ElementDescription,
				ElementValue,
				RiskIndicatorStatus,
				LineageRowID,
				@Now,
				@By
		FROM
				#tblSubjectAcxiom t
		WHERE
				NOT EXISTS(
						SELECT
								1
						FROM
								feed.Subject
						WHERE
								BusinessID = t.BusinessID
							AND ElementID = t.ElementID);


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessRiskIndicatorChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.SubjectAcxiom s (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				s.BusinessID = cob.BusinessID
		WHERE
				s.Subject = 1
			AND NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessRiskIndicatorChangeQueue (nolock)
							WHERE
									BusinessID = cob.BusinessID);


		INSERT INTO dataflow.BusinessProfileChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.SubjectAcxiom s (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				s.BusinessID = cob.BusinessID
		WHERE
				s.Subject = 1
			AND s.PrimarySIC IS NOT NULL
			AND NOT EXISTS (
							SELECT
									1
							FROM
									dataflow.BusinessProfileChangeQueue (nolock)
							WHERE
									BusinessID = cob.BusinessID);

		
		INSERT INTO dataflow.BusinessScoreChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				#tblOOB t (nolock)
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


		IF OBJECT_ID('tempdb..#tblSubjectAcxiom') IS NOT NULL 
			DROP TABLE #tblSubjectAcxiom;

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