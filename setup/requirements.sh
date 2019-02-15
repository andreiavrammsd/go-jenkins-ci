#!/usr/bin/env bash
set -e

U=${USER}
DOCKER_COMPOSE_VERSION=1.23.2

# Root privileges required
[[ "$(whoami)" != "root" ]] && exec sudo -- "$0" "$@"

apt update

apt install -y make

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
apt install -y docker-ce

if [[ ${U} != "root" ]]; then
    usermod -aG docker ${U}
fi

# Docker compose
f=/usr/local/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ${f}
chmod +x ${f}

if [[ ${U} != "root" ]]; then
    exit
fi
