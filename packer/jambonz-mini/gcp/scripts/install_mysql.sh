#!/bin/bash
DB_USER=$1
DB_PASS=$2

sudo apt install -y dirmngr
sudo apt-key add - < /tmp/mysql-server.key
echo "deb http://repo.mysql.com/apt/debian $(lsb_release -sc) mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql80.list
sudo apt update
sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password JambonzR0ck\$"
sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password JambonzR0ck\$"
sudo debconf-set-selections <<< "mysql-community-server mysql-server/default-auth-override select Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)"
sudo DEBIAN_FRONTEND=noninteractive apt install -y default-mysql-server
#cd /etc/systemd/system
#rm mysql.service 
#sudo systemctl enable mysql
echo "starting mysql"
sudo systemctl start mysql
echo "creating database"

# create the database and the user
mysql -h localhost -u root -pJambonzR0ck\$ << END
create database jambones;
SET old_passwords=0;
create user $DB_USER@'%' IDENTIFIED BY '$DB_PASS';
grant all on jambones.* to $DB_USER@'%' with grant option;
grant create user on *.* to $DB_USER@'%' with grant option;
flush privileges;
END

# create the schema
echo "creating schema"
mysql -h localhost -u $DB_USER -p$DB_PASS -D jambones < /home/admin/apps/jambonz-api-server/db/jambones-sql.sql
echo "seeding initial data"
mysql -h localhost -u $DB_USER -p$DB_PASS -D jambones < /home/admin/apps/jambonz-api-server/db/seed-production-database-open-source.sql

