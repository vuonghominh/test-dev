# Base image:
FROM ruby:2.4-slim

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /home/web/site
ENV NODE_VERSION 6.13.1
ENV NVM_DIR /usr/local/nvm

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

# Install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install yarn -g

# Make root directory
RUN mkdir -p $RAILS_ROOT

# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT

# Gems:
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install

# Node dependencies
COPY package.json package.json
COPY yarn.lock yarn.lock
RUN source $NVM_DIR/nvm.sh && yarn install --ignore-engines

# Copy the main application.
COPY . .

EXPOSE 3000

# Starts the Puma server.
CMD source $NVM_DIR/nvm.sh && foreman start
