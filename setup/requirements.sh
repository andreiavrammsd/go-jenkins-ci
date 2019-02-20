#!/usr/bin/env bash
set -e

DOCKER_COMPOSE_VERSION=1.23.2

# Root privileges required
[[ "$(whoami)" != "root" ]] && exec sudo -- "$0" "$@"

# Determine distribution
osid=$(cat /etc/os-release 2> /dev/null | grep ^ID= | awk -F "=" '{print $2}')
osid="${osid//\"}"

case ${osid} in
    debian|ubuntu)
        apt update
        apt install -y curl make

        # Docker
        apt install -y \
            apt-transport-https \
            ca-certificates \
            software-properties-common
        curl -fsSL https://download.docker.com/linux/${osid}/gpg | sudo apt-key add -
        apt-key fingerprint 0EBFCD88
        add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/${osid} \
           $(lsb_release -cs) \
           stable"

        apt update
        apt install -y docker-ce
        ;;
    centos)
        [[ -z $(which curl) ]] && yum install -y curl
        [[ -z $(which make) ]] && yum install -y make

        # Docker
        yum install -y yum-utils device-mapper-persistent-data lvm2
        yum-config-manager \
            --add-repo \
            https://download.docker.com/linux/${osid}/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io

        systemctl enable docker

        service docker status > /dev/null
        [[ $? != 0 ]] && service docker start
        ;;
    fedora)
        dnf -y install dnf-plugins-core

        # Docker
        dnf config-manager \
            --add-repo \
            https://download.docker.com/linux/${osid}/docker-ce.repo
        dnf install docker-ce docker-ce-cli containerd.io

        systemctl enable docker

        service docker status &> /dev/null
        [[ $? != 0 ]] && service docker start
        ;;
    *)
        echo Cannot install requirements automatically
        exit 1
    ;;
esac

[[ ! -z ${SUDO_USER} ]] && usermod -aG docker ${SUDO_USER}

# Docker compose
f=/usr/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ${f}
chmod +x ${f}
