variable "aws_region" {
  default = ""
}
variable "cluster_name" {
  default = ""
}
variable "ssh_key_name" {
  default = ""
}
variable "ssh_private_key" {
  default = ""
}
variable "aws_subnets_map" {
  default = {}
}
variable "aws_security_groups" {
  default = []
}
variable "instance_type" {
  default = ""
}
variable "aws_base_ami" {
  default = ""
}
variable "use_private_ip_to_provision" {
  default = 0
}
variable "user_data" {
  default = ""
}
variable "aws_iam_profile" {
  default = ""
}

variable "volume_type" {
  type = "string"
  default = "gp2"
}

variable "volume_size" {
  default = 50
}
