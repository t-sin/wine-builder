#!/usr/bin/env bash
#
# Build wine64 as an image: wine-builder_${WINE_VERSION}_wine64
#
# Usage: 02-build-wine64.bash BASEDIR TMPDIR INSTALL_PATH WINE_VERSION

set -uo pipefail

usage() {
  echo 'Usage: 02-build-wine64.bash BASEDIR TMPDIR INSTALL_PATH WINE_VERSION'
  echo
  exit 1
}

if [ $# -ne 4 ]; then
  usage
fi

script_base_dir=$1
tmpdir=$2
install_path=$3
wine_version=$4

. ${script_base_dir}/config.bash

base_image="${IMAGE_BASENAME}_${wine_version}_base_amd64"
image_name="${IMAGE_BASENAME}_${wine_version}_wine64"

prerequisties() {
  local image_found

  docker image ls --format "{{.Repository}}" | grep -x "${base_image}" > /dev/null; local image_found=$?
  if [ $image_found -ne 0 ]; then
    echo "   base image '${base_image}' not found."
    exit 1
  fi
}

setup() {
  :
}

teardown() {
  :
}

dockerfile="${script_base_dir}/docker/Dockerfile.build_wine64"

main() {
  docker image ls --format "{{.Repository}}" | grep -x "${image_name}" > /dev/null; local image_found=$?
  if [ $image_found -eq 0 ]; then
    echo "   skipped this docker build because the image '${image_name}' found."
    return 0
  fi

  echo "   building an image '${image_name}'..."
  docker build \
    -f "$dockerfile" \
    --tag "$image_name" \
    --platform "$PLATFORM_WINE64" \
    --build-arg "BASE_IMAGE=$base_image" \
    --build-arg "PREFIX=$install_path" \
    --build-arg "MAKE_MAX_JOBS=$MAKE_MAX_JOBS" \
    ${opts[@]} \
    "${tmpdir}"

  echo "   an image '${image_name}' is built."
}

########################################

echo 'building wine64...'
prerequisties
setup
main
teardown
