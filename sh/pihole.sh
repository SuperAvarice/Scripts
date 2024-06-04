#!/bin/bash

NAME="pihole"
IMAGE="pihole/pihole:latest"
DATA="/docker/appdata/pihole"
TIME_ZONE="America/Chicago"
NETWORK="0.0.0"
SERVER_IP="0"
DOMAIN="lan"
THEME="lcars"
TEMP_UNIT="f"

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = start, stop, setpass, clean, update"
    exit 1
fi

function start_docker () {
    docker run -d \
        --name=${NAME} \
        --hostname ${NAME} \
        -p 53:53/tcp -p 53:53/udp \
        -p 80:80/tcp \
        -e TZ="${TIME_ZONE}" \
        -e FTLCONF_LOCAL_IPV4="${NETWORK}.${SERVER_IP}" \
        -e REV_SERVER="true" \
        -e REV_SERVER_TARGET="${NETWORK}.1" \
        -e REV_SERVER_DOMAIN="${DOMAIN}" \
        -e REV_SERVER_CIDR="${NETWORK}.0/24" \
        -e WEBTHEME="${THEME}" \
        -e TEMPERATUREUNIT="${TEMP_UNIT}" \
        -v "${DATA}/etc/:/etc/pihole/" \
        -v "${DATA}/dnsmasqd/:/etc/dnsmasq.d/" \
        -v "/etc/timezone:/etc/timezone:ro" \
        -v "/etc/localtime:/etc/localtime:ro" \
        --dns=127.0.0.1 --dns=1.1.1.1 \
        --cap-add=NET_ADMIN \
        --restart unless-stopped \
        ${IMAGE}
}

function stop_docker () {
    docker stop ${NAME}
    docker rm ${NAME}
}

function setpass_docker () {
    docker exec -it ${NAME} pihole -a -p
}

function clean_docker () {
    docker builder prune --all --force
    docker image rm ${IMAGE}
    docker volume rm ${VOLUME}
}

function update_docker () {
    stop_docker
    docker pull ${IMAGE}
    start_docker
}

case "$1" in
    start)
        start_docker ;;
    stop)
        stop_docker ;;
    setpass)
        setpass_docker ;;
    clean)
        clean_docker ;;
    update)
        update_docker ;;
    *)
        echo "$0: Error: Invalid option: $1"
        exit 1
    ;;
esac
