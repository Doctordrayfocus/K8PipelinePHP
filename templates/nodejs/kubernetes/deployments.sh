#!/usr/bin/env bash

SERVICE_NAME=$1
ENV=$2
REGISTRY=$3
DIR_ROOT=$4
VERSION=$5


echo "Setting up deployments deployment.yaml for $ENV";
cat > $DIR_ROOT/environments/$ENV/deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${SERVICE_NAME}-deployment
  namespace: ${ENV}-${SERVICE_NAME}
  labels:
    app: ${SERVICE_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${SERVICE_NAME}
  template:
    metadata:
      labels:
        app: ${SERVICE_NAME}
    spec:
      containers:
      - name: ${SERVICE_NAME}-deployment
        image: ${REGISTRY}/${SERVICE_NAME}_node_app:v${VERSION}
        ports:
        - containerPort: 3000
EOF
