variable "ami_owner_account" {
  description = "AWS account id that owns the AMIs that will be installed"
  default = "aws_owner_account here"
}
variable "ami_role_name" {
  description = "Name of AWS AMI role that you created for SNS scale-in notifications (see README)"
  default = "ami_role_name_here"
}
variable "prefix" {
  description = "name of VPC and other identifiers - lower case letters only"
  default = "jambonz"
}
variable "region" {
  description = "the aws region in which to create the VPC"
  default = "us-west-1"
}
variable "domain" {
  description = "the domain you want to use for the portal"
  default = "your_domain.com"
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
variable "ec2_instance_type_sbc" {
  description = "the EC2 instance type to use for the SBC"
  default = "t3.medium"
}
variable "ec2_instance_type_fs" {
  description = "the EC2 instance type to use for the Feature server"
  default = "t3.medium"
}
variable "key_name" {
  description = "name of an aws keypair that you have downloaded and wish to use to access the jambonz instance via ssh"
  default = "your-key"
}
variable "ssh_key_path" {
  description = "path to your aws keypair on your local machine"
  default = "path-to-key.pem"
}
variable "cluster_id" {
  description = "short cluster identifier"
  default = "jb"
}



