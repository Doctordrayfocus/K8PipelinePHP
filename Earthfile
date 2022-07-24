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
	# setup kubectl
	ARG env='dev'

	COPY environments environments

	RUN kubectl version --client
	# doctl authenticating
    RUN doctl auth init --access-token dop_v1_d45f4f3c0714c8004429e517a9c7bb9dfbe112c9ce44296b2bde239bc1be7fe1

	# save Kube config
	RUN doctl kubernetes cluster kubeconfig save roof-income
	RUN kubectl config get-contexts

	RUN doctl registry login

	# ## deploy kubernetes configs
	# RUN kubectl apply -f environments/${env}/namespace.yaml
	# RUN kubectl apply -f environments/${env}

	




