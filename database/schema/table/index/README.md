# Index

https://www.postgresql.org/docs/9.6/static/view-pg-indexes.html

### all_indexes
````sql
select i.schemaname   as "@schema"
     , i.tablename    as "@table"
     , i.indexname    as "@index"
     , i.schemaname                 /* Name of schema containing table and index */
     , i.tablename                  /* Name of table the index is for */
     , i.indexname                  /* Name of index */
     , i.tablespace                 /* Name of tablespace containing index (null if default for database) */
     , i.indexdef                   /* Index definition (a reconstructed CREATE INDEX command) */
  from pg_catalog.pg_indexes i
 where lower(i.schemaname) like lower('${uri.path(0)}')
   and lower(i.tablename) like lower('${uri.path(1)}')
   and lower(i.indexname) like lower('${uri.path(2)}')
````


### unused_indexes

https://www.cybertec-postgresql.com/en/get-rid-of-your-unused-indexes/

````sql
select s.schemaname                   as "@schema"
     , s.relname                      as "@table"
     , s.indexrelname                 as "@index"
     , pg_relation_size(s.indexrelid) as index_size
  from pg_catalog.pg_stat_user_indexes s
  join pg_catalog.pg_index i on s.indexrelid = i.indexrelid
 where s.idx_scan = 0      -- has never been scanned
   and 0 <> all (i.indkey)  -- no index column is an expression
   and not exists          -- does not enforce a constraint
         (select 1
            from pg_catalog.pg_constraint c
           where c.conindid = s.indexrelid)
 order by pg_relation_size(s.indexrelid) desc
````
