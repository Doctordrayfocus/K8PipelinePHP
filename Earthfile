VERSION 0.6
FROM bash:4.4
IMPORT ./templates/nodejs AS nodejs_engine
IMPORT ./templates/nodejs/docker AS nodejs_docker_engine
WORKDIR /build-arena

install:
	ARG service='sample'
	ARG envs='dev,prod'
	ARG version='0.1'
	ARG docker_registry='drayfocus/earthly-sample' 

	WORKDIR /setup-arena
	
	FOR --sep="," env IN "$envs"	
		ENV dir="./$service/environments/$env"
		RUN echo "Creating environment $env"
		RUN mkdir -p $dir
		DO nodejs_engine+DEPLOYMENT --service=$service --env=$env --dir=$dir --version=$version --docker_registry=$docker_registry
		DO nodejs_engine+SERVICE --service=$service --env=$env --dir=$dir
		DO nodejs_engine+NAMESPACE --service=$service --env=$env --dir=$dir
	END
	SAVE ARTIFACT $service AS LOCAL ${service}

build:
	ARG version='0.1'
	ARG docker_registry='drayfocus'
	ARG service='sample'
	ARG envs='dev,prod'
	ARG node_env="developement"

	BUILD nodejs_docker_engine+node-app --version=$version --docker_registry=$docker_registry --service=$service --node_env=$node_env

	## Update deployment.yaml with latest versions
	FOR --sep="," env IN "$envs"	
		DO nodejs_engine+DEPLOYMENT --service=$service --env=$env --version=$version --docker_registry=$docker_registry
		SAVE ARTIFACT $service/environments/$env/* AS LOCAL ${service}/environments/$env/
	END


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

	




