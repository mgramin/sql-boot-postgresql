# Table

https://www.postgresql.org/docs/current/static/infoschema-tables.html

### get_all_tables

````sql
select t.table_schema   as "@schema"
     , t.table_name     as "@table"
     , t.table_catalog                    /* Name of the database that contains the table (always the current database) */
     , t.table_schema                     /* Name of the schema that contains the table */
     , t.table_name                       /* Name of the table */
     , t.table_type                       /* Type of the table: BASE TABLE for a persistent base table (the normal table type), VIEW for a view, FOREIGN TABLE for a foreign table, or LOCAL TEMPORARY for a temporary table */
     -- , t.self_referencing_column_name  /* Applies to a feature not available in PostgreSQL */
     -- , t.reference_generation          /* Applies to a feature not available in PostgreSQL */
     , t.user_defined_type_catalog        /* If the table is a typed table, the name of the database that contains the underlying data type (always the current database), else null. */
     , t.user_defined_type_schema         /* If the table is a typed table, the name of the schema that contains the underlying data type, else null. */
     , t.user_defined_type_name           /* If the table is a typed table, the name of the underlying data type, else null. */
     , t.is_insertable_into               /* YES if the table is insertable into, NO if not (Base tables are always insertable into, views not necessarily.) */
     , t.is_typed                         /* YES if the table is a typed table, NO if not */
     -- , t.commit_action                 /* Not yet implemented */
  from information_schema.tables t
 where t.table_type='BASE TABLE'
   and lower(t.table_schema) like lower('${uri.path(0)}')
   and lower(t.table_name) like lower('${uri.path(1)}')
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
   --and tc.constraint_schema ~ 'public'
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

#### bloat
````sql
select schema_name          as "@schema_name"
     , table_name           as "@table_name"
     , "Extra"              as "extra"
     , "Bloat"              as "bloat"
     , "Live"               as "live"
     , "Last Vaccuum"       as "last_vacuum"
     , fillfactor           as "fillfactor"
     , real_size_raw        as "real_size_raw"
     , extra_size_raw       as "extra_size_raw"
     , bloat_size_raw       as "bloat_size_raw"
     , live_data_size_raw   as "live_data_size_raw"
  from (
with step1 as (
  select
    tbl.oid tblid,
    ns.nspname as schema_name,
    tbl.relname as table_name,
    tbl.reltuples,
    tbl.relpages as heappages,
    coalesce(toast.relpages, 0) as toastpages,
    coalesce(toast.reltuples, 0) as toasttuples,
    coalesce(substring(array_to_string(tbl.reloptions, ' ') from '%fillfactor=#"__#"%' for '#')::int2, 100) as fillfactor,
    current_setting('block_size')::numeric as bs,
    case when version() ~ 'mingw32|64-bit|x86_64|ppc64|ia64|amd64' then 8 else 4 end as ma, -- NS: TODO: check it
    24 as page_hdr,
    23 + case when max(coalesce(null_frac, 0)) > 0 then (7 + count(*)) / 8 else 0::int end
      + case when tbl.relhasoids then 4 else 0 end as tpl_hdr_size,
    sum((1 - coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 1024)) as tpl_data_size,
    bool_or(att.atttypid = 'pg_catalog.name'::regtype) or count(att.attname) <> count(s.attname) as is_na
  from pg_attribute as att
  join pg_class as tbl on att.attrelid = tbl.oid and tbl.relkind = 'r'
  join pg_namespace as ns on ns.oid = tbl.relnamespace
  join pg_stats as s on s.schemaname = ns.nspname and s.tablename = tbl.relname and not s.inherited and s.attname = att.attname
  left join pg_class as toast on tbl.reltoastrelid = toast.oid
  where att.attnum > 0 and not att.attisdropped and s.schemaname not in ('pg_catalog', 'information_schema')
  group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, tbl.relhasoids
  order by 2, 3
), step2 as (
  select
    *,
    (
      4 + tpl_hdr_size + tpl_data_size + (2 * ma)
      - case when tpl_hdr_size % ma = 0 then ma else tpl_hdr_size % ma end
      - case when ceil(tpl_data_size)::int % ma = 0 then ma else ceil(tpl_data_size)::int % ma end
    ) as tpl_size,
    bs - page_hdr as size_per_block,
    (heappages + toastpages) as tblpages
  from step1
), step3 as (
  select
    *,
    ceil(reltuples / ((bs - page_hdr) / tpl_size)) + ceil(toasttuples / 4) as est_tblpages,
    ceil(reltuples / ((bs - page_hdr) * fillfactor / (tpl_size * 100))) + ceil(toasttuples / 4) as est_tblpages_ff
    -- , stattuple.pgstattuple(tblid) as pst
  from step2
), step4 as (
  select
    *,
    tblpages * bs as real_size,
    (tblpages - est_tblpages) * bs as extra_size,
    case when tblpages - est_tblpages > 0 then 100 * (tblpages - est_tblpages) / tblpages::float else 0 end as extra_ratio,
    (tblpages - est_tblpages_ff) * bs as bloat_size,
    case when tblpages - est_tblpages_ff > 0 then 100 * (tblpages - est_tblpages_ff) / tblpages::float else 0 end as bloat_ratio
    -- , (pst).free_percent + (pst).dead_tuple_percent as real_frag
  from step3
  left join pg_stat_user_tables su on su.relid = tblid
  -- WHERE NOT is_na
  --   AND tblpages*((pst).free_percent + (pst).dead_tuple_percent)::float4/100 >= 1
)
select
  schema_name, table_name,
  case is_na when true then 'TRUE' else '' end as "Is N/A",
  pg_size_pretty(real_size::numeric) as "Size",
  '~' || pg_size_pretty(extra_size::numeric)::text || ' (' || round(extra_ratio::numeric, 2)::text || '%)' as "Extra",
  '~' || pg_size_pretty(bloat_size::numeric)::text || ' (' || round(bloat_ratio::numeric, 2)::text || '%)' as "Bloat",
  '~' || pg_size_pretty((real_size - bloat_size)::numeric) as "Live",
  greatest(last_autovacuum, last_vacuum)::timestamp(0)::text
    || case greatest(last_autovacuum, last_vacuum)
      when last_autovacuum then ' (auto)'
    else '' end as "Last Vaccuum"
  ,
  fillfactor,
  real_size as real_size_raw,
  extra_size as extra_size_raw,
  bloat_size as bloat_size_raw,
  real_size - bloat_size as live_data_size_raw
from step4
order by real_size desc nulls last) main
````
