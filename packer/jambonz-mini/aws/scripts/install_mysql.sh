#!/bin/bash
DISTRO=$1
DB_USER=$2
DB_PASS=$3
RHEL_RELEASE=

if [[ "$DISTRO" == rhel* ]] ; then
  RHEL_RELEASE="${DISTRO:5}"
  HOME=/home/ec2-user
  cd /tmp
  wget https://repo.mysql.com//mysql80-community-release-el${RHEL_RELEASE}-1.noarch.rpm
  sudo dnf install -y mysql80-community-release-el${RHEL_RELEASE}-1.noarch.rpm
  if [ "$RHEL_RELEASE" == "8" ]; then
    sudo dnf install -y @mysql
    echo "starting mysql"
    sudo systemctl enable mysqld
    sudo systemctl start mysqld
    echo checking mysql status
    sudo systemctl status mysqld
    mysql -u root << EOL
ALTER USER 'root'@'localhost' IDENTIFIED BY 'JambonzR0ck$';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOL
else
    sudo dnf install -y mysql-community-server
    echo "starting mysql"
    sudo systemctl enable mysqld
    sudo systemctl start mysqld
    echo checking mysql status
    sudo systemctl status mysqld
    TEMP_PASS=$(sudo grep 'A temporary password is generated' /var/log/mysqld.log | tail -1 | awk '{print $NF}')
    echo "temporary password is $TEMP_PASS"
    mysql -u root -p"${TEMP_PASS}" --connect-expired-password << EOL
ALTER USER 'root'@'localhost' IDENTIFIED BY 'JambonzR0ck$';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOL
  fi
else
  HOME=/home/admin
  sudo apt install -y dirmngr
  sudo apt-key add - < /tmp/mysql-server.key
  echo "deb http://repo.mysql.com/apt/debian $(lsb_release -sc) mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql80.list
  sudo apt update
  sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password JambonzR0ck\$"
  sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password JambonzR0ck\$"
  sudo debconf-set-selections <<< "mysql-community-server mysql-server/default-auth-override select Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)"
  sudo DEBIAN_FRONTEND=noninteractive apt install -y default-mysql-server
  echo "starting mysql"
  sudo systemctl start mysql
fi

echo "creating database"

# create the database and the user
mysql -h localhost -u root -pJambonzR0ck\$ << EOL
create database jambones;
create user $DB_USER@'%' IDENTIFIED BY '$DB_PASS';
grant all on jambones.* to $DB_USER@'%' with grant option;
grant create user on *.* to $DB_USER@'%' with grant option;
flush privileges;
EOL

# create the schema
echo "creating schema"
mysql -h localhost -u $DB_USER -p$DB_PASS -D jambones < $HOME/apps/jambonz-api-server/db/jambones-sql.sql
echo "seeding initial data"
mysql -h localhost -u $DB_USER -p$DB_PASS -D jambones < $HOME/apps/jambonz-api-server/db/seed-production-database-open-source.sql

