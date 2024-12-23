FROM ruby:3.1-bullseye as builder
LABEL maintainer="nabeta@fastmail.fm"

ARG http_proxy
ARG https_proxy

COPY Gemfile /
COPY Gemfile.lock /
RUN apt-get update -qq && apt-get install -y libpq-dev && bundle install

FROM ruby:3.1-bullseye
LABEL maintainer="nabeta@fastmail.fm"

ARG http_proxy
ARG https_proxy
ARG UID=1000
ARG GID=1000

RUN groupadd --gid ${GID} enju && useradd -m --uid ${UID} --gid ${GID} enju
RUN apt-get update -qq && curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get install -y nodejs postgresql-client imagemagick poppler-utils ffmpeg && npm install -g yarn
RUN mkdir /enju && chown -R enju:enju /enju
USER enju
WORKDIR /enju
ADD package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . /enju/
