#!/bin/sh

U=${USER}
DOCKER_VERSION=5:18.09.2~3-0~ubuntu-bionic # Find available versions: apt-cache madison docker-ce
DOCKER_COMPOSE_VERSION=1.23.2

if [ ${U} != "root" ]; then
    sudo su -s "$0"
    exit
fi

apt update

apt install -y make unzip

# Docker
apt remove docker docker-engine docker.io -y
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt update
apt install -y docker-ce=${DOCKER_VERSION} docker-ce-cli=${DOCKER_VERSION}

if [ ${U} != "root" ]; then
    usermod -aG docker ${U}
fi

# Docker compose
f=/usr/local/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ${f}
chmod +x ${f}

if [[ ${U} != "root" ]]; then
    exit
fi
