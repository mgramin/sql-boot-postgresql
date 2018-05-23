# sql-boot-demo

Clone this repo:

    git clone https://github.com/sql-boot/sql-boot-demo.git
    cd sql-boot-demo

Clone some db-configurations to "conf" folder:

    git clone https://github.com/sql-boot/sql-boot-oracle.git conf/sql-boot-oracle
    git clone https://github.com/sql-boot/sql-boot-postgresql.git conf/sql-boot-postgresql
    git clone https://github.com/sql-boot/sql-boot-cassandra.git conf/sql-boot-cassandra
    git clone https://github.com/sql-boot/sql-boot-clickhouse.git conf/sql-boot-clickhouse

Run docker-compose file:

    sudo docker-compose up -d

Waiting 10-20 seconds...

    sudo docker-compose logs -f

Get api description for Oracle db (in Swagger json format):

  [http://localhost:8007/api/oracle](http://localhost:8007/api/oracle)

Or in Swagger yaml format:

  [http://localhost:8007/api/oracle?format=yaml](http://localhost:8007/api/oracle?format=yaml)

Open this api description in Swagger Editor:

  [http://localhost:8888/?url=http://localhost:8007/api/oracle?format=yaml](http://localhost:8888/?url=http://localhost:8007/api/oracle?format=yaml)


#### Get some information from Oracle db.

get detailed information about tables in HR schema (including DDL script):

  [http://localhost:8007/api/oracle/table/hr](http://localhost:8007/api/oracle/table/hr)

get only table properties:

  [http://localhost:8007/api/oracle/headers/table/hr](http://localhost:8007/api/oracle/headers/table/hr)

get specific properties:

  [http://localhost:8007/api/oracle/headers/table/hr?select=table_name,avg_row_len](http://localhost:8007/api/oracle/headers/table/hr?select=table_name,avg_row_len)


get all indexes in HR schema:

  [http://localhost:8007/api/oracle/headers/index/hr](http://localhost:8007/api/oracle/headers/index/hr)

get all indexes for HR.employees table:

  [http://localhost:8007/api/oracle/headers/index/hr.employees](http://localhost:8007/api/oracle/headers/index/hr.employees)


Similar operations also available for other db objects (e.g. pk, fk, constraints, packages, functions, procedures, synonyms, tablespaces, extents, segments etc);

get all db processes:

  [http://localhost:8007/api/oracle/headers/process](http://localhost:8007/api/oracle/headers/process)

get process by id:

  [http://localhost:8007/api/oracle/headers/process.5](http://localhost:8007/api/oracle/headers/process.5)

get "pga_max_mem" for all processes:

  [http://localhost:8007/api/oracle/headers/process?select=pid,pga_max_mem](http://localhost:8007/api/oracle/headers/process?select=pid,pga_max_mem)


#### metrics visualization

Log in to Grafana (admin/admin):

  [http://localhost:3000](http://localhost:3000)

Install our datasource and dashboard:

    sh ./grafana-dashboard-setup.sh

Open dashboard "oracle_process":

  [http://localhost:3000/dashboard/db/oracle_process](http://localhost:3000/dashboard/db/oracle_process)
