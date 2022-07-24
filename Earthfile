VERSION 0.6
FROM bash:4.4
IMPORT ./templates/php AS php_engine
IMPORT ./templates/php/docker AS php_docker_engine
IMPORT ./templates/kubectl AS kubectl_engine
WORKDIR /build-arena

install-php:
	FROM php_engine+setup-docker 

	SAVE ARTIFACT conf docker/conf AS LOCAL docker/conf
	SAVE ARTIFACT docker-compose.yml AS LOCAL docker-compose.yml
	SAVE ARTIFACT Dockerfile AS LOCAL docker/Dockerfile
	SAVE ARTIFACT environments AS LOCAL environments

push-php:
	FROM alpine/doctl:1.22.2
	ARG version='0.1'
	ARG docker_registry='drayfocus'
	ARG service='sample'
	ARG DOCKER_USERNAME=''
	ARG DOCKER_PASSWORD=''
	RUN apk add --update docker openrc
	RUN rc-update add docker boot
	RUN apk update && \
	apk add cmd:pip3 && \
    apk add --no-cache docker-cli python3 && \
	&& pip3 install --upgrade pip && \
    apk add --no-cache --virtual .docker-compose-deps python3-dev libffi-dev openssl-dev gcc libc-dev make && \
    pip3 install docker-compose && \
    apk del .docker-compose-deps

	RUN mkdir -p /build-arena

	# Next, set our working directory
	WORKDIR /build-arena

	COPY docker-compose.yml .
	COPY templates/php/docker docker

	# build docker images
	RUN docker-compose --version
	RUN docker --version

	# # authenticate docker
	# RUN docker login -u=${DOCKER_USERNAME} -p=${DOCKER_PASSWORD}

	# # tag images
	# RUN docker tag ${service}/cron ${docker_registry}/${service}_cron:v${version}
	# RUN docker tag ${service}/fpm_server ${docker_registry}/${service}_fpm_server:v${version}
	# RUN docker tag ${service}/web_server ${docker_registry}/${service}_web_server:v${version}

	# # push images
	# RUN docker push ${docker_registry}/${service}_cron:v${version}
	# RUN docker push ${docker_registry}/${service}_fpm_server:v${version}
	# RUN docker push ${docker_registry}/${service}_web_server:v${version}

build-php:
	ARG version='0.1'
	ARG docker_registry='drayfocus'
	ARG service='sample'
	ARG envs='dev,prod'
	COPY docker docker
	COPY docker-compose.yml .

	BUILD php_docker_engine+fpm-server --version=$version --docker_registry=$docker_registry --service=$service 
	BUILD php_docker_engine+web-server --version=$version --docker_registry=$docker_registry --service=$service
	BUILD php_docker_engine+cron --version=$version --docker_registry=$docker_registry --service=$service

	## update deployment.yaml with latest versions
	COPY ./templates/php/kubernetes kubernetes
	COPY environments environments
	COPY version-update.sh .
	RUN chmod -R 775 .
	RUN ./version-update.sh $envs $service $docker_registry $version
	SAVE ARTIFACT environments AS LOCAL environments

deploy:
	FROM alpine/doctl:1.22.2
	RUN apk add --update docker openrc
	RUN rc-update add docker boot
	# setup kubectl
	ARG env='dev'
	ARG DIGITALOCEAN_ACCESS_TOKEN=""

	COPY environments environments

	RUN kubectl version --client
	# doctl authenticating
    RUN doctl auth init --access-token ${DIGITALOCEAN_ACCESS_TOKEN}

	# save Kube config
	RUN doctl kubernetes cluster kubeconfig save roof-income
	RUN kubectl config get-contexts

	RUN doctl registry login

	RUN docker --version

	# ## deploy kubernetes configs
	# RUN kubectl apply -f environments/${env}/namespace.yaml
	# RUN kubectl apply -f environments/${env}

	




