-- Neat idea based on https://wiki.postgresql.org/wiki/Date_and_Time_dimensions
--
-- For PostgreSQL

select
  datum::date as date
 ,extract(year from datum) as year
 ,extract(month from datum) as month
 ,to_char(datum,'TMMonth') as MonthName
 ,extract(day from datum) as Day
 ,extract(doy from datum) as DayOfYear
 ,to_char(datum,'TMDay') as WeekdayName
 ,extract(week from datum) as CalendarWeek
 ,to_char(datum,'yyyy.mm.dd') as FormattedDate
 ,'Q'||to_char(datum,'Q') as Quarter
 ,to_char(datum,'yyyy/"Q"Q') as YearQuarter
 ,to_char(datum,'yyyy/mm') as YearMonth
 ,to_char(datum,'iyyy/IW') as ISOYearCalendarWeek
 ,case when extract(isodow from datum) in (6,7) then 'Weekend' else 'Weekday' end as Weekend
 -- ISO start and end of the week of this date! -- VERY USEFUL!
 ,datum::date + (1 - extract(isodow from datum))::integer as CWStart
 ,datum::date + (7 - extract(isodow from datum))::integer as CWEnd
 ,datum::date + (1 - extract(day from datum))::integer as MonthStart
 ,(datum::date + (1 - extract(day from datum))::integer + '1 month'::interval - interval '1 day')::date as MonthEnd
from generate_series('2010-01-01'::date,'2019-12-31'::date,interval '1 day') as df(datum)
order by datum
;


-- This is for time dimension...
-- select to_char(minute, 'hh24:mi') AS TimeOfDay,
-- 	-- Hour of the day (0 - 23)
-- 	extract(hour from minute) as Hour,
-- 	-- Extract and format quarter hours
-- 	to_char(minute - (extract(minute from minute)::integer % 15 || 'minutes')::interval, 'hh24:mi') ||
-- 	' – ' ||
-- 	to_char(minute - (extract(minute from minute)::integer % 15 || 'minutes')::interval + '14 minutes'::interval, 'hh24:mi')
-- 		as QuarterHour,
-- 	-- Minute of the day (0 - 1439)
-- 	extract(hour from minute)*60 + extract(minute from minute) as minute,
-- 	-- Names of day periods
-- 	case when to_char(minute, 'hh24:mi') between '06:00' and '08:29'
-- 		then 'Morning'
-- 	     when to_char(minute, 'hh24:mi') between '08:30' and '11:59'
-- 		then 'AM'
-- 	     when to_char(minute, 'hh24:mi') between '12:00' and '17:59'
-- 		then 'PM'
-- 	     when to_char(minute, 'hh24:mi') between '18:00' and '22:29'
-- 		then 'Evening'
-- 	     else 'Night'
-- 	end as DaytimeName,
-- 	-- Indicator of day or night
-- 	case when to_char(minute, 'hh24:mi') between '07:00' and '19:59' then 'Day'
-- 	     else 'Night'
-- 	end AS DayNight
-- from (SELECT '0:00'::time + (sequence.minute || ' minutes')::interval AS minute
-- 	FROM generate_series(0,1439) AS sequence(minute)
-- 	GROUP BY sequence.minute
--      ) DQ
-- order by 1
