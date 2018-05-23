# Primary key

https://www.postgresql.org/docs/current/static/infoschema-table-constraints.html

````sql
select c.constraint_schema   as "@schema"
     , c.table_name          as "@table"
     , c.constraint_name     as "@pk"
     , c.constraint_catalog               /* Name of the database that contains the constraint (always the current database) */
     , c.constraint_schema                /* Name of the schema that contains the constraint */
     , c.constraint_name                  /* Name of the constraint */
     , c.table_catalog                    /* Name of the database that contains the table (always the current database) */
     , c.table_schema                     /* Name of the schema that contains the table */
     , c.table_name                       /* Name of the table */
     --, c.constraint_type                  /* Type of the constraint: CHECK, FOREIGN KEY, PRIMARY KEY, or UNIQUE */
     , c.is_deferrable                    /* Type of the constraint: CHECK, FOREIGN KEY, PRIMARY KEY, or UNIQUE */
     , c.initially_deferred               /* YES if the constraint is deferrable and initially deferred, NO if not */
  from information_schema.table_constraints c
 where constraint_type  = 'PRIMARY KEY'
   and lower(c.constraint_schema) like lower('${uri.path(0)}')
   and lower(c.table_name) like lower('${uri.path(1)}')
   and lower(c.constraint_name) like lower('${uri.path(2)}')
````
