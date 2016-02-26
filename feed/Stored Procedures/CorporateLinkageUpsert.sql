CREATE PROCEDURE [feed].[CorporateLinkageUpsert]
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE
				@ErrorNumber		int = 0,
				@ErrorMessage		nvarchar(4000) = 'Success',
				@ErrorSeverity		int,
				@ExecutionID		int,
				@Now				datetime = GETUTCDATE(),
				@By					varchar(50),
				@DunsNumberList		DunsNumberTableType;	

    BEGIN TRY

		BEGIN TRANSACTION; 
		
		SELECT DISTINCT 
				@ExecutionID		= e.ExecutionID
		FROM 
				feed.Execution e (nolock) 
		INNER JOIN 
				staging.CorporateLinkage pt (nolock) 
			ON 
				e.ExecutionID = pt.ExecutionID;
		

		SET @By = OBJECT_NAME(@@PROCID) + '(ExID:' + CAST(@ExecutionID AS varchar)+ ')';

		


		SELECT DISTINCT	
				WorldBase3NumericCode, 
				ISOCountryAlpha2Code = CASE WHEN ISOCountryAlpha2Code IN ('PR', 'VI','US' ) AND WorldBase3NumericCode = '805' THEN  'US' 
										ELSE ISOCountryAlpha2Code 
									END
		INTO 
				#ref
		FROM 
				reference.WBISOFIPSMapping WITH(NOLOCK)
		WHERE	
				WorldBase3NumericCode IS NOT NULL

		CREATE INDEX #I ON #ref (WorldBase3NumericCode)

				
		;WITH Src AS
			( 
				SELECT 
					 [LineageRowID]
					,[DunsNumber]
					,[DataFeedEffectiveDate]
					,[ParentIndicator]
					,[SubsidiaryIndicator]
					,[HQIndicator]
					,[LocationType]	  = CASE WHEN LocationType = '1' THEN 'Headquarters' 
											 WHEN LocationType = '2' THEN 'Branch'
											 WHEN LocationType = '0' THEN 'Single Location (Subsidiary)'
											 ELSE 'Unknown'
									    END
					,[DomUltimateDunsNumber]
					,[DomUltimateName]
					,[DomUltimateAddressLine1]
					,[DomUltimateAddressLine2]
					,[DomUltimateCity]
					,[DomUltimateState]
					,[DomUltimatePostalCode]
					,[DomUltimateCountryCode]		= rd.ISOCountryAlpha2Code
					,[GlobalUltimateDunsNumber]
					,[GlobalUltimateName]
					,[GlobalUltimateAddressLine1]
					,[GlobalUltimateAddressLine2]
					,[GlobalUltimateCity]
					,[GlobalUltimateState]
					,[GlobalUltimatePostalCode]
					,[GlobalUltimateCountryCode]	= rG.ISOCountryAlpha2Code
					,[HQDunsNumber]
					,[HQName]
					,[HQAddressLine1]
					,[HQAddressLine2]
					,[HQCity]
					,[HQState]
					,[HQPostalCode]
					,[HQCountryCode]				= rH.ISOCountryAlpha2Code
					,[ExecutionID]
				FROM 
						staging.CorporateLinkage s WITH(NOLOCK)
				LEFT JOIN 
						 #ref rH WITH(NOLOCK)
						ON	
							s.[HQCountryCode] = rH.WorldBase3NumericCode 
				LEFT JOIN 
						#ref rG WITH(NOLOCK)
						ON	
							s.[GlobalUltimateCountryCode] = rG.WorldBase3NumericCode
				LEFT JOIN 
						#ref rD WITH(NOLOCK)
						ON	
							s.[DomUltimateCountryCode] = rD.WorldBase3NumericCode
				)	
		MERGE	 feed.CorporateLinkage Trg
		USING Src
			ON 
				Src.DunsNumber = Trg.DunsNumber
		WHEN MATCHED 
			THEN
				UPDATE 
						SET 
						Trg.LineageRowID					   =  	Src.LineageRowID				,
						Trg.[DataFeedEffectiveDate]			   =	Src.[DataFeedEffectiveDate]		,
						Trg.[ParentIndicator]				   =	Src.[ParentIndicator]			,
						Trg.[SubsidiaryIndicator]			   =	Src.[SubsidiaryIndicator]		,
						Trg.[HQIndicator]					   =	Src.[HQIndicator]				,
						Trg.[LocationType]	 				   =	Src.[LocationType]	 			,
						Trg.[DomUltimateDunsNumber]			   =	Src.[DomUltimateDunsNumber]		,
						Trg.[DomUltimateName]				   =	Src.[DomUltimateName]			,
						Trg.[DomUltimateAddressLine1]		   =	Src.[DomUltimateAddressLine1]	,
						Trg.[DomUltimateAddressLine2]		   =	Src.[DomUltimateAddressLine2]	,
						Trg.[DomUltimateCity]				   =	Src.[DomUltimateCity]			,
						Trg.[DomUltimateState]				   =	Src.[DomUltimateState]			,
						Trg.[DomUltimatePostalCode]			   =	Src.[DomUltimatePostalCode]		,
						Trg.[DomUltimateCountryCode]		   =	Src.[DomUltimateCountryCode]	,
						Trg.[GlobalUltimateDunsNumber]		   =	Src.[GlobalUltimateDunsNumber]	,
						Trg.[GlobalUltimateName]			   =	Src.[GlobalUltimateName]		,
						Trg.[GlobalUltimateAddressLine1]	   =	Src.[GlobalUltimateAddressLine1]	,
						Trg.[GlobalUltimateAddressLine2]	   =	Src.[GlobalUltimateAddressLine2]	,
						Trg.[GlobalUltimateCity]			   =	Src.[GlobalUltimateCity]		,
						Trg.[GlobalUltimateState]			   =	Src.[GlobalUltimateState]		,
						Trg.[GlobalUltimatePostalCode]		   =	Src.[GlobalUltimatePostalCode]	,
						Trg.[GlobalUltimateCountryCode]		   =	Src.[GlobalUltimateCountryCode]	,
						Trg.[HQDunsNumber]					   =	Src.[HQDunsNumber]				,
						Trg.[HQName]						   =	Src.[HQName]					,
						Trg.[HQAddressLine1]				   =	Src.[HQAddressLine1]			,
						Trg.[HQAddressLine2]				   =	Src.[HQAddressLine2]			,
						Trg.[HQCity]						   =	Src.[HQCity]					,
						Trg.[HQState]						   =	Src.[HQState]					,
						Trg.[HQPostalCode]					   =	Src.[HQPostalCode]				,
						Trg.[HQCountryCode]					   =	Src.[HQCountryCode]				,
						UpdatedDate				= @Now										,
						UpdatedBy				= @By			
		WHEN NOT MATCHED BY TARGET THEN 
				INSERT 
						(LineageRowID				
						,[DunsNumber]				
						,[DataFeedEffectiveDate]		
						,[ParentIndicator]			
						,[SubsidiaryIndicator]		
						,[HQIndicator]				
						,[LocationType]	 			
						,[DomUltimateDunsNumber]		
						,[DomUltimateName]			
						,[DomUltimateAddressLine1]	
						,[DomUltimateAddressLine2]	
						,[DomUltimateCity]			
						,[DomUltimateState]			
						,[DomUltimatePostalCode]		
						,[DomUltimateCountryCode]	
						,[GlobalUltimateDunsNumber]	
						,[GlobalUltimateName]		
						,[GlobalUltimateAddressLine1]	
						,[GlobalUltimateAddressLine2]	
						,[GlobalUltimateCity]		
						,[GlobalUltimateState]		
						,[GlobalUltimatePostalCode]	
						,[GlobalUltimateCountryCode]	
						,[HQDunsNumber]				
						,[HQName]					
						,[HQAddressLine1]			
						,[HQAddressLine2]			
						,[HQCity]					
						,[HQState]					
						,[HQPostalCode]				
						,[HQCountryCode]	
						,CreatedDate
						,CreatedBy
						)			
					VALUES
						(Src.LineageRowID				,
						 Src.[DunsNumber]				,
						 Src.[DataFeedEffectiveDate]		,
						 Src.[ParentIndicator]			,
						 Src.[SubsidiaryIndicator]		,
						 Src.[HQIndicator]				,
						 Src.[LocationType]	 			,
						 Src.[DomUltimateDunsNumber]		,
						 Src.[DomUltimateName]			,
						 Src.[DomUltimateAddressLine1]	,
						 Src.[DomUltimateAddressLine2]	,
						 Src.[DomUltimateCity]			,
						 Src.[DomUltimateState]			,
						 Src.[DomUltimatePostalCode]		,
						 Src.[DomUltimateCountryCode]	,
						 Src.[GlobalUltimateDunsNumber]	,
						 Src.[GlobalUltimateName]		,
						 Src.[GlobalUltimateAddressLine1]	,
						 Src.[GlobalUltimateAddressLine2]	,
						 Src.[GlobalUltimateCity]		,
						 Src.[GlobalUltimateState]		,
						 Src.[GlobalUltimatePostalCode]	,
						 Src.[GlobalUltimateCountryCode]	,
						 Src.[HQDunsNumber]				,
						 Src.[HQName]					,
						 Src.[HQAddressLine1]			,
						 Src.[HQAddressLine2]			,
						 Src.[HQCity]					,
						 Src.[HQState]					,
						 Src.[HQPostalCode]				,
						 Src.[HQCountryCode]			,
						 @Now,
						 @By
						);

		INSERT INTO @DunsNumberList(DunsNumber)
		SELECT
				cl.DunsNumber
		FROM
				staging.CorporateLinkage cl (nolock)
		INNER JOIN
				dataflow.CirrusOnlineBusiness cob (nolock)
			ON
				cl.DunsNumber = cob.DunsNumber;


		EXEC dataflow.SendCorporateLinkageToCirrusOnline @DunsNumberList;


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