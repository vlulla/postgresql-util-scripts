--
-- https://github.com/pgexperts/pgx_scripts/blob/master/bloat/index_bloat_check.sql
--
with
  btree_index_atts as (select nspname, indexclass.relname as index_name, indexclass.reltuples, indexclass.relpages, indrelid,
    indexrelid, indexclass.relam, tableclass.relname as tablename, regexp_split_to_table(indkey::text, ' ')::smallint as attnum,
    indexrelid as index_oid
    from pg_index
      join pg_class as indexclass on pg_index.indexrelid = indexclass.oid
      join pg_class as tableclass on pg_index.indrelid = tableclass.oid
      join pg_namespace on pg_namespace.oid = indexclass.relnamespace
      join pg_am on indexclass.relam = pg_am.oid
    where pg_am.amname = 'btree' and indexclass.relpages > 0 and nspname not in ('pg_catalog', 'information_schema')),


  index_item_sizes as (select ind_atts.nspname, ind_atts.index_name, ind_atts.reltuples, ind_atts.relpages, ind_atts.relam,
    indrelid as table_oid, index_oid, current_setting('block_size')::numeric as bs, 8 as maxalign, 24 as pagehdr,
    case when max(coalesce(pg_stats.null_frac, 0))=0 then 2 else 6 end as index_tuple_hdr,
    sum((1-coalesce(pg_stats.null_frac, 0))*coalesce(pg_stats.avg_width, 1024)) as nulldatawidth
    from pg_attribute
      join btree_index_atts as ind_atts on pg_attribute.attrelid = ind_atts.indexrelid and pg_attribute.attnum = ind_atts.attnum
      join pg_stats on pg_stats.schemaname = ind_atts.nspname and
         ((pg_stats.tablename = ind_atts.tablename and pg_stats.attname = pg_catalog.pg_get_indexdef(pg_attribute.attrelid, pg_attribute.attnum, TRUE))
          or (pg_stats.tablename = ind_atts.index_name and pg_stats.attname = pg_attribute.attname))
    where pg_attribute.attnum > 0 group by 1, 2, 3, 4, 5, 6, 7, 8, 9),


  index_aligned_est as (select maxalign, bs, nspname, index_name, reltuples, relpages, relam, table_oid, index_oid,
    coalesce(ceil(reltuples * (6 + maxalign - case when index_tuple_hdr % maxalign = 0 then maxalign else index_tuple_hdr % maxalign end +
          nulldatawidth + maxalign - case when nulldatawidth::integer % maxalign = 0 then maxalign else nulldatawidth::Integer % maxalign end)::numeric /
          (bs - pagehdr::numeric) + 1), 0) as expected
    from index_item_sizes),


  raw_bloat as (select current_database() as dbname, nspname, pg_class.relname as table_name, index_name,
      bs * (index_aligned_est.relpages)::bigint as totalbytes, expected,
      case when index_aligned_est.relpages <= expected then 0 else bs * (index_aligned_est.relpages - expected)::bigint end as wastedbytes,
      case when index_aligned_est.relpages <= expected then 0 else bs * (index_aligned_est.relpages - expected)::bigint * 100 / (bs * (index_aligned_est.relpages)::bigint) end as realbloat,
      pg_relation_size(index_aligned_est.table_oid) as table_bytes, stat.idx_scan as index_scans
    from index_aligned_est
      join pg_class on pg_class.oid = index_aligned_est.table_oid
      join pg_stat_user_indexes as stat on index_aligned_est.index_oid = stat.indexrelid),


  format_bloat as (select dbname as database_name, nspname as schema_name, table_name, index_name, round(realbloat) as bloat_pct,
      round(wastedbytes/(1024*1024)::numeric) as bloat_mb, round(totalbytes / (1024 * 1024)::numeric, 3) as index_mb,
      round(table_bytes/(1024*1024)::numeric, 3) as table_mb, index_scans from raw_bloat)

select * from format_bloat -- where (bloat_pct > 50 and bloat_mb > 10) order by bloat_pct desc
;
