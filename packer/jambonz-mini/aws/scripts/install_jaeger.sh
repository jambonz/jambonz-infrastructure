#!/bin/bash
DISTRO=$1

if [ "$2" == "yes" ]; then 

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
sudo systemctl daemon-reload

echo "installing cassandra on $2"

if [ "$DISTRO" == "debian-12" ]; then

  # if debian 12 we need to downgrade java JDK to 11
  echo "downgrading Java JSDK to 11 because cassandra requires it"
  wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9%2B11.1/OpenJDK11U-jdk_x64_linux_hotspot_11.0.9_11.tar.gz
  sudo tar -xvf OpenJDK11U-jdk_x64_linux_hotspot_11.0.9_11.tar.gz -C /opt/
  sudo update-alternatives --install /usr/bin/java java /opt/jdk-11.0.9+11/bin/java 100
  sudo update-alternatives --install /usr/bin/javac javac /opt/jdk-11.0.9+11/bin/javac 100
  sudo update-alternatives --set java /opt/jdk-11.0.9+11/bin/java
  sudo update-alternatives --set javac /opt/jdk-11.0.9+11/bin/javac
  echo "export JAVA_HOME=/opt/jdk-11.0.9+11" >> ~/.bashrc
  echo "export PATH=$PATH:$JAVA_HOME/bin" >> ~/.bashrc
  source ~/.bashrc
elif [[ "$DISTRO" == rhel* ]]; then
  sudo dnf install -y java-11-openjdk-devel
else
  sudo apt-get install -y default-jdk
fi
# Verify the installation
java -version

tar xvfz apache-cassandra-4.1.3-bin.tar.gz
sudo mv apache-cassandra-4.1.3 /usr/local/cassandra
sudo cp cassandra.yaml /usr/local/cassandra/conf

if [[ "$DISTRO" == rhel* ]] ; then
  chown -R ec2-user:ec2-user /usr/local/cassandra/
  echo 'export PATH=$PATH:/usr/local/cassandra/bin' | sudo tee -a /home/ec2-user/.bashrc
  sed -i 's/\badmin\b/ec2-user/g' cassandra.service
else 
  sudo chown -R admin:admin /usr/local/cassandra/
  chown -R admin:admin /usr/local/cassandra/
  echo 'export PATH=$PATH:/usr/local/cassandra/bin' | sudo tee -a /home/admin/.bashrc
fi

echo 'export PATH=$PATH:/usr/local/cassandra/bin' | sudo tee -a /etc/profile
export PATH=$PATH:/usr/local/cassandra/bin

sudo cp cassandra.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/cassandra.service
sudo systemctl daemon-reload
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

if [[ "$DISTRO" == rhel* ]] ; then
  sudo sed -i 's/User=admin/User=ec2-user/' /etc/systemd/system/jaeger-collector.service
  sudo sed -i 's/User=admin/User=ec2-user/' /etc/systemd/system/jaeger-query.service
fi

sudo systemctl enable jaeger-collector
sudo systemctl enable jaeger-query

fi
