output "drone-dns" {
  value = "${aws_instance.drone.public_dns}"
}

output "drone-ip" {
  value = "${aws_instance.drone.public_ip}"
}

output "reprovision-command" {
  value = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.ansible_inventory_path} --private-key ${var.private_key_path} ${path.module}/ansible/play.yml"
}
