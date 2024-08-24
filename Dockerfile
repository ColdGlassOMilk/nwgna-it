FROM ruby:3.3.4-slim

ENV APP_PATH /nwgna-it-app

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    git

RUN mkdir ${APP_PATH}
WORKDIR ${APP_PATH}
ADD . .

RUN bundle install
