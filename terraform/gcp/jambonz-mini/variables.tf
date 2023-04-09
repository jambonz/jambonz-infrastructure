variable "image" {
  description = "the image to use for the boot disk"
}
variable "region" {
  description = "the GCP region"
}
variable "zone" {
  description = "the GCP zone"
}
variable "project" {
  description = "the GCP project name"
}
variable "dns_name" {
  description = "the domain you want to use for the portal"
}
variable "instance_type" {
  description = "the VM instance type"
}
variable "jaeger_username" {
  description = "the jaeager user"
}
variable "jaeger_password" {
  description = "the jaeager password"
}
