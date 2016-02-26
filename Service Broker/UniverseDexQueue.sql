CREATE QUEUE dataflow.UniverseDexQueue


ALTER QUEUE [dataflow].[UniverseDexQueue]
WITH   STATUS=ON,                                                                               -- the queue is on 
              RETENTION = OFF,                                                               -- the queue is not retaining messages after they are received 
              ACTIVATION (  
                     STATUS = ON,                                                               -- automatic activation once a queue receives a message
                     PROCEDURE_NAME =[dataflow].[ProcessUniverseDexQueue],                                       -- the procedure to activate
                     MAX_QUEUE_READERS = 5,                                                     -- number of processes that read from the queue
                     EXECUTE AS OWNER                                                           -- database security context in which to execute this queue
              )       