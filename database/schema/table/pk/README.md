````sql
select constraint_name as "pk"
  from information_schema.table_constraints
 where constraint_type  = 'PRIMARY KEY'
   and table_schema like '$schema'
   and table_name like '$table'
   and constraint_name like '$pk'
````
