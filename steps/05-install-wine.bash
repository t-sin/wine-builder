#!/usr/bin/env bash
#
# Create wine_{WINE_VERSION} dir from wine32 & wine64
#
# Usage: 05-install-wine.bash BASEDIR TMPDIR PREFIX WINE_VERSION

set -ueo pipefail

usage() {
  echo 'Usage: 05-install-wine.bash BASEDIR TMPDIR PREFIX WINE_VERSION'
  echo
  exit 1
}

if [ $# -ne 4 ]; then
  usage
fi

script_base_dir=$1
tmpdir=$2
prefix=$3
wine_version=$4

. ${script_base_dir}/config.bash

wine_dirname="wine_${wine_version}"
install_path="${prefix}/${wine_dirname}"

wine32_image="${IMAGE_BASENAME}_${wine_version}_wine32"
wine64_image="${IMAGE_BASENAME}_${wine_version}_wine64"

prerequisties() {
  local image_found=
  local image_name=

  image_name=${wine32_image}
  docker image ls --format "{{.Repository}}" | grep -x "${image_name}" > /dev/null; local image_found=$?
  if [ $image_found -ne 0 ]; then
    echo "   wine32 image '${image_name}' not found."
    exit 1
  fi

  image_name=${wine64_image}
  docker image ls --format "{{.Repository}}" | grep -x "${image_name}" > /dev/null; local image_found=$?
  if [ $image_found -ne 0 ]; then
    echo "   wine64 image '${image_name}' not found."
    exit 1
  fi

  if [ -d "${install_path}" ]; then
    echo "ERROR: wine ${wine_version} is already installed at:"
    echo "   ${install_path}"
    echo
    exit 1
  fi
}

wine32_path="${tmpdir}/wine32_${wine_version}"
wine64_path="${tmpdir}/wine64_${wine_version}"
wine_path="${tmpdir}/wine_${wine_version}"

setup() {
  echo '   copying wine32...'
  container_id=$(docker create "${IMAGE_BASENAME}_${wine_version}_wine32")
  docker cp "${container_id}:${install_path}" "${wine32_path}"
  docker rm "${container_id}"
  echo '   wine32 is copied'

  echo '   copying wine64...'
  container_id=$(docker create "${IMAGE_BASENAME}_${wine_version}_wine64")
  docker cp "${container_id}:${install_path}" "${wine64_path}"
  docker rm "${container_id}"
  echo '   wine64 is copied'
}

teardown() {
  echo "   deleting ${wine32_path}..."
  rm -rf "${wine32_path}"
  echo "   deleting ${wine64_path}..."
  rm -rf "${wine64_path}"
}

main() {
  # MUST COPY wine64 OVER wine32
  #
  # > One last catch is that if you do choose to install your WoW64 build, you should run make install
  # in the 32-bit build tree first, then in the 64-bit one.
  # --- from "Shared WoW64" in "Building Wine · Wiki · wine / wine · GitLab"
  #     https://gitlab.winehq.org/wine/wine/-/wikis/Building-Wine#shared-wow64
  mkdir -p "${wine_path}"
  cp -r "${wine32_path}"/* "${wine_path}"
  cp -r "${wine64_path}"/* "${wine_path}"
  mv "${wine_path}" "${prefix}"

  echo "wine (${wine_version}) is installed at '${prefix}/${wine_dirname}'."
}

########################################

echo "installing wine ${wine_version}..."
prerequisties
setup
main
teardown
