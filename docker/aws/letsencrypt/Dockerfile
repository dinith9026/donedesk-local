FROM alpine:3.6
MAINTAINER Grok Interactive <developers@grok-interactive.com>

RUN apk update && apk upgrade && \
    apk add --upgrade coreutils certbot openssl python py-pip

RUN pip install awscli

RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

ADD docker/aws/letsencrypt/bin/install-dummy-certificates /usr/local/bin/install-dummy-certificates
RUN install-dummy-certificates

RUN mkdir -p \
  /var/www/letsencrypt \
  /etc/letsencrypt

WORKDIR /etc/letsencrypt/

ADD docker/aws/letsencrypt/bin/ /usr/local/bin/
ADD docker/aws/letsencrypt/certbot.cli.ini /root/.config/letsencrypt/cli.ini

CMD fetch-certificates-from-s3; tail -f /dev/stdout
