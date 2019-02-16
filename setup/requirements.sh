#!/usr/bin/env bash
set -e

DOCKER_COMPOSE_VERSION=1.23.2

# Root privileges required
[[ "$(whoami)" != "root" ]] && exec sudo -- "$0" "$@"

apt update
apt install -y curl make software-properties-common apt-transport-https

# Docker
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
osid=$(cat /etc/os-release | grep ^ID= | awk -F "=" '{print $2}')
curl -fsSL https://download.docker.com/linux/${osid}/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/${osid} \
   $(lsb_release -cs) \
   stable"

apt update
apt install -y docker-ce

[[ ! -z ${SUDO_USER} ]] && usermod -aG docker ${SUDO_USER}

# Docker compose
f=/usr/local/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ${f}
chmod +x ${f}
