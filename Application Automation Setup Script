#!/bin/bash

set -e

APP_NAME="my-web-app"
GIT_REPO_URL="https://github.com/harshalsabale1/gittt.git"
DOCKER_IMAGE_NAME="my-web-app-image"
DOCKER_CONTAINER_NAME="my-web-app-container"
APP_PORT=8080

echo "Updating system packages..."
sudo yum update -y
sudo yum upgrade -y

echo "Installing Git..."
sudo yum install git -y

echo "Installing Docker..."
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo docker --version

if [ -d "$APP_NAME" ]; then
    echo "Removing existing application directory..."
    rm -rf $APP_NAME
fi

echo "Cloning the application repository..."
git clone $GIT_REPO_URL $APP_NAME
cd $APP_NAME

echo "Building Docker image..."
sudo docker build -t $DOCKER_IMAGE_NAME .

echo "Running Docker container..."
sudo docker container run -dt --name $DOCKER_CONTAINER_NAME -p $APP_PORT:80 $DOCKER_IMAGE_NAME

echo "Application setup complete. Your application is running on port $APP_PORT."
