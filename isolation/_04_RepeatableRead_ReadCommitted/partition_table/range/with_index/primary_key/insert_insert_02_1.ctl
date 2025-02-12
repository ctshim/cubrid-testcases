/*
Test Case: insert & insert
Priority: 1
Reference case:
Author: Rong Xu

Test Point:
X_LOCK on first key OID for unique indexes
two clients insert the same row at the same time, the first commit
partition id and primary key on the same column

NUM_CLIENTS = 2
C1: insert(1,'abc');
C2: insert(11,'abc');
C1: commit
C2: commit -- 0 row insert
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int primary key,col varchar(10)) partition by range(id)(partition p1 values less than (10),partition p2 values less than (100));
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t values(1,'abc');
MC: wait until C1 ready;
C2: insert into t values(11,'abc');
MC: wait until C2 ready;
C1: commit work;
MC: wait until C1 ready;
C2: commit work;
C2: select * from t order by 1;
C2: commit;

C2: quit;
C1: quit;

