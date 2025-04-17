--
-- 2025.04.16
--
-- Generate random strings with something like this:
--
--   with
--     _ as (select cast(trunc(random()*15)+1 as int) as len from generate_series(1,25))
--   select row_number() over () as rn,len,randomstr(len) as randstr from _;
--
create or replace function randomstr(len int) returns text as $$
  with _ as (select 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' as alnum)
    , _1 as (select substr(alnum,cast(trunc(length(alnum)*random())+1 as int),1) as ch from _,generate_series(1,len))
  select string_agg(ch,'') from _1
$$ language sql volatile;
