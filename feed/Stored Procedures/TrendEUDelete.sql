-- =============================================
-- Author:		DR
-- Create date: 10-28-2015
-- Description:	This will delete all EU trend data from feed.*Trend tables
-- =============================================
CREATE PROCEDURE [feed].[TrendEUDelete]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber			int = 0,
				@ErrorMessage			nvarchar(4000) = 'Success',
				@ErrorSeverity			int;	

    BEGIN TRY

		BEGIN TRANSACTION;
		
		DELETE
		FROM
				feed.PaydexTrend 
		WHERE 
				ISOCountryAlpha2Code IN ('GB','IE','LU','NL','BE');


		DELETE
		FROM
				feed.CCSTrend 
		WHERE 
				ISOCountryAlpha2Code IN ('GB','IE','LU','NL','BE');


		DELETE
		FROM
				feed.FSSTrend 
		WHERE 
				ISOCountryAlpha2Code IN ('GB','IE','LU','NL','BE');

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