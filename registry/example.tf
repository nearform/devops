# This file is only an example. Please see the README.md for more info

module "registry" {
  source = "https://github.com/nearform/labs-devops//registry"
  keypair_key = "<your-public-key>"
  private_key_path = "~/.ssh/<your-private-key-file>"
  registry_subnet_id = ""
  registry_vpc_id = ""
}
