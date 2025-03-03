#!/bin/bash

set -e

DOCKER_REPO_URL=153432822124.dkr.ecr.ap-southeast-2.amazonaws.com
DOCKER_IMAGE=lms
DOCKER_TAG=

# Check if user is in the docker group
IS_DOCKER_USER=false
if id -nG | grep -qw "docker"; then
    IS_DOCKER_USER=true
fi

function run_as_sudo {
    if $IS_DOCKER_USER; then
        $@
    else
        sudo $@
    fi
}

mvn clean package -DskipTests=True
DOCKER_TAG=$(mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.version | grep -v '\[\|Download')

# Login to AWS ECR Docker Repository - This requires awscli to be installed and configured
aws ecr get-login-password --region ap-southeast-2 | run_as_sudo docker login --username AWS --password-stdin $DOCKER_REPO_URL

run_as_sudo docker system prune -af
run_as_sudo docker build -t $DOCKER_REPO_URL/$DOCKER_IMAGE:$DOCKER_TAG .
run_as_sudo docker push $DOCKER_REPO_URL/$DOCKER_IMAGE:$DOCKER_TAG

echo "Docker build done. New tag=$DOCKER_TAG"
echo "Done!!"
