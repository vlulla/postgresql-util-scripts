--
-- Create a listing of all the columns of the tables (excluding system tables)!
-- 2021.09.17
--
-- 1.
-- SELECT  attrelid::regclass AS tablename, array_agg(attname) FILTER (WHERE (attnum > 0)) AS colnames
-- FROM pg_attribute att JOIN pg_class c ON att.attrelid = c.oid
-- WHERE
--   c.oid IN (SELECT oid FROM pg_class WHERE relnamespace IN
--       (SELECT oid FROM pg_namespace WHERE nspname NOT LIKE 'pg_%' AND nspname <> 'information_schema'))
--   AND
--   c.relkind='r'
-- GROUP BY attrelid;
--
-- 2.
select attrelid::regclass as tablename, array_agg(attname order by attnum) filter (where (attnum > 0)) as colnames
from pg_attribute att join pg_class c on att.attrelid = c.oid
where
  relkind = 'r' and
  -- relnamespace::regnamespace::text not like 'pg_%' and
  -- relnamespace::regnamespace::text <> 'information_schema'
  relnamespace::regnamespace::text not like all(array['pg_%','information_schema%'])
group by attrelid;
