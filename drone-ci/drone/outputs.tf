output "drone-dns" {
  value = "${aws_instance.drone.public_dns}"
}

output "drone-ip" {
  value = "${aws_instance.drone.public_ip}"
}

output "reprovision-command" {
  value = <<EOF
    echo "[drone]\n${aws_instance.drone.public_ip}" > ${var.ansible_inventory_path};
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.ansible_inventory_path} ${path.module}/ansible/play.yml
  EOF
}
