# Create monitoring instance
data "aws_ami" "jambonz-monitoring-server" {
  most_recent      = true
  name_regex       = "^jambonz-monitoring-server"
  owners           = ["376029039784"]
}
resource "aws_eip" "jambonz-monitoring-server" {
  instance = aws_instance.jambonz-monitoring-server.id
  vpc      = true
}

resource "aws_instance" "jambonz-monitoring-server" {
  ami                    = data.aws_ami.jambonz-monitoring-server.id
  instance_type          = var.ec2_instance_type_monitoring
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_jambonz_monitoring.id]
  subnet_id              = local.my_subnet_ids[0]
  monitoring             = true

  tags = {
    Name = "${var.prefix}-monitoring-server"  
  }
}
