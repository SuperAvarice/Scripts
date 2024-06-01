#!/bin/bash

IMAGE="hello-world"
NAME="hello-world"
#VOLUME="" -v ${VOLUME}:/data \
#DATA_DIR="" -v ${DATA_DIR}:/data \
#PORT_MAP="80:80" -p ${PORT_MAP} \

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = pull, start, stop, rm, update"
    exit 1
fi

case "$1" in
    pull)
        docker pull ${IMAGE}
    ;;
    start)
        #docker volume create ${VOLUME}
        docker run \
	    --name=${NAME} \
        ${IMAGE}
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
        #docker volume rm ${VOLUME}
    ;;
    update)
        ./$0 stop
        ./$0 rm
        ./$0 pull
        ./$0 start
    ;;
    *)
        echo "$0: Error: Invalid option: $1"
        exit 1
    ;;
esac
