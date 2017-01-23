output "drone-dns" {
  value = "${aws_instance.drone.public_dns}"
}

output "drone-ip" {
  value = "${aws_instance.drone.public_ip}"
}

output "reprovision-command" {
  value = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.ansible_inventory_path} --private-key ${var.ssh_private_key} ${path.module}/ansible/play.yml"
}

output "instance-id" {
  value = "${aws_instance.drone.id}"
}
