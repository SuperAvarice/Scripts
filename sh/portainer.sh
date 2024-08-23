#!/bin/bash

IMAGE="portainer/portainer-ce"
NAME="portainer"
VOLUME="portainer-data"
PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c20)
HOST_PORT="9000"
PORT_MAP="${HOST_PORT}:9000"
MY_HOST="localhost"

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = start, stop, clean, update"
    exit 1
fi

function start_docker () {
    PASS_HASH=$(docker run --rm httpd:2.4-alpine htpasswd -nbB admin "${PASS}" | cut -d ":" -f 2)
    docker volume create ${VOLUME}
    docker run -d \
        --name=${NAME} \
        --restart always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${VOLUME}:/data \
        -p ${PORT_MAP} \
        ${IMAGE} --admin-password "${PASS_HASH}" -H unix:///var/run/docker.sock
    echo "Go to -- http://${MY_HOST}:${HOST_PORT} | Admin Password: ${PASS}"
}

function stop_docker () {
    docker stop ${NAME}
    docker rm ${NAME}
}

function clean_docker () {
    docker builder prune --all --force
    docker image rm ${IMAGE}
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
    clean)
        clean_docker ;;
    update)
        update_docker ;;
    *)
        echo "$0: Error: Invalid option: $1"
        exit 1
    ;;
esac
