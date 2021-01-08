#!/bin/bash
IMAGE="portainer/portainer-ce"
NAME="portainer"
PASS="super_secret_pw"

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
        docker run \
        -d --restart always \
        -v /var/run/docker.sock:/var/run/docker.sock \
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
