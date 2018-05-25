# Server process

https://www.postgresql.org/docs/current/static/monitoring-stats.html

### all_server_process

````sql
select datname  as "@database"
     , pid      as "@pid"
     , datid              /* OID of the database this backend is connected to */
     , datname            /* Name of the database this backend is connected to */
     , pid                /* Process ID of this backend */
     , usesysid           /* OID of the user logged into this backend */
     , usename            /* Name of the user logged into this backend */
     , application_name   /* Name of the application that is connected to this backend */
     , client_addr        /* IP address of the client connected to this backend. If this field is null, it indicates either that the client is connected via a Unix socket on the server machine or that this is an internal process such as autovacuum. */
     , client_hostname    /* Host name of the connected client, as reported by a reverse DNS lookup of client_addr. This field will only be non-null for IP connections, and only when log_hostname is enabled. */
     , client_port        /* TCP port number that the client is using for communication with this backend, or -1 if a Unix socket is used */
     , backend_start      /* Time when this process was started. For client backends, this is the time the client connected to the server. */
     , xact_start         /* Time when this process' current transaction was started, or null if no transaction is active. If the current query is the first of its transaction, this column is equal to the query_start column. */
     , query_start        /* Time when the currently active query was started, or if state is not active, when the last query was started */
     , state_change       /* Time when the state was last changed */
     , wait_event_type    /* he type of event for which the backend is waiting, if any */
     , wait_event         /* Wait event name if backend is currently waiting, otherwise NULL. See Table 28.4 for details. */
     , state              /* Current overall state of this backend. */
     , backend_xid        /* Top-level transaction identifier of this backend, if any. */
     , backend_xmin       /* The current backend's xmin horizon. */
     , query              /* Text of this backend's most recent query. If state is active this field shows the currently executing query. In all other states, it shows the last query that was executed. By default the query text is truncated at 1024 characters; this value can be changed via the parameter track_activity_query_size. */
  from pg_stat_activity
````
