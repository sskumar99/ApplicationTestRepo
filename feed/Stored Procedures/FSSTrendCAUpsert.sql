-- =============================================
-- Author:		DR
-- Create date: 08-31-2015
-- Description:	This will upsert Canadian FSS Trend scores
-- =============================================
CREATE PROCEDURE [feed].[FSSTrendCAUpsert](
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
									staging.FSSTrendCA (nolock)), '1900-01-01');

		SELECT DISTINCT 
				@ConfigurationID	= e.ConfigurationID,
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.FSSTrendCA pt (nolock) 
			ON 
				e.ExecutionID = pt.ExecutionID;

		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';


		

		UPDATE
				ct
		SET
				InitialMonth		= @InitialMonth,
				FSSMonth1			= sct.FSSMonth1,
				FSSMonth2			= sct.FSSMonth2,
				FSSMonth3			= sct.FSSMonth3,
				FSSMonth4			= sct.FSSMonth4,
				FSSMonth5			= sct.FSSMonth5,
				FSSMonth6			= sct.FSSMonth6,
				FSSMonth7			= sct.FSSMonth7,
				FSSMonth8			= sct.FSSMonth8,
				FSSMonth9			= sct.FSSMonth9,
				FSSMonth10			= sct.FSSMonth10,
				FSSMonth11			= sct.FSSMonth11,
				FSSMonth12			= sct.FSSMonth12,
				LineageRowID		= sct.LineageRowID,
				UpdatedDate			= @Now,
				UpdatedBy			= @By
		FROM
				staging.FSSTrendCA sct (nolock)
		INNER JOIN
				feed.FSSTrend ct 
			ON
				sct.DunsNumber = ct.DunsNumber;


	


		INSERT INTO feed.FSSTrend(
				BusinessID,
				DunsNumber,
				InitialMonth,
				ISOCountryAlpha2Code,
				FSSMonth1,
				FSSMonth2,
				FSSMonth3,
				FSSMonth4,
				FSSMonth5,
				FSSMonth6,
				FSSMonth7,
				FSSMonth8,
				FSSMonth9,
				FSSMonth10,
				FSSMonth11,
				FSSMonth12,
				LineageRowID,
				ConfigurationID,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				ct.BusinessID,
				ct.DunsNumber,
				@InitialMonth,
				'CA',
				ct.FSSMonth1,
				ct.FSSMonth2,
				ct.FSSMonth3,
				ct.FSSMonth4,
				ct.FSSMonth5,
				ct.FSSMonth6,
				ct.FSSMonth7,
				ct.FSSMonth8,
				ct.FSSMonth9,
				ct.FSSMonth10,
				ct.FSSMonth11,
				ct.FSSMonth12,
				ct.LineageRowID,
				@ConfigurationID,
				@Now,
				@By
		FROM
				staging.FSSTrendCA ct (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.FSSTrend (nolock)
							WHERE
									DunsNumber = ct.DunsNumber);	
			


		UPDATE
				ct
		SET
				InitialMonth	= @InitialMonth,
				FSSMonth1	= NULL,
				FSSMonth2	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth3	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth4	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth5	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth6	=  CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth7	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth8	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth9	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth8
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth10	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth9
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth8
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth11	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth10
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth9
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth8
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 10 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth12	= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth11
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth10
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth9
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth8
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN FSSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 8 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 9 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 10 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 11 THEN FSSMonth1
										ELSE NULL
								END,
							
				UpdatedDate		= @Now,
				UpdatedBy		= @By
		FROM
				feed.FSSTrend ct
		WHERE
					ct.ISOCountryAlpha2Code = 'CA'
			AND ct.InitialMonth <> @InitialMonth
			AND NOT EXISTS (SELECT
									1
							FROM
									staging.FSSTrendCA sct (nolock)
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
					'FSS'
			FROM
					dataflow.CirrusOnlineBusiness cob (nolock)
		
			INNER JOIN
					staging.FSSTrendCA ct (nolock)
				ON
					ct.DunsNumber = cob.DunsNumber
			WHERE
					NOT EXISTS (
								SELECT
										1
								FROM
										dataflow.BusinessScoreTrendQueue (nolock)
								WHERE
										BusinessID = cob.BusinessID
									AND ScoreType = 'FSS');	


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