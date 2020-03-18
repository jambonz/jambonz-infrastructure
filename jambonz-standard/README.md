# jambonz-standard

A "standard" jambonz deployment consists of 3 instance types:
- An [SBC SIP server](./packer-sbc-sip)
- An [SBC RTP server](./packer-sbc-rtp)
- A [feature server](./packer-feature-server)

The terraform script creates a deployment consisting of:
- a VPC
- 2 public subnets in different availability zones
- an SBC SIP server, an SBC RTP server and a feature server in each availbility zone
- security groups to filter and block traffic
- a redis Elasticache database
- an Aurora serverless database

