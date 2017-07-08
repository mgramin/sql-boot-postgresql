````sql
select i.schemaname as "schema"
     , i.tablename as "table"
     , i.indexname as "index"
  from pg_catalog.pg_indexes i
 where i.schemaname like '$schema'
   and i.tablename like '$table'
   and i.indexname like '$index'
````
