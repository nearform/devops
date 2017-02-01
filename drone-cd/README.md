# Drone CD

This document shows how to create a CI/CD pipeline with Drone
and Docker.

## Prerequisites

You must have installed the CLI tool for Drone. You can find the instructions [here](http://readme.drone.io/0.5/install/cli/).

You also need access to an AWS account.

## Setting up Drone

This [document](../drone-ci/README.md) will guide you through setting up an instance of Drone in AWS.

## Build your First Project
There are no build configurations stored in the server. All configuration is stored per-project in a file called `.drone.yml` at the
root of your project:

```
pipeline:
  build:
    image: node
    commands:
      - npm install --development
      - npm test
```

This example, defines a pipeline with a step called `build`. The `build` step will start a container using the `node` base image
and run the given commands inside it. Containers are given access to the build workspace so you can install dependencies, run tests, etc.

Each build step in Drone is run inside its own container, based off any Docker image you choose. 
Images can be specified with the standard syntax: `<username>/<image>:tag` and Drone will automatically pull them for you.

This gives us the powerful concept of `containerized plugins`, and makes it very easy to create our own plugin by building a docker image. 
You can find more information about it [here](http://drone-python.readthedocs.io/en/latest/writing_a_plugin.html).

## Setting up a Continuous Delivery Pipeline

Now we will configure Drone to deploy a **new version of our containerized app** to a remote
host once the tests have passed.

We are going to have 3 steps:

1. Run the tests
2. Push the container to the AWS Container Registry
3.  Deploy the container to a remote machine

The three steps are translated into the following configuration:
```
pipeline:
  build:
    image: node
    commands:
      - npm install --development
      - npm test
  publish
    image: plugins/ecr
    access_key: $ECR_ACCESS_KEY
    secret_key: $ECR_SECRET_KEY
    region: eu-central-1
    repo: 1234567890.dkr.ecr.eu-central-1.amazonaws.com/your-repo
    tag: latest
    file: Dockerfile
  deploy:
    image: plugins/ssh
    host: your-target-host.yourcompany.com
    user: ubuntu
    port: 22
    commands:
      - docker pull 1234567890.dkr.ecr.eu-central-1.amazonaws.com/your-repo:latest
      - docker stop drone-lab
      - docker rm drone-lab
      - docker run -d -p 3000:3000 --name drone-lab 1234567890.dkr.ecr.eu-central-1.amazonaws.com/drone-lab:latest
```

Let's explain the three steps:

1.  **build** - Here we specify how to test our build.
2.  **publish** - Here we use the `drone-ecr` plugin to build and push the image specified in our `Dockerfile` to the Amazon Container Registry (ECR).
3.  **deploy** - Here we use the `drone-ssh` plugin to run commands on the `target host`.

You can find more information about the plugins used in the following urls:
- [drone-ecr](https://github.com/drone-plugins/drone-ecr)
- [drone-ssh](https://github.com/drone-plugins/drone-ssh)

The official list of Drone plugins can be found [here](http://plugins.drone.io/).

## Managing secrets in Drone

The example above makes use of the secrets `$ECR_ACCESS_KEY` and `ECR_SECRET_KEY`. 
Drone v0.5 stores secrets in a central store so you don’t need to include them in your Yaml file.

The Drone CLI tool is used to persist secrets.

```bash
drone secret add --image=<image> <githubusername/repo> <variable> <value>
```

Example based on the above Yaml file.
```bash
drone secret add --image=plugins/ecr githubusername/repo ECR_ACCESS_KEY XXXXXXXXXXXX
drone secret add --image=plugins/ecr githubusername/repo XXXXXXXXXXXXXXXXXXXXXXXXX
```

Secrets are passed to your container as environment variables using the equivalent flags:

```bash
docker run -e ECR_ACCESS_KEY=XXXXXXXXXXX plugins/ecr
```

## Signature

Secrets are not exposed to the build unless your `.drone.yml` is signed and verified. You can sign `.drone.yml` using the Drone CLI tool.

```bash
drone sign githubusername/repo
```

This results in a `.drone.yml.sig` file which must be committed to your repo. 

**N.B** Every time you make a change to `.drone.yml`, the signature must be updated and committed or builds will not run.

The official documentation on secrets can be found [here](http://readme.drone.io/0.5/secrets/).