# database-wide statistics

````sql
select database as "@database"
     , _size as "size"              /* Size */
     , stats_age as "stats_age"     /* Stats Age */
     , cache_eff as "cache_eff"     /* Cache eff. */
     , committed as "committed"     /* Committed */
     , conflicts as "conflicts"     /* Conflicts */
     , deadlocks as "deadlocks"     /* Deadlocks */
     , temp_files as "temp_files"   /* Temp. Files */
  from ( select
  database_name || coalesce(' [' || nullif(tblspace, 'pg_default') || ']', '') as "database",
  case
    when has_access then
      pg_size_pretty(size) || ' (' || round(
        100 * size::numeric / nullif(sum(size) over (partition by (oid is null)), 0),
        2
      )::text || '%)'
    else 'no access'
  end as "_size",
  (now() - stats_reset)::interval(0)::text as "stats_age",
  case
    when blks_hit + blks_read > 0 then
      (round(blks_hit * 100::numeric / (blks_hit + blks_read), 2))::text || '%'
    else null
  end as "cache_eff",
  case
    when xact_commit + xact_rollback > 0 then
      (round(xact_commit * 100::numeric / (xact_commit + xact_rollback), 2))::text || '%'
    else null
  end as "committed",
  conflicts as "Conflicts",
  deadlocks as "Deadlocks",
  temp_files::text || coalesce(' (' || pg_size_pretty(temp_bytes) || ')', '') as "Temp. Files"
  ,*
from (
  select
    d.oid,
    (select spcname from pg_tablespace where oid = dattablespace) as tblspace,
    d.datname as database_name,
    pg_catalog.pg_get_userbyid(d.datdba) as owner,
    has_database_privilege(d.datname, 'connect') as has_access,
    pg_database_size(d.datname) as size,
    stats_reset,
    blks_hit,
    blks_read,
    xact_commit,
    xact_rollback,
    conflicts,
    deadlocks,
    temp_files,
    temp_bytes
  from pg_catalog.pg_database d
  join pg_stat_database s on s.datid = d.oid
) data
order by oid is null desc) main
````
