FROM ruby:3.0.7-buster


RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client \
    cron  # Added cron to run scheduled jobs


WORKDIR /app


COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock


RUN bundle install


RUN echo 'require "logger"\n\nmodule ActiveSupport\n  module LoggerThreadSafeLevel\n    Logger = ::Logger unless defined?(Logger)\n  end\nend' > /patch_logger.rb


COPY . /app

EXPOSE 3000


CMD ["bash", "-c", "ruby -r /patch_logger.rb -e 'load File.join(Dir.pwd, \"bin/rails\")' db:create db:migrate && ruby -r /patch_logger.rb -e 'load File.join(Dir.pwd, \"bin/rails\")' server -b 0.0.0.0"]
