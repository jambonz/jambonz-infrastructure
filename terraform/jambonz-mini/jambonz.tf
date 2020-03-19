provider "aws" {
  profile    = "default"
  region     = var.region
}

# create a VPC with a public subnet
resource "aws_vpc" "jambonz" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "jambonz"
  }
}

resource "aws_internet_gateway" "jambonz" {
  vpc_id = aws_vpc.jambonz.id

  tags = {
    Name = "jambonz"
  }
}

resource "aws_default_route_table" "jambonz" {
   default_route_table_id = aws_vpc.jambonz.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jambonz.id
  }

  tags = {
    Name = "jambonz default route table"
  }
}

resource "aws_subnet" "jambonz" {
  vpc_id            = aws_vpc.jambonz.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "jambonz"
  }
}

resource "aws_subnet" "jambonz-extra" {
  vpc_id            = aws_vpc.jambonz.id
  cidr_block        = var.extra_subnet_cidr_block
  availability_zone = var.extra_availability_zone

  tags = {
    Name = "jambonz"
  }
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
    Name = "allow_redis"
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
    Name = "allow_mysql"
  }
}

# create a security group to allow sip/rtp/http 
resource "aws_security_group" "allow_jambonz" {
  name        = "allow_jambonz"
  description = "Allow traffic needed for jambonz"
  vpc_id      = aws_vpc.jambonz.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sip from everywhere"
    from_port   = 5060
    to_port     = 5060
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sip from everywhere"
    from_port   = 5060
    to_port     = 5060
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
    description = "http"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_jambonz"
  }
}

# create a subnet group for mysql
resource "aws_db_subnet_group" "jambonz" {
  name       = "jambonz-mysql-subnet"
  subnet_ids = [aws_subnet.jambonz.id, aws_subnet.jambonz-extra.id]
}

# create aurora database
resource "aws_rds_cluster" "jambonz" {
  cluster_identifier      = "aurora-cluster-jambonz"
  engine                  = "aurora"
  engine_version          = "5.6.10a"
  engine_mode             = "serverless"
  vpc_security_group_ids  = [aws_security_group.allow_mysql.id]
  db_subnet_group_name    = aws_db_subnet_group.jambonz.name
  database_name           = "jambones"
  master_username         = "admin"
  master_password         = "JambonzR0ck$"
  skip_final_snapshot     = true
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"

  scaling_configuration {
    auto_pause               = true
    min_capacity             = 1
    max_capacity             = 1
    seconds_until_auto_pause = 300
  }
}


# create an elastic IP and copy google credentials into place
resource "aws_eip" "jambonz" {
  instance = aws_instance.jambonz.id
  vpc      = true

  # copy user-provided google application credentials file
  provisioner "file" {
    source      = "credentials/"
    destination = "/home/admin/credentials"

    connection {
      type      = "ssh"
      user      = "admin"
      host      = self.public_ip
    }
  }

  # create the database tables
  provisioner "remote-exec" {
    inline = [
      "mysql -h ${aws_rds_cluster.jambonz.endpoint} -u admin -D jambones -pJambonzR0ck$ < /home/admin/apps/jambonz-api-server/db/jambones-sql.sql",
      "mysql -h ${aws_rds_cluster.jambonz.endpoint} -u admin -D jambones -pJambonzR0ck$ < /home/admin/apps/jambonz-api-server/db/create-admin-token.sql",
    ]

    connection {
      type      = "ssh"
      user      = "admin"
      host      = self.public_ip
    }
  }

  depends_on = [aws_rds_cluster.jambonz]
}

# select the most recent jambonz-mini AMI
data "aws_ami" "jambonz" {
  most_recent      = true
  name_regex       = "^jambonz-mini"
  owners           = ["376029039784"]
}

# create the EC2 instance that will run jambonz
resource "aws_instance" "jambonz" {
  ami                    = aws_ami.jambonz.id
  instance_type          = var.ec2_instance_type
  private_ip             = var.jambonz_mini_private_ip
  subnet_id              = aws_subnet.jambonz.id
  vpc_security_group_ids = [aws_security_group.allow_jambonz.id]
  user_data              = templatefile("${path.module}/ecosystem.config.js.tmpl", {
    JAMBONES_MYSQL_HOST     = aws_rds_cluster.jambonz.endpoint
    JAMBONES_MYSQL_USER     = aws_rds_cluster.jambonz.master_username
    JAMBONES_MYSQL_PASSWORD = aws_rds_cluster.jambonz.master_password
    JAMBONES_REDIS_HOST     = aws_elasticache_cluster.jambonz.cache_nodes.0.address
    AWS_ACCESS_KEY_ID       = var.aws_access_key_id_runtime
    AWS_SECRET_ACCESS_KEY   = var.aws_secret_access_key_runtime
    AWS_REGION              = var.region
  })
  key_name               = var.key_name
  monitoring             = true

  depends_on = [aws_internet_gateway.jambonz, aws_elasticache_cluster.jambonz, aws_rds_cluster.jambonz]

  tags = {
    Name = "jambonz"  
  }
}

resource "aws_elasticache_subnet_group" "jambonz" {
  name       = "jambonz-cache-subnet"
  subnet_ids = [aws_subnet.jambonz.id]
}

resource "aws_elasticache_cluster" "jambonz" {
  cluster_id           = "jambonz"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  subnet_group_name    = "jambonz-cache-subnet"
  security_group_ids   = [aws_security_group.allow_redis.id]
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379

  tags = {
    Name = "jambonz"
  }
}
