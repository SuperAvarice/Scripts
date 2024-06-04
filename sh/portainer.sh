#!/bin/bash

IMAGE="portainer/portainer-ce"
NAME="portainer"
VOLUME="portainer-data"
PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c20)

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = start, stop, clean, update"
    exit 1
fi

function start_docker () {
    PASS_HASH=$(docker run --rm httpd:2.4-alpine htpasswd -nbB admin "${PASS}" | cut -d ":" -f 2)
    docker volume create ${VOLUME}
    docker run -d \
        --restart always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${VOLUME}:/data \
        -p 9000:9000 \
        --name=${NAME} \
        ${IMAGE} --admin-password "${PASS_HASH}" -H unix:///var/run/docker.sock
    echo "Go to -- http://localhost:9000 | Admin Password: ${PASS}"
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
