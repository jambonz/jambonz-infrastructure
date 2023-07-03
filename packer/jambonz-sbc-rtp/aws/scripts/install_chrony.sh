#!/bin/bash

sudo apt-get update
sudo apt-get install -y chrony
sudo systemctl enable chrony
