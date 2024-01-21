FROM ruby:3.1.4 as builder
LABEL maintainer="nabeta@fastmail.fm"

ARG http_proxy
ARG https_proxy

COPY Gemfile /
COPY Gemfile.lock /
RUN apt-get update -qq && apt-get install -y libpq-dev && bundle install

FROM ruby:3.1.4
LABEL maintainer="nabeta@fastmail.fm"

ARG http_proxy
ARG https_proxy
ARG UID=1000
ARG GID=1000

RUN groupadd --gid ${GID} enju && useradd -m --uid ${UID} --gid ${GID} enju
RUN mkdir -p /etc/apt/keyrings && \
  apt-get update -qq && apt-get install -y curl ca-certificates gnupg && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarnkey.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
  echo "deb [signed-by=/etc/apt/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update -qq && apt-get install -y nodejs yarn postgresql-client imagemagick poppler-utils ffmpeg && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir /enju && chown -R enju:enju /enju
USER enju
WORKDIR /enju
ADD package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . /enju/
