# Create SBC SIP+RTP instance
data "aws_ami" "jambonz-sbc-sip-rtp" {
  most_recent      = true
  name_regex       = "^jambonz-sbc-sip-rtp"
  owners           = ["376029039784"]
}
resource "aws_eip" "jambonz-sbc-sip-rtp" {
  count          = length(var.jambonz_sbc_sip_rtp_private_ips)

  instance = aws_instance.jambonz-sbc-sip-rtp-server[count.index].id
  vpc      = true
}
resource "aws_instance" "jambonz-sbc-sip-rtp-server" {
  count          = length(var.jambonz_sbc_sip_rtp_private_ips)

  ami                    = data.aws_ami.jambonz-sbc-sip-rtp.id
  instance_type          = var.ec2_instance_type_sbc
  private_ip             = var.jambonz_sbc_sip_rtp_private_ips[count.index]
  subnet_id              = local.my_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.allow_jambonz_sbc_sip_rtp.id]
  user_data              = templatefile("${path.module}/sbc-sip-rtp-server.ecosystem.config.js.tmpl", {
    VPC_CIDR                = var.vpc_cidr_block
    JAMBONES_SBC_SIP_IPS    = join(",", var.jambonz_sbc_sip_rtp_private_ips)
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

  depends_on = [aws_internet_gateway.jambonz, aws_instance.jambonz-monitoring-server, aws_elasticache_cluster.jambonz, aws_rds_cluster.jambonz]

  tags = {
    Name = "${var.prefix}-sbc-sip-rtp-server"  
  }
}
