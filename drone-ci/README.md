# drone-ci

This is a Terraform module to provision the necessary infrastructure to create a drone
server in AWS.

The setup requires Terraform (it has been tested with version 0.7.x) and Ansible (any version).

## Setup

In order to create the Drone instance in AWS just follow the steps:

- Clone this repository
- Create a sample terraform file (main.tf or similar):

```
module "drone" {
  source = "https://www.github.com/nearform/labs-devos/drone-ci/drone"
  user_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABCQC/eADYZQ1gUrxP4sfHi/H07dm9M0KnjYnmcY1Ek8rrPzR1gCEsC+JThZC446AdKHbsNHOIlo+XL5yNYwHKRwKgtnE0uGQi/yJNQvxQpE1fqp/cCRQxoJZ34DJkO0HJAtq4miU/dMLTsmLSDR6VOB10SDF7kwMxpSveOrBBMe0dj/MgtlnQSJJBSpb/rfwCq0EWTmajcgx21F8/msBak/isPPYSi6IlKMwgSTbV4xjDsTcjww0BpyiWoUCw2CE9fDeZw5PdHqWXo895ENVtcHf9FdM8JoZks8mHLEnu5B813Ez+nWS9eJjwWmZq5LmIyVHJCrEohUcS8hX/qWErEfDX dgonzalez@iamdave.com"
  drone_security_groups = ["sg-799ac311"]
}

output "drone-ssh" {
  value = "ubuntu@${module.drone.drone-dns}"
}

output "drone-ip" {
  value = "${module.drone.drone-ip}"
}
```

Please note that is important to keep the `output` for the `drone-ip` as Ansible will
request this value when provisioning the drone machine.

- Setup your github OAuth app by clicking on settings in Github and then OAuth applications:

![screen shot 2016-11-23 at 14 29 07](https://cloud.githubusercontent.com/assets/123962/20565374/39261bd0-b189-11e6-80c3-c863fab41be9.png)

Don't worry about the callback url, we will come back to it later (just enter some random url).

Github will provide you with a client ID (displayed in the image above) and a client secret (clicking in the app link).

- Run the following command on the base of this repo:
```
./dronify [client-id] [client-secret]
```
Please note that client-id and secret-id are provided in the previous step.

This will take a bit (it is creating the infrastructure in AWS as well as provisioning the instance of drone) but then you will have a fully working instance of Drone in the IP displayed by:

```
terraform output drone-ip
```

## Configuring Drone

Drone is pretty straight forward to configure but there are a couple of possible problems
