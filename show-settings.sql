-- \x on
select name, setting, unit, category, (reset_val = setting) is_default from pg_settings order by name, category;
