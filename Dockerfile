FROM ruby:2.7.6
LABEL maintainer="nabeta@fastmail.fm"

ARG UID=1000
ARG GID=1000
ARG http_proxy
ARG https_proxy

RUN apt-get update -qq && curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
apt-get install -y nodejs postgresql-client libpq-dev imagemagick mupdf-tools ffmpeg && npm install -g yarn && yarn install
RUN groupadd --gid ${GID} enju && useradd -m --uid ${UID} --gid ${GID} enju
RUN mkdir /enju && chown -R enju:enju /enju

USER enju
WORKDIR /enju
COPY Gemfile /enju/
COPY Gemfile.lock /enju/
RUN bundle install
COPY . /enju/
