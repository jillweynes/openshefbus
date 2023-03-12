# Dockerfile

# Include the Ruby base image (https://hub.docker.com/_/ruby)
# in the image for this application, version 2.7.4.
FROM ruby:2.5

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY main.rb /myapp/main.rb
COPY route.rb /myapp/route.rb
COPY keys.txt /myapp/keys.txt
COPY db/* /myapp/db/
RUN bundle install

#RUN bash -c "cat Gemfile.lock; qwe"

# Tell Docker to listen on port 4567.
#EXPOSE 4567

# Tell Docker that when we run "docker run", we want it to
# run the following command:
# $ bundle exec rackup --host 0.0.0.0 -p 4567.
CMD ["ruby", "main.rb", "-p", "80", "-e", "production"]