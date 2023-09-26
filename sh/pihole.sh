#!/bin/bash

NAME="pihole"
IMAGE="pihole/pihole"
BASE_DIR="/docker/appdata/pihole"
NETWORK="172.16.0"
SERVERIP="172.16.0.200"
PASSWD="**************"

if [[ -z "$@" ]]; then
  echo >&2 "Usage: $0 <command>"
  echo >&2 "command = pull, start, stop, rm, update"
  exit 1
fi

case "$1" in
    pull)
        docker pull $IMAGE
    ;;
    start)
        docker run -d \
        --name=$NAME \
        --hostname $NAME \
        -p 53:53/tcp -p 53:53/udp \
        -p 80:80/tcp \
        -e TZ="America/Chicago" \
        -e WEBPASSWORD="${PASSWD}" \
        -e ServerIP="${SERVERIP}" \
        -e REV_SERVER="true" \
        -e REV_SERVER_TARGET="${NETWORK}.1" \
        -e REV_SERVER_DOMAIN="local" \
        -e REV_SERVER_CIDR="${NETWORK}.0/24" \
        -v "${BASE_DIR}/etc/:/etc/pihole/" \
        -v "${BASE_DIR}/dnsmasqd/:/etc/dnsmasq.d/" \
        -v "/etc/timezone:/etc/timezone:ro" \
        -v "/etc/localtime:/etc/localtime:ro" \
        --dns=127.0.0.1 --dns=1.1.1.1 \
        --cap-add=NET_ADMIN \
        --restart unless-stopped \
        $IMAGE
    ;;
    stop)
        docker stop $NAME
    ;;
    rm)
        docker rm $NAME
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
