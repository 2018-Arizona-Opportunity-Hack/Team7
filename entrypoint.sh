chown shiny /srv/shiny-server/
export MYSQL_ROOT_PASSWORD=$(dbus-uuidgen)
service mysql start
sed "s/passPlaceholder/$(echo $MYSQL_ROOT_PASSWORD)/" /survey-stack.sql > /survey-stack-gen.sql
mysql -e 'source /survey-stack-gen.sql'
service mysql restart
rm /survey-stack.sql /survey-stack-gen.sql
shiny-server
