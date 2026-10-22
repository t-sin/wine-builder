#!/usr/bin/env bash
set -eu -o pipefail

if [ $# -ne 3 ]; then
  echo "usage: $0 BASE_DIR WINE_REPO_BASE WINE_STAGING_TAG"
  echo
  echo 'Setup wine sources into the current directory'
  echo 'Wine source codes will be cloned from `WINE_REPO_BASE/wine`.'
  exit 1
fi

base_dir=${1:-}
wine_repo_base=${2:-}
wine_staging_tag=${3:-}

echo "cloning wine-staging (${wine_staging_tag})..."
git clone --no-tags --depth 1 --single-branch --branch "$wine_staging_tag" "${wine_repo_base}/wine-staging" "${base_dir}/wine-staging.src"
wine_upstream=$("${base_dir}/wine-staging.src/staging/patchinstall.py" --upstream-commit)

echo
echo "cloning wine (${wine_upstream})..."
mkdir  "${base_dir}/wine.src"
git -C "${base_dir}/wine.src" init
git -C "${base_dir}/wine.src" remote add origin "${wine_repo_base}/wine"
git -C "${base_dir}/wine.src" fetch --depth 1 origin "$wine_upstream"
git -C "${base_dir}/wine.src" switch -d FETCH_HEAD

echo
echo "applying all patches in wine-staging (${wine_upstream})..."
"${base_dir}/wine-staging.src/staging/patchinstall.py" DESTDIR="${base_dir}/wine.src" --all

echo
echo "successfully set up wine-staging (${wine_staging_tag})."
