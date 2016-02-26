
-- =============================================
-- Author:		Morvarid Amirfathi
-- Create date: 09/25/2015
-- Description:	
-- =============================================
create PROCEDURE [dataflow].[ReturnedBusinessIdDex] 
( @msg XML )
AS

Set Transaction Isolation Level Read unCommitted
Set LOCK_Timeout 2000

BEGIN
DECLARE @ErrMsg NVARCHAR(4000),@ErrSeverity INT,@ErrorMsg VARCHAR(100),@now datetime = getdate()

BEGIN TRY	


			IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp
			
			

			SELECT DISTINCT a.b.value('Duns[1]', '[varchar](50)') AS Duns
						   ,a.b.value('BusinessId[1]', 'bigint') as BusinessID
			into #temp
			FROM @msg.nodes('BusInfoReturn') AS a(b)


END TRY
	BEGIN CATCH
		-- If you are using explicit trans
		IF @@Trancount > 0
			ROLLBACK

		SELECT @ErrMsg = isNull(@ErrorMsg, ERROR_MESSAGE())
			,@ErrSeverity = ERROR_SEVERITY()


		SELECT 
				CAST(0 AS bit)	as Success, 
				@ErrMsg			as ErrMsg,
				@ErrSeverity	as ErrSeverity;

		RAISERROR (
				@ErrMsg
				,@ErrSeverity
				,1
				)
	END CATCH
END
