CREATE PROCEDURE [feed].[ExecutionUpdate] 
(
	@ExecutionID				int,
	@ConfigurationID			int			= NULL,
	@ExecutionStartTime			datetime2	= NULL,
	@ExecutionEndTime			datetime2	= NULL,
	@ExecutionStartLineageID	bigint		= NULL,
	@ExecutionEndLineageID		bigint		= NULL,
	@ExecutionStatusID			tinyint		= NULL,
	@Notes						varchar(MAX)= NULL,
	@DWExecutionID				int			= NULL,
	@ExecutionOutput			ExecutionOutputTableType READONLY,
	@CreatedDate				datetime2	= NULL,
	@CreatedBy					varchar(50)	= NULL,
	@UpdatedDate				datetime2	= NULL,
	@UpdatedBy					varchar(50)	= NULL	
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
			@ExecutionOutputXML xml = NULL;
	
	IF EXISTS(SELECT 1 FROM @ExecutionOutput)
		BEGIN
			SET @ExecutionOutputXML = (
				SELECT
						1									AS Tag,
						NULL								AS Parent,
						ExecutionOutputKey					AS [EO!1!Key],
						ExecutionOutputValue				AS [EO!1!!cdata]
				FROM
						@ExecutionOutput
				FOR XML EXPLICIT, ROOT('ExecutionOutput'))	
		END


	UPDATE feed.Execution 
	SET
			ConfigurationID				= ISNULL(@ConfigurationID, ConfigurationID),
			ExecutionStartTime			= ISNULL(@ExecutionStartTime, ExecutionStartTime),
			ExecutionEndTime			= ISNULL(@ExecutionEndTime, ExecutionEndTime),
			ExecutionStartLineageID		= ISNULL(@ExecutionStartLineageID, ExecutionStartLineageID),
			ExecutionEndLineageID		= ISNULL(@ExecutionEndLineageID, ExecutionEndLineageID),
			ExecutionStatusID			= ISNULL(@ExecutionStatusID, ExecutionStatusID),
			Notes						= ISNULL(@Notes, Notes),
			DWExecutionID				= ISNULL(@DWExecutionID, DWExecutionID),
			ExecutionOutput				= ISNULL(@ExecutionOutputXML, ExecutionOutput),
			CreatedDate					= ISNULL(@CreatedDate, CreatedDate),
			CreatedBy					= ISNULL(@CreatedBy, CreatedBy),
			UpdatedDate					= ISNULL(@UpdatedDate, UpdatedDate),
			UpdatedBy					= ISNULL(@UpdatedBy, UpdatedBy)
	WHERE
			ExecutionID = @ExecutionID;


			
	
END