#!/usr/bin/env bash

# Root privileges required
[[ "$(whoami)" != "root" ]] && exec sudo -- "$0" "$@"

echo

declare -A VARS
VARS["SSH_AUTHORIZED_KEYS"]=/root/.ssh/authorized_keys
VARS["NON_ROOT_USER"]=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
VARS["NON_ROOT_USER_PASSWORD"]=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
VARS["LOCALE"]=$LANG
VARS["TIMEZONE"]=$(timedatectl status | grep "Time zone" | awk '{print $3}')
VARS["JENKINS_PORT"]=9696
VARS["SSH_PORT"]=6352

KEYS=(SSH_AUTHORIZED_KEYS NON_ROOT_USER NON_ROOT_USER_PASSWORD LOCALE TIMEZONE JENKINS_PORT SSH_PORT)

for key in "${KEYS[@]}"; do
    default=${VARS[$key]}
    read -p "$key [$default] = " val
    val=${val:-$default}
    VARS[$key]=$val
    declare ${key}=$val
done

echo

for key in "${KEYS[@]}"; do
    echo ${key}=${VARS[$key]}
done

echo
echo -n "Are the above correct? [y/N] " && read ans && [ $${ans:-N} == y ]
[[ "${ans}" != "y" ]] && exit 0

if [[ ! -f ${SSH_AUTHORIZED_KEYS} ]]; then
    echo An SSH private key is expected at ${SSH_AUTHORIZED_KEYS}
    exit 1
fi

if [[ -z ${NON_ROOT_USER} || -z ${NON_ROOT_USER_PASSWORD} ]]; then
    echo Non root username and password required
    exit 1
fi

if [[ -z ${JENKINS_PORT} ]]; then
    echo The port you want Jenkins to run on is required
    exit 1
fi

if [[ -z ${SSH_PORT} ]]; then
    echo The port you want SSH to run on is required
    exit 1
fi

# Stay up to date
apt update && apt upgrade -y

# Locale and timezone settings
if [[ -z "${LOCALE}" ]]; then
    locale-gen ${LOCALE}
fi

if [[ -z "${TIMEZONE}" ]]; then
    timedatectl set-timezone ${TIMEZONE}
fi

# Create non root user
useradd -d /home/${NON_ROOT_USER} -m -U -G sudo ${NON_ROOT_USER} -s /bin/bash
printf "$NON_ROOT_USER_PASSWORD\n$NON_ROOT_USER_PASSWORD\n" | passwd ${NON_ROOT_USER}

# Set ssh access
mkdir -p /home/${NON_ROOT_USER}/.ssh
mv ${SSH_AUTHORIZED_KEYS} /home/${NON_ROOT_USER}/.ssh/authorized_keys
chown -R ${NON_ROOT_USER}:${NON_ROOT_USER} /home/${NON_ROOT_USER}/.ssh

# Disable password and root auth
sshdconfig="/etc/ssh/sshd_config"
sed -i -re "s/^(\#?)(PasswordAuthentication)([[:space:]]+)yes/\2\3no/" ${sshdconfig}
sed -i -re "s/^(\#?)(ChallengeResponseAuthentication)([[:space:]]+)yes/\2\3no/" ${sshdconfig}
sed -i -re "s/^(\#?)(UsePAM)([[:space:]]+)yes/\2\3no/" ${sshdconfig}
sed -i -re "s/^(\#?)(Port)([[:space:]]+)([0-9]+)/\2\3${SSH_PORT}/" ${sshdconfig}
sed -i -re "s/^(\#?)(PermitRootLogin)([[:space:]]+)yes/\2\3no/" ${sshdconfig}
sudo systemctl reload sshd

# Enable firewall
apt install ufw -y
echo "y" | ufw enable
ufw allow ${JENKINS_PORT}
ufw allow ${SSH_PORT}

# Cleanup
apt clean
apt autoremove --purge -y

# Reboot
echo
echo -n "Reboot is required. Then login with 'ssh ${NON_ROOT_USER}@host -p ${SSH_PORT}'. Reboot now? [y/N] " && read ans && [ $${ans:-N} == y ]
[[ "${ans}" = "y" ]] && reboot
