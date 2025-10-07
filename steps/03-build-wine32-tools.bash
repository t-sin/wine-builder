#!/usr/bin/env bash
#
# Build wine32 tools as an image: wine-builder_${WINE_VERSION}_wine32-tools
#
# Usage: 03-build-wine32-tools.bash BASEDIR TMPDIR WINE_VERSION

set -uo pipefail

usage() {
  echo 'Usage: 03-build-wine32-tools.bash BASEDIR TMPDIR WINE_VERSION'
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

base_image="${IMAGE_BASENAME}_${wine_version}_base_i386"
image_name="${IMAGE_BASENAME}_${wine_version}_wine32-tools"

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

dockerfile="${script_base_dir}/docker/Dockerfile.build_wine32-tools"

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
    --platform "$PLATFORM_WINE32" \
    --build-arg "BASE_IMAGE=$base_image" \
    --build-arg "WINE_VERSION=$wine_version" \
    --build-arg "MAKE_MAX_JOBS=$MAKE_MAX_JOBS" \
    ${opts[@]} \
    "${tmpdir}"

  echo "   an image '${image_name}' is built."
}

########################################

echo 'building wine32 tools...'
prerequisties
setup
main
teardown
