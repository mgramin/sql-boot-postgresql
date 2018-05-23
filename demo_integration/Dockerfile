FROM mgramin/sql-boot
ADD . conf/postgresql
ADD application.yml application.yml
RUN curl https://jdbc.postgresql.org/download/postgresql-42.1.1.jar -o postgresql-jdbc.jar
