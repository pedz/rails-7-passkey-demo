#!/usr/bin/env zsh

# Execute this from the parent directory via ./docker/first-build.sh

PROG=${0:t}

if [[ $1 == "--help" || $1 == "-?" || $1 == "-h" ]] ; then
    echo "Usage: $0(:t) [options for the rails new command]" 1>&2
    exit 1
fi

if [[ $# == 0 ]] ; then
    rails_options=( "--database=postgresql" )
else
    rails_options=( $@ )
fi

# Pick up the Docker variables into the environment
setopt all_export
source ${0:h}/env.sh
unsetopt all_export

echo $PROG: "COMPOSE_PROJECT_NAME = $COMPOSE_PROJECT_NAME"
echo $PROG: "sleeping 5 seconds.  Whack ^C to stop"
sleep 5

# There are two versions of the Dockerfile.  One is Dockerfile.first
# which is what this script copies to Dockerfile.  After this
# first-build.sh script completes "correctly" (according to your own
# requirements), then edit Dockerfile to make adjustments as your
# project grows.
cp ${0:h}/Dockerfile.first ${0:h}/Dockerfile

# Create an initial Gemfile to get Rails installed.  Note that this
# can not be replaced in the Dockerfile with a simpler "gem install
# rails" because the Dockerfile is also used to rebuild the image.
# Rebuilding the image requires that the latest Gemfile beused.  This
# initial Gemfile is later deleted below just before the `rails new`
# command.
echo $PROG: Creating Gemfile
cat <<EOF > Gemfile
# Project
source "https://rubygems.org"
gem "rails", "~>${RAILS_MAJOR_VERSION}"
EOF
touch Gemfile.lock

# Create a zshrc file to be used as root's .zshrc
echo $PROG: Creating zshrc
cat <<EOF > docker/zshrc
HISTFILE=/${COMPOSE_PROJECT_NAME}/.zsh_history
SAVEHIST=32768
(( HISTSIZE = SAVEHIST * 2 ))
EOF

echo $PROG: Creating zshenv
cat <<EOF > docker/zshenv
path=( /root/bin \${(@)path:#/root/bin} )
path=( /${COMPOSE_PROJECT_NAME}/bin \${(@)path:#/${COMPOSE_PROJECT_NAME}/bin} )
EOF

echo $PROG: Linking .dir-locals.el
ln ${0:h}/dir-locals.el ./.dir-locals.el

# Create the volume for the database
echo $PROG: Create database volumn
docker volume create --name "${COMPOSE_PROJECT_NAME}-db"

# Run docker compose with . as context and docker/compose.yml as the
# compose file.
echo $PROG: Docker compose run rails new
docker compose \
       --project-directory . \
       --file ${0:h}/compose.yml \
       run \
       --no-deps --rm \
       web \
       sh -c "rm -f Gemfile*; git config --global init.defaultBranch master; rails new . $rails_options"

# Do the first git add and commit
echo $PROG: Do first git add and commit
git add .
git commit -a -m "First Commit"

# Now do the build.  `rails new` will have created a new Gemfile which
# Dockerfile copies into the image and then does a `bundle install`
# which pulls the needed Ruby gems into the image.
echo $PROG: Docker compose build
./docker/compose-build.sh

# Now we need to fix the database.yml file.  I save the original
# because it has a lot of nice information in it that I've never read
# and probably never will but its nice to know its there.  i.e. can
# you say "mental illness"?
echo $PROG: Fixing database.yml
mv config/{,orig-}database.yml
cat <<EOF > config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  host: db
  username: postgres
  password: password
  pool: 5

development:
  <<: *default
  database: ${COMPOSE_PROJECT_NAME}_development


test:
  <<: *default
  database: ${COMPOSE_PROJECT_NAME}_test
EOF

# Now run bin/setup
echo $PROG: Docker compose run bin/setup
docker compose \
       --project-directory . \
       --file ${0:h}/compose.yml \
       run \
       --rm \
       web \
       bin/setup

# We now do a second git add and commit to get the new database file
# into the repo
echo $PROG: Do second git add and commit
git add .
git commit -a -m "After fixing database.yml and doing bin/setup"

# Finally bring the full application up
echo Docker compose up
./docker/compose-up.sh
