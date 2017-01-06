data "aws_availability_zones" "available-zones" {}

variable "aws_region" {
  type = "string"
  default = "eu-central-1"
}

variable "aws_access_key" {
  type = "string"
  default = ""
}

variable "aws_secret_key" {
  type = "string"
  default = ""
}

variable "aws_instance_type" {
  type = "string"
  default = "t2.micro"
}

variable "aws_volume_type" {
  type = "string"
  default = "gp2"
}

variable "aws_instance_tag" {
  type = "string"
  default = "Drone CI"
}

variable "aws_volume_tag" {
  type = "string"
  default = "Drone CI"
}

// TODO - it's possible to query this automatically
variable "aws_base_ami" {
  # Ubuntu 16.04 amd64 server - 2016-08-30
  # Root device type: ebs
  # Virtualization type: hvm
  default = "ami-82cf0aed"
}

variable "aws_security_group_name" {
  default = "Drone security group"
}

variable "drone_volume_size" {
  default = "8"
}

variable "keypair_name" {
  type = "string"
  default = "drone-ssh-key"
}

variable "keypair_key" {
  type = "string"
}

variable "drone_subnet_id" {
  type = "string"
}

variable "drone_vpc_id" {
  type = "string"
}

variable "drone_security_groups" {
  default = []
}

variable "drone_private_ip" {
  type = "string"
  default = ""
}

variable "ansible_user" {
  type = "string"
  default = "ubuntu"
}

variable "ansible_inventory_path" {
  type = "string"
  default = "/tmp/inventory"
}

variable "private_key_path" {
  type = "string"
}

variable "use_private_ip_to_provision" {
  default = false
}
