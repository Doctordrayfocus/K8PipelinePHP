#!/usr/bin/env bash

SERVICE_NAME=$1
ENV=$2
DIR_ROOT=$3

echo "Setting up configmap configmap.yaml for $ENV";

cat > $DIR_ROOT/environments/$ENV/configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: $SERVICE_NAME
  namespace: $ENV-$SERVICE_NAME
data:
  APP_NAME: "Laravel"
  APP_ENV: "production"
  APP_DEBUG: "true"
  # Once you have an external URL for your application, you can add it here.
  APP_URL: "http://localhost"

  # Update the LOG_CHANNEL to stdout for Kubernetes
  LOG_CHANNEL: "stdout"
  LOG_LEVEL: "debug"
  DB_CONNECTION: "mysql"
  DB_HOST: "localhost"
  DB_PORT: "3306"
  DB_DATABASE: "laravel_in_kubernetes"
  BROADCAST_DRIVER: "log"
  CACHE_DRIVER: "file"
  FILESYSTEM_DRIVER: "local"
  QUEUE_CONNECTION: "sync"

  # Update the Session driver to Redis, based off part-2 of series
  SESSION_DRIVER: "native"
  SESSION_LIFETIME: "120"
  MEMCACHED_HOST: "memcached"
  REDIS_HOST: "redis"
  REDIS_PORT: "6379"
  MAIL_MAILER: "smtp"
  MAIL_HOST: "mailhog"
  MAIL_PORT: "1025"
  MAIL_ENCRYPTION: "null"
  MAIL_FROM_ADDRESS: "null"
  MAIL_FROM_NAME: ""
  AWS_DEFAULT_REGION: "us-east-1"
  AWS_BUCKET: ""
  AWS_USE_PATH_STYLE_ENDPOINT: "false"
  PUSHER_APP_ID: ""
  PUSHER_APP_CLUSTER: "mt1"
  MIX_PUSHER_APP_KEY: "PUSHER_APP_KEY"
EOF