# Create SBC SIP instances
data "aws_ami" "jambonz-sbc-sip" {
  most_recent      = true
  name_regex       = "^jambonz-sbc-sip"
  owners           = ["376029039784"]
}
resource "aws_eip" "jambonz-sbc-sip" {
  count          = length(var.jambonz_sbc_sip_private_ips)

  instance = aws_instance.jambonz-sbc-sip-server[count.index].id
  vpc      = true
}
resource "aws_instance" "jambonz-sbc-sip-server" {
  count          = length(var.jambonz_sbc_sip_private_ips)

  ami                    = data.aws_ami.jambonz-sbc-sip.id
  instance_type          = var.ec2_instance_type_sbc_sip
  private_ip             = var.jambonz_sbc_sip_private_ips[count.index]
  subnet_id              = local.my_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.allow_jambonz_sbc_sip.id]
  user_data              = templatefile("${path.module}/sbc-sip-server.ecosystem.config.js.tmpl", {
    VPC_CIDR                = var.vpc_cidr_block
    JAMBONES_SBC_SIP_IPS    = join(",", var.jambonz_sbc_sip_private_ips)
    JAMBONES_RTPENGINE_IPS  = join(",", local.rtpengine_hostports)
    JAMBONES_MYSQL_HOST     = aws_rds_cluster.jambonz.endpoint
    JAMBONES_MYSQL_USER     = aws_rds_cluster.jambonz.master_username
    JAMBONES_MYSQL_PASSWORD = aws_rds_cluster.jambonz.master_password
    JAMBONES_REDIS_HOST     = aws_elasticache_cluster.jambonz.cache_nodes.0.address
    MS_TEAMS_FQDN           = var.ms_teams_fqdn
    JAMBONES_CLUSTER_ID     = var.cluster_id
    MONITORING_SERVER_IP    = aws_instance.jambonz-monitoring-server.private_ip
  })
  key_name               = var.key_name
  monitoring             = true
  
  depends_on = [aws_internet_gateway.jambonz, aws_elasticache_cluster.jambonz, aws_rds_cluster.jambonz]

  tags = {
    Name = "${var.prefix}-sbc-sip-server"  
  }
}

# Create SBC RTP instances
data "aws_ami" "jambonz-sbc-rtp" {
  most_recent      = true
  name_regex       = "^jambonz-sbc-rtp"
  owners           = ["376029039784"]
}
resource "aws_eip" "jambonz-sbc-rtp" {
  count          = length(var.jambonz_sbc_rtp_private_ips)

  instance = aws_instance.jambonz-sbc-rtp-server[count.index].id
  vpc      = true
}
resource "aws_instance" "jambonz-sbc-rtp-server" {
  count          = length(var.jambonz_sbc_rtp_private_ips)

  ami                    = data.aws_ami.jambonz-sbc-rtp.id
  instance_type          = var.ec2_instance_type_sbc_rtp
  private_ip             = var.jambonz_sbc_rtp_private_ips[count.index]
  subnet_id              = local.my_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.allow_jambonz_sbc_rtp.id]
  key_name               = var.key_name
  monitoring             = true
  user_data              = templatefile("${path.module}/sbc-rtp-server.ecosystem.config.js.tmpl", {
    MONITORING_SERVER_IP    = aws_instance.jambonz-monitoring-server.private_ip
  })

  depends_on = [aws_internet_gateway.jambonz, aws_instance.jambonz-monitoring-server]

  tags = {
    Name = "${var.prefix}-sbc-rtp-server"  
  }
}
