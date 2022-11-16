#!/usr/bin/env zsh

# Execute from the parent directory (a.k.a the Rails directory or the
# COMPOSE_PROJECT_NAME directory

if [[ $# -ne 1 || ( $1 != "web" && $1 != "db" ) ]] ; then
    echo "Usage: ${0:t} [ web | db ]" 1>&2
    exit 1
fi

# Execute this from the parent directory via ./docker/first-build.sh
setopt all_export
source ${0:h}/env.sh
unsetopt all_export

set -x
docker compose --project-directory . --file docker/compose.yml run --rm --no-deps -it $1 zsh
