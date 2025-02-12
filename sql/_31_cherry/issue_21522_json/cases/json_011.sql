set system parameters 'ansi_quotes=default';
drop table if exists t1;
create table t1 (id int AUTO_INCREMENT, a json, b string);
insert into T1(a) values ("aaa");
insert into T1(a) values ('aaa');
insert into T1(a) values ('"aaa"');
insert into T1(a) values ("'aaa'");
insert into T1(a) values (json_array('a','b'));
insert into T1(a) values (json_array("a","b"));
insert into T1(a) values (json_object('a','b'));     
insert into T1(a) values (json_object("a","b")); 
insert into T1(a,b) values ('{"message":"There''re lots of apples there."}', "There''re lots of apples there.");
insert into T1(b) values ("There''re lots of ""APPLES"" there.");
insert into T1(b) values ("There''re lots of 'APPLES' there.");    
insert into T1(a) values ('{"message":"There''re lots of ""APPLES"" there."}');
insert into T1(a) values ('{"message":"There''re lots of 'APPLES' there."}');
select id, a, json_type(a), json_extract(a,'/message'), b from t1 order by 1;

drop table if exists t1;
set system parameters 'ansi_quotes=no';
create table t1 (id int AUTO_INCREMENT, a json, b string);
insert into T1(a) values ('123');
insert into T1(a) values ("123");
insert into T1(a) values ("aaa");
insert into T1(a) values ('aaa');
insert into T1(a) values ('"aaa"');
insert into T1(a) values ("'aaa'");
insert into T1(a) values (json_array('a','b'));
insert into T1(a) values (json_array("a","b"));
insert into T1(a) values (json_object('a','b'));
insert into T1(a) values (json_object("a","b"));
insert into T1(a,b) values ('{"message":"There''re lots of apples there."}', "There''re lots of apples there.");
insert into T1(b) values ("There''re lots of ""APPLES"" there.");
insert into T1(b) values ("There''re lots of 'APPLES' there.");
insert into T1(a) values ('{"message":"There''re lots of ""APPLES"" there."}');
insert into T1(a) values ('{"message":"There''re lots of 'APPLES' there."}');
select id, a, json_type(a), json_extract(a,'/message'), b from t1 order by 1;

drop table if exists t1;
set system parameters 'ansi_quotes=default';
