#!/bin/bash

if [ "$1" == "yes" ]; then 

cd /tmp

echo "installing jaeger"
wget https://github.com/jaegertracing/jaeger/releases/download/v1.33.0/jaeger-1.33.0-linux-amd64.tar.gz
sudo tar xvfz jaeger-1.33.0-linux-amd64.tar.gz
sudo cp jaeger-1.33.0-linux-amd64/jaeger-all-in-one /usr/local/bin 

sudo cp jaeger.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/jaeger.service
sudo systemctl enable jaeger
sudo systemctl start jaeger

fi