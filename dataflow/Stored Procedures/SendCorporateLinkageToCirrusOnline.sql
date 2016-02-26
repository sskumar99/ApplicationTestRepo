

--=========================================
-- Author:		DR
-- Create date: 9-24-2015
-- Description:	Sends a service broker message with latest corporate linkage updates to CirrusOnline
-- =============================================
CREATE PROCEDURE [dataflow].[SendCorporateLinkageToCirrusOnline]
(
	@DunsNumberList			DunsNumberTableType READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE 
			@InitDlgHandle				uniqueidentifier,
			@RequestMsg					nvarchar(100),
			@CorporateLinkageChangeXml	xml;


	IF OBJECT_ID('tempdb..#DunsNumberList') IS NOT NULL
		DROP TABLE #DunsNumberList;

	CREATE TABLE #DunsNumberList(
			DunsNumber		varchar(10) PRIMARY KEY);

	INSERT INTO #DunsNumberList(DunsNumber)
	SELECT
			DunsNumber
	FROM
			@DunsNumberList;


	DELETE 
			b
	FROM
			#DunsNumberList b
	WHERE
			NOT EXISTS (
						SELECT
								1
						FROM
								dataflow.CirrusOnlineBusiness 
						WHERE
								DunsNumber = b.DunsNumber);

	IF NOT EXISTS(
				SELECT 
						1
				FROM
						#DunsNumberList)
		return;


	CREATE TABLE 
			#tblBusinessToProcess (DunsNumber varchar(10) PRIMARY KEY);



	
	IF EXISTS(SELECT 1 FROM #DunsNumberList)
		BEGIN
			


			WHILE 1=1
				BEGIN
		

					IF NOT EXISTS(SELECT 1 FROM #DunsNumberList)
					BREAK;

					BEGIN TRANSACTION


					DELETE TOP (50000)
					FROM 
							#DunsNumberList
					OUTPUT 
							deleted.DunsNumber
					INTO #tblBusinessToProcess;

					BEGIN DIALOG @InitDlgHandle
						FROM SERVICE [DataFlowUniverseService]
						TO SERVICE N'DataFlowOnlineService'
					 ON CONTRACT [DataFlowContract]
					 WITH
						 ENCRYPTION = OFF;	
							
					SET @CorporateLinkageChangeXml = (
							SELECT 
									Tag,
									Parent,
									[CL!1!ID!element],
									[CL!1!DN!element],
									[CL!1!CN!element],
									[CL!1!PI!element],
									[CL!1!SI!element],
									[CL!1!HI!element],
									[CL!1!LT!element],
									[CL!1!DDN!element],
									[CL!1!DNM!cdata],
									[CL!1!DA1!cdata],
									[CL!1!DA2!cdata],
									[CL!1!DC!cdata],
									[CL!1!DS!cdata],
									[CL!1!DPC!element],
									[CL!1!DCC!element],
									[CL!1!GDN!element],
									[CL!1!GNM!cdata],
									[CL!1!GA1!cdata],
									[CL!1!GA2!cdata],
									[CL!1!GC!cdata],
									[CL!1!GS!cdata],
									[CL!1!GPC!element],
									[CL!1!GCC!element],
									[CL!1!HDN!element],
									[CL!1!HNM!cdata],
									[CL!1!HA1!cdata],
									[CL!1!HA2!cdata],
									[CL!1!HC!cdata],
									[CL!1!HS!cdata],
									[CL!1!HPC!element],
									[CL!1!HCC!element],
									[CL!1!LR!element],
									[CL!1!D!element]
							FROM (
								SELECT 
										1																			AS Tag,
										NULL																		AS Parent,
										cob.BusinessID																AS [CL!1!ID!element],
										cl.DunsNumber																AS [CL!1!DN!element],
										cob.ISOCountryAlpha2Code													AS [CL!1!CN!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.ParentIndicator)				AS [CL!1!PI!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.SubsidiaryIndicator)			AS [CL!1!SI!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQIndicator)					AS [CL!1!HI!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.LocationType)					AS [CL!1!LT!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.DomUltimateDunsNumber)			AS [CL!1!DDN!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.DomUltimateName)				AS [CL!1!DNM!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.DomUltimateAddressLine1)		AS [CL!1!DA1!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.DomUltimateAddressLine2)		AS [CL!1!DA2!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.DomUltimateCity)				AS [CL!1!DC!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.DomUltimateState)				AS [CL!1!DS!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.DomUltimatePostalCode)			AS [CL!1!DPC!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.DomUltimateCountryCode)		AS [CL!1!DCC!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.GlobalUltimateDunsNumber)		AS [CL!1!GDN!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.GlobalUltimateName)			AS [CL!1!GNM!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.GlobalUltimateAddressLine1)	AS [CL!1!GA1!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.GlobalUltimateAddressLine2)	AS [CL!1!GA2!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.GlobalUltimateCity)			AS [CL!1!GC!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.GlobalUltimateState)			AS [CL!1!GS!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.GlobalUltimatePostalCode)		AS [CL!1!GPC!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.GlobalUltimateCountryCode)		AS [CL!1!GCC!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQDunsNumber)					AS [CL!1!HDN!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQName)						AS [CL!1!HNM!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQAddressLine1)				AS [CL!1!HA1!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQAddressLine2)				AS [CL!1!HA2!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQCity)						AS [CL!1!HC!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQState)						AS [CL!1!HS!cdata],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQPostalCode)					AS [CL!1!HPC!element],
										IIF(gcp.StopDistributionIndicator=1, NULL,cl.HQCountryCode)					AS [CL!1!HCC!element],
										cl.LineageRowID																AS [CL!1!LR!element],
										cl.DataFeedEffectiveDate													AS [CL!1!D!element]
								FROM 
										#tblBusinessToProcess t
								INNER JOIN
										feed.CorporateLinkage cl (nolock)
									ON
										t.DunsNumber = cl.DunsNumber
								INNER JOIN
										dataflow.CirrusOnlineBusiness cob (nolock)
									ON
										cl.DunsNumber = cob.DunsNumber
								LEFT JOIN
										feed.GlobalCompanyProfile gcp (nolock)
									ON
										t.DunsNumber = gcp.DunsNumber) B
											
							ORDER BY
									[CL!1!ID!element]
							FOR XML EXPLICIT, ROOT('Dataflow')
							);

					
	
					IF @CorporateLinkageChangeXml IS NOT NULL
						BEGIN
							SET @CorporateLinkageChangeXml.modify('insert attribute Type {"CorporateLinkageChange"} into (/Dataflow)[1]');
							
							SEND ON CONVERSATION @InitDlgHandle
							MESSAGE TYPE [DataFlowSendMessage]
								  (@CorporateLinkageChangeXml);
						END

					COMMIT TRANSACTION;

					IF NOT EXISTS(SELECT 1 FROM #DunsNumberList)
						BREAK;

					TRUNCATE TABLE #tblBusinessToProcess;

				END
		END
		
   
END