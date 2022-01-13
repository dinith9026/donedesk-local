FROM ruby:2.4.1-alpine
MAINTAINER Grok Interactive <developers@grok-interactive.com>

EXPOSE 3000

RUN mkdir /donedesk
WORKDIR /donedesk

ENV BUILD_PACKAGES curl-dev ruby-dev build-base git wget
ENV RUBY_PACKAGES ruby-io-console ruby-bundler
ENV RAILS_PACKAGES postgresql-dev libffi-dev nodejs
ENV RAILS_ENV production

RUN apk update && \
  apk upgrade && \
  apk add $BUILD_PACKAGES $RAILS_PACKAGES $RUBY_PACKAGES && \
  rm -rf /var/cache/apk/*

RUN gem install bundler

ADD Gemfile .
ADD Gemfile.lock .

RUN bundle install -j 32

VOLUME /donedesk/public/

CMD start-app

ADD docker/aws/app/bin/ /usr/local/bin/

ADD . /donedesk

RUN cp -r /donedesk/public/ /tmp/donedesk-public/
