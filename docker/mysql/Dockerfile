FROM mysql:5.7
ADD create_db.sql /docker-entrypoint-initdb.d/create_db.sql
RUN chmod -R 775 /docker-entrypoint-initdb.d