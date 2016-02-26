-- =============================================
-- Author:		DR
-- Create date: 08-12-2015
-- Description:	This will upsert EU Global Company Profile data
-- =============================================
CREATE PROCEDURE [feed].[IdentityAcxiomUpsert]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber		int = 0,
				@ErrorMessage		nvarchar(4000) = 'Success',
				@ErrorSeverity		int,
				@ExecutionID		int,
				@Now				datetime2 = GETUTCDATE(),
				@By					varchar(50);			

    BEGIN TRY

		
		IF NOT EXISTS(
						SELECT
								1
						FROM
								staging.SubjectAcxiom
						WHERE
								[Identity] = 1 OR GlobalCompanyProfile = 1)
				RETURN;


		

		BEGIN TRANSACTION;
		



		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.SubjectAcxiom sa (nolock) 
			ON 
				e.ExecutionID = sa.ExecutionID;


		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';

		UPDATE
				i
		SET
				DataFeedEffectiveDate	= ssa.DataFeedEffectiveDate,
				LineageRowID			= ssa.LineageRowID,
				City					= CAST(ssa.PrimaryTown AS nvarchar(100)),
				Name					= CAST(ssa.BusinessName AS nvarchar(256)),
				TradeStyle1				= CAST(ssa.TradeStyles1 AS nvarchar(256)),
				TradeStyle2				= CAST(ssa.TradeStyles2 AS nvarchar(256)),
				TradeStyle3				= CAST(ssa.TradeStyles3 AS nvarchar(256)),
				Street1					= CAST(ssa.PrimaryAddressLine1 AS nvarchar(150)),
				Street2					= CAST(ssa.PrimaryAddressLine2 AS nvarchar(150)),
				PostalCode				= CAST(ssa.PrimaryPostalCd AS nvarchar(100)),
				State					= CAST(ssa.PrimaryCounty AS nvarchar(100)),
				Phone					= CAST(ssa.TelephoneNumber AS nvarchar(100)),
				LegalStructure			= COALESCE(ssa.LegalFormtext, l.LegalStructure),
				LegalFormCode			= CAST(ssa.LegalStructure AS nvarchar(100)),
				YearStarted				= ssa.StartYear,
				IncYear					= TRY_CAST(CAST(ssa.IncorporationYear AS varchar) AS date),
				IsActive				= 1,
				UpdatedDate				= @Now,
				UpdatedBy				= @By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				feed.[Identity] i 
			ON
				ssa.DunsNumber = i.DunsNumber
			--AND ssa.DataFeedEffectiveDate >= i.DataFeedEffectiveDate
		OUTER APPLY	(
					SELECT 
							ProductLiteralDescription AS LegalStructure
					FROM
							reference.SCoTSCodeToLiteralMap
					WHERE
							LanguageCode = 39
						AND CodeTableID = 4
						AND @Now BETWEEN EffectiveDate AND ExpirationDate 
						AND SCoTSCode = ssa.LegalStructure) l;


		
		INSERT INTO feed.[Identity](
				DunsNumber,
				DataFeedEffectiveDate,
				LineageRowID,
				City,
				Country,
				Name,
				TradeStyle1,
				TradeStyle2,
				TradeStyle3,
				Street1,
				Street2,
				PostalCode,
				State,
				Phone,
				LegalStructure,
				LegalFormCode,
				YearStarted,
				IncYear,
				CreatedDate,
				CreatedBy)
		SELECT DISTINCT
				ssa.DunsNumber,
				ssa.DataFeedEffectiveDate,
				ssa.LineageRowID,
				CAST(ssa.PrimaryTown AS nvarchar(100)),
				gccm.ISOCountryAlpha2Code,
				CAST(ssa.BusinessName AS nvarchar(256)),
				CAST(ssa.TradeStyles1 AS nvarchar(256)),
				CAST(ssa.TradeStyles2 AS nvarchar(256)),
				CAST(ssa.TradeStyles3 AS nvarchar(256)),
				CAST(ssa.PrimaryAddressLine1 AS nvarchar(150)),
				CAST(ssa.PrimaryAddressLine2 AS nvarchar(150)),
				CAST(ssa.PrimaryPostalCd AS nvarchar(100)),
				CAST(ssa.PrimaryCounty AS nvarchar(100)),
				CAST(ssa.TelephoneNumber AS nvarchar(100)),
				COALESCE(ssa.LegalFormtext, l.LegalStructure),
				CAST(ssa.LegalStructure AS nvarchar(100)),
				ssa.StartYear,
				TRY_CAST(CAST(ssa.IncorporationYear AS varchar) AS date),					
				@Now,
				@By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				reference.GEOUnitToISOCountryCodeMap gccm (nolock)
			ON
				ssa.CountryCode = gccm.GEOUnitID
		OUTER APPLY	(
					SELECT TOP 1
							ProductLiteralDescription AS LegalStructure
					FROM
							reference.SCoTSCodeToLiteralMap
					WHERE
							LanguageCode = 39
						AND CodeTableID = 4
						AND @Now BETWEEN EffectiveDate AND ExpirationDate 
						AND SCoTSCode = ssa.LegalStructure) l
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.[Identity] (nolock)
							WHERE
									DunsNumber = ssa.DunsNumber);

		
		UPDATE
				sa
		SET
				BusinessID = i.BusinessID
		FROM
				staging.SubjectAcxiom sa
		INNER JOIN
				feed.[Identity] i
			ON
				sa.DunsNumber = i.DunsNumber;	

		
		--GlobalCompanyProfile
		UPDATE
				gcp
		SET
				Address3						= CAST(ssa.PrimaryAddressLine3 AS nvarchar(100)),
				Address4						= CAST(ssa.PrimaryAddressLine4 AS nvarchar(100)),
				RegistrationNumber				= CAST(ssa.RegistrationNumber AS nvarchar(32)),
				VATNumber						= CAST(ssa.VatNumber AS varchar(50)),
				SeverNegativeInfo				= CAST(ssa.SevereNegativeInformation AS varchar(50)),
				RegAddressLine1					= CAST(ssa.RegisteredAddressLine1 AS nvarchar(100)),
				RegAddressLine2					= CAST(ssa.RegisteredAddressLine2 AS nvarchar(100)),
				RegAddressLine3					= CAST(ssa.RegisteredAddressLine3 AS nvarchar(100)),
				RegAddressLine4					= CAST(ssa.RegisteredAddressLine4 AS nvarchar(100)),
				RegState						= ssa.RegisteredCounty,
				RegPostalCode					= CAST(ssa.RegisteredPostalCd  AS varchar(50)),
				RegCity							= CAST(ssa.RegisteredTown AS varchar(50)),
				LocalActivityCode				= CAST(ssa.LocalActivityCode AS varchar(50)),
				LocalActivityType				= CAST(ssa.LocalActivityCodeType AS varchar(50)),
				DNBRatingFinancialStrength		= CAST(ssa.DnBRatingFinancialStrength AS varchar(50)),
				DNBRatingRiskInd				= CAST(ssa.DnBRatingRiskIndicator AS varchar(50)),
				MaxCreditRec					= CAST(ssa.MaximumCreditRecommendation AS varchar(50)),
				CurrencyCode					= feed.fn_Get3LetterCountryCodeBySCoTS(ssa.CurrencyCode1, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)) ,
				LegalEventAmtYr1				= TRY_CAST(ssa.LegalEvent1YearTotalAmount AS decimal(19,4)),
				LegalEvent1YrCurrCD				= CAST(ssa.LegalEvent1YearTotalAmountCurrencyCd AS nvarchar(6)),
				LegalEventCnt1yr				= TRY_CAST(ssa.LegalEvent1YearTotalCount AS int),
				LegalEventAmtYr5				= TRY_CAST(ssa.LegalEvent5YearTotalAmount AS decimal(19,4)),
				LegalEvent5YrCurrCD				= CAST(ssa.LegalEvent5YearTotalAmountCurrencyCd AS nvarchar(6)),
				LegalEventCntYr5				= TRY_CASt(ssa.LegalEvent5YearTotalCount AS int),
				LegalFormText					= CAST(ssa.LegalFormtext AS nvarchar(500)),
				IssuedCapital					= TRY_CAST(ssa.IssuedCapital AS decimal(19,4)),
				IssuedCapitalCurrencyCode		= CAST(ssa.IssuedCapitalCurrencyCode AS varchar(6)),
				IssuedCapitalCurrencyCodeValue	= feed.fn_Get3LetterCountryCodeBySCoTS(ssa.IssuedCapitalCurrencyCode, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)),
				RecordTypeCode					= ssa.RecordTypeCode,
				RecordTypeCodeValue				= sclm1.ProductLiteralDescription,
				TransferReasonCode				= ssa.TransferReasonCode,
				TransferReasonCodeValue			= sclm2.ProductLiteralDescription,
				InfoSourceCode					= ssa.InfoSourceCode,
				InfoSourceCodeValue				= sclm3.ProductLiteralDescription,
				DeletionIndicator				= TRY_PARSE(ssa.DeletionIndicator AS tinyint),
				StopDistributionIndicator		= TRY_PARSE(ssa.StopDistributionIndicator AS tinyint),
				UpdatedDate						= @Now,
				UpdatedBy						= @By
		FROM
				staging.SubjectAcxiom ssa (nolock)
		INNER JOIN
				feed.GlobalCompanyProfile gcp 
			ON
				ssa.BusinessID = gcp.BusinessID
		
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap sclm1
			ON
				sclm1.SCoTSCode = ssa.RecordTypeCode
			AND sclm1.LanguageCode = 39
			AND sclm1.CodeTableID = 270
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap sclm2
			ON
				sclm2.SCoTSCode = ssa.TransferReasonCode
			AND sclm2.LanguageCode = 39
			AND sclm2.CodeTableID = 101
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap sclm3
			ON
				sclm3.SCoTSCode = ssa.InfoSourceCode
			AND sclm3.LanguageCode = 39
			AND sclm3.CodeTableID = 29
		
		
		INSERT INTO feed.GlobalCompanyProfile(
				BusinessID,
				DunsNumber,
				Address3,
				Address4,
				RegistrationNumber,
				VATNumber,
				SeverNegativeInfo,
				RegAddressLine1,
				RegAddressLine2,
				RegAddressLine3,
				RegAddressLine4,
				RegState,
				RegPostalCode,
				RegCity,
				LocalActivityCode,
				LocalActivityType,
				DNBRatingFinancialStrength,
				DNBRatingRiskInd,
				MaxCreditRec,
				CurrencyCode,
				LegalEventAmtYr1,
				LegalEvent1YrCurrCD,
				LegalEventCnt1yr,
				LegalEventAmtYr5,
				LegalEvent5YrCurrCD,
				LegalEventCntYr5,
				LegalFormText,
				IssuedCapital,
				IssuedCapitalCurrencyCode,
				IssuedCapitalCurrencyCodeValue,
				RecordTypeCode,
				RecordTypeCodeValue,
				TransferReasonCode,
				TransferReasonCodeValue,
				InfoSourceCode,
				InfoSourceCodeValue,
				DeletionIndicator,
				StopDistributionIndicator,
				CreatedDate,
				CreatedBy)
		SELECT
				ssa.BusinessID,
				ssa.DunsNumber,
				CAST(ssa.PrimaryAddressLine3 AS nvarchar(100)),
				CAST(ssa.PrimaryAddressLine4 AS nvarchar(100)),
				CAST(ssa.RegistrationNumber AS nvarchar(32)),
				CAST(ssa.VatNumber AS varchar(50)),
				CAST(ssa.SevereNegativeInformation AS varchar(50)),
				CAST(ssa.RegisteredAddressLine1 AS nvarchar(100)),
				CAST(ssa.RegisteredAddressLine2 AS nvarchar(100)),
				CAST(ssa.RegisteredAddressLine3 AS nvarchar(100)),
				CAST(ssa.RegisteredAddressLine4 AS nvarchar(100)),
				ssa.RegisteredCounty,
				CAST(ssa.RegisteredPostalCd  AS varchar(50)),
				CAST(ssa.RegisteredTown AS varchar(50)),
				CAST(ssa.LocalActivityCode AS varchar(50)),
				CAST(ssa.LocalActivityCodeType AS varchar(50)),
				CAST(ssa.DnBRatingFinancialStrength AS varchar(50)),
				CAST(ssa.DnBRatingRiskIndicator AS varchar(50)),
				CAST(ssa.MaximumCreditRecommendation AS varchar(50)),
				feed.fn_Get3LetterCountryCodeBySCoTS(ssa.CurrencyCode1, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)) ,
				TRY_CAST(ssa.LegalEvent1YearTotalAmount AS decimal(19,4)),
				CAST(ssa.LegalEvent1YearTotalAmountCurrencyCd AS nvarchar(6)),
				TRY_CAST(ssa.LegalEvent1YearTotalCount AS int),
				TRY_CAST(ssa.LegalEvent5YearTotalAmount AS decimal(19,4)),
				CAST(ssa.LegalEvent5YearTotalAmountCurrencyCd AS nvarchar(6)),
				TRY_CASt(ssa.LegalEvent5YearTotalCount AS int),
				CAST(ssa.LegalFormtext AS nvarchar(500)),
				TRY_CAST(ssa.IssuedCapital AS decimal(19,4)),
				CAST(ssa.IssuedCapitalCurrencyCode AS varchar(6)),
				feed.fn_Get3LetterCountryCodeBySCoTS(ssa.IssuedCapitalCurrencyCode, CAST(CAST(ssa.DataFeedEffectiveDate AS varchar) AS date)),
				ssa.RecordTypeCode,
				sclm1.ProductLiteralDescription,
				ssa.TransferReasonCode,
				sclm2.ProductLiteralDescription,
				ssa.InfoSourceCode,
				sclm3.ProductLiteralDescription,
				TRY_PARSE(ssa.DeletionIndicator	AS tinyint),
				TRY_PARSE(ssa.StopDistributionIndicator	AS tinyint),
				@Now,
				@By
		FROM
				staging.SubjectAcxiom ssa	
		
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap sclm1
			ON
				sclm1.SCoTSCode = ssa.RecordTypeCode
			AND sclm1.LanguageCode = 39
			AND sclm1.CodeTableID = 270
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap sclm2
			ON
				sclm2.SCoTSCode = ssa.TransferReasonCode
			AND sclm2.LanguageCode = 39
			AND sclm2.CodeTableID = 101
		LEFT JOIN
				reference.SCoTSCodeToLiteralMap sclm3
			ON
				sclm3.SCoTSCode = ssa.InfoSourceCode
			AND sclm3.LanguageCode = 39
			AND sclm3.CodeTableID = 29
		
		WHERE
				NOT EXISTS(
							SELECT 
									1
							FROM
									feed.GlobalCompanyProfile (nolock)
							WHERE
									BusinessID = ssa.BusinessID)
			AND BusinessID IS NOT NULL;

		--Enqueue businesses to CirrusOnline update
		INSERT INTO dataflow.BusinessProfileChangeQueue(
				BusinessID)
		SELECT 
				cob.BusinessID
		FROM
				staging.SubjectAcxiom sa (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				sa.BusinessID = cob.BusinessID
		WHERE
				NOT EXISTS (
							SELECT
									1
							FROM
									feed.GlobalCompanyProfile (nolock)
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