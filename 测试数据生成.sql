drop table test_table;
CREATE table test_table(
	p_key INT PRIMARY KEY   NOT NULL,
	integer_t int, 
	--整型
	point_t point, 
	--geometry型
	string_t text,
	--md5字符串
	text_t text,
	--中文文本
	id_t text,
	--身份证
	phonenumber_t character varying,
	--电话号码
	time_t time
	--时间
	);

--创建函数

--随机中文
create or replace function get_ch(int) returns text as $$    
declare    
  res text;    
begin    
  if $1 >=1 then    
    select string_agg(chr(19968+(random()*20901)::int), '') into res from generate_series(1,$1);    
    return res;    
  end if;    
  return null;    
end;    
$$ language plpgsql strict;

--随机身份证号
create or replace function gen_id(    
  a date,    
  b date    
)     
returns text as $$    
select lpad((random()*99)::int::text, 2, '0') ||     
       lpad((random()*99)::int::text, 2, '0') ||     
       lpad((random()*99)::int::text, 2, '0') ||     
       to_char(a + (random()*(b-a))::int, 'yyyymmdd') ||     
       lpad((random()*99)::int::text, 2, '0') ||     
       random()::int ||     
       (case when random()*10 >9 then 'X' else (random()*9)::int::text end ) ;    
$$ language sql strict;    

--随机生成10个身份证号码 gen_id('2000-01-01', '2022-03-14') from generate_series(1,10);


--随机电话号码
create or replace function get_tel() returns varchar(300) as $body$
declare
        startlength int  default 11 ;
        endlength int  default 11  ;
        first_no varchar(100) default '1';
        chars_str varchar(100) default '0123456789';
        return_str varchar(300) default substring('3578' , cast((1 + random()*3 ) as int),1);
        i int ;
        end1 int;
    begin
        end1 :=cast((random()*(endlength - startlength)) as int)+startlength;
        for i in 1 .. end1-2 loop
        return_str = concat(return_str,substring(chars_str , cast((1 + random()*9 ) as int),1));
        end loop;
        return concat(first_no,return_str);
    end;
$body$
language 'plpgsql' ;
--随机生成10个电话号码 select get_tel() from  generate_series(1,10);


--随机时间
create or replace function get_rand_datetime(start_date date, end_date date) returns timestamp as $body$  
declare   
        interval_days integer;
        random_seconds integer; 
        random_dates integer;
        random_date date; 
        random_time time;
    begin
        interval_days := end_date - start_date;
        random_dates:= trunc(random()*interval_days);
        random_date := start_date + random_dates;
        random_seconds:= trunc(random()*3600*24);
        random_time:=' 00:00:00'::time+(random_seconds || ' second')::interval;
        return random_date +random_time;
    end; 
$body$ 
language plpgsql;






--插入
insert into test_table 
select generate_series(1,50) as key,--修改generate_series(start, end)来改变问题规模
	(random()*(10^9))::integer,
	--int
	point((random()*(10^8))::float, (random()*(10^5))::float ),
	--point
	repeat(md5(random()::text),2) ,
	--string
	get_ch(20),
	--text
	gen_id('2000/01/01', '2023/10/17'),
	--id
	get_tel(),
	--tel_num
	get_rand_datetime('2000/01/01', '2023/10/17');
	-time
select * from test_table;




