-- Generate list of dates for each of the days.
--
-- This is how to use it:
--
-- bash $ <generate-current-year-calendar.sql psql mydb
-- bash $ <generate-current-year-calendar.sql psql -c '\pset format csv' -f - mydb
--
-- 2023.02.22
--

with y(yr) as (select extract(year from now())),
     days(dy) as (select generate_series((yr||'-01-01')::date,(yr||'-12-31')::date,interval 'P1D') from y)
select
  dy::date
  -- to_char(dy,'MON, DD') dy
  , (to_char(dy,'IYYY_IW')) iso_year_week,to_char(dy,'DY') d,to_char(dy,'ID') dow from days
\crosstabview iso_year_week d dy dow
-- ;
