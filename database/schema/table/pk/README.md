# Primary key

https://www.postgresql.org/docs/current/static/view-pg-indexes.html

````sql
select c.constraint_schema   as "@schema"
     , c.table_name          as "@table"
     , c.constraint_name     as "@pk"
     , c.constraint_catalog
     , c.constraint_schema
     , c.constraint_name
     , c.table_catalog
     , c.table_schema
     , c.table_name
     , c.constraint_type
     , c.is_deferrable
     , c.initially_deferred
  from information_schema.table_constraints c
 where constraint_type  = 'PRIMARY KEY'
   and lower(c.constraint_schema) like lower('${uri.path(0)}')
   and lower(c.table_name) like lower('${uri.path(1)}')
   and lower(c.constraint_name) like lower('${uri.path(2)}')
````
