variable "prefix" {
  description = "name of VPC and other identifiers - lower case letters only"
  default = "jambonz"
}
variable "region" {
  description = "the aws region in which to create the VPC"
  default = "us-west-1"
}
variable "vpc_cidr_block" {
  description = "the CIDR block for the whole VPC"
  default = "172.31.0.0/16"
}
variable "public_subnets" {
  type = map(string)
  default = {
    "us-west-1a" = "172.31.32.0/24"
    "us-west-1b" = "172.31.33.0/24"
  }
}
variable "jambonz_sbc_sip_rtp_private_ips" {
  type = list(string)
  default = ["172.31.32.10"]
}
variable "ec2_instance_type" {
  description = "the EC2 instance type to use for the jambonz server"
  default = "t2.medium"
}
variable "key_name" {
  description = "name of an aws keypair that you have downloaded and wish to use to access the jambonz instance via ssh"
  default = "aws-drachtio-us-west-1"
}
variable "ssh_key_path" {
  description = "path to your aws keypair on your local machine"
  default = "~/aws/aws-drachtio-us-west-1.pem"
}
variable "aws_access_key_id_runtime" {
  description = "AWS access key jambonz will use to access AWS Polly TTS"
  default = "AKIAJH6IPHQPOLMVLVWQ"
}
variable "aws_secret_access_key_runtime" {
  description = "AWS secret access key jambonz will use to access AWS Polly TTS"
  default = "WycWsihQzDY2KQ+/+1tMPO4/DM9ADWOd86+kC5DC"
}
variable "sns_topic" {
  description = "AWS SNS topic for autoscale events"
  default = "jambonz-fs-lifecycle-events"
}
variable "ms_teams_fqdn" {
  description = "Microsoft Teams FQDN"
  default = ""
}
variable "cluster_id" {
  description = "short cluster identifier"
  default = "jb"
}

variable "datadog_api_key" {
  description = "datadog api key - only supply if you wish to install datadog monitoring"
  default = "88e5d83b6a857cc5dca140b432df583f"
}
variable "datadog_site" {
  description = "datadog site"
  default = "datadoghq.com"
}
variable "datadog_env_name" {
  description = "environment identifier"
  default = "us-west-1"
}



