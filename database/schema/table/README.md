````sql
select t.table_schema   as "@schema"
     , t.table_name     as "@table"
     , t.table_schema
     , t.table_name
     , t.table_catalog
     , t.table_type
     , t.self_referencing_column_name
     , t.reference_generation
     , t.user_defined_type_catalog
     , t.user_defined_type_schema
     , t.user_defined_type_name
     , t.is_insertable_into
     , t.is_typed
  from information_schema.tables t
 where t.table_type='BASE TABLE'
   and lower(t.table_schema) like '$schema'
   and lower(t.table_name) like '$table'
````
