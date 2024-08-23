#!/bin/bash

IMAGE="jlesage/firefox"
NAME="firefox"
VOLUME="firefox-data"
HOST_PORT="5801"
PORT_MAP="${HOST_PORT}:5800"
MY_HOST="localhost"

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = start, stop, clean, update"
    exit 1
fi

function start_docker () {
    docker volume create ${VOLUME}
    docker run -d --rm \
        --name=${NAME} \
        -p ${PORT_MAP} \
        -v ${VOLUME}:/config \
        -e DARK_MODE=1 \
        -e KEEP_APP_RUNNING=1 \
        ${IMAGE}
    echo "connect: http://${MY_HOST}:${HOST_PORT}/"
}

function stop_docker () {
    docker stop ${NAME}
    docker rm ${NAME}
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
    clean)
        clean_docker ;;
    update)
        update_docker ;;
    *)
        echo "$0: Error: Invalid option: $1"
        exit 1
    ;;
esac
