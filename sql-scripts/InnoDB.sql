SHOW ENGINE INNODB STATUS;

-- lock_deadlocks – Number of deadlocks
-- lock_timeouts – Number of lock timeouts
-- lock_deadlock_false_positives – Number of times a heuristic found a spurious candidate deadlock cycle in the wait-for graph
-- lock_deadlock_rounds – Number of times a wait-for graph was scanned in search for deadlocks
-- lock_threads_waiting – Number of query threads sleeping waiting for a lock

SELECT * FROM INFORMATION_SCHEMA.INNODB_METRICS WHERE name IN ('lock_deadlocks','lock_timeouts','lock_deadlock_false_positives','lock_deadlock_rounds');

SELECT name,comment 
FROM INFORMATION_SCHEMA.INNODB_METRICS 
WHERE name IN ('-- lock_deadlocks','lock_timeouts','lock_deadlock_false_positives','lock_deadlock_rounds');

SELECT ENGINE_TRANSACTION_ID as trx_id,OBJECT_NAME as `table`,INDEX_NAME,LOCK_DATA,LOCK_MODE,LOCK_STATUS FROM performance_schema.data_locks WHERE LOCK_TYPE='RECORD';

SELECT @@innodb_lock_wait_timeout;

SELECT `count` FROM INFORMATION_SCHEMA.INNODB_METRICS 
WHERE NAME="lock_deadlocks";

SHOW VARIABLES LIKE 'innodb_rollback_on_timeout';

SET innodb_rollback_on_timeout = ON;

SET GLOBAL innodb_rollback_on_timeout = ON;
SET SESSION innodb_lock_wait_timeout = 50; 

SHOW VARIABLES LIKE 'innodb_lock_wait_timeout';



