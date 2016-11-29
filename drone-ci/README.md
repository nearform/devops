# drone-ci

This is a Terraform module to provision the necessary infrastructure to create a drone
server in AWS.

The setup requires Terraform (it has been tested with version 0.7.x) and Ansible (any version but tested with 2.1.X).

## Setup

In order to create the Drone instance in AWS just follow the steps:

- Create a sample (and simple) terraform file (main.tf or similar). In order to do that, you will need the public key of one of your identities added to your local ssh-agent (you can create a new key with `ssh-keygen` and register it in the ssh-agent):

```
module "drone" {
  source = "github.com/nearform/labs-devops//drone-ci/drone"
  public_ssh_key = "<your-public-key>"
}

output "drone-ip" {
  value = "${module.drone.drone-ip}"
}
```

- Setup your github OAuth app by clicking on settings in Github and then OAuth applications. In the top right there is a button to register a new application. Don't worry about the callback url, we will come back to it later (just enter some random url).

- Once you finished registering the new Github will provide you with a client ID (displayed in the image above) and a client secret (clicking in the app link). Now we need to setup two environment variables with those values that Ansible will read to provision the drone machine:

```
export DRONE_GITHUB_CLIENT_ID=<your-client-id>
export DRONE_GITHUB_CLIENT_SECRET=<your-client-secret>
```

Now run Terraform:

```
terraform apply
```

This will take a bit (around 3 minutes) as it is creating all the required infrastructure and provisioning the Drone machine.

## Configuring Drone

Drone is pretty straight forward to configure but there are a couple of possible problems that you can fall into.

Drone uses OAuth for authenticating users. In order to configure the callback in Github execute the following command:

```
terraform output drone-ip
```

Now go to github -> settings -> OAuth applications and visit the Drone app that was creted before.

There is one field called `Authorization callback URL`. This field needs to point to your Drone instance. In this case we are not using a DNS so, assuming that the output from terraform is the IP `37.50.42.57`, the value for your callback URL will be `http://37.50.42.57/authorize`. This allows Drone
to setup the OAuth flow with Github for authorizations.

Once this is done, browse the IP from above and you are done.

From now on, you can access to Drone and it is connected to your Github account.

## Security Considerations

By default, this module creates a security group allowing traffic from every source into the port 80 (for HTTP) and into
the port 22 (for SSH).

The security group associated to it is called `Drone` in the AWS console so customize it as you need.
