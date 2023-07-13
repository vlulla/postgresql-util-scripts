with
  schemas(oid,_schema) as (select oid,nspname from pg_namespace where nspname not in ('pg_toast','pg_catalog','information_schema'))
, tables(_schema,_tbl,_fqtn,_rowestimate,_ncols) as (select s._schema,relname,quote_ident(s._schema)||'.'||quote_ident(relname::text),reltuples,relnatts from pg_class c join schemas s on c.relnamespace = s.oid where has_schema_privilege(relnamespace,'USAGE') and relkind='r')
select
  _schema schemaname, _tbl tablename, to_char(_rowestimate,'999G999G999G999') rowestimate,_ncols ncols, pg_size_pretty(pg_table_size(_fqtn)) tbl_size
 ,pg_size_pretty(pg_indexes_size(_fqtn)) index_size,pg_size_pretty(pg_total_relation_size(_fqtn)) total_relation_size
from tables
order by pg_total_relation_size(_fqtn) desc;

