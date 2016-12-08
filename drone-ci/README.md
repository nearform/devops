# drone-ci

This is a Terraform module to provision infrastructure for a [Drone](https://drone.io) CI server in AWS.

The setup requires Terraform (it has been tested with version 0.7.x) and Ansible (any version but tested with 2.1.X).

## Setup

1) Create a `main.tf` terraform file:

```
module "drone" {
  source = "github.com/nearform/labs-devops//drone-ci/drone"
  keypair_key = "<your-public-key>"
  private_key_path = "~/.ssh/id_rsa"
  drone_vpc_id = "12345"
  drone_subnet_id = "678910"
}

output "drone-ip" {
  value = "${module.drone.drone-ip}"
}
```

See [variables.tf](./drone/variables.tf) for more information.

2) Create a new github OAuth developer application for Drone. Click on settings in Github and then OAuth applications. In the top right there is a button to register a new application. Don't worry about the callback url, we will come back to it later (just enter some random url).

3) Once you finished registering the new Github will provide you with a client ID (displayed in the image above) and a client secret (clicking in the app link). Now we need to setup two environment variables with those values that Ansible will read to provision the drone machine:

```
export DRONE_GITHUB_CLIENT_ID=<your-client-id>
export DRONE_GITHUB_CLIENT_SECRET=<your-client-secret>
```
Alternatively, if you are using an on-premises version of github, instead of configuring
the `client id` and `secret` variables from above, just pass the full config url in the environment
variable `DRONE_GITHUB_CONFIG_URL` (which includes `client id` and `secret`):

```
export DRONE_GITHUB_CONFIG_URL=github.mycompany.com?client_id=<client-id>&client_secret=<client-secret>
```

4) Run Terraform:

```
$ terraform apply
```

This will take a around 5 minutes to create all the required infrastructure and provision the Drone instance.

5) Configuring Drone

Now that Done is up and running, we need to go back to GitHub and configure the drone callback.

```
terraform output drone-ip
```

Now go to github -> settings -> OAuth applications and visit the Drone app that we just created.

There is one field called `Authorization callback URL`. This field needs to point to your Drone instance. In this case we are not using a DNS so, assuming that the output from terraform is the IP `37.50.42.57`, the value for your callback URL will be `http://37.50.42.57/authorize`. This allows Drone to setup the OAuth flow with Github for authorizations.

6) Once this is done, browse the IP from above, login, and you should be up and running.

Next you need to add `.drone.yml` files to your code repositories, see the [Drone Documentation](http://readme.drone.io/usage/overview/) for more on this.

## Security Considerations

By default, this module creates a security group allowing traffic from every source into the port 80 (for HTTP) and into
the port 22 (for SSH).

The security group associated to it is called `Drone security group` in the AWS console so customize it as you need.

We do not recommend creating a public facing Drone server directly on the internet - instead adopt one of the recommended AWS VPC [patterns](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html).
