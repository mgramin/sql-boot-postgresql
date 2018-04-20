# Table Column

https://www.postgresql.org/docs/current/static/infoschema-columns.html

### get_all_columns
````sql
select c.table_schema     as "@schema"
     , c.table_name       as "@table"
     , c.column_name      as "@column"
     , c.table_catalog                  /* Name of the database containing the table (always the current database) */
     , c.table_schema                   /* Name of the schema containing the table */
     , c.table_name                     /* Name of the table */
     , c.column_name                    /* Name of the column */
     , c.ordinal_position               /* Ordinal position of the column within the table (count starts at 1) */
     , c.column_default                 /* Default expression of the column */
     , c.is_nullable                    /* YES if the column is possibly nullable, NO if it is known not nullable. A not-null constraint is one way a column can be known not nullable, but there can be others. */
     , c.data_type                      /* Data type of the column, if it is a built-in type, or ARRAY if it is some array (in that case, see the view element_types), else USER-DEFINED (in that case, the type is identified in udt_name and associated columns). If the column is based on a domain, this column refers to the type underlying the domain (and the domain is identified in domain_name and associated columns). */
     , c.character_maximum_length       /* If data_type identifies a character or bit string type, the declared maximum length; null for all other data types or if no maximum length was declared. */
     , c.character_octet_length         /* If data_type identifies a character type, the maximum possible length in octets (bytes) of a datum; null for all other data types. The maximum octet length depends on the declared character maximum length (see above) and the server encoding. */
     , c.numeric_precision              /* If data_type identifies a numeric type, this column contains the (declared or implicit) precision of the type for this column. The precision indicates the number of significant digits. It can be expressed in decimal (base 10) or binary (base 2) terms, as specified in the column numeric_precision_radix. For all other data types, this column is null. */
     , c.numeric_precision_radix        /* If data_type identifies a numeric type, this column indicates in which base the values in the columns numeric_precision and numeric_scale are expressed. The value is either 2 or 10. For all other data types, this column is null. */
     , c.numeric_scale                  /* If data_type identifies an exact numeric type, this column contains the (declared or implicit) scale of the type for this column. The scale indicates the number of significant digits to the right of the decimal point. It can be expressed in decimal (base 10) or binary (base 2) terms, as specified in the column numeric_precision_radix. For all other data types, this column is null. */
     , c.datetime_precision             /* If data_type identifies a date, time, timestamp, or interval type, this column contains the (declared or implicit) fractional seconds precision of the type for this column, that is, the number of decimal digits maintained following the decimal point in the seconds value. For all other data types, this column is null. */
     , c.interval_type                  /* If data_type identifies an interval type, this column contains the specification which fields the intervals include for this column, e.g., YEAR TO MONTH, DAY TO SECOND, etc. If no field restrictions were specified (that is, the interval accepts all fields), and for all other data types, this field is null. */
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
   and lower(c.table_schema) like lower('${uri.path(0)}')
   and lower(c.table_name) like lower('${uri.path(1)}')
   and lower(c.column_name) like lower('${uri.path(2)}')
 order by c.ordinal_position asc
````
