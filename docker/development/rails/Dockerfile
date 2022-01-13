FROM ruby:2.4.1-alpine
MAINTAINER Grok Interactive <developers@grok-interactive.com>

ENV BUILD_PACKAGES curl-dev ruby-dev build-base git wget
ENV RUBY_PACKAGES ruby-io-console ruby-bundler
ENV RAILS_PACKAGES postgresql-dev libffi-dev nodejs

RUN apk update && \
  apk upgrade && \
  apk add $BUILD_PACKAGES $RAILS_PACKAGES $RUBY_PACKAGES && \
  rm -rf /var/cache/apk/*

RUN mkdir /donedesk
WORKDIR /donedesk

ADD Gemfile .
ADD Gemfile.lock .

RUN bundle install -j 32

EXPOSE 3000
