variable "region" {
  description = "the aws region in which to create the VPC"
  default = "us-east-1"
}
variable "vpc_cidr_block" {
  description = "the CIDR block for the whole VPC"
  default = "172.31.0.0/16"
}
variable "public_subnets" {
  type = map(string)
  default = {
    "us-east-1a" = "172.31.32.0/24"
    "us-east-1b" = "172.31.33.0/24"
  }
}
variable "jambonz_sbc_sip_private_ips" {
  type = list(string)
  default = ["172.31.32.10", "172.31.33.10"]
}
variable "jambonz_sbc_rtp_private_ips" {
  type = list(string)
  default = ["172.31.32.20", "172.31.33.20"]
}
variable "jambonz_feature_server_private_ips" {
  type = list(string)
  default = ["172.31.32.100", "172.31.33.100"]
}
variable "ec2_instance_type" {
  description = "the EC2 instance type to use for the jambonz server"
  default = "t2.micro"
}
variable "key_name" {
  description = "name of an aws keypair that you have downloaded and wish to use to access the jambonz instance via ssh"
  default = "your-key-here"
}
variable "aws_access_key_id_runtime" {
  description = "AWS access key jambonz will use to access AWS Polly TTS"
  default = "your-aws-access-key-id"
}
variable "aws_secret_access_key_runtime" {
  description = "AWS secret access key jambonz will use to access AWS Polly TTS"
  default = "your-aws-secret_access-key"
}
