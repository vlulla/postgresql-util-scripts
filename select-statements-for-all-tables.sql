--
-- Since I don't like doing "select *" on tables I wrote this script to generate
-- select queries for all the tables in the database.
--
-- PostgreSQL's system catalogs make this very easy! I suspect that something like
-- this happens in spatialite too. Haven't checked the source code to know conclusively though.
--
-- 2022.03.16
--
--
-- \pset format unaligned
-- \COPY (
with cols(tblname, colname, colnum) as (
  select attrelid::regclass,attname,attnum from pg_attribute att join pg_class c on c.oid = att.attrelid
  where
    c.relkind='r' and att.attnum > 0
    and c.relnamespace::regnamespace::text not like all(array['pg_%','information_schema%'])
)
select 'SELECT ' || string_agg(quote_ident(colname), ', ' order by colnum) || ' FROM ' || tblname::regclass::text || ' LIMIT 15;' as sql
from cols
group by tblname
order by tblname
-- ) TO 'select-statements-for-all-tables.sql'
-- \pset format aligned
;
