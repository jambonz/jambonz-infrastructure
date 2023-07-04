#!/bin/bash

if [ "$1" == "yes" ]; then 

cd /tmp

echo "installing jaeger"

wget https://github.com/jaegertracing/jaeger/releases/download/v1.46.0/jaeger-1.46.0-linux-amd64.tar.gz
tar xvfz jaeger-1.46.0-linux-amd64.tar.gz
sudo mv jaeger-1.46.0-linux-amd64/jaeger-collector /usr/local/bin/
sudo mv jaeger-1.46.0-linux-amd64/jaeger-query /usr/local/bin/

sudo cp jaeger-collector.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/jaeger-collector.service

sudo cp jaeger-query.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/jaeger-query.service

echo "installing cassandra"

sudo apt-get install -y default-jdk

wget https://dlcdn.apache.org/cassandra/4.1.2/apache-cassandra-4.1.2-bin.tar.gz
tar xvfz apache-cassandra-4.1.2-bin.tar.gz
mv apache-cassandra-4.1.2 /usr/local/cassandra
sudo cp cassandra.yaml /usr/local/cassandra/conf
sudo chown -R admin:admin /usr/local/cassandra/
cat /usr/local/cassandra/conf/cassandra.yaml 

chown -R admin:admin /usr/local/cassandra/

echo 'export PATH=$PATH:/usr/local/cassandra/bin' | tee -a /home/admin/.bashrc
echo 'export PATH=$PATH:/usr/local/cassandra/bin' | tee -a /etc/profile
export PATH=$PATH:/usr/local/cassandra/bin

sudo cp cassandra.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/cassandra.service
sudo systemctl enable cassandra
sudo systemctl start cassandra

echo "waiting 60 secs for cassandra to start.."
sleep 60
echo "create jambonz user in cassandra"

export CQLSH_HOST='127.0.0.1'
export CQLSH_PORT=9042
export USER_TO_CREATE='jaeger'
export PASSWORD='JambonzR0ck$'
cqlsh -u cassandra -p cassandra -e "CREATE ROLE IF NOT EXISTS $USER_TO_CREATE WITH PASSWORD = '$PASSWORD' AND LOGIN = true AND SUPERUSER = false;"

echo "create keyspace and schema for jaeger in cassandra"

export CASSANDRA_HOST="localhost" 
export CASSANDRA_PORT=9042
echo "CREATE KEYSPACE IF NOT EXISTS jaeger_v1_dc1 WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '2'}  AND durable_writes = true;"
cqlsh -u cassandra -p cassandra -e "CREATE KEYSPACE IF NOT EXISTS jaeger_v1_dc1 WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '2'}  AND durable_writes = true;"
cqlsh -u cassandra -p cassandra -e "GRANT ALL PERMISSIONS ON KEYSPACE jaeger_v1_dc1 TO $USER_TO_CREATE;"

git clone https://github.com/jaegertracing/jaeger.git
cd jaeger/plugin/storage/cassandra/schema
MODE=prod DATACENTER=datacenter1 TRACE_TTL=604800 KEYSPACE=jaeger_v1_dc1 ./create.sh | cqlsh localhost -u cassandra -p cassandra

systemctl enable jaeger-collector
systemctl enable jaeger-query

fi
