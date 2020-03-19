# jambonz infrastructure

This repository contains [packer](packer.io) and [terraform](terraform.io) scripts for deploying ja,mbonz on AWS.  Packer scripts build the necessary AMIs, and terraform scripts create the full AWS infrastructure using those AMIs.

There are 3 different deployment alternatives:

- a "jambonz mini" deployment, consisting of a single server
- a "jambonz small" deployment, consisting of one server for SBC functionality and a second server for feature server functionality
- a "jambonz standard" deployment, which provides redundancy and scalability and a fully-exploded functional architecture consisting of one set of instances for SBC SIP signaling, a second set of instance for SBC media handling, and a third set of instances for feature server.

## jambonz standard

A "standard" jambonz deployment consists of 3 instance types:
- An [SBC SIP server](./packer/jambonz-sbc-sip)
- An [SBC RTP server](./packer/jambonz-sbc-rtp)
- A [feature server](./packer/jambonz-feature-server)

The terraform script creates a deployment consisting of:
- a VPC
- 2 public subnets in different availability zones
- an SBC SIP server, an SBC RTP server and a feature server in each availbility zone
- security groups to filter and block traffic
- a redis Elasticache database
- an Aurora serverless database

