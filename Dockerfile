FROM ruby:2.7.6 as builder
LABEL maintainer="nabeta@fastmail.fm"

ARG http_proxy
ARG https_proxy

COPY Gemfile /
COPY Gemfile.lock /
RUN apt-get update -qq && apt-get install -y libpq-dev && bundle install

FROM ruby:2.7.6
LABEL maintainer="nabeta@fastmail.fm"

ARG http_proxy
ARG https_proxy
ARG UID=1000
ARG GID=1000

RUN groupadd --gid ${GID} enju && useradd -m --uid ${UID} --gid ${GID} enju
RUN apt-get update -qq && curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
apt-get install -y nodejs postgresql-client imagemagick mupdf-tools ffmpeg && npm install -g yarn && yarn install
RUN mkdir /enju && chown -R enju:enju /enju
USER enju
WORKDIR /enju
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . /enju/
