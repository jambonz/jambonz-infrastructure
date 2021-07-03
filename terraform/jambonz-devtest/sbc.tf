# Create SBC SIP+RTP instance
data "aws_ami" "jambonz-sbc-sip-rtp" {
  most_recent      = true
  name_regex       = "^jambonz-sbc-sip-rtp"
  owners           = [var.ami_owner_account]
}

resource "aws_eip" "jambonz-sbc-sip-rtp" {
  instance = aws_instance.jambonz-sbc-sip-rtp-server.id
  vpc      = true
}

resource "aws_instance" "jambonz-sbc-sip-rtp-server" {
  ami                    = data.aws_ami.jambonz-sbc-sip-rtp.id
  instance_type          = var.ec2_instance_type_sbc
  key_name               = var.key_name
  subnet_id              = local.my_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.allow_jambonz_sbc_sip_rtp.id]
  monitoring             = true
  user_data              = templatefile("${path.module}/sbc-sip-rtp-server.ecosystem.config.js.tmpl", {
    VPC_CIDR                = var.vpc_cidr_block
    JAMBONES_RTPENGINE_IPS  = "127.0.0.1:22222"
    JAMBONES_MYSQL_HOST     = aws_rds_cluster.jambonz.endpoint
    JAMBONES_MYSQL_USER     = aws_rds_cluster.jambonz.master_username
    JAMBONES_MYSQL_PASSWORD = aws_rds_cluster.jambonz.master_password
    JAMBONES_REDIS_HOST     = aws_elasticache_cluster.jambonz.cache_nodes.0.address
    JAMBONES_CLUSTER_ID     = var.cluster_id
    MONITORING_SERVER_IP    = "127.0.0.1"
    JAMBONES_DNS_NAME       = var.domain
  })

  depends_on = [aws_internet_gateway.jambonz, aws_elasticache_cluster.jambonz, aws_rds_cluster.jambonz]

  tags = {
    Name = "jambonz-sbc-sip-rtp-server"  
  }
}
