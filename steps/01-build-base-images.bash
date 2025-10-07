#!/usr/bin/env bash
#
# Build two base images to build wine.
# These are:
# - wine-builder_${WINE_VERSION}_base_amd64
# - wine-builder_${WINE_VERSION}_base_i386
#
# Usage: 01-build-base-images.bash BASEDIR TMPDIR WINE_VERSION

set -uo pipefail


usage() {
  echo "Usage: $(basename ""$0"") BASEDIR TMPDIR WINE_VERSION"
  echo
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi

script_base_dir=$1
tmpdir=$2
wine_version=$3

. ${script_base_dir}/config.bash

image_name_wine32="${IMAGE_BASENAME}_${wine_version}_base_i386"
image_name_wine64="${IMAGE_BASENAME}_${wine_version}_base_amd64"

prerequisties() {
  if [ -z "${wine_version}" ]; then
    echo 'ERROR: WINE_VERSION cannot be empty.'
    echo
    usage
  fi
}

setup() {
  :
}

teardown() {
  :
}

build_image() {
  local platform=$1
  local base_image=$2
  local image_name=$3

  local dockerfile="${script_base_dir}/docker/Dockerfile.base"
  local wine_branch="wine-${wine_version}"

  docker image ls --format "{{.Repository}}" | grep -x "${image_name}" > /dev/null; local image_found=$?
  if [ $image_found -eq 0 ]; then
    echo "   skipped this docker build because the image '${image_name}' found."
    return 0
  fi

  echo "   building an image '${image_name}'..."
  docker build \
    -f "$dockerfile" \
    --tag "$image_name" \
    --platform "$platform" \
    --build-arg "BASE_IMAGE=$base_image" \
    --build-arg "WINE_REPO=$WINE_REPO_URL" \
    --build-arg "WINE_BRANCH=$wine_branch" \
    ${opts[@]} \
    "${tmpdir}"

  echo "   an image '${image_name}' is built."
}


base_image_wine32=i386/ubuntu:latest
base_image_wine64=ubuntu:24.04

main() {
  # for wine32
  build_image "${PLATFORM_WINE32}" "${base_image_wine32}" "${image_name_wine32}"
  # for wine64
  build_image "${PLATFORM_WINE64}" "${base_image_wine64}" "${image_name_wine64}"
}

########################################

echo 'building base images...'
prerequisties
setup
main
teardown
