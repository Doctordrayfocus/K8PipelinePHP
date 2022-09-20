VERSION 0.6
FROM bash:4.4
IMPORT ./templates/nodejs/kubernetes AS nodejs_kubernetes_engine
IMPORT ./templates/nodejs/docker AS nodejs_docker_engine
IMPORT ./templates/php/kubernetes AS php_kubernetes_engine
IMPORT ./templates/php/docker AS php_docker_engine
WORKDIR /build-arena

install:
	ARG service='sample'
	ARG envs='dev,prod'
	ARG version='0.1'
	ARG docker_registry='drayfocus/earthly-sample'
	ARG apptype='nodejs'

	WORKDIR /setup-arena
	
	RUN mkdir $service

	COPY . $service

	FOR --sep="," env IN "$envs"	
		ENV dir="./$service/environments/$env"
		RUN echo "Creating environment $env"
		
		IF [ "$apptype" = "nodejs" ]
			RUN mkdir -p $dir
			DO nodejs_kubernetes_engine+DEPLOYMENT --service=$service --env=$env --dir=$dir --version=$version --docker_registry=$docker_registry
			DO nodejs_kubernetes_engine+SERVICE --service=$service --env=$env --dir=$dir
			DO nodejs_kubernetes_engine+NAMESPACE --service=$service --env=$env --dir=$dir
		END

		IF [ "$apptype" = "php" ]
			RUN mkdir -p $dir $dir/extras-$service
			DO php_kubernetes_engine+LARAVELAPP --service=$service --env=$env --dir=$dir --version=$version 
			DO php_kubernetes_engine+CONFIGMAP --service=$service --env=$env --dir=$dir
			DO php_kubernetes_engine+SECRETS --service=$service --env=$env --dir=$dir
		END

	END

	SAVE ARTIFACT $service AS LOCAL ${service}

build:
	ARG version='0.1'
	ARG docker_registry='drayfocus'
	ARG service='sample'
	ARG envs='dev,prod'
	ARG node_env="developement"
	ARG apptype='nodejs'

	IF [ "$apptype" = "nodejs" ]
		BUILD nodejs_docker_engine+node-app --version=$version --docker_registry=$docker_registry --service=$service --node_env=$node_env
	END
	IF [ "$apptype" = "php" ]
		BUILD php_docker_engine+fpm-server --version=$version --docker_registry=$docker_registry --service=$service 
		BUILD php_docker_engine+web-server --version=$version --docker_registry=$docker_registry --service=$service
		BUILD php_docker_engine+cron --version=$version --docker_registry=$docker_registry --service=$service 
	END
	
	## Update deployment.yaml with latest versions
	FOR --sep="," env IN "$envs"	
		IF [ "$apptype" = "nodejs" ]
			DO nodejs_kubernetes_engine+DEPLOYMENT --service=$service --env=$env --version=$version --docker_registry=$docker_registry
		END

		IF [ "$apptype" = "php" ]
			DO php_kubernetes_engine+LARAVELAPP --service=$service --env=$env --version=$version 
		END
		
		SAVE ARTIFACT $service/environments/$env/* AS LOCAL ${service}/environments/$env/
	END


deploy:
	FROM alpine/doctl:1.22.2
	# setup kubectl
	ARG env='dev'
	ARG DIGITALOCEAN_ACCESS_TOKEN=""
	ARG apptype='nodejs'

	COPY environments environments

	RUN kubectl version --client
	# doctl authenticating
    RUN doctl auth init --access-token ${DIGITALOCEAN_ACCESS_TOKEN}

	# save Kube config
	RUN doctl kubernetes cluster kubeconfig save cluster-name
	RUN kubectl config get-contexts	

	## deploy kubernetes configs
	IF [ "$apptype" = "nodejs" ]
		RUN kubectl apply -f environments/${env}/namespace.yaml
		RUN kubectl apply -f environments/${env}
	END

	IF [ "$apptype" = "php" ]
		RUN kubectl apply -f environments/${env}/app-template.yaml
		RUN kubectl cp environments/${env}/extras-$service $(kubectl get pod -l app=apptemplate-controller -o jsonpath="{.items[0].metadata.name}"):/usr/src/app/configs/extras
	END
	

auto-deploy:
	ARG version='0.1'
	ARG docker_registry='drayfocus'
	ARG service='sample'
	ARG env='dev'
	ARG apptype='nodejs'

	# Build and push docker images
	BUILD +build

	# Deploy to kubernetes
	BUILD +deploy

	




