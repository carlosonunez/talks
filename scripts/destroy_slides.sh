#!/usr/bin/env bash
export $(egrep -v '^#' infra/.env | xargs)
TERRAFORM_STATE_S3_KEY="${TERRAFORM_STATE_S3_KEY?Please define the Terraform S3 state key.}"
TERRAFORM_STATE_S3_BUCKET="${TERRAFORM_STATE_S3_BUCKET?Please define the Terraform S3 state bucket.}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY?Please define AWS_SECRET_ACCESS_KEY}"
AWS_REGION="${AWS_REGION?Please define AWS_REGION}"
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID?Please define AWS_ACCESS_KEY_ID}"
PLAN="${PLAN:-true}"
PRODUCTION="${PRODUCTION:-false}"
ALTERNATE_TALK_NAME="${ALTERNATE_TALK_NAME}"

usage() {
  cat <<-USAGE_DOC
$(basename $0) [talk_name]
Removes slides from "the cloud."

ARGUMENTS

  [talk_name]           The name of the talk. Must be a folder in this repo.

ENVIRONMENT VARIABLES

  PRODUCTION            Destroys the website to the CloudFront CDN and issues
                        a HTTPS certificate for it.
                  
                        Use wisely; these deployments can take upwards of 20 minutes!
                        (Default: false)

  ALTERNATE_TALK_NAME   This script will use the same name as your talk folder
                        for the website URL. Use this to supply an alternate
                        name. You can also define this in your talk's .env file.
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
talk_name="$(echo "${@:1}" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/\/$//')"
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

set -e
export $(egrep -v '^#' ./$talk_name/.env | xargs)
for stage in tf-init tf-destroy
do
  if [ "$stage" == "tf-destroy" ] && [ "$PRODUCTION" == "true" ]
  then
    >&2 echo "INFO: Destroying production."
    stage="tf-destroy-prod"
  fi
  talk_bucket_key="${ALTERNATE_TALK_NAME:-(echo $talk_name | tr -d '-')}"
  SLIDES_DIR=./$talk_name \
    TALK_S3_BUCKET="talks.${DNS_DOMAIN_NAME}" \
    TALK_S3_BUCKET_KEY="${talk_bucket_key}" \
    docker-compose run --rm \
    -e TF_VAR_route53_domain_name=${DNS_DOMAIN_NAME} \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_REGION \
    "$stage"
done


