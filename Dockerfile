FROM ubuntu

RUN apt-get -y install ruby1.9.1-dev memcached imagemagick libicu-dev \
 openjdk-7-jre-headless git libxslt1-dev build-essential nodejs redis-server \
 libsqlite3-dev
