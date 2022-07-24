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
  name: ${SERVICE_NAME}-fpm
  namespace: ${ENV}-${SERVICE_NAME}
  labels:
    tier: backend
    layer: fpm
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: backend
      layer: fpm
  template:
    metadata:
      labels:
        tier: backend
        layer: fpm
    spec:
      containers:
        - name: fpm
          image: ${REGISTRY}/${SERVICE_NAME}_fpm_server:v${VERSION}
          ports:
            - containerPort: 9000
          envFrom:
            - configMapRef:
                name: ${SERVICE_NAME}
            - secretRef:
                name: ${SERVICE_NAME}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${SERVICE_NAME}-webserver
  namespace: ${ENV}-${SERVICE_NAME}
  labels:
    tier: backend
    layer: webserver
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: backend
      layer: webserver
  template:
    metadata:
      labels:
        tier: backend
        layer: webserver
    spec:
      containers:
        - name: webserver
          image: ${REGISTRY}/${SERVICE_NAME}_web_server:v${VERSION}
          ports:
            - containerPort: 80
          env:
            # Inject the FPM Host as we did with Docker Compose
            - name: FPM_HOST
              value: ${SERVICE_NAME}-fpm:9000
EOF
