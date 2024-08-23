#!/bin/bash

# Info: https://github.com/plexinc/pms-docker

#IMAGE="plexinc/pms-docker:plexpass" -- This tag is really old, do not use.
IMAGE="plexinc/pms-docker:latest"
NAME="plex"
SERVER_NAME="PlexServer"
DATA_DIR="/docker/appdata/plex" # Configs for Plex
MEDIA_DIR="/media" # Mounts for content on NAS (RO) and mounts for dvr and transcode (RW)
TIME_ZONE="America/Chicago"
PLEX_CLAIM="claim-**************"
ADVERTISE_IP="http://0.0.0.0:32400/"

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = start, stop, clean, update"
    exit 1
fi

function start_docker () {
    docker run -d \
	    --name=${NAME} \
        --network=host \
        --device /dev/dri:/dev/dri \
        --restart unless-stopped \
        -h ${SERVER_NAME} \
        -e TZ="${TIME_ZONE}" \
        -e PLEX_CLAIM="${PLEX_CLAIM}" \
        -e ADVERTISE_IP="${ADVERTISE_IP}" \
        -v ${MEDIA_DIR}/tv:/data/tv:ro \
        -v ${MEDIA_DIR}/movies:/data/movies:ro \
        -v ${MEDIA_DIR}/dvr:/data/dvr \
        -v ${MEDIA_DIR}/transcode:/transcode \
        -v ${DATA_DIR}/config:/config \
        ${IMAGE}
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
