#!/usr/bin/env bash

SERVICE_NAME=$1
ENV=$2
DIR_ROOT=$3

echo "Setting up services service.yaml $ENV";
cat > $DIR_ROOT/environments/$ENV/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME-fpm
  namespace: $ENV-$SERVICE_NAME
spec:
  selector:
    tier: backend
    layer: fpm
  ports:
    - protocol: TCP
      port: 9000
      targetPort: 9000
---
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME-webserver
  namespace: $ENV-$SERVICE_NAME
spec:
  selector:
    tier: backend
    layer: webserver
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF