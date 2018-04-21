# database-wide statistics

https://www.postgresql.org/docs/current/static/monitoring-stats.html

### database_stat

````sql
select datid          as "@dataid"  /* OID of a database */
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
