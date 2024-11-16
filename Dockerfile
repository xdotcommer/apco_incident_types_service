# syntax=docker/dockerfile:1

FROM ruby:3.3.4-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential git

# Set working directory
WORKDIR /app

# Install gems in a way that's friendly to development
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Make port 3000 available
EXPOSE 4000

# Start the server by default
CMD ["rails", "server", "-b", "0.0.0.0"]