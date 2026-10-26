#!/usr/bin/env bash
set -eu -o pipefail

if [ $# -ne 2 ]; then
  echo "usage: $(basename ""$0"") WORK_DIR WINE_STAGING_TAG"
  echo
  echo 'Setup wine sources into the current directory'
  echo 'Wine source codes will be cloned from:'
  echo "- ${WINE_REPO_BASE_URL}/${WINE_STAGING_REPO_NAME}'"
  echo "- ${WINE_REPO_BASE_URL}/${WINE_REPO_NAME}'"
  echo
  exit 1
fi

workdir=${1:-}
wine_staging_tag=v${2:-}

echo "cloning wine-staging (${wine_staging_tag})..."
git clone \
  --no-tags --depth 1 --single-branch \
  --branch "$wine_staging_tag" \
  "${WINE_REPO_BASE_URL}/${WINE_STAGING_REPO_NAME}" \
  "${workdir}/${WINE_STAGING_REPO_NAME}.src" \
  > "${workdir}/git-clone.log" 2>&1
wine_upstream=$("${workdir}/${WINE_STAGING_REPO_NAME}.src/staging/patchinstall.py" --upstream-commit)

echo "cloning wine (${wine_upstream})..."
mkdir  "${workdir}/${WINE_REPO_NAME}.src"
git -C "${workdir}/${WINE_REPO_NAME}.src" \
  init > "${workdir}/git-clone.log" 2>&1
git -C "${workdir}/${WINE_REPO_NAME}.src" \
  remote add origin "${WINE_REPO_BASE_URL}/${WINE_REPO_NAME}" \
  > "${workdir}/git-clone.log" 2>&1
git -C "${workdir}/${WINE_REPO_NAME}.src" \
  fetch --depth 1 origin "$wine_upstream" \
  > "${workdir}/git-clone.log" 2>&1
git -C "${workdir}/${WINE_REPO_NAME}.src" \
  switch -d FETCH_HEAD > "${workdir}/git-clone.log" 2>&1

echo "applying all patches in wine-staging (${wine_upstream})..."
"${workdir}/${WINE_STAGING_REPO_NAME}.src/staging/patchinstall.py" \
  DESTDIR="${workdir}/${WINE_REPO_NAME}.src" --all \
  > "${workdir}/git-clone.log" 2>&1

echo "successfully set up wine-staging (${wine_staging_tag})."
