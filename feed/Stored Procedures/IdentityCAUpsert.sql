-- =============================================
-- Author:		DR
-- Create date: 09-16-2015
-- Description:	This will upsert Canadian identity  data
-- =============================================
CREATE PROCEDURE [feed].[IdentityCAUpsert]
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
				staging.[IdentityCA] si (nolock) 
			ON 
				e.ExecutionID = si.ExecutionID;
		
		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';


		UPDATE
				i
		SET
				DataFeedEffectiveDate	= si.DataFeedEffectiveDate,
				LineageRowID			= si.LineageRowID,
				City					= si.City,
				Name					= si.BusinessName,
				TradeStyle1				= si.TradeStyle1,
				TradeStyle2				= si.TradeStyle2,
				TradeStyle3				= si.TradeStyle3,
				TradeStyle4				= si.TradeStyle4,
				TradeStyle5				= si.TradeStyle5,
				Street1					= si.AddressLine,
				PostalCode				= si.ZipCode,
				State					= si.State,
				Phone					= si.Telephone,
				CEOName					= si.CEOName,
				LegalStructure			= feed.fn_GetLegalStructureByLegalFormCodes(si.LegalStructure, NULL, @Now),
				LegalFormCode			= si.LegalStructure,
				IsActive				= 1,
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.[IdentityCA] si (nolock)
		INNER JOIN
				feed.[Identity] i 
			ON
				si.DunsNumber = i.DunsNumber;
			
	
		

							
		INSERT INTO feed.[Identity](
				DunsNumber,
				DataFeedEffectiveDate,
				LineageRowID,
				Country,
				City,
				Name,
				TradeStyle1,
				TradeStyle2,
				TradeStyle3,
				TradeStyle4,
				TradeStyle5,
				Street1,
				PostalCode,
				State,
				Phone,
				CEOName,
				LegalStructure,
				LegalFormCode,
				IsActive,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				si.DunsNumber,
				si.DataFeedEffectiveDate,
				si.LineageRowID,
				'CA',
				si.City,
				si.BusinessName,
				si.TradeStyle1,
				si.TradeStyle2,
				si.TradeStyle3,
				si.TradeStyle4,
				si.TradeStyle5,
				si.AddressLine,
				si.ZipCode,
				si.State,
				si.Telephone,
				si.CEOName,
				feed.fn_GetLegalStructureByLegalFormCodes(si.LegalStructure, NULL, @Now),
				si.LegalStructure,
				1,					
				@Now,
				@By
		FROM
				staging.[IdentityCA] si (nolock)
	
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = si.DunsNumber);	
			
		---PrimarySICCodeType
		INSERT INTO feed.Subject(
				BusinessID,
				DunsNumber,
				ElementID,
				ElementValue,
				ElementDescription,
				DatafeedEffectiveDate,
				LineageRowID,
				CreatedDate,
				CreatedBy)
		SELECT
				i.BusinessID,
				i.DunsNumber,
				'XY',
				'2831',
				'PrimarySICCodeType',
				si.DataFeedEffectiveDate,
				si.LineageRowID,
				@Now,
				@By
		FROM
				staging.[IdentityCA] si
		INNER JOIN
				feed.[Identity] i
			ON
				si.DunsNumber = i.DunsNumber
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.Subject (nolock)
							WHERE
									BusinessID = i.BusinessID
								AND ElementID = 'XY');


		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessProfileChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.[IdentityCA] si
		INNER JOIN
				feed.[Identity] i
			ON
				si.DunsNumber = i.DunsNumber
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