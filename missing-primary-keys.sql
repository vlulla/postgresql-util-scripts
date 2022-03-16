--
-- https://github.com/pgexperts/pgx_scripts/blob/master/columns/missing_PKs
--
select table_catalog,table_schema,table_name 
from information_schema.tables 
where 
  (table_catalog,table_schema,table_name) not in (select table_catalog,table_schema,table_name from information_schema.table_constraints where constraint_type = 'PRIMARY KEY') 
  and table_schema not in ('pg_catalog','information_schema') 
  and table_type <> 'VIEW';
