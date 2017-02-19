#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

gettimestamp() {
	date +%Y%m%d-%H%M%S
}

# Builds container with given name, and any dependencies
docker_build() {
	local NAME=$1
	[[ -z $NAME ]] && echo "No name provided for docker build" && exit 1

	local PARENT="$(get_docker_parent $NAME)"
	echo $PARENT
	[[ -n $PARENT ]] && docker_build_if_needed $PARENT

	(cd $BASE_DIR/$NAME && docker build -t $NAME -t $NAME:$(gettimestamp) . )
}

# Builds a container if it doesn't already have a latest
docker_build_if_needed() {
	local NAME=$1
	( [[ "$(docker images --quiet $NAME:latest)" == "" ]] && docker_build $NAME
}

get_docker_parent() {
	local CHILD=$1
	[[ $CHILD == "base" ]] && exit 0
	grep -i  "^FROM" $BASE_DIR/$CHILD/Dockerfile  | awk '{print $2}' | cut -d: -f1
}