--TEST: test with bit strings and blob/clob data types and normal syntax
--+ holdcas on;
set system parameters 'dont_reuse_heap_file=yes';

create table var_samp_bbc(
	col1 bit(20),
	col2 bit varying, 
	col3 blob,
	col4 clob,
	col5 int
);


insert into var_samp_bbc values(B'1011', X'abc', X'0', '123', 123.5678);
insert into var_samp_bbc values(B'1011', x'bcd', X'1', '11111', 123.1234);
insert into var_samp_bbc values(B'1011', X'abc', X'2', '9898', 123.2345);
insert into var_samp_bbc values(B'1011', x'bcd', X'3', '123.456', 123.5678);
insert into var_samp_bbc values(B'1011', X'abc', X'4', '9999999', 123.1234);
insert into var_samp_bbc values(B'1001', x'bcd', X'5', '9999999', 123.2345);
insert into var_samp_bbc values(B'1001', X'abc', X'6', '123', 123.3456);
insert into var_samp_bbc values(B'1001', X'abc', X'7', '123', 123.3456);
insert into var_samp_bbc values(B'1001', X'cde', X'8', '123.456', 123.3456);
insert into var_samp_bbc values(B'0011', X'abc', X'9', '7766', 123.5678);
insert into var_samp_bbc values(B'0011', X'abc', X'10', '9898', 123.4567);
insert into var_samp_bbc values(B'0011', X'cde', X'11', '123.456', 123.5678);
insert into var_samp_bbc values(B'1010', X'abc', X'12', '3333', 123.1234);
insert into var_samp_bbc values(B'1111', X'abc', X'13', '123', 123.4567);
insert into var_samp_bbc values(B'1111', x'bcd', X'14', '9898', 123.2345);
insert into var_samp_bbc values(B'1111', X'abc', X'15', '7766', 123.4567);
insert into var_samp_bbc values(B'1111', X'abc', X'16', '9898', 123.1357);
insert into var_samp_bbc values(B'1111', X'cde', X'17', '123', 123.1357);
insert into var_samp_bbc values(B'1111', X'abc', X'18', '999999', 123.9999);
insert into var_samp_bbc values(B'1111', X'abc', X'19', '9999999', 123.9999);


--TEST: OVER() clause
--TEST: bit(n) 
select col1, col2, var_samp(col5) over() from var_samp_bbc order by 1, 2;
--TEST: bit varying, with alias+all
select col2, blob_to_bit(col3), var_samp(all col5) over() var_samp from var_samp_bbc order by 1, blob_to_bit(col3);
--TEST: blob, with where clause
select blob_to_bit(col3), clob_to_char(col4), var_samp(col5) over() var_samp from var_samp_bbc where col1 > B'1011' order by blob_to_bit(col3), clob_to_char(col4);
--TEST: clob, distinct
select clob_to_char(col4), col1, var_samp(unique clob_to_char(col4)) over() var_samp from var_samp_bbc order by clob_to_char(col4), 2;
--TEST: syntax error
select col1, blob_to_bit(col3), clob_to_char(col4), var_samp(col5) over var_samp from var_samp_bbc;
select col1, blob_to_bit(col3), col2, var_samp(col5) over(1) var_samp from var_samp_bbc;



--TEST: OVER(PARTITION BY) clause
--TEST: partition by bit(n)
select col1, col2, blob_to_bit(col3), clob_to_char(col4), var_samp(col5) over(partition by col1) var_samp from var_samp_bbc order by 1, 2, blob_to_bit(col3), clob_to_char(col4);
--TEST: partition by bit varying
select col1, col2, blob_to_bit(col3), clob_to_char(col4), var_samp(all clob_to_char(col4)) over(partition by col2) var_samp from var_samp_bbc order by 2, 1, blob_to_bit(col3), clob_to_char(col4);
--TEST: partition by blob
select col1, col2, blob_to_bit(col3), clob_to_char(col4), var_samp(distinctrow col5) over(partition by 3) var_samp from var_samp_bbc order by blob_to_bit(col3), 1, 2, clob_to_char(col4);
--TEST: partition by clob
select col1, col2, blob_to_bit(col3), clob_to_char(col4), var_samp(all col5) over(partition by 4) var_samp from var_samp_bbc order by clob_to_char(col4), 1, 2, blob_to_bit(col3), 5;



--TEST: OVER(ORDER BY) clause
--TEST: order by 1 column name
select col1, var_samp(col5) over(order by col1) var_samp from var_samp_bbc order by 1, 2;
--TEST: order by 2 column names
select col2, blob_to_bit(col3), var_samp(all clob_to_char(col4)) over(order by col2, blob_to_bit(col3) asc) var_samp from var_samp_bbc order by 1, 2;
--TEST: order by more than 2 column names
select col1, col2, blob_to_bit(col3), clob_to_char(col4), var_samp(unique col5) over(order by col1, col2 desc, blob_to_bit(col3), clob_to_char(col4) asc) var_samp from var_samp_bbc;
--TEST: order by columns not selected
select var_pop from (select blob_to_bit(col3), var_samp(distinct clob_to_char(col4)) over(order by clob_to_char(col4) desc, col2, col1 asc) var_samp1, var_samp(distinct clob_to_char(col4)) over() var_samp2 from var_samp_bbc) order by 1;
--TEST: order by 1 position
select clob_to_char(col4), var_samp(all col5) over(order by 1) var_samp from var_samp_bbc;
--TEST: order by 3 positions
select blob_to_bit(col3), col2, var_samp(clob_to_char(col4)) over(order by blob_to_bit(col3), 2 desc, 3 asc) var_samp from var_samp_bbc;
--TEST: order by more than 3 positions
select col1, col2, blob_to_bit(col3), clob_to_char(col4), var_samp(unique col5) over(order by blob_to_bit(col3), 2 asc, 1 desc, clob_to_char(col4)) var_samp from var_samp_bbc;
--TEST: order by positions not existed
select col2, var_samp(distinct col5) over(order by 2) var_samp from var_samp_bbc;
select col1, var_samp(all col5) over(order by 3, 4, 1 desc) var_samp, col2, clob_to_char(col4) from var_samp_bbc;
select blob_to_bit(col3), clob_to_char(col4), var_samp(col5) over(order by 5) var_samp from var_samp_bbc;
select blob_to_bit(col3), col1, var_samp(col5) over(order by 100) var_samp from var_samp_bbc;
--TEST: order by column names and positions
select col1, col2, blob_to_bit(col3), clob_to_char(col4), var_samp(distinctrow col5) over(order by 1, col2 desc, 3, clob_to_char(col4) asc) var_samp from var_samp_bbc;




--TEST: OVER(PARTITION BY ORDER BY) clause
--TEST: partition by bit(n)
select col1, col2, blob_to_bit(col3), var_samp(distinct clob_to_char(col4)) over(partition by col1 order by 1, 2, blob_to_bit(col3)) var_samp1, var_samp(distinct clob_to_char(col4)) over(partition by col1) var_samp2 from var_samp_bbc;
--TEST: partition by bit varying
select col2, clob_to_char(col4), col1, var_samp(col5) over(partition by col2 order by col2, clob_to_char(col4), col1 desc) from var_samp_bbc;
--TEST: partition by blob
select var_pop from (select blob_to_bit(col3), var_samp(all clob_to_char(col4)) over(partition by 1 order by blob_to_bit(col3), clob_to_char(col4), 3) var_samp, col2 from var_samp_bbc order by 1;
--TEST: partition by clob
select clob_to_char(col4), col1, var_samp(unique col5) over(partition by 1 order by clob_to_char(col4), 2 desc) var_samp from var_samp_bbc;
--TEST: syntax error
select col1, col2, var_samp(distinct col5) over(order by col1, col2 partition by col2) from var_samp_bbc;


delete from var_samp_bbc;
drop table var_samp_bbc; 

set system parameters 'dont_reuse_heap_file=no';
--+ holdcas off;













