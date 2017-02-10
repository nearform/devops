# Vault

This is a Terraform module to provision [Vault](https://www.hashicorp.com/blog/vault.html) in your infrastructure on AWS.

The module will spawn one server per availability zone so if you pass multiple availability zones and subnets you can achieve an HA setup backed by [Consul](https://www.hashicorp.com/blog/consul.html). Then to expose or not Consul is up to you and to your security group configuration.

All the ports used are the standard ones, no additonal port mapping was done on the containers.

## Setup

#### Create a `main.tf` terraform file

```
provider "aws" {
  region = "us-east-2"
  profile = "aws_profile"
}

module "vault" {
  source = "./vault"
  ssh_key_name = "key_name"
  ssh_private_key = "~/.ssh/key_name.pem"
  aws_region = "us-east-2"
  cluster_name = "vault-cluster"

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
# Use this if you use private IP to provision
# output "vault-ips" {
#   value = "${module.vault.vault-private-ips}"
# }
```

See [variables.tf](./variables.tf) for more information.

#### init the vault cluster
The Vault cluster needs to be initialized before being able to run, so connect to one of your Vault machines and run:

```bash
ubuntu@myHost:~$ docker exec -it vault vault init -address http://127.0.0.1:8200
Unseal Key 1: IAhvh/hpdN5Q57jHOHv2YOtKjV/p3qBKhAMHT+j00CgB
Unseal Key 2: z4n+VZstu8Azh+1HyDSuSYW1DsVpFeuxacX8J7HQaFkC
Unseal Key 3: IVu3gLotw3EGlekYqhUV7bz3bVFQ87hkJbSIq2ZanHgD
Unseal Key 4: +eG+sl3qfl85UmGiJjaekOiNrSO4pw2JdUjxodSLduEE
Unseal Key 5: FzP3Z3zqBu4MQGX9RBclNNHPzreBQV5cOTmFLQMBgsAF
Initial Root Token: 383e2478-151e-05e5-4a46-7a9ab424b113

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the Vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your Vault will remain permanently sealed.
```

**Note** the setup assume the cluster will be behind a load balancer that will take care of doing tls offloading, for this reason you need to specify the `-address` flag specifying the `http` protocol when issuing commands to the vault daemon.

Please [read the official Vault documentation](https://www.vaultproject.io/intro/getting-started/deploy.html#initializing-the-vault) to understand what is going on and how to continue from here.
