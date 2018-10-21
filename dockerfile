FROM mysql
RUN export MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
