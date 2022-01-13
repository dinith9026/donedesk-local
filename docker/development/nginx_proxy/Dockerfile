FROM nginx:1.13.0-alpine
MAINTAINER Grok Interactive <developers@grok-interactive.com>

WORKDIR /donedesk
RUN mkdir -p /etc/nginx/tls/
RUN mkdir log

# openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout server.key -out server.crt
# openssl dhparam -out server.dhparam 4096
ADD ./docker/development/nginx_proxy/server.dhparam /etc/nginx/tls/
ADD ./docker/development/nginx_proxy/server.key /etc/nginx/tls/
ADD ./docker/development/nginx_proxy/server.crt /etc/nginx/tls/

ADD ./docker/development/nginx_proxy/nginx.conf /etc/nginx/conf.d/default.conf

CMD [ "nginx", "-g", "daemon off;" ]
