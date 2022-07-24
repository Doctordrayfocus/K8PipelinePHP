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
	FROM earthly/dind:alpine
	ARG version='0.1'
	ARG docker_registry='drayfocus/earthly-sample'
	ARG service='sample'
	ARG envs='dev,prod'
	COPY docker docker
	COPY docker-compose.yml .
	
	WITH DOCKER \
			--compose docker-compose.yml \
			--load fpm_server:$version=php_docker_engine+fpm-server \
			--load web_server:$version=php_docker_engine+web-server \
			--load cron:$version=php_docker_engine+cron 
        RUN docker build --network=laravel-in-kubernetes fpm_server:$version && \
			docker build --network=laravel-in-kubernetes web_server:$version && \
			docker build --network=laravel-in-kubernetes cron:$version 
    END

	## update deployment.yaml with latest versions
	COPY ./templates/php/kubernetes kubernetes
	COPY environments environments
	COPY version-update.sh .
	RUN chmod -R 775 .
	RUN RUN ./version-update.sh $envs $service $docker_registry $version
	SAVE ARTIFACT environments AS LOCAL environments

deploy:
	FROM alpine/doctl:1.22.2
	# setup kubectl
	ARG env='dev'

	COPY environments environments

	RUN kubectl version --client
	# doctl authenticating
    RUN doctl auth init -t dop_v1_00829cd565e3210d8dbaad6f862bee2d57156a071b39817d8bbc9d917cce0e79

	# save Kube config
	RUN doctl kubernetes cluster kubeconfig save roof-income
	RUN kubectl config get-contexts
	

	# ## deploy kubernetes configs
	# RUN kubectl apply -f environments/${env}/namespace.yaml
	# RUN kubectl apply -f environments/${env}

	




