FROM nginx:1.13.0-alpine
MAINTAINER Grok Interactive <developers@grok-interactive.com>

RUN apk update && \
    apk upgrade && \
    apk add --upgrade coreutils python py-pip && \
    rm -rf /var/cache/apk/*

RUN pip install awscli

RUN apk --purge -v del py-pip

WORKDIR /etc/nginx/

ADD docker/aws/nginx_proxy/nginx.conf /etc/nginx/nginx.conf
ADD docker/aws/nginx_proxy/bin/ /usr/local/bin/

CMD start-nginx
