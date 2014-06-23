FROM ubuntu

RUN apt-get update
RUN apt-get -y install ruby1.9.1-dev memcached imagemagick libicu-dev \
 openjdk-7-jre-headless git libxslt1-dev build-essential nodejs redis-server \
 libsqlite3-dev zlib1g-dev
RUN gem install rails
RUN rails new enju -m https://gist.github.com/nabeta/6319160.txt
