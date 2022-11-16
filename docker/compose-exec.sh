#!/usr/bin/env zsh

# Execute this from the parent directory via ./docker/first-build.sh
setopt all_export
source ${0:h}/env.sh
unsetopt all_export

set -x
docker compose \
       --project-directory . \
       --file ${0:h}/compose.yml \
       exec \
       $@
