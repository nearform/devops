output "drone-dns" {
  value = "${aws_instance.drone.public_dns}"
}

output "drone-ip" {
  value = "${aws_instance.drone.public_ip}"
}
