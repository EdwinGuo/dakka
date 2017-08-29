FROM loyaltyone/docker-alpine-java-node:jre-8-node-8

MAINTAINER LoyaltyOne

#=============
# Docker
# Ref: https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/
#=============
ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 17.06.0-ce

RUN set -ex; \
	apk add --no-cache --virtual .fetch-deps \
		curl \
		tar \
	; \
	\
# this "case" statement is generated via "update.sh"
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64) dockerArch='x86_64' ;; \
		*) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;;\
	esac; \
	\
	if ! curl -fL -o docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"; \
		exit 1; \
	fi; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	apk del .fetch-deps; \
	\
	dockerd -v; \
	docker -v
		    
COPY bootstrap /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/env-decrypt", "/usr/local/bin/bootstrap"]