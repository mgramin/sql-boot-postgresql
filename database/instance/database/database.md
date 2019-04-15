# database-wide statistics

https://www.postgresql.org/docs/current/static/monitoring-stats.html

### database

````sql
select datname as "@database"
     , datid          /* OID of a database */
     , datname        /* Name of this database */
     , numbackends    /* Number of backends currently connected to this database. This is the only column in this view that returns a value reflecting current state; all other columns return the accumulated values since the last reset. */
     , xact_commit    /* Number of transactions in this database that have been committed */
     , xact_rollback  /* Number of transactions in this database that have been rolled back */
     , blks_read      /* Number of disk blocks read in this database */
     , blks_hit       /* Number of times disk blocks were found already in the buffer cache, so that a read was not necessary (this only includes hits in the PostgreSQL buffer cache, not the operating system's file system cache) */
     , tup_returned   /* Number of rows returned by queries in this database */
     , tup_fetched    /* Number of rows fetched by queries in this database */
     , tup_inserted   /* Number of rows inserted by queries in this database */
     , tup_updated    /* Number of rows updated by queries in this database */
     , tup_deleted    /* Number of rows deleted by queries in this database */
     , conflicts      /* Number of queries canceled due to conflicts with recovery in this database. (Conflicts occur only on standby servers; see pg_stat_database_conflicts for details.) */
     , temp_files     /* Number of temporary files created by queries in this database. All temporary files are counted, regardless of why the temporary file was created (e.g., sorting or hashing), and regardless of the log_temp_files setting. */
     , temp_bytes     /* Total amount of data written to temporary files by queries in this database. All temporary files are counted, regardless of why the temporary file was created, and regardless of the log_temp_files setting. */
     , deadlocks      /* Number of deadlocks detected in this database */
     , blk_read_time  /* Time spent reading data file blocks by backends in this database, in milliseconds */
     , blk_write_time /* Time spent writing data file blocks by backends in this database, in milliseconds */
     , stats_reset    /* Time at which these statistics were last reset */
  from pg_stat_database
````


#### stat
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
