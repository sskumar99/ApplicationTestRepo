CREATE SERVICE [DataFlowUniverseService]
    AUTHORIZATION [dbo]
    ON QUEUE [dataflow].[UniverseQueue]
    ([DataFlowContract]);

