#!/usr/bin/env bash

SERVICE_NAME=$1
ENV=$2
DIR_ROOT=$3

echo "Setting up namespace for $ENV";

cat > $DIR_ROOT/environments/$ENV/namespace.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $ENV-$SERVICE_NAME
EOF
