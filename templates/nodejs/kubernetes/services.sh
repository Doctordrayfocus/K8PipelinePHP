#!/usr/bin/env bash

SERVICE_NAME=$1
ENV=$2
DIR_ROOT=$3

echo "Setting up services service.yaml $ENV";
cat > $DIR_ROOT/environments/$ENV/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}-service
spec:
  selector:
    app: ${SERVICE_NAME}
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 5000
    targetPort: 3000
    nodePort: 31110
EOF