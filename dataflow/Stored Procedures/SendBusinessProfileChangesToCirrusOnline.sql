--=========================================
-- Author:		DR
-- Create date: 9-24-2015
-- Description:	Sends a service broker message with latest busines profiles to CirrusOnline
-- =============================================
CREATE PROCEDURE [dataflow].[SendBusinessProfileChangesToCirrusOnline]
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE 
			@InitDlgHandle				uniqueidentifier,
			@RequestMsg					nvarchar(100),
			@BusinessProfileChangeXml	xml;


	
	CREATE TABLE #tblBusinessIDList (
			BusinessID			bigint,
			DunsNumber			varchar(10) NULL,
			PRIMARY KEY CLUSTERED(BusinessID));



	CREATE TABLE 
			#tblBusinessToProcess (BusinessID bigint PRIMARY KEY);



	
	IF EXISTS(SELECT 1 FROM dataflow.BusinessProfileChangeQueue)
		BEGIN
			


			WHILE 1=1
				BEGIN
		
		
					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessProfileChangeQueue)
						BREAK;

					BEGIN TRANSACTION


					DELETE TOP (10000)
					FROM 
							dataflow.BusinessProfileChangeQueue
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
									AND cl.LocationType = 'Branch')



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
					SET @BusinessProfileChangeXml = (
							SELECT 
									Tag,
									Parent,
									[BP!1!ID!element],
									[BP!1!DN!element],
									[BP!1!BN!cdata],
									[BP!1!TS1!cdata],
									[BP!1!TS2!cdata],
									[BP!1!TS3!cdata],
									[BP!1!S1!element],
									[BP!1!S2!element],
									[BP!1!C!element],
									[BP!1!PC!element],
									[BP!1!PCP!element],
									[BP!1!SP!element],
									[BP!1!CN!element], 
									[BP!1!RN!cdata],
									[BP!1!VN!cdata],
									[BP!1!TN!element],
									[BP!1!LS!element],
									[BP!1!YS!element],
									[BP!1!IY!element],
									[BP!1!CY!element],
									[BP!1!SAE!element],
									[BP!1!SAF!element],
									[BP!1!SXY!element],
									--DNBSIC4
									--DNBSIC3
									--DNBSIC2
									--DNBSIC1
									[BP!1!SAG!element],
									[BP!1!SAH!element],
									[BP!1!SAA!element],
									[BP!1!SAB!element],
									[BP!1!SAC!element],
									[BP!1!SAT!element],
									[BP!1!SAR!element],
									[BP!1!SAS!element],
									[BP!1!SAU!element],
									[BP!1!CEON!cdata],
									[BP!1!A3!cdata],
									[BP!1!A4!cdata],
									[BP!1!RAL1!cdata],
									[BP!1!RAL2!cdata],
									[BP!1!RAL3!cdata],
									[BP!1!RAL4!cdata],
									[BP!1!LFCC!element],
									[BP!1!LFC!element],
									[BP!1!RS!element],
									[BP!1!RC!element],
									[BP!1!RPC!element],
									[BP!1!SAP!element],
									[BP!1!SAV!element],
									[BP!1!SAW!element],
									[BP!1!SAY!element],
									[BP!1!LEAY1!element],
									[BP!1!LE1YC!element],
									[BP!1!LEC1!element],
									[BP!1!IC!element],
									[BP!1!ICCC!element],
									[BP!1!RT!element],
									[BP!1!TR!element],
									[BP!1!IS!element],
									[BP!1!LID!element],
									[BP!1!LAC!element],
									[BP!1!LACT!element],
									[BP!1!MCR!element],
									[BP!1!MCRC!element]
							FROM (
								SELECT
										1																									AS Tag,
										NULL																								AS Parent,
										t.BusinessID																						AS [BP!1!ID!element],
										i.DunsNumber																						AS [BP!1!DN!element],
										i.Name																								AS [BP!1!BN!cdata],
										i.TradeStyle1																						AS [BP!1!TS1!cdata],
										i.TradeStyle2																						AS [BP!1!TS2!cdata],
										i.TradeStyle3																						AS [BP!1!TS3!cdata],
										i.Street1																							AS [BP!1!S1!element],
										i.Street2																							AS [BP!1!S2!element],
										i.City																								AS [BP!1!C!element],
										i.PostalCode																						AS [BP!1!PC!element],
										i.PostalCodePlus																					AS [BP!1!PCP!element],
										i.State																								AS [BP!1!SP!element],
										i.Country																							AS [BP!1!CN!element], 
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.RegistrationNumber)								AS [BP!1!RN!cdata],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.VATNumber)											AS [BP!1!VN!cdata],
										i.Phone																								AS [BP!1!TN!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, i.LegalStructure)										AS [BP!1!LS!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, COALESCE(i.YearStarted, TRY_PARSE(s.AZ AS int)))		AS [BP!1!YS!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, COALESCE(i.IncYear, TRY_PARSE(s.BA AS date)))			AS [BP!1!IY!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, COALESCE(i.ControlYear, TRY_PARSE(s.AX AS int)))		AS [BP!1!CY!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AE)													AS [BP!1!SAE!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AF)													AS [BP!1!SAF!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.XY)													AS [BP!1!SXY!element],
										--DNBSIC4
										--DNBSIC3
										--DNBSIC2
										--DNBSIC1
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AG)													AS [BP!1!SAG!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AH)													AS [BP!1!SAH!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AA)													AS [BP!1!SAA!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AB)													AS [BP!1!SAB!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AC)													AS [BP!1!SAC!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AT)													AS [BP!1!SAT!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AR)													AS [BP!1!SAR!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.[AS])												AS [BP!1!SAS!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AU)													AS [BP!1!SAU!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, i.CEOName)												AS [BP!1!CEON!cdata],
										gcp.Address3																						AS [BP!1!A3!cdata],
										gcp.Address4																						AS [BP!1!A4!cdata],
										gcp.RegAddressLine1																					AS [BP!1!RAL1!cdata],
										gcp.RegAddressLine2																					AS [BP!1!RAL2!cdata],
										gcp.RegAddressLine3																					AS [BP!1!RAL3!cdata],
										gcp.RegAddressLine4																					AS [BP!1!RAL4!cdata],
										IIF(gcp.StopDistributionIndicator = 1, NULL, i.LegalFormClassCode)									AS [BP!1!LFCC!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, i.LegalFormCode)										AS [BP!1!LFC!element],
										gcp.RegState																						AS [BP!1!RS!element],
										gcp.RegCity																							AS [BP!1!RC!element],
										gcp.RegPostalCode																					AS [BP!1!RPC!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AP)													AS [BP!1!SAP!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AV)													AS [BP!1!SAV!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AW)													AS [BP!1!SAW!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, s.AY)													AS [BP!1!SAY!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.LegalEventAmtYr1)									AS [BP!1!LEAY1!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.LegalEvent1YrCurrCD)								AS [BP!1!LE1YC!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.LegalEventCnt1yr)									AS [BP!1!LEC1!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.IssuedCapital)										AS [BP!1!IC!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.IssuedCapitalCurrencyCodeValue)					AS [BP!1!ICCC!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.RecordTypeCodeValue)								AS [BP!1!RT!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.TransferReasonCodeValue)							AS [BP!1!TR!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.InfoSourceCodeValue)								AS [BP!1!IS!element],
										con.ActivityDetailLogID																				AS [BP!1!LID!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.LocalActivityCode)									AS [BP!1!LAC!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.LocalActivityType)									AS [BP!1!LACT!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.MaxCreditRec)										AS [BP!1!MCR!element],
										IIF(gcp.StopDistributionIndicator = 1, NULL, gcp.CurrencyCode)										AS [BP!1!MCRC!element]
								FROM
										#tblBusinessToProcess t
								INNER JOIN
										dataflow.CirrusOnlineBusiness con (nolock)
									ON
										t.BusinessID = con.BusinessID
								INNER JOIN
										feed.[Identity] i (nolock)
									ON
										t.BusinessID = i.BusinessID
								LEFT JOIN
										feed.GlobalCompanyProfile gcp (nolock)
									ON
										t.BusinessID = gcp.BusinessID
								OUTER APPLY	(
											SELECT
													BusinessID,
													[AZ],[AE], [AF], [XY], [AG], [AH], [AA], [AB], [AC], [AT], [AR], [AS], [AU], [AP], [AV], [AW], [AY], [BA], [AX]
											FROM	(
													SELECT 
															BusinessID,
															ElementID,
															ElementValue
				
													FROM
															feed.Subject (nolock)
													WHERE 
															ElementID IN ('AZ', 'AE', 'AF', 'XY', 'AG', 'AH', 'AA', 'AB', 'AC', 'AT', 'AR', 'AS', 'AU', 'AP', 'AV', 'AW', 'AY', 'BA', 'AX')
														AND BusinessID = t.BusinessID
													) p
											PIVOT	(
													MIN(ElementValue) 
												FOR ElementID IN ([AZ], [AE], [AF], [XY], [AG], [AH], [AA], [AB], [AC], [AT], [AR], [AS], [AU], [AP], [AV], [AW], [AY], [BA], [AX]) ) AS pvt

											) s
										) B
											
							ORDER BY
									[BP!1!ID!element]
							FOR XML EXPLICIT, ROOT('Dataflow')
							);


					--Push message to service broker
					IF @BusinessProfileChangeXml IS NOT NULL
						BEGIN
							SET @BusinessProfileChangeXml.modify('insert attribute Type {"BusinessProfileChange"} into (/Dataflow)[1]');
							
							SEND ON CONVERSATION @InitDlgHandle
							MESSAGE TYPE [DataFlowSendMessage]
								  (@BusinessProfileChangeXml);
						END

					--Only for the businesses which are being processed for the first time
					INSERT INTO dataflow.BusinessScoreChangeQueue(
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
												dataflow.BusinessScoreChangeQueue (nolock)
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

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessProfileChangeQueue)
						BREAK;

					TRUNCATE TABLE #tblBusinessToProcess;
					TRUNCATE TABLE #tblBusinessIDList;
				END
		END
		
   
	IF OBJECT_ID('tempdb..#tblBusinessIDList') IS NOT NULL 
		DROP TABLE #tblBusinessIDList;

	IF OBJECT_ID('tempdb..#tblBusinessToProcess') IS NOT NULL 
		DROP TABLE #tblBusinessToProcess;
END