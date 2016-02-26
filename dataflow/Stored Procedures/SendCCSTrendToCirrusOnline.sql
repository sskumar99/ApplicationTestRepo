
--=========================================
-- Author:		DR
-- Create date: 9-29-2015
-- Description:	Sends a service broker message with latest CCS score trends to CirrusOnline
-- =============================================
CREATE PROCEDURE [dataflow].[SendCCSTrendToCirrusOnline]

AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE 
			@InitDlgHandle			uniqueidentifier,
			@RequestMsg				nvarchar(100),
			@CCSTrendXml			xml;


	DELETE 
			bstq
	FROM
			dataflow.BusinessScoreTrendQueue bstq
	WHERE
			bstq.ScoreType = 'CCS'
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
						ScoreType = 'CCS')
		return;


	CREATE TABLE 
			#tblBusinessToProcess (BusinessID bigint PRIMARY KEY);



	
	IF EXISTS(SELECT 1 FROM dataflow.BusinessScoreTrendQueue WHERE ScoreType = 'CCS')
		BEGIN
			


			WHILE 1=1
				BEGIN
		

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessScoreTrendQueue WHERE ScoreType = 'CCS')
					BREAK;

					BEGIN TRANSACTION


					DELETE TOP (50000)
					FROM 
							dataflow.BusinessScoreTrendQueue
					OUTPUT 
							deleted.BusinessID
					INTO #tblBusinessToProcess
					WHERE 
							ScoreType = 'CCS';

					BEGIN DIALOG @InitDlgHandle
						FROM SERVICE [DataFlowUniverseService]
						TO SERVICE N'DataFlowOnlineService'
					 ON CONTRACT [DataFlowContract]
					 WITH
						 ENCRYPTION = OFF;

		
					SET @CCSTrendXml	= (
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
									cob.BusinessID													AS 'ID',
									cob.DunsNumber													AS 'DN',
									cob.ISOCountryAlpha2Code										AS 'CN',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth1)			AS 'M1',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth2)			AS 'M2',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth3)			AS 'M3',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth4)			AS 'M4',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth5)			AS 'M5',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth6)			AS 'M6',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth7)			AS 'M7',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth8)			AS 'M8',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth9)			AS 'M9',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth10)			AS 'M10',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth11)			AS 'M11',
									IIF(gcp.StopDistributionIndicator=1,NULL,pd.CCSMonth12)			AS 'M12'
							FROM
									#tblBusinessToProcess t
							INNER JOIN
									dataflow.CirrusOnlineBusiness cob (nolock)
								ON
									t.BusinessID = cob.BusinessID
							INNER JOIN
									feed.CCSTrend pd (nolock)
								ON
									cob.DunsNumber = pd.DunsNumber
							LEFT JOIN
									feed.GlobalCompanyProfile gcp (nolock)
								ON
									t.BusinessID = gcp.BusinessID) T
					FOR XML AUTO, ROOT('Dataflow'));
					

	
					IF @CCSTrendXml IS NOT NULL
						BEGIN
							SET @CCSTrendXml.modify('insert attribute Type {"CCSTrend"} into (/Dataflow)[1]');
							
							SEND ON CONVERSATION @InitDlgHandle
							MESSAGE TYPE [DataFlowSendMessage]
								  (@CCSTrendXml);
						END


					COMMIT TRANSACTION;

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessScoreTrendQueue WHERE ScoreType = 'CCS')
					BREAK;

					TRUNCATE TABLE #tblBusinessToProcess;

				END
		END
		
   
END