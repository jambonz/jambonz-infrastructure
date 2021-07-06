provider "aws" {
  profile    = "default"
  region     = var.region
}

# create a VPC 
resource "aws_vpc" "jambonz" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.prefix
  }
}

# add an internet gateway to the VPC
resource "aws_internet_gateway" "jambonz" {
  vpc_id = aws_vpc.jambonz.id

  tags = {
    Name = var.prefix
  }
}

# add a route to the default route table 
# to route non-local traffic via the internet gateway
resource "aws_default_route_table" "jambonz" {
   default_route_table_id = aws_vpc.jambonz.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jambonz.id
  }

  tags = {
    Name = "${var.prefix} default route table"
  }
}

# create public subnets
resource "aws_subnet" "jambonz" {
  for_each          = var.public_subnets

  vpc_id            = aws_vpc.jambonz.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = var.prefix
  }
}

# for ease of reference later on, create a list of public subnet ids
locals {
  my_subnet_ids = [for v in aws_subnet.jambonz : v.id]
}

# create a security group that allows any server in the VPC to access redis
resource "aws_security_group" "allow_redis" {
  name        = "allow_redis"
  description = "Allow redis connections"
  vpc_id      = aws_vpc.jambonz.id

  ingress {
    description = "redis from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jambonz_allow_redis"
  }
}

# create a security group that allows any server in the VPC to access aurora
resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow mysl connections"
  vpc_id      = aws_vpc.jambonz.id

  ingress {
    description = "mysql from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jambonz_allow_mysql"
  }
}

# create a security group to allow ssh to feature server
resource "aws_security_group" "allow_jambonz_feature_server" {
  name        = "allow_jambonz_feature_server"
  description = "Allow traffic needed for jambonz feature server"
  vpc_id      = aws_vpc.jambonz.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from sbc/api servers"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "http from aws sns"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sip from VPC"
    from_port   = 5060
    to_port     = 5060
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "sip from VPC"
    from_port   = 5060
    to_port     = 5060
    protocol    = "udp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "freeswitch sip from VPC"
    from_port   = 5080
    to_port     = 5080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "freeswitch sip from VPC"
    from_port   = 5080
    to_port     = 5080
    protocol    = "udp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "rtp"
    from_port   = 25000
    to_port     = 40000
    protocol    = "udp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jambonz_allow_feature_server"
  }
}

# create a security group to allow sip, rtp and http to the sbc sip+rtp server
resource "aws_security_group" "allow_jambonz_sbc_sip_rtp" {
  name        = "allow_jambonz_sbc_sip_rtp"
  description = "Allow traffic to jambonz sbc sip rtp server"
  vpc_id      = aws_vpc.jambonz.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sip over udp"
    from_port   = 5060
    to_port     = 5060
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sip over tls"
    from_port   = 5061
    to_port     = 5061
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sip over wss"
    from_port   = 4433
    to_port     = 4433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "rtp from everywhere"
    from_port   = 40000
    to_port     = 60000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "rtpengine ng protocol from VPC"
    from_port   = 22222
    to_port     = 22222
    protocol    = "udp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "rtpengine http protocol from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "http api from FS"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_jambonz_feature_server.id]
  }

  ingress {
    description = "influxdb"
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "influxdb backup"
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  ingress {
    description = "homer HEP"
    from_port   = 9060
    to_port     = 9060
    protocol    = "udp"
    cidr_blocks = [aws_vpc.jambonz.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jambonz_allow_sip_rtp_http"
  }
}


