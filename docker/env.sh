#!/usr/bin/env zsh

# Note: this because the directory that this docker directory is
# within -- i.e. the project's directory.  But you can override it if
# it is not producing the desired result.

if [[ $0 == /* ]] ; then
    TMP=${0:h:h:t}
else
    TMP="$PWD/$0"
    TMP=${TMP:s%/./%/%:h:h:t}
fi

# setopt all_export
COMPOSE_PROJECT_NAME=$TMP
DOCKER_REPOSITORY=pedzsan
DOCKER_SCAN_SUGGEST=false
PORT=4000
POSTGRES_VERSION=14.5-bullseye
PROJECT_VERSION=1.0
RAILS_MAJOR_VERSION=7
RUBY_IMAGE=pedzsan/ruby-with-rdoc
RUBY_VERSION=3.1.2-bullseye
# unsetopt all_export
