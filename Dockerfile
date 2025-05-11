FROM ruby:3.2-alpine
RUN apk add --no-cache build-base
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
VOLUME /app/db

CMD ["ruby", "app.rb"]