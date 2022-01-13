FROM postgres:9.6.3-alpine
MAINTAINER Grok Interactive <developers@grok-interactive.com>

ADD docker/development/database/setup-databases.sh /docker-entrypoint-initdb.d

CMD ["postgres"]
