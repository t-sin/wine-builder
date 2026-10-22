#!/usr/bin/env bash
set -eu -o pipefail

if [ $# -ne 3 ]; then
  echo "usage: $0 BASE_DIR WINE_REPO_BASE WINE_TAG"
  echo
  echo 'Setup wine sources into the current directory'
  echo 'Wine source codes will be cloned from `WINE_REPO_BASE/wine`.'
  exit 1
fi

base_dir=${1:-}
wine_repo_base=${2:-}
wine_tag="wine-${3:-}"

echo "cloning wine (${wine_tag})..."
git clone --no-tags --depth 1 --single-branch --branch "$wine_tag" "${wine_repo_base}/wine" "${base_dir}/wine.src"

echo
echo "successfully set up wine (${wine_tag})."
