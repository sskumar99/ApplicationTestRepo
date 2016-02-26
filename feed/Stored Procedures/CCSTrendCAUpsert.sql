-- =============================================
-- Author:		DR
-- Create date: 08-31-2015
-- Description:	This will upsert Canadian CCS Trend scores
-- =============================================
CREATE PROCEDURE [feed].[CCSTrendCAUpsert](
	@IsMonthlyFile		int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber			int = 0,
				@ErrorMessage			nvarchar(4000) = 'Success',
				@ErrorSeverity			int,
				@DataFeedEffectiveDate	int,
				@InitialMonth			date,
				@ConfigurationID		int,
				@ExecutionID			int,
				@Now					datetime		= GETUTCDATE(),
				@By						varchar(50);;	

    BEGIN TRY

		BEGIN TRANSACTION;
		
		SET @InitialMonth = ISNULL((
								SELECT TOP 1 
										EOMONTH(DATEADD(MONTH,-1,CAST(CAST(DataFeedEffectiveDate AS varchar) AS date))) AS InitialMonth 
								FROM 
										staging.CCSTrendCA (nolock)), '1900-01-01');

		SELECT DISTINCT 
				@ConfigurationID	= e.ConfigurationID,
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.CCSTrendCA pt (nolock) 
			ON 
				e.ExecutionID = pt.ExecutionID;

		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';
		

		
		UPDATE
				ct
		SET
				InitialMonth		= @InitialMonth,
				CCSMonth1			= sct.CCSMonth1,
				CCSMonth2			= sct.CCSMonth2,
				CCSMonth3			= sct.CCSMonth3,
				CCSMonth4			= sct.CCSMonth4,
				CCSMonth5			= sct.CCSMonth5,
				CCSMonth6			= sct.CCSMonth6,
				CCSMonth7			= sct.CCSMonth7,
				CCSMonth8			= sct.CCSMonth8,
				CCSMonth9			= sct.CCSMonth9,
				CCSMonth10			= sct.CCSMonth10,
				CCSMonth11			= sct.CCSMonth11,
				CCSMonth12			= sct.CCSMonth12,
				LineageRowID		= sct.LineageRowID,
				UpdatedDate			= @Now,
				UpdatedBy			= @By
		FROM
				staging.CCSTrendCA sct (nolock)
		INNER JOIN
				feed.CCSTrend ct 
			ON
				sct.DunsNumber = ct.DunsNumber;


	


		INSERT INTO feed.CCSTrend(
				BusinessID,
				DunsNumber,
				InitialMonth,
				ISOCountryAlpha2Code,
				CCSMonth1,
				CCSMonth2,
				CCSMonth3,
				CCSMonth4,
				CCSMonth5,
				CCSMonth6,
				CCSMonth7,
				CCSMonth8,
				CCSMonth9,
				CCSMonth10,
				CCSMonth11,
				CCSMonth12,
				LineageRowID,
				ConfigurationID,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				ct.BusinessID,
				ct.DunsNumber,
				@InitialMonth,
				'CA',
				ct.CCSMonth1,
				ct.CCSMonth2,
				ct.CCSMonth3,
				ct.CCSMonth4,
				ct.CCSMonth5,
				ct.CCSMonth6,
				ct.CCSMonth7,
				ct.CCSMonth8,
				ct.CCSMonth9,
				ct.CCSMonth10,
				ct.CCSMonth11,
				ct.CCSMonth12,
				ct.LineageRowID,
				@ConfigurationID,
				@Now,
				@By
		FROM
				staging.CCSTrendCA ct (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.CCSTrend (nolock)
							WHERE
									DunsNumber = ct.DunsNumber);	
			



		UPDATE
				ct
		SET
				InitialMonth	= @InitialMonth,
				CCSMonth1		= NULL,
				CCSMonth2		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth3		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth4		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth5		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth6		=  CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth7		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth8		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN CCSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth9		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth8
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN CCSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN CCSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth10		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth9
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth8
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN CCSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN CCSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN CCSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth11		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth10
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth9
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth8
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN CCSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN CCSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN CCSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN CCSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 10 THEN CCSMonth1
										ELSE NULL
								END,
				CCSMonth12		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN CCSMonth11
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN CCSMonth10
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN CCSMonth9
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN CCSMonth8
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN CCSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN CCSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN CCSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN CCSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN CCSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 10 THEN CCSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 11 THEN CCSMonth1
										ELSE NULL
								END,
							
				UpdatedDate		= @Now,
				UpdatedBy		= @By
		FROM
				feed.CCSTrend ct
		WHERE
				ct.ISOCountryAlpha2Code = 'CA'
			AND ct.InitialMonth <> @InitialMonth
			AND NOT EXISTS (SELECT
									1
							FROM
									staging.CCSTrendCA sct (nolock)
							WHERE 
									sct.DunsNumber = ct.DunsNumber);

		SELECT
					@InitialMonth AS InitialMonth;

		--Enqueue businesses to CirrusOnline update
		IF @IsMonthlyFile = 0
			INSERT INTO dataflow.BusinessScoreTrendQueue(
					BusinessID,
					ScoreType
					)
			SELECT 
					cob.BusinessID,
					'CCS'
			FROM
					dataflow.CirrusOnlineBusiness cob (nolock)
		
			INNER JOIN
					staging.CCSTrendCA pt (nolock)
				ON
					pt.DunsNumber = cob.DunsNumber
			WHERE
					NOT EXISTS (
								SELECT
										1
								FROM
										dataflow.BusinessScoreTrendQueue (nolock)
								WHERE
										BusinessID = cob.BusinessID
									AND ScoreType = 'CCS');	

		
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