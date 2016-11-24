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
  type = "string",
  default = "t2.micro"
}

variable "aws_base_ami" {
  # Ubuntu 16.04 amd64 server - 2016-08-30
  # Root device type: ebs
  # Virtualization type: hvm
  default = "ami-82cf0aed"
}

variable "drone_volume_size" {
  default = "8"
}

variable "user_public_key" {
  type = "string"
}

variable "drone_subnet_id" {
  type = "string"
  default = ""
}

variable "drone_security_groups" {
  default = []
}

variable "drone_private_ip" {
  type = "string"
  default = ""
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_key_pair" "user" {
  key_name = "user-key"
  public_key = "${var.user_public_key}"
}

resource "aws_security_group" "drone" {
  name = "Drone"
  description = "minimal security group for drone setup"
  vpc_id = "${var.drone_subnet_id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
     "0.0.0.0/0"
    ]
  }
  ingress {
    from_port = 80
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = [
     "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_ebs_volume" "drone-volume" {
  availability_zone = "${data.aws_availability_zones.available-zones.names[0]}"
  type = "gp2"
  size = "${var.drone_volume_size}"
  tags {
    Name = "Drone CI"
  }
}

resource "aws_instance" "drone" {
  key_name = "user-key"
  ami = "${var.aws_base_ami}"
  instance_type = "${var.aws_instance_type}"
  availability_zone = "${data.aws_availability_zones.available-zones.names[0]}"
  subnet_id = "${var.drone_subnet_id}"
  vpc_security_group_ids = [
    "${aws_security_group.drone.id}"
  ]
  private_ip = "${var.drone_private_ip}"
  tags {
      Name = "Drone CI"
  }
}

resource "aws_volume_attachment" "default" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.drone-volume.id}"
  instance_id = "${aws_instance.drone.id}"
  force_detach = true

  provisioner "local-exec" {
    command = "echo \"[drone]\n${aws_instance.drone.public_ip}\" > /tmp/inventory; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /tmp/inventory ${path.module}/ansible/play.yml"
  }
}

output "drone-dns" {
  value = "${aws_instance.drone.public_dns}"
}

output "drone-ip" {
  value = "${aws_instance.drone.public_ip}"
}
