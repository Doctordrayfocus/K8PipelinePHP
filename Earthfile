VERSION 0.6
FROM bash:4.4
IMPORT ./templates/php AS php_engine
IMPORT ./templates/php/docker AS php_docker_engine
IMPORT ./templates/nodejs AS nodejs_engine
IMPORT ./templates/nodejs/docker AS nodejs_docker_engine
WORKDIR /build-arena

install:
	ARG service_lang=php
	ARG service='sample'
	FROM busybox
	IF [ "$service_lang" = "php" ]
		FROM php_engine+setup-docker  --service=$service
	ELSE
		FROM nodejs_engine+setup-docker --service=$service
	END

	# create project setup folder
	COPY templates ${service}/templates
	COPY version-update.sh ./${service}
	COPY Earthfile ./${service}

	SAVE ARTIFACT $service AS LOCAL ${service}

build:
	ARG service_lang='php'
	ARG version='0.1'
	ARG docker_registry='drayfocus'
	ARG service='sample'
	ARG envs='dev,prod'
	ARG node_env="developement"

	IF [ "$service_lang" = "php" ]
		BUILD php_docker_engine+fpm-server --version=$version --docker_registry=$docker_registry --service=$service 
		BUILD php_docker_engine+web-server --version=$version --docker_registry=$docker_registry --service=$service
		BUILD php_docker_engine+cron --version=$version --docker_registry=$docker_registry --service=$service
	ELSE
		BUILD nodejs_docker_engine+node-app --version=$version --docker_registry=$docker_registry --service=$service --node_env=$node_env
	END

	## update deployment.yaml with latest versions
	COPY ./templates/php/kubernetes kubernetes
	COPY environments environments
	COPY version-update.sh .
	RUN chmod -R 775 .
	RUN ./version-update.sh $envs $service $docker_registry $version
	SAVE ARTIFACT environments AS LOCAL environments


deploy:
	FROM alpine/doctl:1.22.2
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

	## deploy kubernetes configs
	RUN kubectl apply -f environments/${env}/namespace.yaml
	RUN kubectl apply -f environments/${env}

auto-deploy:
	ARG version='0.1'
	ARG docker_registry='drayfocus'
	ARG service='sample'
	ARG env='dev'

	# build and push docker images
	BUILD +build

	# Deploy to kubernetes
	BUILD +deploy

	




