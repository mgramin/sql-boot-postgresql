# Table

https://www.postgresql.org/docs/current/static/infoschema-tables.html

````sql
select t.table_schema   as "@schema"
     , t.table_name     as "@table"
     , t.table_catalog                  /* Name of the database that contains the table (always the current database) */
     , t.table_schema                   /* Name of the schema that contains the table */
     , t.table_name                     /* Name of the table */
     , t.table_type                     /* Type of the table: BASE TABLE for a persistent base table (the normal table type), VIEW for a view, FOREIGN TABLE for a foreign table, or LOCAL TEMPORARY for a temporary table */
     -- , t.self_referencing_column_name   /* Applies to a feature not available in PostgreSQL */
     -- , t.reference_generation           /* Applies to a feature not available in PostgreSQL */
     , t.user_defined_type_catalog      /* If the table is a typed table, the name of the database that contains the underlying data type (always the current database), else null. */
     , t.user_defined_type_schema       /* If the table is a typed table, the name of the schema that contains the underlying data type, else null. */
     , t.user_defined_type_name         /* If the table is a typed table, the name of the underlying data type, else null. */
     , t.is_insertable_into             /* YES if the table is insertable into, NO if not (Base tables are always insertable into, views not necessarily.) */
     , t.is_typed                       /* YES if the table is a typed table, NO if not */
     -- , t.commit_action                  /* Not yet implemented */
  from information_schema.tables t
 where t.table_type='BASE TABLE'
````


#### depends
````sql
select distinct  tc.table_schema    as "@schema"        /* Schema */
     , ccu.table_name               as "@table"         /* Table */
     , tc.table_name                as "child_table"    /* Child table name */
  from information_schema.table_constraints as tc
  join information_schema.key_column_usage as kcu
       on tc.constraint_name = kcu.constraint_name
  join information_schema.constraint_column_usage as ccu
       on ccu.constraint_name = tc.constraint_name
 where tc.constraint_type = 'FOREIGN KEY'
   and tc.constraint_schema ~ 'public'
   and tc.table_name ~ '.*'
````


#### size
````sql
select schema_name  as "@schema"        /* Schema name */
     , table_name   as "@table"         /* Table name */
     , rows         as "rows"           /* Rows */
     , total_size   as "total_size"     /* Total size */
     , table_size   as "table_size"     /* Table size */
     , indexes_size as "indexes_size"   /* Index(es) size */
     , toast_size   as "toast_size"     /* TOAST size */
     , row_estimate as "row_estimate"   /* Row estimate */
     , total_bytes  as "total_bytes"    /* Total bytes */
     , table_bytes  as "table_bytes"    /* Table bytes */
     , index_bytes  as "index_bytes"    /* Index bytes */
     , toast_bytes  as "toast_bytes"    /* Toast bytes */
     , tblspace     as "tblspace"       /* Tablespace name */
     , oid          as "oid"            /* Oid */
  from (select row_estimate
             , total_bytes
             , table_bytes
             , index_bytes
             , toast_bytes
             , schema_name
             , table_name
             , tblspace
             , oid
             , pg_size_pretty(total_bytes) || ' (' || round(
                100 * total_bytes::numeric / nullif(sum(total_bytes) over (partition by (schema_name is null), left(table_name, 3) = '***'), 0),
                2)::text || '%)' as "total_size"
             , pg_size_pretty(table_bytes) || ' (' || round(
                100 * table_bytes::numeric / nullif(sum(table_bytes) over (partition by (schema_name is null), left(table_name, 3) = '***'), 0),
                2)::text || '%)' as "table_size"
             , pg_size_pretty(index_bytes) || ' (' || round(
                100 * index_bytes::numeric / nullif(sum(index_bytes) over (partition by (schema_name is null), left(table_name, 3) = '***'), 0),
                2)::text || '%)' as "indexes_size"
             , pg_size_pretty(toast_bytes) || ' (' || round(
                100 * toast_bytes::numeric / nullif(sum(toast_bytes) over (partition by (schema_name is null), left(table_name, 3) = '***'), 0),
                2)::text || '%)' as "toast_size"
             , '~' || case
                        when row_estimate > 10^12 then round(row_estimate::numeric / 10^12::numeric, 0)::text || 'T'
                        when row_estimate > 10^9 then round(row_estimate::numeric / 10^9::numeric, 0)::text || 'B'
                        when row_estimate > 10^6 then round(row_estimate::numeric / 10^6::numeric, 0)::text || 'M'
                        when row_estimate > 10^3 then round(row_estimate::numeric / 10^3::numeric, 0)::text || 'k'
                        else row_estimate::text
                      end as "rows"
          from (select *
                  from (select c.oid
                             , (select spcname from pg_tablespace where oid = reltablespace) as tblspace
                             , nspname as schema_name
                             , relname as table_name
                             , c.reltuples as row_estimate
                             , pg_total_relation_size(c.oid) as total_bytes
                             , pg_indexes_size(c.oid) as index_bytes
                             , pg_total_relation_size(reltoastrelid) as toast_bytes
                             , pg_total_relation_size(c.oid) - pg_indexes_size(c.oid) - coalesce(pg_total_relation_size(reltoastrelid), 0) as table_bytes
                          from pg_class c
                          left join pg_namespace n on n.oid = c.relnamespace
                         where relkind = 'r'
                           and nspname <> 'pg_catalog') data) test2
         where table_name is not null
         order by oid is null desc
             , total_bytes desc nulls last) main
````


#### no_stat
````sql
select table_schema as "@schema"
     , table_name as "@table"
     , is_empty as "is_empty"
     , never_analyzed as "never_analyzed"
  from (
SELECT table_schema
     , table_name
     , case when pg_class.relpages = 0 then 1 else 0 end AS is_empty
     , case when ( psut.relname IS NULL OR ( psut.last_analyze IS NULL and psut.last_autoanalyze IS NULL ) ) then 1 else 0 end AS never_analyzed
FROM information_schema.columns
    JOIN pg_class ON columns.table_name = pg_class.relname
        AND pg_class.relkind = 'r'
    JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
        AND nspname = table_schema
    LEFT OUTER JOIN pg_stats
    ON table_schema = pg_stats.schemaname
        AND table_name = pg_stats.tablename
        AND column_name = pg_stats.attname
    LEFT OUTER JOIN pg_stat_user_tables AS psut
        ON table_schema = psut.schemaname
        AND table_name = psut.relname
WHERE pg_stats.attname IS NULL
    AND table_schema NOT IN ('pg_catalog', 'information_schema')
GROUP BY table_schema, table_name, relpages, psut.relname, last_analyze, last_autoanalyze) base
````
