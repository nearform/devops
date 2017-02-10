provider "aws" {
  region = "us-east-2"
  profile = "tm"
}

module "vault" {
  source = "./vault"
  ssh_key_name = "tm-us-east-2"
  ssh_private_key = "~/.ssh/tm-us-east-2.pem"
  aws_region = "us-east-2"
  cluster_name = "vault-dev"

  aws_subnets_map = {
    us-east-2a = "subnet-8c38fce5"
    us-east-2b = "subnet-31130149"
  }
  aws_security_groups = ["sg-6ee75007"]
  instance_type = "t2.small"
  aws_base_ami = "ami-fcc19b99" ## expects an Ubuntu 16.04
  use_private_ip_to_provision = false
}

output "vault-ips" {
  value = "${module.vault.vault-public-ips}"
}

# output "vault-ips" {
#   value = "${module.vault.vault-private-ips}"
# }
