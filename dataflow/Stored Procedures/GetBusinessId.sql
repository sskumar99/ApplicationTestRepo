
-- =============================================
-- Author:		Morvarid Amirfathi
-- Create date: 09/24/2015
-- Description:	
-- =============================================
create PROCEDURE [dataflow].[GetBusinessId] 
( @msg XML )
AS

Set Transaction Isolation Level Read UnCommitted
Set LOCK_Timeout 2000

BEGIN
DECLARE @ErrMsg NVARCHAR(4000),@ErrSeverity INT,@ErrorMsg VARCHAR(100)

BEGIN TRY			   


/*************************************************
		-- Create Service Broker Message
**************************************************/
			DECLARE @Message VARCHAR(max) = cast(@msg as varchar(max))
					,@Message_Body XML
			
			SET @Message_Body = '<Message>' + @Message + '</Message>'
		

			DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
			DECLARE @RequestMsg NVARCHAR(100);

			BEGIN
				DIALOG @InitDlgHandle
				FROM SERVICE [UniverseDexService] 
				TO SERVICE N'DexCirrusUniverseService' 
				ON CONTRACT [DexCUniverseSimpleContract]
				WITH ENCRYPTION = OFF;

				SEND ON CONVERSATION @InitDlgHandle MESSAGE TYPE [DexCUniverseSendMessage](@Message_Body);
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
