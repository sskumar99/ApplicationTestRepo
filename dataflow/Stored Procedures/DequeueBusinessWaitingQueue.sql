
--=========================================
-- Author:		DR
-- Create date: 12-02-2015
-- Description:	Dequeue the waiting queue ([dataflow].[BusinessWaitingQueue])
-- =============================================
CREATE PROCEDURE [dataflow].[DequeueBusinessWaitingQueue]
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;



	IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessWaitingQueue)
		RETURN;
	
	CREATE TABLE #tblBusinessIDList (
			BusinessID			bigint,
			DunsNumber			varchar(10) NULL,
			PRIMARY KEY CLUSTERED(BusinessID));

	BEGIN TRANSACTION


	DELETE
			bwq
	FROM
			dataflow.BusinessWaitingQueue bwq
	LEFT JOIN 
			dataflow.CirrusOnlineBusiness cob (nolock)
		ON 
			bwq.BusinessID = cob.BusinessID
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
	

	
	INSERT INTO #tblBusinessIDList(
			BusinessID)
	SELECT
			bwq.BusinessID
	FROM
			BusinessWaitingQueue bwq
	WHERE
			EXISTS(
					SELECT
							1
					FROM
							feed.[Identity] i (nolock)
					WHERE
							i.BusinessID = bwq.BusinessID
						AND NOT (LEN(ISNULL(i.Name, '')) = 0
						OR LEN(ISNULL(i.Street1, '') + ISNULL(i.Street2, '')) = 0
						OR LEN(ISNULL(i.City, '') + ISNULL(i.State, '') + ISNULL(i.PostalCode, '')) = 0))
		AND EXISTS(
						SELECT
								1
						FROM
								feed.PaydexDaily
						WHERE
								BusinessID = bwq.BusinessID)	
		AND EXISTS(
						SELECT
								1
						FROM
								feed.SASDaily
						WHERE
								BusinessID = bwq.BusinessID);
			

	INSERT INTO dataflow.BusinessProfileChangeQueue(
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
								dataflow.BusinessProfileChangeQueue
						WHERE
								BusinessID = t.BusinessID);
	
	INSERT INTO dataflow.BusinessScoreChangeQueue(
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
								dataflow.BusinessScoreChangeQueue
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
			t.BusinessID = cob.BusinessID
	WHERE
			cob.FirstTimeProcessedDate IS NULL;

	DELETE
			bwq
	FROM
			dataflow.BusinessWaitingQueue bwq
	INNER JOIN
			#tblBusinessIDList t
		ON
			bwq.BusinessID = t.BusinessID;
							


	COMMIT TRANSACTION;

	
		
   
END