

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_key_pair" "user" {
  key_name = "${var.public_ssh_key_name}"
  public_key = "${var.public_ssh_key}"
}

resource "aws_security_group" "drone" {
  name = "${var.aws_security_group_name}"
  description = "${var.aws_security_group_name}"
  vpc_id = "${var.drone_vpc_id}"
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
  type = "${var.aws_volume_type}"
  size = "${var.drone_volume_size}"
  tags {
    Name = "Drone CI"
  }
}

resource "aws_instance" "drone" {
  key_name = "${var.public_ssh_key_name}"
  ami = "${var.aws_base_ami}"
  instance_type = "${var.aws_instance_type}"
  availability_zone = "${data.aws_availability_zones.available-zones.names[0]}"
  subnet_id = "${var.drone_subnet_id}"
  vpc_security_group_ids = [
    "${aws_security_group.drone.id}"
  ]
  private_ip = "${var.drone_private_ip}"
  tags {
      Name = "${var.aws_instance_tags}"
  }
}

resource "aws_volume_attachment" "default" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.drone-volume.id}"
  instance_id = "${aws_instance.drone.id}"
  force_detach = true

  provisioner "local-exec" {
    command = <<EOF
      echo "[drone]\n${aws_instance.drone.public_ip}" > ${var.ansible_inventory_path};
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.ansible_inventory_path} ${path.module}/ansible/play.yml
    EOF
  }
}
