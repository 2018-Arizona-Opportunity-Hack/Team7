FROM mysql
COPY survey-stack.sql /docker-entrypoint-initdb.d/
