ARG RUBY_VERSION

FROM ruby:${RUBY_VERSION}
WORKDIR /tmp
COPY Gemfile ./
ENV BUNDLE_GEMFILE=/tmp/Gemfile
RUN bundle install

WORKDIR /data
CMD ["jekyll", "serve", "--destination=/tmp/_site", "--host="]
STOPSIGNAL SIGKILL
