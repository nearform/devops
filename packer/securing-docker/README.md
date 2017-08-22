## Securing Docker Containers on AWS

In 2015 the Docker team set out to consolidate all the information around best practices for securing docker containers.  You can find references to the [CIS Docker Community Edition Benchmark version 1.1.0](https://www.cisecurity.org/cis-benchmarks/) and Docker's own white paper [Introduction to Docker Security](https://d3oypxn00j2a10.cloudfront.net/assets/img/Docker%20Security/WP_Intro_to_container_security_03.20.2015.pdf) on the topic [here](https://blog.docker.com/2015/05/understanding-docker-security-and-best-practices/). The links above get you more directly to the assets. Just an FYI, the CIS benchmark will cost you an email address for download.

On most projects at nearForm we are deploying our solutions within Docker containers. There are tasks that are repeated on each project to secure and harden off those deployments and we built this packer template to produce a quick and easy way for you to spin up an AWS AMI that passes the [Docker-Bench-Security](https://github.com/docker/docker-bench-security) script. The Docker-Bench-Security repo is a work product of the above mentioned consolidation efforts by the Docker team.

To accomplish the building of this AMI we use [Packer](https://www.packer.io/), which is an easy way to automate the creation of your images.  It supports multiple providers (i.e. AWS, Digital Ocean) and allows you to document in a repo how your images were built and modifications that were done to them over time.

The work to get this AMI passing the [Docker-Bench-Security](https://github.com/docker/docker-bench-security) was not a small task, but a critical task of any development organization. Minimizing the attack surface of an application we deploy into the wild will always return on investment. Whether that return comes from keeping an active attacker from escalating privileges and damaging our craft or simply letting you sleep at night knowing that you've done everything you can to secure your environments. Give it a spin and feel free to raise [issues or PRs](https://github.com/nearform/devops) if you find ways to improve upon the work.

#### Requirements 

- [Packer](https://www.packer.io/intro/getting-started/install.html)
- [AWS account](https://aws.amazon.com/) - free tier will work with our examples.
- [Security Credentials](https://console.aws.amazon.com/iam/home) from your AWS account

#### Setup
 
 1. Setup packer
 2. `$ git clone git@github.com:nearform/devops.git`
 3. Create a file named `variables.json` in the root of the example repo from #2.  Add your access and secret keys. If you want to use a different region in AWS change the `aws_region` and find replace the `ubuntu_source_ami` with the AMI ID that has an instance type of `hvm-ssd` from [Ubuntu](https://cloud-images.ubuntu.com/locator/).  Your File should look something like this:
 
``` json
{
  "aws_secret_key": "< INSERT YOUR SECRET KEY >",
  "aws_access_key": "< INSERT YOUR ACCESS KEY >",
  "aws_region": "us-east-1",
  "ubuntu_source_ami": "ami-cb1d41b0"
}
```
 
 #### Build the AMI
 After executing the command below you should see an AMI in the [AWS Console](https://console.aws.amazon.com/ec2/v2/home?#Images)
 
 `$ packer build -var-file=variables.json base-image-us-east-template.json`

Our example template uses packer's [amazon-ebs](https://www.packer.io/docs/builders/amazon-ebs.html) builder.  We use a builder and two provisioners in our template to accomplish the following:

1. Create /etc/docker/daemon.json
2. Create and mount the volume that will be used to store our Docker assets
3. Install Docker CE
4. Clone [Docker-Bench-Security](https://github.com/docker/docker-bench-security) 
5. Install and configure [auditd](https://linux.die.net/man/8/auditd)

#### Run an Instance of Your AMI
Once packer has finished building your AMI, you can log into the AWS Console and launch an instance from the AMI.  You will only need to configure network related items (i.e. subnet) and the rest you should be able to take the defaults. Once your instance is up and running ssh into it and you should find docker-bench-security in the home directory of the ubuntu user. Do the following to run and verify the AMI passes the test we've documented above.

1. `$ cd docker-bench-security`
2. `$ sudo sh ./docker-bench-security.sh `
 
*note*: sudo is used in step 2 due to checks against files and directories that require elevated privileges.

#### Run a Container in your Instance
If you would like to build a docker image and run a container based on that image you can include [./files/app/]() in your AMI build, which will give you a simple [hapi](https://hapijs.com/) app to run the [Docker-Bench-Security](https://github.com/docker/docker-bench-security) tests against.

To include these files add the following to the provisioners section of the template

```
    {
      "type": "shell",
      "inline": ["mkdir ./app/"]
    },   
    {
      "type": "file",
      "source": "./files/app/",
      "destination": "./app/"
    }
```
