/*
Test Case: delete & update 
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/composite_index/basic_sql/delete_update_07.ctl
Author: Ray

Test Plan: 
Test DELETE/UPDATE locks (X_LOCK on instance) if the instances of the transactions are not overlapped (with composite index)

Test Scenario:
C1 delete, C2 update, the affected rows are not overlapped (based on where clause)
C2 try to update an unique index column to a duplicate key which is C1 try to deleting 
C1,C2 where clauses are not on index column (heap scan)
C1 commit, C2 commit
Metrics: data size = small, index = composite index (Unique), where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances should be deleted, C2 instances should be updated (since the duplicate key has been deleted)

NUM_CLIENTS = 3
C1: delete from table t1;   
C2: update table t1;  
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
C1: CREATE TABLE t1(id INT UNIQUE, col VARCHAR(10) UNIQUE, tag VARCHAR(2));
C1: CREATE UNIQUE INDEX idx_id_col on t1(id,col) with online parallel 7;
C1: INSERT INTO t1 VALUES(1,'abc','A');INSERT INTO t1 VALUES(2,'def','B');INSERT INTO t1 VALUES(3,'ghi','C');INSERT INTO t1 VALUES(4,'jkl','D');INSERT INTO t1 VALUES(5,'mno','E');INSERT INTO t1 VALUES(6,'pqr','F');INSERT INTO t1 VALUES(7,'stu','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE tag IN ('B','D','E');
MC: wait until C1 ready;
C2: UPDATE t1 SET id = 4, tag = 'X' WHERE tag = 'F';
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 2,4,5 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
/* expect: 1 row (id=6) updated message should generated once C2 ready, C2 select - id = 6 is updated */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
/* expect: id = 2,4,5 are deleted, id = 6 is updated */
C3: select * from t1 order by 1,2;

C3: commit;
C1: quit;
C2: quit;
C3: quit;