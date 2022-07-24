#!/usr/bin/env bash

SERVICE_NAME=$1
ENV=$2
DIR_ROOT=$3

echo "Setting up secrets secrets.yaml for $ENV";

cat > $DIR_ROOT/environments/$ENV/secrets.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $SERVICE_NAME
  namespace: $ENV-$SERVICE_NAME
type: Opaque
stringData:
  APP_KEY: ""
  DB_USERNAME: "$ENV"
  DB_PASSWORD: "password"
  REDIS_PASSWORD: "null"
  MAIL_USERNAME: "null"
  MAIL_PASSWORD: "null"
  AWS_ACCESS_KEY_ID: ""
  AWS_SECRET_ACCESS_KEY: ""
  PUSHER_APP_KEY: ""
  PUSHER_APP_SECRET: ""
  MIX_PUSHER_APP_KEY: "PUSHER_APP_KEY"
EOF