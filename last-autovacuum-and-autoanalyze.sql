select
  c.relname,ns.nspname,
  pg_size_pretty(pg_total_relation_size(quote_ident(ns.nspname)||'.'||quote_ident(c.relname))) total_relation_size,
  pg_size_pretty(pg_relation_size(quote_ident(ns.nspname::regnamespace::text)||'.'||quote_ident(c.relname))) relation_size,
  pg_stat_all_tables.last_autovacuum,pg_stat_all_tables.last_autoanalyze
from pg_class c
  join pg_namespace ns on c.relnamespace  = ns.oid
  join pg_stat_all_tables on (c.relname = pg_stat_all_tables.relname and ns.nspname = pg_stat_all_tables.schemaname)
where ns.nspname not in ('pg_toast') and has_schema_privilege(ns.nspname,'USAGE')
order by last_autoanalyze desc;
