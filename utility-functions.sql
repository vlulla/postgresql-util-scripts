create or replace function round2(x anyelement) returns double precision language sql as $$ select round(x, 2) $$;
create or replace function round3(x anyelement) returns double precision language sql as $$ select round(x, 3) $$;

create or replace function deg2rad(deg anyelement) returns double precision language sql as $$ select deg * acos(-1) / 180 $$;
create or replace function rad2deg(rad anyelement) returns double precision language sql as $$ select rad * 180 / acos(-1) $$;

create or replace function random_ip() returns inet language sql as $$ select '0.0.0.0'::inet + trunc(random() * ((2^32) - 1))::bigint $$;

-- I've come to like BQ's ifnull and nullif functions!
create or replace function ifnull(x anyelement, def anyelement) returns anyelement language sql as $$ select coalesce(x, def) $$;
-- create or replace function nullif(expr1 anyelement, expr_to_match anyelement) returns anyelement language sql as $$ select case expr1 when expr_to_match then null else expr1 end $$; -- PostgreSQL already has NULLIF!
create or replace function if(cond boolean, true_result anyelement, false_result anyelement) returns anyelement language sql as $$ select case when cond then true_result else false_result end $$;
-- The above function will need help determining the type[s]...so will *always* require some casting! This is where BQ's IF function is super nice!
-- with nums(a,b) as (values(10,20),(50,30),(60,60)) select *,if(a<b,'true'::text,'false') as result from nums;
-- This is like R's `ifelse` function!

create or replace function iso_yyyyweek(x anyelement) returns integer language sql as $$ select cast(to_char(cast(x as date), 'IYYYIW'  ) as int) $$;
create or replace function iso_yyyyday (x anyelement) returns integer language sql as $$ select cast(to_char(cast(x as date), 'IYYYIDDD') as int) $$;
