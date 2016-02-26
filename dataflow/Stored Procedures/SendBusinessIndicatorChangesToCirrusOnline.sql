--=========================================
-- Author:		DR
-- Create date: 9-22-2015
-- Description:	Sends a service broker message with latest risk indicators to CirrusOnline
-- =============================================
CREATE PROCEDURE [dataflow].[SendBusinessIndicatorChangesToCirrusOnline]
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE 
			@InitDlgHandle			uniqueidentifier,
			@RequestMsg				nvarchar(100),
			@RiskIndicatorChangeXml	xml;


	DELETE 
			bscq
	FROM
			dataflow.BusinessRiskIndicatorChangeQueue bscq
	WHERE
			NOT EXISTS (
						SELECT
								1
						FROM
								dataflow.CirrusOnlineBusiness 
						WHERE
								BusinessID = bscq.BusinessID)
		OR NOT EXISTS (
						SELECT
								1
						FROM
								feed.Subject s (nolock)
						WHERE
								s.BusinessID = bscq.BusinessID
							AND	s.ElementID IN ('AD', 'BB', 'AU', 'XX', 'XZ','AA', 'AC', 'AT')
							AND s.ElementValue IS NOT NULL);

	IF NOT EXISTS(
				SELECT 
						1
				FROM
						dataflow.BusinessRiskIndicatorChangeQueue)
		return;


	CREATE TABLE 
			#tblBusinessToProcess (BusinessID bigint PRIMARY KEY);



	
	IF EXISTS(SELECT 1 FROM dataflow.BusinessRiskIndicatorChangeQueue)
		BEGIN
			


			WHILE 1=1
				BEGIN
		

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessRiskIndicatorChangeQueue)
					BREAK;

					BEGIN TRANSACTION


					DELETE TOP (50000)
					FROM 
							dataflow.BusinessRiskIndicatorChangeQueue
					OUTPUT 
							deleted.BusinessID
					INTO #tblBusinessToProcess;

					BEGIN DIALOG @InitDlgHandle
						FROM SERVICE [DataFlowUniverseService]
						TO SERVICE N'DataFlowOnlineService'
					 ON CONTRACT [DataFlowContract]
					 WITH
						 ENCRYPTION = OFF;


					SET @RiskIndicatorChangeXml = (
							SELECT 
									Tag,
									Parent,
									[R!1!ID],
									[R!1!DN],
									[RI!2!D], 
									[RI!2!ED],
									[RI!2!EV],
									[RI!2!RIS]
							FROM (
								SELECT DISTINCT 
										1								AS 'Tag',
										NULL							AS 'Parent',
										s.BusinessID					AS 'R!1!ID',
										s.DunsNumber					AS 'R!1!DN',
										NULL							AS 'RI!2!D', 
										NULL							AS 'RI!2!ED',
										NULL							AS 'RI!2!EV',
										NULL							AS 'RI!2!RIS'
								FROM
										#tblBusinessToProcess t
								INNER JOIN
										feed.Subject s (nolock)
									ON
										t.BusinessID = s.BusinessID
								WHERE
										s.ElementID IN ('AD', 'BB', 'AU', 'XX', 'XZ','AA', 'AC', 'AT')
									AND s.ElementValue IS NOT NULL
								UNION ALL
								SELECT DISTINCT 
										2								AS Tag,
										1								AS Parent,
										s.BusinessID					AS [R!1!ID],
										s.DunsNumber					AS [R!1!DN],
										s.DatafeedEffectiveDate			AS [RI!2!D], 
										s.ElementID						AS [RI!2!ED],
										CASE
											WHEN gcp.StopDistributionIndicator = 1 THEN '-1'
											ELSE
												CASE
													WHEN s.ElementID IN ('AD', 'BB', 'AU', 'XX', 'XZ') THEN 
																								CASE
																										WHEN s.ElementValue IN ('y', '1') THEN 1
																										WHEN s.ElementValue IN ('n', '0') THEN 0
																								END
													ELSE
														CASE
															WHEN TRY_PARSE(s.ElementValue AS decimal(18,2)) > 0 THEN 1
															ELSE 0 
														END
												END
										END					AS [RI!2!EV],
										CASE
											WHEN s.ElementID = 'XZ' THEN s.RiskIndicatorStatus
											ELSE '-1'
										END					AS [RI!2!RIS] 
								FROM
										#tblBusinessToProcess t
								INNER JOIN		
										feed.Subject s (nolock)
									ON
										t.BusinessID = s.BusinessID
								LEFT JOIN
										feed.GlobalCompanyProfile gcp (nolock)
									ON
										t.BusinessID = gcp.BusinessID
								WHERE
										s.ElementID IN ('AD', 'BB', 'AU', 'XX', 'XZ', 'AA', 'AC', 'AT')
									AND s.ElementValue IS NOT NULL) B
											
							ORDER BY
									[R!1!ID],
									[R!1!DN],
									[RI!2!D],
									[RI!2!ED]
							FOR XML EXPLICIT, ROOT('Dataflow'));


					

	
					IF @RiskIndicatorChangeXml IS NOT NULL
						BEGIN
							SET @RiskIndicatorChangeXml.modify('insert attribute Type {"RiskIndicatorChange"} into (/Dataflow)[1]');
							
							SEND ON CONVERSATION @InitDlgHandle
							MESSAGE TYPE [DataFlowSendMessage]
								  (@RiskIndicatorChangeXml);
						END

					COMMIT TRANSACTION;

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessRiskIndicatorChangeQueue)
						BREAK;

					TRUNCATE TABLE #tblBusinessToProcess;

				END
		END
		
   
END