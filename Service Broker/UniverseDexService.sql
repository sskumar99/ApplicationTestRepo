CREATE SERVICE [UniverseDexService]

       ON QUEUE dataflow.UniverseDexQueue;
GO


GRANT SEND
      ON SERVICE::[UniverseDexService]
      TO public;


GO