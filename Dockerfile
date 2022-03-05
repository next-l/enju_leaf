FROM ruby:2.7
LABEL maintainer="nabeta@fastmail.fm"

ARG UID=10000
ARG GID=10000
ARG http_proxy
ARG https_proxy

RUN apt-get update -qq && apt-get install -y npm postgresql-client libpq-dev imagemagick mupdf-tools ffmpeg && npm install -g yarn
RUN groupadd --gid ${GID} enju && useradd -m --uid ${UID} --gid ${GID} enju
RUN mkdir /enju && chown -R enju:enju /enju
RUN sed -i -e "s/DEFAULT@SECLEVEL=2/#DEFAULT@SECLEVEL=2/" /etc/ssl/openssl.cnf

USER enju
WORKDIR /enju
COPY Gemfile /enju/
COPY Gemfile.lock /enju/
RUN bundle install
COPY . /enju/
