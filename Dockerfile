FROM ruby:2.6.5
MAINTAINER JeongWooYeong(wjd030811@gmail.com)

ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV SCARFS_PASSWORD $SCARFS_PASSWORD
ENV API_KEY $API_KEY
ENV DOMAIN dsm-scarfs.hs.kr
ENV NOTICE_FILE_PATH /scarfs/storage/notice_file
ENV EXCEL_FILE_PATH /scarfs/storage/excel_file
ENV SINGLE_FILE_PATH /scarfs/storage/single_file
ENV MULTI_FILE_PATH /scarfs/storage/multi_file
ENV SCARFS_DB $SCARFS_DB
ENV REDIS_URL $REDIS_URL

RUN apt-get update && \
    apt-get install -y \
    default-libmysqlclient-dev \
    nodejs \
    zip

RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN gem install bundler

RUN mkdir scarfs
COPY . scarfs
WORKDIR scarfs

RUN bundle install

EXPOSE 3000