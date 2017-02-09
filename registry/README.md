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

In order to create self signed certs [this link will](http://serverfault.com/questions/224122/what-is-crt-and-key-and-how-can-i-generate-them) give you a straight answer:
```
openssl genrsa 1024 > host.key
chmod 400 host.key
openssl req -new -x509 -nodes -sha1 -days 365 -key host.key -out host.cert
```
But if what you want is know what is going under the hood, please read [this tutorial](http://www.thegeekstuff.com/2009/07/linux-apache-mod-ssl-generate-key-csr-crt-file/).

Once the environment variables are setup just run terraform:
```
terraform apply
```

And if everything goes well, your registry should be up and running.

By default, the user is `docker` and the password is `$ecret` but you can customise
it through the ansible variables `registry_user` and `registry_password` or manually
in the registry machine on the file `/data/auth/passwd` following the instructions
from the [registry documentation](https://docs.docker.com/registry/deploying/).
