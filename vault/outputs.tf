output "vault-public-ips" {
  value = "${join(",", aws_instance.cluster.*.public_ip)}"
}

output "vault-private-ips" {
  value = "${join(",", aws_instance.cluster.*.public_ip)}"
}
