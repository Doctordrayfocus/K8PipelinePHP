#!/usr/bin/env bash

SERVICE_NAME=$1


echo "Setting up docker-compose.yml";
cat > docker-compose.yml <<EOF
version: "3"
services:
  # We need to run the FPM container for our application
  laravel.fpm:
	build:
      context: ./docker
      target: fpm_server
    image: ${SERVICE_NAME}/fpm_server
    # We can override any env values here.
    # By default the .env in the project root will be loaded as the environment for all containers
    environment:
      APP_DEBUG: "true"
    # Mount the codebase, so any code changes we make will be propagated to the running application
    volumes:
      # Here we mount in our codebase so any changes are immediately reflected into the container
      - "./docker/laravel:/opt/apps/laravel-in-kubernetes"
    networks:
      - laravel-in-kubernetes

  # Run the web server container for static content, and proxying to our FPM container
  laravel.web:
	build:
      context: ./docker
      target: web_server
    image: ${SERVICE_NAME}/web_server
    # Expose our application port (80) through a port on our local machine (8080)
    ports:
      - "8080:80"
    environment:
      # We need to pass in the new FPM hst as the name of the fpm container on port 9000
      FPM_HOST: "laravel.fpm:9000"
    # Mount the public directory into the container so we can serve any static files directly when they change
    volumes:
      # Here we mount in our codebase so any changes are immediately reflected into the container
      - "./docker/laravel/public:/opt/apps/laravel-in-kubernetes/public"
    networks:
      - laravel-in-kubernetes
  # Run the Laravel Scheduler
  laravel.cron:
	build:
      context: ./docker
      target: cron
    image: ${SERVICE_NAME}/cron
    # Here we mount in our codebase so any changes are immediately reflected into the container
    volumes:
      # Here we mount in our codebase so any changes are immediately reflected into the container
      - "./docker/laravel:/opt/apps/laravel-in-kubernetes"
    networks:
      - laravel-in-kubernetes

networks:
  laravel-in-kubernetes:
EOF