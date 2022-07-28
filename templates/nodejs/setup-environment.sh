#!/usr/bin/env bash

ENV_STRING=$1
IFS=','
read -a ENVS <<< "$ENV_STRING"
SERVICE_NAME=$2
REGISTRY=$3
VERSION=$4
FOLDER=$5

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );

for ENV in ${ENVS[@]}
do
	mkdir $DIR/$FOLDER/environments/$ENV/
	./kubernetes/deployments.sh $SERVICE_NAME $ENV $REGISTRY $DIR/$FOLDER $VERSION
	./kubernetes/services.sh $SERVICE_NAME $ENV $DIR/$FOLDER
	./kubernetes/namespace.sh $SERVICE_NAME $ENV $DIR/$FOLDER
done