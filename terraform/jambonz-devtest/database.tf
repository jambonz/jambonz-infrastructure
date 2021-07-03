# create a subnet group for aurora mysql
resource "aws_db_subnet_group" "jambonz" {
  name       = "${var.prefix}-mysql-subnet"
  subnet_ids = local.my_subnet_ids
}

# generate random password
resource "random_password" "password" {
  length           = 16
  special          = false
}

# create aurora database
resource "aws_rds_cluster" "jambonz" {
  cluster_identifier      = "aurora-cluster-${var.prefix}"
  engine                  = "aurora"
  engine_version          = "5.6.10a"
  engine_mode             = "serverless"
  vpc_security_group_ids  = [aws_security_group.allow_mysql.id]
  db_subnet_group_name    = aws_db_subnet_group.jambonz.name
  database_name           = "jambones"
  master_username         = "admin"
  master_password         = random_password.password.result
  skip_final_snapshot     = true
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"

  scaling_configuration {
    auto_pause               = false
    min_capacity             = 1
    max_capacity             = 2
  }
}

# create a subnet group for redis elasticache
resource "aws_elasticache_subnet_group" "jambonz" {
  name       = "${var.prefix}-cache-subnet"
  subnet_ids = local.my_subnet_ids
}

# create redis cluster
resource "aws_elasticache_cluster" "jambonz" {
  cluster_id           = var.prefix
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  subnet_group_name    = "${var.prefix}-cache-subnet"
  security_group_ids   = [aws_security_group.allow_redis.id]
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379

  tags = {
    Name = var.prefix
  }

  depends_on = [aws_elasticache_subnet_group.jambonz]
}
