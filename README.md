# A Docker image for cloud-based Akka Cluster applications #
This project is focused on allowing the nodes in your cluster to communicate with each other when the nodes are running 
in Docker in Cloud environments that do not provide software defined network capabilities for Docker (like AWS ECS).

A compact Docker image based on Alpine Linux with:
- JRE 8 (8u111)
- Node.JS 7 (7.7.1)
- kms-env 
- bootstrapping behavior for retrieving host ip /port within container

In addition to having Node.JS and Java installed, this image comes with [kms-env](https://github.com/ukayani/kms-env) 
installed. If you pass in environment variables encrypted using `kms-env`. The image will automatically decrypt them. 

In order for decryption to work, your Docker container must be running on an EC2 instance with a role that has access 
to AWS KMS (and the master key used for encryption).

## Instructions ##
- Set up [Docker-Mirror](https://github.com/LoyaltyOne/docker-mirror) 
  - Docker-Mirror needs to be running in the same bridge network. It provides you information about your Docker host 
    and the external port mapped to your Docker container port. By default, this image expects that Docker-Mirror runs 
    on port `9001` but you can override it by supplying an environment variable named `MIRROR_PORT`.

- Specify the Akka Clustering port (`2551`) via the environment variable `APP_PORT`

- Configure your application's clustering `bind-hostname` and `bind-port`
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
      Inside the Docker container, we bind to all available network interfaces and use port `2551` and we make use of 
      the environment variables (`HOST_IP` and `HOST_PORT`) that Docker-Mirror has provided us to advertise to all external 
      parties that it can be reached via the IP of the machine/host hosting the Docker container and the port of the machine/host that         is mapped to the internal Docker container port. This allows Network Address Translation (NAT) to take place as 
      suggested by the [Akka documentation](http://doc.akka.io/docs/akka/current/scala/remoting.html#akka-behind-nat-or-in-a-docker-container).

## Architecture ##
When the `dakka` container is initialized, it makes a call out to the [Docker-Mirror](https://github.com/LoyaltyOne/docker-mirror) service that exists on the same bridge network to obtain the Docker Host IP and external Docker port (host port) that is mapped to the internal Docker container port. The Docker internal port is chosen based on your supplied `APP_PORT` (which is your Akka Clustering port). The host's port (that maps to your Docker container port) will be made available to your container via the 
`HOST_PORT` environment variable. The Host IP that is hosting your Docker container is made available to your container 
via the `HOST_IP` environment variable.
