FROM ubuntu

RUN sed -i -e "s/$/ restricted universe/" /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install ruby1.9.1-dev memcached imagemagick libicu-dev \
 openjdk-7-jre-headless git libxslt1-dev build-essential nodejs redis-server \
 libsqlite3-dev
