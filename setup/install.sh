#!/usr/bin/env bash

echo Configuring...
echo

out=""
lines=`cat ./.env.dist`
current=`cat ./.env 2> /dev/null`

for line in ${lines}; do
    var=$(echo "$line" | cut -d '=' -f1)
    default=""

    for c in ${current}; do
        v=$(echo "$c" | cut -d '=' -f1)
        if [[ ${var} = ${v} ]]; then
            default=$(echo "$c" | cut -d '=' -f2)
            break
        fi
    done

    if [[ -z "$default" ]]; then
        default=$(echo "$line" | cut -d '=' -f2)

        if [[ "$var" = "JENKINS_USER" ]]; then
            default=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
        fi
        if [[ "$var" = "JENKINS_PASS" ]]; then
            default=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
        fi
    fi

    echo -n "$var [$default] = "
    read val

    val=${val:-$default}
    out+="$var=$val\n"
done

echo -e ${out} > .env

echo
echo Installing...
echo
sudo make
