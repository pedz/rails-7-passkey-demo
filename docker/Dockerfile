# syntax=docker/dockerfile:1
#
# These value come from the .env file via docker compose or
# --build-arg.  The reasson for the odd sequence (why all the ARG
# lines are not together) is because the FROM line wipes out previous
# ARG values.  https://stackoverflow.com/a/56748289/341980 and
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact

ARG RUBY_IMAGE
ARG RUBY_VERSION
FROM ${RUBY_IMAGE}:${RUBY_VERSION}

ARG COMPOSE_PROJECT_NAME
ARG DOCKER_REPOSITORY
ARG DOCKER_SCAN_SUGGEST
ARG PORT
ARG POSTGRES_VERSION
ARG PROJECT_VERSION
ARG RAILS_MAJOR_VERSION
ARG RUBY_IMAGE
ARG RUBY_VERSION
ENV PORT=${PORT}

# The reason for this:
#
# 1. It is one big command because each instruction (e.g. RUN) adds a
#    layer to the image so there is a point to minimize instructions.
#
# 2. The starting Ruby image may or may not have the exact level of
#    postgres-client that is desired.  lsb-release is first installed
#    because it is needed to specify the contents of the
#    pgdg.list. One is to get the pgp keys and the other is to create
#    the pgdg list.  Then the update and install are done.
#
# 3. I added installing zsh and doing the chsh for root's shell
#    because that is how my brain now thinks.  I also added the update
#    to the bundler gem due to an error I was getting.
#    See https://stackoverflow.com/a/15937572/341980
#
#    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee -o /etc/apt/trusted.gpg.d/apt.postgresql.org && \
#     wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
RUN apt-get update -qq && \
    apt-get install -y lsb-release && \
    wget -qO /etc/apt/trusted.gpg.d/ACCC4CF8.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update -qq && \
    apt-get install -y "postgresql-client-${POSTGRES_VERSION%.*}" zsh less exuberant-ctags && \
    chsh -s /usr/bin/zsh root && \
    gem update bundler

# I keep making the mistake of thinking I can do this better but this
# needs to be done like this.  This will copy the Gemfile that Rails
# or the user needs into the image along with the lock file and then
# do the bundle install.  This will get all the required Ruby gems
# into the image.
WORKDIR ${COMPOSE_PROJECT_NAME}
COPY Gemfile Gemfile.lock /${COMPOSE_PROJECT_NAME}
COPY docker/zshrc /root/.zshrc
COPY docker/zshenv /root/.zshenv
RUN chmod +x /root/.zsh*
RUN mkdir /root/bin
RUN bundle config set --global bin /root/bin
RUN bundle install

# Create all of the rdoc for the installed gems (first line) as well
# as all of the Rails app code in and below the current directory
RUN bundle exec gem rdoc --all
RUN bundle exec rdoc --ri
RUN /root/bin/yard gems --quiet

# So I can keep track of my changes to the gems I use more easily.
RUN ( cd $GEM_HOME/gems && git init . )
RUN ( cd $GEM_HOME/gems && git config --global init.defaultBranch master )
RUN ( cd $GEM_HOME/gems && git config --global user.email "pedz@easesoftware.com" )
RUN ( cd $GEM_HOME/gems && git config --global user.name "Perry Smith" )
RUN ( cd $GEM_HOME/gems && git add . )
RUN ( cd $GEM_HOME/gems && git commit -a -m "First Commit" )

# Add a script to be executed every time the container starts.
COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE ${PORT}

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
