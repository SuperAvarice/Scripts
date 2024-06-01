#!/bin/bash

# Info: https://github.com/plexinc/pms-docker

#IMAGE="plexinc/pms-docker:plexpass" -- This tag is really old, do not use.
IMAGE="plexinc/pms-docker:latest"
NAME="plex"
SERVER_NAME="PlexServer"
DATA_DIR="/docker/appdata/plex"
MEDIA_DIR="/media"
TIME_ZONE="America/Chicago"
PLEX_CLAIM="claim-**************"
ADVERTISE_IP="http://0.0.0.0:32400/"

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

