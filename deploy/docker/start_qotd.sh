#!/bin/bash

if [ -z "$1" ]
  then
    echo "Hostname or IP address of host is required."
    exit -1
fi

HOSTNAME=$1

docker rm -f qotd-db
docker rm -f qotd-image
docker rm -f qotd-author
docker rm -f qotd-quote
docker rm -f qotd-ratings
docker rm -f qotd-pdf
docker rm -f qotd-engraving
docker rm -f qotd-qrcode
docker rm -f qotd-web
docker rm -f qotd-usecase

# 169.61.23.253

docker run -d --name=qotd-usecase \
    -e LOG_LEVEL="info" \
    -e BRANDING="Anomaly Generator" \
    -e AUTO_SHUTOFF="true" \
    -p 3012:3012 \
    registry.gitlab.com/quote-of-the-day/qotd-usecase-generator:v5.1.0

sleep 10

docker run -d --name=qotd-db \
    -e MYSQL_ROOT_PASSWORD=root \
    -e MYSQL_DATABASE=qotd \
    -p 3306:3306 \
    registry.gitlab.com/quote-of-the-day/qotd-db:v5.1.0

docker run -d --name=qotd-image \
    -e ANOMALY_GENERATOR_URL=http://$HOSTNAME:3012/services/image \
    -e ENABLE_INSTANA=true \
    -p 3003:3003 \
    registry.gitlab.com/quote-of-the-day/qotd-image-service:v5.1.0

docker run -d --name=qotd-author \
    -e ANOMALY_GENERATOR_URL=http://$HOSTNAME:3012/services/author \
    -e ENABLE_INSTANA=true \
    -e IMAGE_SVC=http://$HOSTNAME:3003 \
    -e DB_HOST=$HOSTNAME \
    -e DB_PORT=3306 \
    -e DB_USER=root \
    -e DB_PASS=root \
    -e DB_NAME=qotd \
    -p 3002:3002 \
    registry.gitlab.com/quote-of-the-day/qotd-author-service:v5.1.0

docker run -d --name=qotd-quote \
    -e ANOMALY_GENERATOR_URL=http://$HOSTNAME:3012/services/quote \
    -e ENABLE_INSTANA=true \
    -e DB_HOST=$HOSTNAME \
    -e DB_PORT=3306 \
    -e DB_USER=root \
    -e DB_PASS=root \
    -e DB_NAME=qotd \
    -p 3001:3001 \
    registry.gitlab.com/quote-of-the-day/quote-service:v5.1.0

docker run -d --name=qotd-engraving \
    -e ANOMALY_GENERATOR_URL=http://$HOSTNAME:3012/services/engraving \
    -e ENABLE_INSTANA=true \
    -e SUPPLY_CHAIN_URL="" \
    -e SUPPLY_CHAIN_SIMULATE=true \
    -p 3006:3006 \
    registry.gitlab.com/quote-of-the-day/qotd-engraving-service:v5.1.0

docker run -d --name=qotd-pdf \
    -e ANOMALY_GENERATOR_URL=http://$HOSTNAME:3012/services/pdf \
    -e ENABLE_INSTANA=true \
    -e QUOTE_SVC=http://$HOSTNAME:3001 \
    -p 3005:3005 \
    registry.gitlab.com/quote-of-the-day/qotd-pdf-service:v5.1.0

docker run -d --name=qotd-qrcode \
    -e ANOMALY_GENERATOR_URL=http://$HOSTNAME:3012/services/qrcode \
    -e ENABLE_INSTANA=true \
    -e WLP_LOGGING_CONSOLE_LOGLEVEL=INFO \
    -p 9080:9080 \
    registry.gitlab.com/quote-of-the-day/qotd-qrcode:v5.1.0

docker run -d --name=qotd-ratings \
    -e ANOMALY_GENERATOR_URL=http://$HOSTNAME:3012/services/ratings \
    -e ENABLE_INSTANA=true \
    -p 3004:3004 \
    registry.gitlab.com/quote-of-the-day/qotd-ratings-service:v5.1.0

docker run -d --name=qotd-web \
    -e ANOMALY_GENERATOR_URL=http://$HOSTNAME:3012/services/web \
    -e ENABLE_INSTANA=true \
    -e QUOTE_SVC="http://$HOSTNAME:3001" \
    -e AUTHOR_SVC="http://$HOSTNAME:3002" \
    -e RATING_SVC="http://$HOSTNAME:3004" \
    -e PDF_SVC="http://$HOSTNAME:3005" \
    -e ENGRAVING_SVC="http://$HOSTNAME:3006" \
    -e QRCODE_SVC="http://$HOSTNAME:9080/qotd-qrcode/qr" \
    -e BRANDING="Quote of the Day" \
    -p 3000:3000 \
    registry.gitlab.com/quote-of-the-day/qotd-web:v5.1.0
