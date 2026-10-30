#!/usr/bin/env bash
set -eu -o pipefail

if [ $# -ne 2 ]; then
  echo "usage: $(basename ""$0"") WORK_DIR WINE_TAG"
  echo
  echo 'Setup wine sources into the current directory'
  echo 'Wine source codes will be cloned from:'
  echo "- ${WINE_REPO_BASE_URL}/${WINE_REPO_NAME}"
  exit 1
fi

workdir=${1:-}
wine_tag=wine-${2:-}

echo "cloning wine (${wine_tag})..."
git clone --no-tags --depth 1 --single-branch \
  --branch "$wine_tag" \
  "${WINE_REPO_BASE_URL}/${WINE_REPO_NAME}" \
  "${workdir}/${WINE_REPO_NAME}.src" \
  > "${workdir}/git-clone.log" 2>&1

echo "successfully set up wine (${wine_tag})."
