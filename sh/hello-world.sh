#!/bin/bash

IMAGE="hello-world"
NAME="hello-world"
#VOLUME="" -v ${VOLUME}:/data \
#DATA_DIR="" -v ${DATA_DIR}:/data \
#PORT_MAP="80:80" -p ${PORT_MAP} \

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = start, stop, update"
    exit 1
fi

case "$1" in
    start)
        #docker volume create ${VOLUME}
        docker run \
	    --name=${NAME} \
        ${IMAGE}
    ;;
    stop)
        docker stop ${NAME}
        docker rm ${NAME}
    ;;
    clean)
        docker builder prune --all --force
        docker image rm ${IMAGE}
        #docker volume rm ${VOLUME}
    ;;
    update)
        ./$0 stop
        docker pull ${IMAGE}
        ./$0 start
    ;;
    *)
        echo "$0: Error: Invalid option: $1"
        exit 1
    ;;
esac
