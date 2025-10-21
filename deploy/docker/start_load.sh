#!/bin/bash

if [ -z "$1" ]
  then
    echo "Hostname or IP address of the QotD Web service is required."
    exit -1
fi

HOSTNAME=$1

echo "Starting QotD load generators for host $HOSTNAME"

docker run -d --name=qotd-load-1 \
    -e LOG_LEVEL="info" \
    -e QRCODE="true" \
    -e QOTD_WEB_HOST=http://$HOSTNAME:3000 \
    registry.gitlab.com/quote-of-the-day/qotd-load-generator:v5.1.0

docker run -d --name=qotd-load-2 \
    -e LOG_LEVEL="info" \
    -e QRCODE="true" \
    -e QOTD_WEB_HOST=http://$HOSTNAME:3000 \
    registry.gitlab.com/quote-of-the-day/qotd-load-generator:v5.1.0
