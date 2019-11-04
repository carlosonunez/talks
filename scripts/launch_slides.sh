#!/usr/bin/env bash
usage() {
  cat <<-USAGE_DOC
$(basename $0) [talk_name]
Launches a slideshow in the folder given.

ARGUMENTS

  [talk_name]     The name of the talk. Must be a folder in this repo.
USAGE_DOC
}

version() {
  echo "$(basename $0): version $(git rev-parse HEAD | head -c 8)"
}

validate_talk_name() {
  ! test -z "$1" && test -d "./$1"
}

verify_that_this_talk_has_slides() {
  test -f "./$1/slides.md"
}

talk_name_raw="${@:1}"
talk_name="$(echo "${@:1}" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
if ! validate_talk_name "$talk_name"
then
  usage
  >&2 echo "ERROR: Invalid talk name provided [$talk_name_raw]."
  exit 1
fi
if ! verify_that_this_talk_has_slides "$talk_name"
then
  >&2 echo "ERROR: Talk [$talk_name_raw] doesn't have any slides."
  exit 1
fi

>&2 echo "INFO: Launching talk: $talk_name_raw. Type CTRL+C to stop and 'S' to view speaker notes."
SLIDES_DIR=./$talk_name docker-compose up slides; \
SLIDES_DIR=./$talk_name docker-compose down
