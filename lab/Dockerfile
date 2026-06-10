FROM ruby:4.0.5-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential curl && rm -rf /var/lib/apt/lists/*

WORKDIR /lab
COPY Gemfile* ./
RUN bundle install --jobs 4

COPY app/ ./app/

EXPOSE 3000
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "3000", "app/config.ru"]
