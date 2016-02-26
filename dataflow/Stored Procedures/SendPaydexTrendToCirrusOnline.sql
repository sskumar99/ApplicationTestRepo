
--=========================================
-- Author:		DR
-- Create date: 9-29-2015
-- Description:	Sends a service broker message with latest score trends to CirrusOnline
-- =============================================
CREATE PROCEDURE [dataflow].[SendPaydexTrendToCirrusOnline]
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE 
			@InitDlgHandle			uniqueidentifier,
			@RequestMsg				nvarchar(100),
			@PaydexTrendXml			xml;


	DELETE 
			bstq
	FROM
			dataflow.BusinessScoreTrendQueue bstq
	WHERE
			bstq.ScoreType = 'Paydex'
		AND NOT EXISTS (
						SELECT
								1
						FROM
								dataflow.CirrusOnlineBusiness 
						WHERE
								BusinessID = bstq.BusinessID);

	IF NOT EXISTS(
				SELECT 
						1
				FROM
						dataflow.BusinessScoreTrendQueue
				WHERE 
						ScoreType = 'Paydex')
		return;


	CREATE TABLE 
			#tblBusinessToProcess (BusinessID bigint PRIMARY KEY);



	
	IF EXISTS(SELECT 1 FROM dataflow.BusinessScoreTrendQueue WHERE ScoreType = 'Paydex')
		BEGIN
			


			WHILE 1=1
				BEGIN
		
		
					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessScoreTrendQueue WHERE ScoreType = 'Paydex')
					BREAK;

					BEGIN TRANSACTION


					DELETE TOP (50000)
					FROM 
							dataflow.BusinessScoreTrendQueue
					OUTPUT 
							deleted.BusinessID
					INTO #tblBusinessToProcess
					WHERE 
							ScoreType = 'Paydex';

					BEGIN DIALOG @InitDlgHandle
						FROM SERVICE [DataFlowUniverseService]
						TO SERVICE N'DataFlowOnlineService'
						ON CONTRACT [DataFlowContract]
						WITH
							ENCRYPTION = OFF;
		
					SET @PaydexTrendXml	= (
					SELECT
							ID,
							DN,
							CN,
							M1,
							M2,
							M3,
							M4,
							M5,
							M6,
							M7,
							M8,
							M9,
							M10,
							M11,
							M12
					FROM	(
							SELECT
									cob.BusinessID															AS 'ID',
									cob.DunsNumber															AS 'DN',
									cob.ISOCountryAlpha2Code												AS 'CN',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth1)			AS 'M1',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth2)			AS 'M2',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth3)			AS 'M3',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth4)			AS 'M4',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth5)			AS 'M5',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth6)			AS 'M6',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth7)			AS 'M7',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth8)			AS 'M8',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth9)			AS 'M9',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth10)			AS 'M10',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth11)			AS 'M11',
									IIF(gcp.StopDistributionIndicator = 1, NULL,pd.PaydexMonth12)			AS 'M12'
							FROM
									#tblBusinessToProcess t
							INNER JOIN
									dataflow.CirrusOnlineBusiness cob (nolock)
								ON
									t.BusinessID = cob.BusinessID
							INNER JOIN
									feed.PaydexTrend pd (nolock)
								ON
									cob.DunsNumber = pd.DunsNumber
							LEFT JOIN
									feed.GlobalCompanyProfile gcp (nolock)
								ON
									t.BusinessID = gcp.BusinessID) T
					FOR XML AUTO, ROOT('Dataflow'));
					

	
					IF @PaydexTrendXml IS NOT NULL
						BEGIN
							SET @PaydexTrendXml.modify('insert attribute Type {"PaydexTrend"} into (/Dataflow)[1]');
							
							SEND ON CONVERSATION @InitDlgHandle
							MESSAGE TYPE [DataFlowSendMessage]
								  (@PaydexTrendXml);
						END


					COMMIT TRANSACTION;

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessScoreTrendQueue WHERE ScoreType = 'Paydex')
					BREAK;

					TRUNCATE TABLE #tblBusinessToProcess;

				END
		END
		
   
END