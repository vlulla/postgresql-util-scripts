--
-- 2022.03.23
--
-- Running this query would be a *bad idea*...especially for big tables. Therefore, I just print the sql statements that could be helpful
-- in explorations. Just copy/paste the query and edit it to meet your needs!
--
with q(query) as (
  with nullqueries(query, tblname) as (
    select E'\tCOUNT(*) FILTER (WHERE ' || quote_ident(attname) || ' is null) AS ' || quote_ident(attname::text) || '_numnull', quote_ident(c.relnamespace::regnamespace::text) || '.' || quote_ident(c.relname::text)
    from pg_attribute join pg_class c on c.oid = attrelid and c.relkind = 'r' where attnum > 0 order by c.relname, attnum
  )
  -- select E'EXPLAIN SELECT\n' || string_agg(query, E', \n') || E'\nFROM ' || tblname || E';\n' from nullqueries
  select E'SELECT\n' || string_agg(query, E', \n') || E'\nFROM ' || tblname || E';\n' from nullqueries
  where tblname not SIMILAR TO '"?pg_%'
  group by tblname
) select query from q
;

-- \gexec
