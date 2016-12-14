# Drone CD

The purpose of this document is to show how to create a CI/CD pipeline with drone
and Docker.

## Setting up Drone

In order to setup Drone, follow the instructions in [here](../drone-ci/README.md).

Once you are done with it, you should have a running instance of drone in AWS.

## Prerequisites

You must have installed the CLI tool for drone. You can find the instructions in [here](http://readme.drone.io/devs/cli/).

You also need access to an AWS account.

## Setting up a continuous delivery pipeline

Drone is built around a powerful concept: containerized plugins. This enables you
to easily create a plugin by building a docker image. You can find more information
about it [here](http://drone-python.readthedocs.io/en/latest/writing_a_plugin.html).

There is no configuration required in the Drone server to make the plugins run. All
the required configuration is stored per project in a file called .drone.yaml in the
root of the project:
```
build:
  image: node
  commands:
    - npm install --development
    - npm test
```

This example, will instruct drone to build a container with the base image golang
and run the commands specified in the `commands` section.

In this case, we are going to deploy a **new version of our containerized app** to the remote
host after a set of tests is successfully run.

We are going to have 3 steps:
- Run the tests
- Push the container to the AWS Container Registry
- Deploy the container in a remote machine

The three steps are translated into the following configuration:
```
build:
  image: node
  commands:
    - npm install --development
    - npm test
publish:
  ecr:
    access_key: $$ECR_ACCESS_KEY
    secret_key: $$ECR_SECRET_KEY
    region: eu-central-1
    repo: 1234567890.dkr.ecr.eu-central-1.amazonaws.com/your-repo
    tag: latest
    file: Dockerfile
deploy:
  ssh:
    host: your-target-host.yourcompany.com
    user: ubuntu
    port: 22
    commands:
      - docker pull 1234567890.dkr.ecr.eu-central-1.amazonaws.com/your-repo:latest
      - docker stop drone-lab
      - docker rm drone-lab
      - docker run -d -p 3000:3000 --name drone-lab 1234567890.dkr.ecr.eu-central-1.amazonaws.com/drone-lab:latest
```

Let's explain the sections from above and how the correlate to the steps:
- **build**: In this section we specify how to test our build. We only specify the commands to run our tests. Drone will take care of building the container to do it so.
- **publish**: In this section we use the plugin `drone-ecr` to push the container specified in our `Dockerfile` to the Amazon Container Registry (ECR).
- **deploy**: In this section we are using the plugin `drone-ssh` to run commands in the `target host`.

As you can see, the publish and deploy steps are relying on plugins. You can find more information
about them in the following urls:
- [drone-ecr](https://github.com/drone-plugins/drone-ecr)
- [drone-ssh](https://github.com/drone-plugins/drone-ssh)

Customize the yaml from above in order to match your requirements.

## Managing secrets in Drone

As you can see in the example from above, we use the `$$` notation to inject
secrets into our configuration. How Drone 0.4 works with secrets is
fairly simple:
- We create a yaml file with our secrets
- Drone encrypts the secrets
- Secrets get commited in your project in a file called `.drone.sec` at the same
level of your `.drone.yaml` file in your project.

Please be aware that before decrypting secrets, Drone will validate that the signature
of your `.drone.yaml` file matches with the one stored in your secrets file so, if you
change the `.drone.yaml` or someone tampers it, your secrets won't get exposed. Yo can find
more information on how to work with secrets [here](http://readme.drone.io/usage/secrets/).

Your secrets file for the example from above should look similar to the following one:
```
  environment:
    ECR_ACCESS_KEY: <your access key>
    ECR_SECRT_KEY: <your secret key>
```

**Please be very careful to not disclose the secrets file in clear**

Once you have created the file with the appropriated values, we need to encrypt it:
```
drone secure --repo githubusername/github-repository --in secrets.yaml
```

If you run this command in the root of your project, a new file called `.drone.sec`
must be present now. Just commit it alongside your code and from now on, Drone will
inject your secrets into the build.
