#!/bin/bash

# https://github.com/ConSol/docker-headless-vnc-container

IMAGE="consol/debian-xfce-vnc"
NAME="xfce-vnc"
MY_HOST="localhost"

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = start, stop, clean, update"
    exit 1
fi

function start_docker () {
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
