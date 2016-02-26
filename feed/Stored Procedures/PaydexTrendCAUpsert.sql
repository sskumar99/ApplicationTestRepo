-- =============================================
-- Author:		DR
-- Create date: 08-31-2015
-- Description:	This will upsert Canadian Paydex Trend scores
-- =============================================
CREATE PROCEDURE [feed].[PaydexTrendCAUpsert](
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
				@Now					datetime = GETUTCDATE(),
				@By						varchar(50);		

    BEGIN TRY

		BEGIN TRANSACTION;
		
		SET @InitialMonth = ISNULL((
								SELECT TOP 1 
										EOMONTH(DATEADD(MONTH,-1,CAST(CAST(DataFeedEffectiveDate AS varchar) AS date))) AS InitialMonth 
								FROM 
										staging.PaydexTrendCA (nolock)), '1900-01-01');


		SELECT DISTINCT 
				@ConfigurationID	= e.ConfigurationID,
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.PaydexTrendCA pt (nolock) 
			ON 
				e.ExecutionID = pt.ExecutionID;


		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';

		

		UPDATE
				pt
		SET
				InitialMonth	= @InitialMonth,
				PaydexMonth1	= CASE
										WHEN TRY_CAST(spt.PaydexMonth1 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth1
										ELSE NULL
								END,
				PaydexMonth2	= CASE
										WHEN TRY_CAST(spt.PaydexMonth2 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth2
										ELSE NULL
								END,
				PaydexMonth3	= CASE
										WHEN TRY_CAST(spt.PaydexMonth3 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth3
										ELSE NULL
								END,
				PaydexMonth4	= CASE
										WHEN TRY_CAST(spt.PaydexMonth4 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth4
										ELSE NULL
								END,
				PaydexMonth5	= CASE
										WHEN TRY_CAST(spt.PaydexMonth5 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth5
										ELSE NULL
								END,
				PaydexMonth6	= CASE
										WHEN TRY_CAST(spt.PaydexMonth6 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth6
										ELSE NULL
								END,
				PaydexMonth7	= CASE
										WHEN TRY_CAST(spt.PaydexMonth7 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth7
										ELSE NULL
								END,
				PaydexMonth8	= CASE
										WHEN TRY_CAST(spt.PaydexMonth8 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth8
										ELSE NULL
								END,
				PaydexMonth9	= CASE
										WHEN TRY_CAST(spt.PaydexMonth9 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth9
										ELSE NULL
								END,
				PaydexMonth10	= CASE
										WHEN TRY_CAST(spt.PaydexMonth10 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth10
										ELSE NULL
								END,
				PaydexMonth11	= CASE
										WHEN TRY_CAST(spt.PaydexMonth11 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth11
										ELSE NULL
								END,
				PaydexMonth12	= CASE
										WHEN TRY_CAST(spt.PaydexMonth12 AS tinyint) BETWEEN 0 AND 100 THEN spt.PaydexMonth12
										ELSE NULL
								END,
				LineageRowID	= spt.LineageRowID,
				UpdatedDate		= @Now,
				UpdatedBy		= @By
		FROM
				feed.PaydexTrend pt
		INNER JOIN
				staging.PaydexTrendCA spt
			ON
				pt.DunsNumber = spt.DunsNumber;

	
		
		INSERT INTO feed.PaydexTrend(
					BusinessID,
					DunsNumber,
					InitialMonth,
					ISOCountryAlpha2Code,
					PaydexMonth1,
					PaydexMonth2,
					PaydexMonth3,
					PaydexMonth4,
					PaydexMonth5,
					PaydexMonth6,
					PaydexMonth7,
					PaydexMonth8,
					PaydexMonth9,
					PaydexMonth10,
					PaydexMonth11,
					PaydexMonth12,
					LineageRowID,
					ConfigurationID,
					CreatedDate,
					CreatedBy)
			SELECT
					BusinessID,
					DunsNumber,
					@InitialMonth,
					'CA',
					CASE
							WHEN TRY_CAST(pt.PaydexMonth1 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth1
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth2 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth2
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth3 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth3
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth4 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth4
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth5 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth5
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth6 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth6
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth7 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth7
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth8 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth8
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth9 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth9
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth10 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth10
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth11 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth11
							ELSE NULL
					END,
					CASE
							WHEN TRY_CAST(pt.PaydexMonth12 AS tinyint) BETWEEN 0 AND 100 THEN pt.PaydexMonth12
							ELSE NULL
					END,
					LineageRowID,
					@ConfigurationID,
					@Now,
					@By
			FROM
					staging.PaydexTrendCA pt
			WHERE
					NOT EXISTS (
								SELECT
										1
								FROM
										feed.PaydexTrend (nolock)
								WHERE
										DunsNumber = pt.DunsNumber);
		
	

			UPDATE
					pt
			SET
					InitialMonth	= @InitialMonth,
					PaydexMonth1	= NULL,
					PaydexMonth2	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth3	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth4	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth5	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth4
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth6	=  CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth5
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth4
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth7	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth6
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth5
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth4
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth8	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth7
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth6
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth5
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN PaydexMonth4
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth9	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth8
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth7
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth6
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN PaydexMonth5
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN PaydexMonth4
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth10	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth9
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth8
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth7
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN PaydexMonth6
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN PaydexMonth5
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN PaydexMonth4
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth11	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth10
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth9
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth8
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN PaydexMonth7
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN PaydexMonth6
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN PaydexMonth5
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN PaydexMonth4
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 10 THEN PaydexMonth1
											ELSE NULL
									END,
					PaydexMonth12	= CASE
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN PaydexMonth11
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN PaydexMonth10
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN PaydexMonth9
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN PaydexMonth8
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN PaydexMonth7
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN PaydexMonth6
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN PaydexMonth5
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN PaydexMonth4
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN PaydexMonth3
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 10 THEN PaydexMonth2
											WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 11 THEN PaydexMonth1
											ELSE NULL
									END,
							
					UpdatedDate		= GETUTCDATE(),
					UpdatedBy		= OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')'
			FROM
					feed.PaydexTrend pt
			WHERE
					pt.ISOCountryAlpha2Code = 'CA'
				AND pt.InitialMonth <> @InitialMonth
				AND NOT EXISTS (SELECT
										1
								FROM
										staging.PaydexTrendCA spt (nolock)
								WHERE 
										spt.DunsNumber = pt.DunsNumber);
			
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
					'PAYDEX'
			FROM
					dataflow.CirrusOnlineBusiness cob (nolock)
		
			INNER JOIN
					staging.PaydexTrendCA pt (nolock)
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
									AND ScoreType = 'PAYDEX');	

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