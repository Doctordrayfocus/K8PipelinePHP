VERSION 0.6
FROM bash:4.4
IMPORT ./templates/kubernetes AS php_kubernetes_engine
IMPORT ./templates/docker AS php_docker_engine
WORKDIR /build-arena

install:
	ARG service='sample'
	ARG envs='dev,prod'
	ARG version='0.1'
	ARG docker_registry='docker.io'
	ARG apptype='php'
	ARG upload_url="http://localhost:8080/save-service-setup"

	RUN apk add zip

	RUN apk add curl

	WORKDIR /setup-arena
	
	RUN mkdir $service $service/app

	COPY templates $service/templates
	COPY Earthfile $service

	FOR --sep="," env IN "$envs"
		ENV dir="./$service/environments/$env"
		RUN echo "Creating environment $env"
	
		RUN mkdir -p $dir $dir/extras-$service
		DO php_kubernetes_engine+LARAVELAPP --service=$service --env=$env --version=$version 
		DO php_kubernetes_engine+CONFIGMAP --service=$service --env=$env 
		DO php_kubernetes_engine+SECRETS --service=$service --env=$env

	END

	RUN zip -r  /setup-arena/${service}.zip /setup-arena/${service}

	RUN curl -F "data=@/setup-arena/$service.zip" ${upload_url}


build:
	ARG version='0.1'
	ARG docker_registry='docker.io'
	ARG service='sample'
	ARG envs='dev'
	ARG apptype='php'

	WORKDIR /build-arena

	COPY ./environments ${service}/environments

	BUILD php_docker_engine+fpm-server --version=$version --docker_registry=$docker_registry --service=$service 
	BUILD php_docker_engine+web-server --version=$version --docker_registry=$docker_registry --service=$service
	BUILD php_docker_engine+cron --version=$version --docker_registry=$docker_registry --service=$service 
	
	
deploy:
	FROM alpine/doctl:1.22.2
	# setup kubectl
	ARG service=""
	ARG envs=""
	ARG DIGITALOCEAN_ACCESS_TOKEN=""
	ARG template=''

	COPY ./environments ${service}/environments

	## Update apptemplate.yaml with latest versions

	DO php_kubernetes_engine+LARAVELAPP --template=$template --service=$service --envs=$envs


	RUN kubectl version --client
	# doctl authenticating
    RUN doctl auth init --access-token ${DIGITALOCEAN_ACCESS_TOKEN}

	# save Kube config
	RUN doctl kubernetes cluster kubeconfig save roof-income
	RUN kubectl config get-contexts	

	## deploy kubernetes configs
	
	RUN kubectl cp $service/environments/${envs}/extras-$service $(kubectl get pod -l app=roofapptemplate-controller -o jsonpath="{.items[0].metadata.name}"):/usr/src/app/configs
	RUN kubectl apply -f $service/environments/${envs}/app-template.yaml

	# Waiting for pods to build

	# RUN sleep 20s

	# Running database migration

	# RUN kubectl exec -n ${envs}-${service} deploy/${service}-fpm  -- php artisan migrate --force
	


