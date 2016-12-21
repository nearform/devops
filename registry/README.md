# Docker registry
This module allows you to setup a docker registry with plain username and password
authentication.

## How does it work?

For an easy setup check out [example.tf](./example.tf):
```
module "registry" {
  source = "https://github.com/nearform/labs-devops//registry"
  keypair_key = "<your-public-key>"
  private_key_path = "<path-to-your-private-key>"
  registry_subnet_id = ""
  registry_vpc_id = ""
}
```

Prior to execute the terraform script you need to setup two environment variables:
```
export REGISTRY_CRT_FILE=<path-to-the-crt-file>
export REGISTRY_KEY_FILE=<path-to-the-key-file>
```
Those two variables will enable the registry to operate over SSL (certificate + private key)
and they have to be generated previously with the [right information](https://docs.docker.com/registry/deploying/).

Those files need to be placed on the machine that is running the terraform script
from above.

Once the environment variables are setup just run terraform:
```
terraform apply
```

And if everything goes well, your registry should be up and running.

By default, the user is `docker` and the password is `$ecret` but you can customise
it through the ansible variables `registry_user` and `registry_password` or manually
in the registry machine on the file `/data/auth/passwd` following the instructions
from the [registry documentation](https://docs.docker.com/registry/deploying/).
