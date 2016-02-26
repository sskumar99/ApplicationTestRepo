-- =============================================
-- Author:		DR
-- Create date: 09-16-2015
-- Description:	This will upsert Portfolio Match Results  data
-- =============================================
CREATE PROCEDURE [feed].[PortfolioMatchResultsUpsert]

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber		int = 0,
				@ErrorMessage		nvarchar(4000) = 'Success',
				@ErrorSeverity		int,
				@ExecutionID		int,
				@Now				datetime2	= GETUTCDATE(),
				@By					varchar(50);	

    BEGIN TRY

		BEGIN TRANSACTION;
		
		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.PortfolioMatchResults si (nolock) 
			ON 
				e.ExecutionID = si.ExecutionID;
		
		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';


		DELETE 
				pmr
		FROM
				staging.PortfolioMatchResults pmr
		INNER JOIN
				feed.[Identity] i (nolock)
			ON
				pmr.DunsNumber = i.DunsNumber
			AND i.IsActive = 1;



			
		UPDATE
				i
		SET
				DataFeedEffectiveDate	= pmr.DataFeedEffectiveDate,
				LineageRowID			= pmr.LineageRowID,
				City					= pmr.City,
				Name					= pmr.BusinessName,
				Street1					= pmr.AddressLine1,
				Street2					= pmr.AddressLine2,
				PostalCode				= pmr.PostalCode,
				State					= ISNULL(NULLIF(pmr.StateProvinceCode, ''), StateProvince),
				IsActive				= 1,
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.PortfolioMatchResults pmr (nolock)
		INNER JOIN
				feed.[Identity] i 
			ON
				pmr.DunsNumber = i.DunsNumber
			AND i.IsActive = 0;
		

		
		
							
		INSERT INTO feed.[Identity](
				DunsNumber,
				Country,
				DataFeedEffectiveDate,
				LineageRowID,
				City,
				Name,
				Street1,
				Street2,
				PostalCode,
				State,
				IsActive,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				pmr.DunsNumber,
				pmr.CountryCode,
				pmr.DataFeedEffectiveDate,
				pmr.LineageRowID,
				pmr.City,
				pmr.BusinessName,
				pmr.AddressLine1,
				pmr.AddressLine2,
				pmr.PostalCode,
				ISNULL(NULLIF(pmr.StateProvinceCode, ''), StateProvince),
				1,			
				@Now,
				@By
		FROM
				staging.PortfolioMatchResults pmr (nolock)
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = pmr.DunsNumber);	


		----Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessProfileChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.PortfolioMatchResults pmr
		INNER JOIN
				feed.[Identity] i
			ON
				pmr.DunsNumber = i.DunsNumber
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				i.BusinessID = cob.BusinessID
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