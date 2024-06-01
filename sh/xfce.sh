#!/bin/bash

# https://github.com/ConSol/docker-headless-vnc-container

IMAGE="consol/debian-xfce-vnc"
NAME="xfce-vnc"
MY_HOST="localhost"

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
	docker run -d \
        --name=${NAME} \
        --user $(id -u):$(id -g) \
        -p 5901:5901 \
        -p 6901:6901 \
        -e VNC_RESOLUTION="1920x1080" \
        ${IMAGE}
        echo "connect via VNC viewer host:5901"
        echo "connect via noVNC HTML5 full client: http://${MY_HOST}:6901/vnc.html?password=vncpassword"
        echo "connect via noVNC HTML5 lite client: http://${MY_HOST}:6901/?password=vncpassword"
    ;;
    stop)
        docker stop ${NAME}
    ;;
    rm)
        docker rm ${NAME}
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
