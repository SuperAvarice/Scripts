#!/bin/bash

IMAGE="hello-world"
NAME="hello-world"
#VOLUME="" -v ${VOLUME}:/data \
#DATA_DIR="" -v ${DATA_DIR}:/data \
#PORT_MAP="80:80" -p ${PORT_MAP} \

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = start, stop, clean, update"
    exit 1
fi

function start_docker () {
    #docker volume create ${VOLUME}
    docker run \
	    --name=${NAME} \
        ${IMAGE}
}

function stop_docker () {
    docker stop ${NAME}
    docker rm ${NAME}
}

function clean_docker () {
    docker builder prune --all --force
    docker image rm ${IMAGE}
    #docker volume rm ${VOLUME}
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
