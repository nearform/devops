## aws
variable "aws_subnet" {
  type = "string"
  default = ""
}

variable "aws_zone" {
  type = "string"
  default = ""
}

variable "aws_base_ami" {
  # Ubuntu 16.04 amd64 server - 2016-08-30
  # Root device type: ebs
  # Virtualization type: hvm
  default = "ami-82cf0aed"
}

variable "aws_security_groups" {
  default = []
}

variable "aws_iam_profile" {
  default = false
}

variable "private_ip" {
  default = ""
}

## volume
variable "volume_type" {
  type = "string"
  default = "gp2"
}

variable "volume_size" {
  default = "8"
}

variable "volume_tag" {
  type = "string"
  default = "Drone CI"
}

## instance
variable "instance_type" {
  type = "string"
  default = "t2.micro"
}

variable "instance_tag" {
  type = "string"
  default = "Drone CI"
}

# ssh
variable "ssh_key_name" {
  type = "string"
}

variable "ssh_private_key" {
  type = "string"
  default = ""
}

# ansible
variable "ansible_inventory_path" {
  type = "string"
  default = "/tmp/inventory"
}

variable "use_private_ip_to_provision" {
  default = false
}
