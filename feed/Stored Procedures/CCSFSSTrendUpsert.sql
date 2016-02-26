-- =============================================
-- Author:		DR
-- Create date: 08-31-2015
-- Description:	This will upsert US CCS/FSS Trend scores
-- =============================================
CREATE PROCEDURE [feed].[CCSFSSTrendUpsert]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber			int = 0,
				@ErrorMessage			nvarchar(4000) = 'Success',
				@ErrorSeverity			int,
				@InitialMonth			date,
				@ConfigurationID		int,
				@ExecutionID			int,
				@Now					datetime		= GETUTCDATE(),
				@By						varchar(50);;	

    BEGIN TRY

		BEGIN TRANSACTION;
		
		SELECT DISTINCT 
				@ConfigurationID			= e.ConfigurationID,
				@ExecutionID				= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.CCSFSSTrend t (nolock) 
			ON 
				e.ExecutionID = t.ExecutionID;

		SET @InitialMonth = ISNULL((
								SELECT TOP 1 
										EOMONTH(DATEADD(MONTH,-1,CAST(CAST(DataFeedEffectiveDate AS varchar) AS date))) AS InitialMonth 
								FROM 
										staging.CCSFSSTrend (nolock)), '1900-01-01');

		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';


				

		---Update existing businesses
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
				UpdatedBy			= OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')'
		FROM
				staging.CCSFSSTrend sct (nolock)
		INNER JOIN
				feed.CCSTrend ct 
			ON
				sct.DunsNumber = ct.DunsNumber;


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
				UpdatedBy			= OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')'
		FROM
				staging.CCSFSSTrend sct (nolock)
		INNER JOIN
				feed.FSSTrend ct 
			ON
				sct.DunsNumber = ct.DunsNumber;


		---Insert new businesses 
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
				'US',
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
				OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')'
		FROM
				staging.CCSFSSTrend ct (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.CCSTrend (nolock)
							WHERE
									DunsNumber = ct.DunsNumber);	
			

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
				'US',
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
				OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')'
		FROM
				staging.CCSFSSTrend ct (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.FSSTrend (nolock)
							WHERE
									DunsNumber = ct.DunsNumber);


		---Shift scores to the right for businesses which are not exist in the current month feed 


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
							
				UpdatedDate		= GETUTCDATE(),
				UpdatedBy		= OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')'
		FROM
				feed.CCSTrend ct
		WHERE
				ct.ISOCountryAlpha2Code = 'US'
			AND ct.InitialMonth <> @InitialMonth
			AND NOT EXISTS (SELECT
									1
							FROM
									staging.CCSFSSTrend sct (nolock)
							WHERE 
									sct.DunsNumber = ct.DunsNumber);

		

		UPDATE
				ct
		SET
				InitialMonth	= @InitialMonth,
				FSSMonth1		= NULL,
				FSSMonth2		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth1
										ELSE NULL
									END,
				FSSMonth3		= CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth4	=	CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth5	=	CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth6	=	CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth7	=	CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth8	=	CASE
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 1 THEN FSSMonth7
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 2 THEN FSSMonth6
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 3 THEN FSSMonth5
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 4 THEN FSSMonth4
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 5 THEN FSSMonth3
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 6 THEN FSSMonth2
										WHEN DATEDIFF(m, InitialMonth, @InitialMonth) = 7 THEN FSSMonth1
										ELSE NULL
								END,
				FSSMonth9	=	CASE
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
				FSSMonth11	=	CASE
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
				UpdatedBy		= OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')'
		FROM
				feed.FSSTrend ct
		WHERE
				ct.ISOCountryAlpha2Code = 'US'
			AND ct.InitialMonth <> @InitialMonth
			AND NOT EXISTS (SELECT
									1
							FROM
									staging.CCSFSSTrend sct (nolock)
							WHERE 
									sct.DunsNumber = ct.DunsNumber);

		--Enqueue businesses to CirrusOnline update
		--Now from EUTRend.dtsx	

		COMMIT TRANSACTION;


		SELECT
			@InitialMonth AS InitialMonth;

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