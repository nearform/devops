# This file is only an example. Please see the README.md for more info
module "drone" {
  source = "github.com/nearform/labs-devops/drone-ci/drone"
  # we reuse a key already create in AWS passing just it's name and the
  # path of the private key used to connect to the machine for provisioning
  ssh_key_name = ""
  ssh_private_key = "~/.ssh/my_pem_file"
  # configure networking and security
  aws_subnet = "subnet_id_1"
  aws_zone = "eu-west-1a"
  aws_security_groups = ["sec_group_id_1", "sec_group_id_2"]
  # instance settings
  instance_type = "t2.small"
  aws_base_ami = "ami-82cf0aed" ## expects an Ubuntu 16.04 AMI id
  instance_tag = "my-drone-ec2"
  # external volume settings
  volume_type = "gp2"
  volume_size = 10
  volume_tag = "my-drone-volume"
  # asnible settings
  ansible_inventory_path = "/tmp/drone-inventory"
  use_private_ip_to_provision = false
}

output "drone-ip" {
  value = "${module.drone.drone-ip}"
}

output "reprovision-command" {
  value = "${module.drone.reprovision-command}"
}
