# Table Column

https://www.postgresql.org/docs/current/static/infoschema-columns.html

````sql
select c.table_schema     as "schema"
     , c.table_name       as "table"
     , c.column_name      as "column"
     , c.table_catalog
     , c.table_schema
     , c.table_name
     , c.column_name
     , c.ordinal_position
     , c.column_default
     , c.is_nullable
     , c.data_type
     , c.character_maximum_length
     , c.character_octet_length
     , c.numeric_precision
     , c.numeric_precision_radix
     , c.numeric_scale
     , c.datetime_precision
     , c.interval_type
     , c.interval_precision
     , c.character_set_catalog
     , c.character_set_schema
     , c.character_set_name
     , c.collation_catalog
     , c.collation_schema
     , c.collation_name
     , c.domain_catalog
     , c.domain_schema
     , c.domain_name
     , c.udt_catalog
     , c.udt_schema
     , c.udt_name
     , c.scope_catalog
     , c.scope_schema
     , c.scope_name
     , c.maximum_cardinality
     , c.dtd_identifier
     , c.is_self_referencing
     , c.is_identity
     , c.identity_generation
     , c.identity_start
     , c.identity_increment
     , c.identity_maximum
     , c.identity_minimum
     , c.identity_cycle
     , c.is_generated
     , c.is_updatable
  from information_schema.columns c
     , information_schema.tables t
 where t.table_schema = c.table_schema
   and t.table_name = c.table_name
   and t.table_type='BASE TABLE'
   and lower(c.table_schema) like '$schema'
   and lower(c.table_name) like '$table'
   and lower(c.column_name) like '$column'
 order by c.ordinal_position asc
````
