
CREATE PROCEDURE [dataflow].[ProcessQueue]
	
AS
-- =============================================
-- Author:		DR
-- Create date: 8/13/2015
-- Description:	This procedure will dequeue messages in UniverseQueue
-- =============================================
BEGIN
	SET NOCOUNT ON;

	DECLARE              
			@XML				xml,
			@ResponseXML		xml,
			@MessageBody		varbinary(MAX),
			@MessageTypeName	sysname,
			@DataflowType		varchar(50),
			@ConversationHandle uniqueidentifier,
			@Response			xml,
			@ErrorNumber		int = 0,
			@ErrorMessage		nvarchar(4000) = 'Success',
			@ErrorSeverity		int;
			


	
	WHILE (1=1)
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION;
				WAITFOR (RECEIVE TOP(1)
								@MessageTypeName = message_type_name,
								@MessageBody = message_body,
								@ConversationHandle = conversation_handle
						FROM dataflow.UniverseQueue), TIMEOUT 5000;
				
				IF (@@ROWCOUNT = 0) 
					BEGIN
						IF @@TRANCOUNT <> 0 
							ROLLBACK TRANSACTION;
						
						BREAK;
					END

				IF @MessageTypeName = 'DataFlowSendMessage'
					BEGIN
						SET @XML = CAST(@MessageBody AS XML);
						SET @DataflowType = (
									SELECT @XML.value('(//Dataflow/@Type)[1]', 'varchar(50)'));

						IF @DataflowType = 'BusinessIDRequest'
							BEGIN
								IF OBJECT_ID('tempdb..#tblDunsNumberBusinessID') IS NOT NULL DROP TABLE #tblDunsNumberBusinessID;
								IF OBJECT_ID('tempdb..#tblCirrusOnlineBusiness') IS NOT NULL DROP TABLE #tblCirrusOnlineBusiness;
								CREATE TABLE #tblDunsNumberBusinessID (
										BusinessID			bigint	,
										DunsNumber			varchar(10),
										Country				char(2),
										ActivityDetailLogID	bigint);		

								CREATE TABLE #tblCirrusOnlineBusiness (
										BusinessID			bigint,
										DunsNUmber			varchar(10));	


								--Create BusinessID for non existing duns
								INSERT INTO feed.[Identity](
										DunsNumber,
										Country,
										IsActive,
										CreatedDate,
										CreatedBy)
								SELECT
										DunsNumber,
										Country,
										0,
										GETUTCDATE(),
										OBJECT_NAME(@@PROCID)
								FROM
										(
										SELECT
												Tbl.Col.value('@ID', 'bigint')													AS BusinessID,
												Tbl.Col.value('@DN', 'varchar(10)')												AS DunsNumber,
												Tbl.Col.value('@LID', 'bigint')													AS ActivityDetailLogID,
												Tbl.Col.value('@CN', 'char(2)')													AS Country
										FROM
												@xml.nodes('//Dataflow/R') Tbl(Col)) x
								WHERE
										NOT EXISTS (
													SELECT
															1
													FROM
															feed.[Identity] (nolock)
													WHERE
															DunsNumber = x.DunsNumber);
								
								
								INSERT INTO #tblDunsNumberBusinessID(
										DunsNumber,
										BusinessID,
										ActivityDetailLogID,
										Country)
								SELECT
										x.DunsNumber,
										i.BusinessID,
										x.ActivityDetailLogID,
										i.Country
		
								FROM	(
										SELECT
												Tbl.Col.value('@ID', 'bigint')													AS BusinessID,
												Tbl.Col.value('@DN', 'varchar(10)')												AS DunsNumber,
												Tbl.Col.value('@LID', 'bigint')													AS ActivityDetailLogID
										FROM
												@xml.nodes('//Dataflow/R') Tbl(Col)) x
								INNER JOIN
										feed.[Identity] i (nolock)
									ON
										x.DunsNumber = i.DunsNumber;
								
								
								
								SET
									@ResponseXML = (
													SELECT
															DN,
															ID,
															LID
													FROM	(
															SELECT
																	BusinessID				AS ID,
																	DunsNumber				AS DN,
																	ActivityDetailLogID		AS LID
															FROM
																	#tblDunsNumberBusinessID) R
													FOR XML AUTO, ROOT('Dataflow'));
									IF @ResponseXML IS NOT NULL
										BEGIN
												SET @ResponseXML.modify('insert attribute Type {"BusinessIDRequest"} into (/Dataflow)[1]');
												
												SEND ON CONVERSATION @ConversationHandle MESSAGE TYPE DataFlowReplyMessage(CAST(@ResponseXML AS nvarchar(MAX)));

												INSERT INTO dataflow.CirrusOnlineBusiness(
														BusinessID,
														DunsNumber,
														ActivityDetailLogID,
														ISOCountryAlpha2Code,
														CreatedBy,
														CreatedDate)
												OUTPUT 
														inserted.BusinessID, inserted.DunsNumber INTO #tblCirrusOnlineBusiness
												SELECT
														t.BusinessID,
														t.DunsNumber,
														t.ActivityDetailLogID,
														t.Country,
														CAST(t.ActivityDetailLogID AS varchar(50)),
														GETUTCDATE()
												FROM
														#tblDunsNumberBusinessID t
												WHERE
														NOT EXISTS (
																	SELECT
																			1
																	FROM
																			dataflow.CirrusOnlineBusiness
																	WHERE
																			BusinessID = t.BusinessID)
														AND t.Country IN ('BE','NL','LU','IE','GB','US','CA');


												INSERT INTO dataflow.BusinessWaitingQueue(
														BusinessID)
												SELECT DISTINCT
														t.BusinessID
												FROM
														#tblCirrusOnlineBusiness t
												WHERE
														NOT EXISTS(						-- Branch					
																	SELECT
																			1
																	FROM
																			feed.CorporateLinkage cl (nolock)
																	WHERE
																			cl.DunsNumber = t.DunsNumber
																		AND cl.LocationType = 'Branch')
													AND (EXISTS (
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
																			pd.BusinessID = t.BusinessID));


												----Temporary section
												if 1=2 begin
												INSERT INTO dataflow.BusinessProfileChangeQueue(BusinessID)
												SELECT BusinessID FROM #tblDunsNumberBusinessID t
												WHERE NOT EXISTS (
																	SELECT
																			1
																	FROM
																			dataflow.BusinessProfileChangeQueue
																	WHERE
																			BusinessID = t.BusinessID);
												
												INSERT INTO dataflow.BusinessScoreChangeQueue(BusinessID)
												SELECT BusinessID FROM #tblDunsNumberBusinessID t
												WHERE NOT EXISTS (
																	SELECT
																			1
																	FROM
																			dataflow.BusinessScoreChangeQueue
																	WHERE
																			BusinessID = t.BusinessID);

												INSERT INTO dataflow.BusinessRiskIndicatorChangeQueue(BusinessID)
												SELECT BusinessID FROM #tblDunsNumberBusinessID t
												WHERE NOT EXISTS (
																	SELECT
																			1
																	FROM
																			dataflow.BusinessRiskIndicatorChangeQueue
																	WHERE
																			BusinessID = t.BusinessID);
												INSERT INTO dataflow.BusinessScoreTrendQueue(BusinessID, ScoreType)
												SELECT BusinessID, 'Paydex' FROM #tblDunsNumberBusinessID t
												WHERE NOT EXISTS (
																	SELECT
																			1
																	FROM
																			dataflow.BusinessScoreTrendQueue
																	WHERE
																			BusinessID = t.BusinessID
																		AND ScoreType = 'Paydex');

												INSERT INTO dataflow.BusinessScoreTrendQueue(BusinessID, ScoreType)
												SELECT BusinessID, 'CCS' FROM #tblDunsNumberBusinessID t
												WHERE NOT EXISTS (
																	SELECT
																			1
																	FROM
																			dataflow.BusinessScoreTrendQueue
																	WHERE
																			BusinessID = t.BusinessID
																		AND ScoreType = 'CCS');

												INSERT INTO dataflow.BusinessScoreTrendQueue(BusinessID, ScoreType)
												SELECT BusinessID, 'FSS' FROM #tblDunsNumberBusinessID t
												WHERE NOT EXISTS (
																	SELECT
																			1
																	FROM
																			dataflow.BusinessScoreTrendQueue
																	WHERE
																			BusinessID = t.BusinessID
																		AND ScoreType = 'FSS');
												end
										END

									IF OBJECT_ID('tempdb..#tblDunsNumberBusinessID') IS NOT NULL DROP TABLE #tblDunsNumberBusinessID;
								
							END

						END CONVERSATION @ConversationHandle;
						
						
					END

				IF (@MessageTypeName = 'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
					BEGIN
						END CONVERSATION @ConversationHandle;
					END
				
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
				BREAK;

			END CATCH
		END --WHILE
	
  
		
END