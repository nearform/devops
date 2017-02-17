resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command = <<EOF
      export ANSIBLE_PATH="${path.module}/ansible"
      rm -f $ANSIBLE_PATH/inventory
      rm -f $ANSIBLE_PATH/all_ips
      touch $ANSIBLE_PATH/all_ips
      touch $ANSIBLE_PATH/inventory
    EOF
  }
}

resource "aws_instance" "cluster" {
  count = "${length(keys(var.aws_subnets_map))}"
  depends_on = [
    "null_resource.cleanup"
  ]
  key_name = "${var.ssh_key_name}"
  ami = "${var.aws_base_ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${element(values(var.aws_subnets_map), count.index)}"
  availability_zone = "${element(keys(var.aws_subnets_map), count.index)}"
  associate_public_ip_address = "${1 - var.use_private_ip_to_provision}"
  vpc_security_group_ids = ["${var.aws_security_groups}"]
  tags {
    Name = "${var.cluster_name}"
  }
}

resource "null_resource" "get_ips" {
  count = "${length(keys(var.aws_subnets_map))}"
  depends_on = [
    "aws_instance.cluster"
  ]
  provisioner "local-exec" {
    command = <<EOF
      export ANSIBLE_PATH="${path.module}/ansible"
      export PRIVATE_IP=${var.use_private_ip_to_provision}
      if [ 1 -eq $PRIVATE_IP ]
      then
        echo "${element(aws_instance.cluster.*.private_ip, count.index)}" >> $ANSIBLE_PATH/all_ips
      else
        echo "${element(aws_instance.cluster.*.public_ip, count.index)}" >> $ANSIBLE_PATH/all_ips
      fi
    EOF
  }
}

resource "null_resource" "build_inventory" {
  depends_on = [
    "null_resource.get_ips"
  ]
  provisioner "local-exec" {
    command = <<EOF
      export ANSIBLE_PATH="${path.module}/ansible"
      echo "[master]" >> $ANSIBLE_PATH/inventory
      echo "$(head -n 1 $ANSIBLE_PATH/all_ips)" >> $ANSIBLE_PATH/inventory
      echo "[slaves]" >> $ANSIBLE_PATH/inventory
      echo "$(tail -n +2 $ANSIBLE_PATH/all_ips)" >> $ANSIBLE_PATH/inventory
    EOF
  }
}

resource "null_resource" "vault_setup" {
  depends_on = [
    "null_resource.build_inventory"
  ]
  provisioner "local-exec" {
    command = <<EOF
      export ANSIBLE_PATH="${path.module}/ansible"
      export ANSIBLE_HOST_KEY_CHECKING=False
      ansible-playbook -i $ANSIBLE_PATH/inventory --private-key ${var.ssh_private_key} $ANSIBLE_PATH/play.yml
    EOF
  }
}
