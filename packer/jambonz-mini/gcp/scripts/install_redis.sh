#!/bin/bash

sudo apt-get install -y redis-server
sudo systemctl enable redis-server
sudo systemctl restart redis-server
