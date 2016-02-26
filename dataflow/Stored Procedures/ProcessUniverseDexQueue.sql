
create Procedure [dataflow].[ProcessUniverseDexQueue]
AS

	SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    --SET LOCK_TIMEOUT 3000;


-- =======================================================
-- Author: MAmirfathi
-- Create date: 09/25/2015
-- Description: 

-- =======================================================



BEGIN
		DECLARE @RcvdMsgs TABLE
			(ch					UNIQUEIDENTIFIER,
			 messagebody		XML,
			 messagetypename	NVARCHAR(256)
	)


	DECLARE	@msg          XML
			,@ErrMsg        nvarchar(4000)
			,@ErrSeverity   int
			,@MessageTypeName	sysname
			,@ConversationHandle uniqueidentifier




--


	BEGIN TRY

		BEGIN TRANSACTION readmessage

			DELETE @RcvdMsgs

			WAITFOR(	
					RECEIVE TOP (1)
							conversation_handle,
							message_body,
							message_type_name
					FROM	UniverseDexQueue
					INTO	@RcvdMsgs
					), timeout 5000;

			-- to create an error
			--Select 1/0

			IF @@ERROR <> 0
			BEGIN
				IF @@TRANCOUNT <> 0 
					ROLLBACK TRANSACTION readmessage

				--BREAK
			END


		If 	Exists(Select 1 From @RcvdMsgs where messagetypename = 'DexCUniverseSendMessage')
		Begin
		


			Select @msg =messagebody.query('/Message/BusInfoReturn') 
			From @RcvdMsgs
			
			

			If @msg is not NULL And Len(Ltrim((cast(@msg as varchar(max)))))> 0
				Begin
					Exec dataflow.ReturnedBusinessIdDex 
					@msg = @msg 
				
				END
				
				
				
			
					
				END
			
			IF (@MessageTypeName = 'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
					BEGIN
						END CONVERSATION @ConversationHandle;
					END
	
			
		Commit Transaction readmessage
			
	END TRY
	BEGIN CATCH 
							
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION readmessage;

			SELECT @ErrMsg = ERROR_MESSAGE(),
			@ErrSeverity = ERROR_SEVERITY()
	 
			RAISERROR(@ErrMsg, @ErrSeverity, 1)

	END CATCH
END


		
	


