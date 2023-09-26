#!/bin/bash

IMAGE="portainer/portainer-ce"
NAME="portainer"
DATA="portainer-data"
PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c20)

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = pull, start, stop, rm, update"
    exit 1
fi

case "$1" in
    pull)
        docker pull $IMAGE:latest
    ;;
    start)
        PASS_HASH=$(docker run --rm httpd:2.4-alpine htpasswd -nbB admin "$PASS" | cut -d ":" -f 2)
		docker volume create $DATA
        docker run \
        -d --restart always \
        -v /var/run/docker.sock:/var/run/docker.sock \
		-v $DATA:/data \
        -p 9000:9000 \
        --name=$NAME \
        $IMAGE --admin-password "$PASS_HASH" -H unix:///var/run/docker.sock
        echo "Go to -- http://localhost:9000 | Admin Password: $PASS"
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
