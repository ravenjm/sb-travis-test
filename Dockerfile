FROM ruby:3.0.2 AS builder
#karkaraasaasass
WORKDIR /build

ARG RAILS_ENV=production
ENV HOME /app

COPY ./build /build
COPY ./app /app


RUN apt-get update && \
    apt-get install tzdata libxslt-dev libxml2-dev build-essential libssl-dev -y
RUN bundle config set --local without 'test development' && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install && \
    RAILS_ENV=${RAILS_ENV} bundle exec rake assets:precompile && \
    apt-get remove libxml2-dev build-essential libssl-dev -y && \
    rm -rf /var/lib/apt/lists/*

FROM ruby:3.0.2-slim-bullseye
ARG RAILS_ENV=production
ENV APP_HOME=/app
ENV APP_USER=www-data
ENV APP_GROUP=www-data
ENV RAILS_ENV=${RAILS_ENV}

#sync test
# RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY --from=builder /app $APP_HOME
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

USER $APP_USER
EXPOSE 4567:4567

CMD ["ruby", "./app.rb"] 
