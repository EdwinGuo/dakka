# A Docker image for Akka Cluster applications
_Making it easier to run your Akka Cluster applications in AWS ECS_

A compact docker image based on Alpine Linux with:
- JRE 8 (8u111)
- Node.JS 7 (7.7.1)
- kms-env 
- bootstrapping behavior for retrieving host ip /port within container

In addition to having Node.JS and Java installed, this image comes with [kms-env](https://github.com/ukayani/kms-env) 
installed. If you pass in environment variables encrypted using `kms-env`. The image will automatically decrypt them. 

In order for decryption to work, your docker container must be running on an ec2-instance with a role that has access 
to AWS KMS (and the master key used for encryption).

## Instructions

### Pre-requisites
- [Docker-Mirror](https://github.com/LoyaltyOne/docker-mirror) 
  - Docker Mirror needs to be running in the same bridge network

- Set up your Akka Cluster applications to run inside a Docker container
  - The `HOST_IP` and `HOST_PORT` represent the machine's IP hosting your Docker container and the machine's port that 
  is mapped to your Docker container's port. Here's an example configuration.
  ```hocon
  akka {
    remote {
      enabled-transports = ["akka.remote.netty.tcp"]
      netty.tcp {
        bind-hostname = 0.0.0.0
        bind-port = 2551
  
        hostname = ${?HOST_IP}
        port = ${?HOST_PORT}
      }
    }
  }
  ```
  Inside the Docker container, we bind to all available network interfaces and use port 2551 but we make use of the 
  environment variables that Docker-Mirror has provided us to advertise to all external parties that it can be reached 
  via the IP of the machine/host hosting the Docker container and the port of the machine/host that is mapped to the 
  internal Docker container port. By doing this, properly allow Network Address Translation (NAT) to take place as 
  suggested by the [Akka documentation](http://doc.akka.io/docs/akka/current/scala/remoting.html#akka-behind-nat-or-in-a-docker-container).
