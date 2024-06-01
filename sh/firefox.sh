#!/bin/bash

IMAGE="jlesage/firefox"
NAME="firefox"
VOLUME="firefox-data"
PORT_MAP="5801:5800" 
MY_HOST="localhost"

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = pull, start, stop, rm, clean, update"
    exit 1
fi

case "$1" in
    pull)
        docker pull ${IMAGE}
    ;;
    start)
        docker volume create ${VOLUME}
        docker run -d --rm \
            --name=${NAME} \
            -p ${PORT_MAP} \
            -v ${VOLUME}:/config \
            -e DARK_MODE=1 \
            -e KEEP_APP_RUNNING=1 \
            ${IMAGE}
        echo "connect: http://${MY_HOST}:5801/"
    ;;
    stop)
        docker stop ${NAME}
    ;;
    rm)
        docker rm ${NAME}
    ;;
    clean)
        docker builder prune --all --force
        docker image rm ${IMAGE}
        docker volume rm ${VOLUME}
    ;;
    update)
        ./$0 stop
        ./$0 pull
        ./$0 start
    ;;
    *)
        echo "$0: Error: Invalid option: $1"
        exit 1
    ;;
esac
