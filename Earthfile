VERSION 0.6
FROM bash:4.4
IMPORT ./templates/nodejs AS nodejs_engine
IMPORT ./templates/nodejs/docker AS nodejs_docker_engine
WORKDIR /build-arena

install:
	ARG service='sample'
	ARG envs='dev,prod'
	FROM nodejs_engine+setup-templates --service=$service --envs=$envs

	SAVE ARTIFACT $service AS LOCAL ${service}

build:
	ARG service_lang=nodejs
	ARG version='0.1'
	ARG docker_registry='drayfocus'
	ARG service='sample'
	ARG envs='dev,prod'
	ARG node_env="developement"

	BUILD nodejs_docker_engine+node-app --version=$version --docker_registry=$docker_registry --service=$service --node_env=$node_env

	## Update deployment.yaml with latest versions
	## ToDo: Remove this when envs is handled
	ARG env='dev'
	DO nodejs_engine+DEPLOYMENT --service=$service --env=$env --version=$version --docker_registry=$docker_registry

	SAVE ARTIFACT $service/* AS LOCAL ${service} 


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

	# Build and push docker images
	BUILD +build

	# Deploy to kubernetes
	BUILD +deploy

	




