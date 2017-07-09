````sql
select c.table_schema     as "schema"
     , c.table_name       as "table"
     , c.column_name      as "column"
     , c.udt_name         as "@data_type"
     , case when c.udt_name like 'varchar%' then '('|| c.character_maximum_length ||')' end as "@length"
     , c.is_nullable      as "@is_nullable"
     , c.column_default   as "@column_default"
  from information_schema.columns c
      ,information_schema.tables t
 where t.table_schema = c.table_schema
   and t.table_name = c.table_name
   and t.table_type='BASE TABLE'
   and lower(c.table_schema) like '$schema'
   and lower(c.table_name) like '$table'
   and lower(c.column_name) like '$column'
 order by c.ordinal_position asc
````
