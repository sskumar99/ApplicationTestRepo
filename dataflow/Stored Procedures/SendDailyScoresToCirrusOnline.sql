
--=========================================
-- Author:		DR
-- Create date: 8-17-2015
-- Description:	Sends a service broker message with latest scores to CirrusOnline
-- =============================================
CREATE PROCEDURE [dataflow].[SendDailyScoresToCirrusOnline]
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE 
			@InitDlgHandle			uniqueidentifier,
			@RequestMsg				nvarchar(100),
			@DailyScoreChangeXml	xml;



	CREATE TABLE #tblBusinessIDList (
			BusinessID			bigint,
			DunsNumber			varchar(10) NULL,
			PRIMARY KEY CLUSTERED(BusinessID));


	CREATE TABLE 
			#tblBusinessToProcess (BusinessID bigint PRIMARY KEY);



	
	IF EXISTS(SELECT 1 FROM dataflow.BusinessScoreChangeQueue)
		BEGIN
			


			WHILE 1=1
				BEGIN
		

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessScoreChangeQueue)
						BREAK;

					BEGIN TRANSACTION


					DELETE TOP (10000)
					FROM 
							dataflow.BusinessScoreChangeQueue
					OUTPUT 
							deleted.BusinessID
					INTO #tblBusinessToProcess;


					DELETE 
							t
					FROM
							#tblBusinessToProcess t
					LEFT JOIN 
							dataflow.CirrusOnlineBusiness cob (nolock)
						ON 
							t.BusinessID = cob.BusinessID
					WHERE 
							cob.BusinessID IS NULL	-- Not in CirrusOnline
					OR			
						EXISTS(						-- Branch					
								SELECT
										1
								FROM
										feed.CorporateLinkage cl (nolock)
								WHERE
										cl.DunsNumber = cob.DunsNumber
									AND cl.LocationType = 'Branch');

					--Min Data Requirments
					DELETE
							t
					OUTPUT
							deleted.BusinessID
					INTO
							#tblBusinessIDList(BusinessID)
					FROM
							#tblBusinessToProcess t
					
					WHERE
							EXISTS (
									SELECT
											1
									FROM
										feed.[Identity] i (nolock)
									WHERE
										i.BusinessID = t.BusinessID
									AND (LEN(ISNULL(i.Name, '')) = 0
									OR LEN(ISNULL(i.Street1, '') + ISNULL(i.Street2, '')) = 0
									OR LEN(ISNULL(i.City, '') + ISNULL(i.State, '') + ISNULL(i.PostalCode, '')) = 0))
							OR NOT EXISTS(
									SELECT
											1
									FROM
											feed.PaydexDaily pd (nolock)
									INNER JOIN	
											feed.SASDaily sd (nolock)
										ON
											pd.BusinessID = sd.BusinessID
									WHERE
											pd.BusinessID = t.BusinessID);


					INSERT INTO dataflow.BusinessWaitingQueue(
							BusinessID)
					SELECT
							BusinessID
					FROM
							#tblBusinessIDList t
					WHERE
							NOT EXISTS(
										SELECT
												1
										FROM
												dataflow.BusinessWaitingQueue
										WHERE 
												BusinessID = t.BusinessID);

					TRUNCATE TABLE #tblBusinessIDList;



					BEGIN DIALOG @InitDlgHandle
						FROM SERVICE [DataFlowUniverseService]
						TO SERVICE N'DataFlowOnlineService'
					 ON CONTRACT [DataFlowContract]
					 WITH
						 ENCRYPTION = OFF;
				
					--Construct XML for Service Broker	
					SET @DailyScoreChangeXml = (
					SELECT
							ID,
							DN,
							CN,
							PX,
							PXD,
							DnBR,
							RI,
							FS,
							CCSP,
							CCSC,
							CCSS,
							FSSP,
							FSSC,
							FSSS,
							SERS,
							SASD
					FROM (	
							SELECT
									t.BusinessID																							AS ID,
									cob.DunsNumber																							AS DN,
									cob.ISOCountryAlpha2Code																				AS CN,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(p.Paydex,-1))											AS PX,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(p.DataFeedEffectiveDate,-1))								AS PXD,
									IIF(gcp.StopDistributionIndicator=1,'-1', ISNULL(dr.DnBRating,'-1'))									AS DnBR,
									IIF(gcp.StopDistributionIndicator=1,'-1', ISNULL(dr.RiskIndicator,'-1'))								AS RI,
									IIF(gcp.StopDistributionIndicator=1,'-1', ISNULL(dr.FinancialStrength,'-1'))							AS FS,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(sas.CCSPercentile,-1))									AS CCSP,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(sas.CCSClass,-1))										AS CCSC,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(sas.CCSScore,-1))										AS CCSS,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(sas.FSSPercentile,-1))									AS FSSP,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(sas.FSSClass,-1))										AS FSSC,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(sas.FSSScore,-1))										AS FSSS,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(sas.SERScore,-1))										AS SERS,
									IIF(gcp.StopDistributionIndicator=1,-1, ISNULL(sas.DataFeedEffectiveDate,-1))							AS SASD
							FROM
									#tblBusinessToProcess t
							INNER JOIN
									dataflow.CirrusOnlineBusiness cob (nolock)
								ON
									t.BusinessID = cob.BusinessID
							LEFT JOIN
									feed.GlobalCompanyProfile gcp (nolock)
								ON
									t.BusinessID = gcp.BusinessID
							--Paydex
							OUTER APPLY (
										SELECT
												CAST(Paydex AS smallint)	AS Paydex,
												DataFeedEffectiveDate,
												LineageRowID
										FROM
												feed.PaydexDaily (nolock) 
										WHERE
												BusinessID = t.BusinessID
										) p
							--DnB Rating
							OUTER APPLY (
										SELECT
												DnBRating,
												RiskIndicator,
												FinancialStrength,
												DataFeedEffectiveDate
										FROM
												feed.DnBRatingDaily (nolock) 
										WHERE
												BusinessID = t.BusinessID
										) dr
							
							--SAS
							OUTER APPLY (
										SELECT
												CCSPercentile,
												CCSClass,
												CCSScore,
												FSSPercentile,
												FSSClass,
												FSSScore,
												SERScore,
												DataFeedEffectiveDate, 
												LineageRowID
										FROM
												feed.SASDaily 
										WHERE
												BusinessID = t.BusinessID
										) sas

							) B
					FOR XML AUTO, ROOT('Dataflow'));

					--Push message to service broker	
					IF @DailyScoreChangeXml IS NOT NULL
						BEGIN
							SET @DailyScoreChangeXml.modify('insert attribute Type {"DailyScoreChange"} into (/Dataflow)[1]');
							
							SEND ON CONVERSATION @InitDlgHandle
							MESSAGE TYPE [DataFlowSendMessage]
								  (@DailyScoreChangeXml);
						END



					--Only for the businesses which are being processed for the first time
					INSERT INTO dataflow.BusinessProfileChangeQueue(
							BusinessID)
					OUTPUT 
							inserted.BusinessID
					INTO
							#tblBusinessIDList(BusinessID)
					SELECT
							t.BusinessID
					FROM
							#tblBusinessToProcess t
					INNER JOIN
							dataflow.CirrusOnlineBusiness cob (nolock)
						ON
							t.BusinessID = cob.BusinessID
						AND cob.FirstTimeProcessedDate IS NULL
					WHERE
							NOT EXISTS(
										SELECT
												1
										FROM
												dataflow.BusinessProfileChangeQueue (nolock)
										WHERE
												BusinessID = t.BusinessID);
					
					
					UPDATE
							cob
					SET
							FirstTimeProcessedDate = GETUTCDATE()
					FROM
							#tblBusinessIDList t
					INNER JOIN
							dataflow.CirrusOnlineBusiness cob (nolock)
						ON
							t.BusinessID = cob.BusinessID;


					COMMIT TRANSACTION;

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessScoreChangeQueue)
						BREAK;

					TRUNCATE TABLE #tblBusinessToProcess;
					TRUNCATE TABLE #tblBusinessIDList;

				END
		END
		
   
END