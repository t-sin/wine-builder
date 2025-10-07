#!/usr/bin/env bash
#
# Build wine32 as an image: wine-builder_${WINE_VERSION}_wine32
#
# Usage: 04-build-wine32.bash BASEDIR TMPDIR INSTALL_PATH WINE_VERSION

set -uo pipefail

usage() {
  echo 'Usage: 04-build-wine32.bash BASEDIR TMPDIR INSTALL_PATH WINE_VERSION'
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

base_image="${IMAGE_BASENAME}_${wine_version}_wine32-tools"
image_name="${IMAGE_BASENAME}_${wine_version}_wine32"
wine64_image="${IMAGE_BASENAME}_${wine_version}_wine64"

declare wine64_path=

prerequisties() {
  local image_found

  docker image ls --format "{{.Repository}}" | grep -x "${base_image}" > /dev/null; local image_found=$?
  if [ $image_found -ne 0 ]; then
    echo "   base image '${base_image}' not found."
    exit 1
  fi

  docker image ls --format "{{.Repository}}" | grep -x "${wine64_image}" > /dev/null; local image_found=$?
  if [ $image_found -ne 0 ]; then
    echo "   base image '${wine64_image}' not found."
    exit 1
  fi
}

wine64_path=$(realpath --relative-to="${tmpdir}" "${tmpdir}/build_wine64_${wine_version}")

setup() {
  :
}

teardown() {
  echo "   deleting ${wine64_path}..."
  rm -rf "${tmpdir}/build_wine64_${wine_version}"
}

dockerfile="${script_base_dir}/docker/Dockerfile.build_wine32"

main() {
  docker image ls --format "{{.Repository}}" | grep -x "${image_name}" > /dev/null; local image_found=$?
  if [ $image_found -eq 0 ]; then
    echo "   skipped this docker build because the image '${image_name}' found."
    return 0
  fi

  echo '   copying wine64 build directory...'
  container_id=$(docker create "${IMAGE_BASENAME}_${wine_version}_wine64")
  docker cp "${container_id}:/build_wine/wine64" "${tmpdir}/build_wine64_${wine_version}"
  docker rm "${container_id}"

  echo "   building an image '${image_name}'..."
  docker build \
    -f "$dockerfile" \
    --tag "$image_name" \
    --platform "$PLATFORM_WINE32" \
    --build-arg "BASE_IMAGE=$base_image" \
    --build-arg "WINE64_PATH=$wine64_path" \
    --build-arg "MAKE_MAX_JOBS=$MAKE_MAX_JOBS" \
    --build-arg "PREFIX=${install_path}" \
    ${opts[@]} \
    "${tmpdir}"

  echo "   an image '${image_name}' is built."
}

########################################

echo 'building wine32...'
prerequisties
setup
main
teardown
