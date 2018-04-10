# Table

https://www.postgresql.org/docs/current/static/infoschema-tables.html

### get_all_tables
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
   and lower(t.table_schema) like lower('${uri.path(0)}')
   and lower(t.table_name) like lower('${uri.path(1)}')
````



```sql
select distinct tc.table_name || ' -> ' || ccu.table_name
  from information_schema.table_constraints as tc
  join information_schema.key_column_usage as kcu on tc.constraint_name = kcu.constraint_name
  join information_schema.constraint_column_usage as ccu on ccu.constraint_name = tc.constraint_name
 where tc.constraint_type = 'FOREIGN KEY'
   and tc.constraint_schema ~ 'public'
   and tc.table_name ~ '.*'
```
