/*
Test Case: insert & insert
Priority: 1
Reference case:
Author: Rong Xu

Test Point:
-    Insert: X_LOCK on first key OID for unique indexes.
-    Update: X_LOCK acquired on current instance
insert should lock all the unique index 

NUM_CLIENTS = 2
C1: insert into t values(4,'abc');
C2: update t set col='abc' where col='c';
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int primary key,col varchar(10) unique);
C1: insert into t values(1,'a');
C1: insert into t values(2,'b');
C1: insert into t values(7,'c');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t values(4,'abc');
MC: wait until C1 ready;
C2: update t set col='abc' where col='c'; 
MC: wait until C2 blocked;

C1: select * from t order by 1; 
C1: commit;
MC: wait until C2 ready;

/* expect (1,a)(2,b)(7,c)(4,abc) */
C2: select * from t order by 1; 
C2: commit;

C2: select * from t order by 1; 
C2: commit; 

C1: quit;
C2: quit;

