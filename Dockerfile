FROM loyaltyone/docker-alpine-java-node:jre-8-node-8

MAINTAINER LoyaltyOne
		    
COPY bootstrap /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/env-decrypt", "/usr/local/bin/bootstrap"]