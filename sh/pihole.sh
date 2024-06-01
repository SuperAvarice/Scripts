#!/bin/bash

NAME="pihole"
IMAGE="pihole/pihole:latest"
DATA="/docker/appdata/pihole"
TIME_ZONE="America/Chicago"
NETWORK="172.16.0"
SERVER_IP="200"
DOMAIN="lan"
THEME="lcars"
TEMP_UNIT="f"

if [[ -z "$@" ]]; then
  echo >&2 "Usage: $0 <command>"
  echo >&2 "command = pull, start, stop, rm, setpass, update"
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
        -e TZ="${TIME_ZONE}" \
        -e FTLCONF_LOCAL_IPV4="${NETWORK}.${SERVER_IP}" \
        -e REV_SERVER="true" \
        -e REV_SERVER_TARGET="${NETWORK}.1" \
        -e REV_SERVER_DOMAIN="${DOMAIN}" \
        -e REV_SERVER_CIDR="${NETWORK}.0/24" \
        -e WEBTHEME="${THEME}" \
        -e TEMPERATUREUNIT="${TEMP_UNIT}" \
        -v "${DATA}/etc/:/etc/pihole/" \
        -v "${DATA}/dnsmasqd/:/etc/dnsmasq.d/" \
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
    setpass)
        docker exec -it $NAME pihole -a -p
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
