-- An example of how to generate random IP addresses.
--
-- 2022.01.14

with d(n) as (select trunc(random() * ((2^32) - 1))::bigint as n from generate_series(1,5))
  select n, '0.0.0.0'::inet + n as rand_ip from d;
