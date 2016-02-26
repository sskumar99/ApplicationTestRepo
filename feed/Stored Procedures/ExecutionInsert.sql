CREATE PROCEDURE [feed].[ExecutionInsert] 
(
	@ConfigurationID			int,
	@ExecutionStartTime			datetime2,
	@ExecutionEndTime			datetime2	= NULL,
	@ExecutionStartLineageID	bigint		= NULL,
	@ExecutionEndLineageID		bigint		= NULL,
	@ExecutionStatusID			tinyint,
	@Notes						varchar(MAX)= NULL,
	@DWExecutionID				int			= NULL,
	@CreatedDate				datetime2	= NULL,
	@CreatedBy					varchar(50)	= NULL,
	@UpdatedDate				datetime2	= NULL,
	@UpdatedBy					varchar(50)	= NULL	
)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO feed.Execution (
			ConfigurationID,
			ExecutionStartTime,
			ExecutionEndTime,
			ExecutionStartLineageID,
			ExecutionEndLineageID,
			ExecutionStatusID,
			Notes,
			DWExecutionID,
			CreatedDate,
			CreatedBy,
			UpdatedDate,
			UpdatedBy)
    VALUES	(	
			@ConfigurationID,
			@ExecutionStartTime,
			@ExecutionEndTime,
			@ExecutionStartLineageID,
			@ExecutionEndLineageID,
			ISNULL(@ExecutionStatusID,1),
			@Notes,
			@DWExecutionID,
			ISNULL(@CreatedDate, GETUTCDATE()),
			ISNULL(@CreatedBy, OBJECT_NAME(@@PROCID)),
			@UpdatedDate,
			@UpdatedBy)


	SELECT 
			SCOPE_IDENTITY() AS ExecutionID;
			
	
END