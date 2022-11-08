-- Run \i 'olap-settings.sql' in your psql session to see some settings that can help with analytical (olap type) queries.

with recommendations(name, recommended, reason) as (values
    ('quote_all_identifiers', 'on', ' Postgresql correclty quotes identifiers with special chars...but it is a good habit to quote identifiers'),
    ('enable_seqscan', 'off', ' questionable!!'),
    ('statement_timeout', '0', ' disable statement_timeout! some queries might take longer than 3 * 60 * 1000 milliseconds!'),
    ('effective_cache_size', '''4GB''', ' high value prefers index scan over seq scan'),
    ('work_mem', '''320MB''', ' Memory used by *each* of the ORDER BY, DISTINCT, JOIN, hash table operations. Start with 0.02 * RAM ...'),
    ('maintenance_work_mem', '''512MB''', ' used for vacuum, and create index! Can be set to as high as 0.15 * RAM. Set in session before vacuum/create index!'),
    ('max_parallel_workers_per_gather', '4', ' 0.25 * #CPU'),
    ('max_parallel_workers', '8', ' 1.0 * #CPU')
),
settings(name, currsetting, unit) as (
  select name, setting, unit from pg_settings where name in (select name from recommendations)
)
select * from settings s join recommendations r using(name);
