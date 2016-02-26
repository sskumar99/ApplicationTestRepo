-- =============================================
-- Author:		DR
-- Create date: 10-28-2015
-- Description:	This will update feed.*Trend tables with BusinessID
-- =============================================
CREATE PROCEDURE [feed].[TrendEUBusinessIDUpdate]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber			int = 0,
				@ErrorMessage			nvarchar(4000) = 'Success',
				@ErrorSeverity			int;	

    BEGIN TRY

		BEGIN TRANSACTION;
		
		UPDATE
				pt
		SET 
				BusinessID = i.BusinessID
		FROM
				feed.PaydexTrend pt
		INNER JOIN
				feed.[Identity] i (nolock)
			ON
				pt.DunsNumber = i.DunsNumber
		WHERE 
				pt.ISOCountryAlpha2Code IN ('GB','IE','LU','NL','BE');
			


		UPDATE
				ct
		SET 
				BusinessID = i.BusinessID
		FROM
				feed.CCSTrend ct
		INNER JOIN
				feed.[Identity] i (nolock)
			ON
				ct.DunsNumber = i.DunsNumber
		WHERE 
				ct.ISOCountryAlpha2Code IN ('GB','IE','LU','NL','BE');


		UPDATE
				ft
		SET 
				BusinessID = i.BusinessID
		FROM
				feed.FSSTrend ft
		INNER JOIN
				feed.[Identity] i (nolock)
			ON
				ft.DunsNumber = i.DunsNumber
		WHERE 
				ft.ISOCountryAlpha2Code IN ('GB','IE','LU','NL','BE');


		

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