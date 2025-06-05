#!/bin/bash

SETUP_FILE="./env.cfg"
if [ ! -f $SETUP_FILE ]; then
  echo 'Setup file not found. Creating with defaults.'
  DEFAULT_DB_PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c20)
  DEFAULT_ADMIN_PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c20)
  echo "BASE_DIR=\"${HOME}/docker\"" >> ${SETUP_FILE}
  echo "DB_PW=\"${DEFAULT_DB_PW}\"" >> ${SETUP_FILE}
  echo "ADMIN_PW=\"${DEFAULT_ADMIN_PW}\"" >> ${SETUP_FILE}
fi
source $SETUP_FILE

DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
BUILD_DIR="${BASE_DIR}/build/monitoring"
BIN_DIR="${BASE_DIR}/bin"
DATA_DIR="${BASE_DIR}/appdata/monitoring"

if [[ -z "$@" ]]; then
    echo >&2 "Usage: $0 <command>"
    echo >&2 "command = up, down, restart, clean, logs"
    exit 1
fi

case "$1" in
  up)
    cd $BUILD_DIR
    ROOT_DIR=${DATA_DIR} DB_PW="${DB_PW}" ADMIN_PW="${ADMIN_PW}" DOCKER_GID="${DOCKER_GID}" docker-compose -p "Monitoring" up -d
    echo "Go to -- http://${HOSTNAME}:3000 for Grafana"
    echo "Database Password: ${DB_PW}"
    echo "Grafana Admin Password: ${ADMIN_PW}"
    echo "Edit ${SETUP_FILE} to change settings."
    cd $BIN_DIR
  ;;
  down)
    cd $BUILD_DIR
    docker-compose down
    cd $BIN_DIR
  ;;
  restart)
    ./$0 down
    ./$0 up
  ;;
  clean)
    cd $BUILD_DIR
    docker-compose down -v
    cd $BIN_DIR
  ;;
  logs)
    cd $BUILD_DIR
    docker-compose logs
    cd $BIN_DIR
  ;;
  *)
    echo "$0: Error: Invalid option: $1"
    exit 1
  ;;
esac
