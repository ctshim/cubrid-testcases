/*
Test Case: delete & delete 
Priority: 1
Reference case:
Author: Ray

Test Plan: 
Test DELETE locks (X_LOCK on instance) if the delete instances of the transactions are overlapped (with multiple indexes)

Test Scenario:
C1 delete, C2 delete, the affected rows are overlapped
C1 where clauses are not on index (heap scan),
C1 delete instances contain the instances from C2 delete 
C1 rollback, C2 commit
Metrics: data size = small, index = multiple indexes(2 simple indexes), where clause = simple, DELETE state = single table deletion

Test Point:
1) C2 needs to wait C1 completed
2) The instances of C1 won't be deleted because of C1 rollback, C2 instances will be deleted
   (i.e.the version won't be updated, the C2 search condition is totally satisfied)

NUM_CLIENTS = 3
C1: delete from table t1;  
C2: delete from table t1;  
C3: select on table t1; C3 is used to check the updated result
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT, col VARCHAR(10), tag VARCHAR(2));
C1: CREATE INDEX idx_id on t1(id) with online parallel 3;
C1: CREATE INDEX idx_col on t1(col) with online parallel 3;
C1: INSERT INTO t1 VALUES(1,'abc','A');INSERT INTO t1 VALUES(2,'def','B');INSERT INTO t1 VALUES(3,'ghi','C');INSERT INTO t1 VALUES(4,'jkl','D');INSERT INTO t1 VALUES(5,'mno','E');INSERT INTO t1 VALUES(6,'pqr','F');INSERT INTO t1 VALUES(7,'abc','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE tag IN ('A','B') or tag >= 'F';
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE tag = 'B' or tag = 'G';
/* expect: C2 needs to wait until C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 1,2,6,7 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: rollback;
MC: wait until C1 ready;
/* expect: 2 row deleted message should generated once C2 ready, C2 select - id = 2,7 are deleted */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;
/* expect: the instances of id = 2,7 are deleted */
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C3: commit;
C1: quit;
C2: quit;
C3: quit;
