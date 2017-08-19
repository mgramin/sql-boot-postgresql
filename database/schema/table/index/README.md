# Index

https://www.postgresql.org/docs/9.6/static/view-pg-indexes.html

````sql
select i.schemaname   as "@schema"
     , i.tablename    as "@table"
     , i.indexname    as "@index"
     , i.schemaname
     , i.tablename
     , i.indexname
     , i.tablespace
     , i.indexdef
  from pg_catalog.pg_indexes i
-- where i.schemaname like '$schema'
--   and i.tablename like '$table'
--   and i.indexname like '$index'
````
