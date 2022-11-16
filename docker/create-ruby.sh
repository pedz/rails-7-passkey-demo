#!/usr/bin/env zsh

# The intention of this script is to be passed Dockerfile-ruby and it
# will create a new image and push it to Docker Hub with the tags
# found in env.sh.
set -x

setopt all_export
source ${0:h}/env.sh
unsetopt all_export

docker build \
       --tag ${RUBY_IMAGE}:${RUBY_VERSION} \
       --file Dockerfile-ruby \
       ${0:h}

docker login

docker push ${RUBY_IMAGE}:${RUBY_VERSION}
