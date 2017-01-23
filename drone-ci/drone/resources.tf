resource "aws_ebs_volume" "volume" {
  availability_zone = "${var.aws_zone}"
  type = "${var.volume_type}"
  size = "${var.volume_size}"
  tags {
    Name = "${var.volume_tag}"
  }
}

resource "aws_instance" "drone" {
  key_name = "${var.ssh_key_name}"
  ami = "${var.aws_base_ami}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.aws_zone}"
  subnet_id = "${var.aws_subnet}"
  vpc_security_group_ids = ["${var.aws_security_groups}"]
  private_ip = "${var.private_ip}"
  tags {
      Name = "${var.instance_tag}"
  }
}

resource "aws_volume_attachment" "default" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.volume.id}"
  instance_id = "${aws_instance.drone.id}"
  force_detach = true

  provisioner "local-exec" {
    command = <<EOF
      if [ 1 -eq ${var.use_private_ip_to_provision} ]
      then
        echo "${aws_instance.drone.private_ip}" > ${var.ansible_inventory_path};
      else
        echo "${aws_instance.drone.public_ip}" > ${var.ansible_inventory_path};
      fi
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.ansible_inventory_path} --private-key ${var.ssh_private_key} ${path.module}/ansible/play.yml
    EOF
  }
}
