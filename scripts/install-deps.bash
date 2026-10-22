#!/usr/bin/env bash
set -eu -o pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 DEPS_LIST"
  echo
  echo 'Install dependent packages.'
  echo 'Currently supports only apt'
  exit 1
fi

deps_list=${1:-}

if [ ! -r "$deps_list" ]; then
  echo "it is not a reqular file: $deps_list"
  echo
  exit 1
fi

list_deps() {
  cat "$deps_list" | sed -E -e 's/#.*$//' | tr '\n' ' '
}

install_via_apt() {
  list_deps | xargs apt install -y
}

install_via_apt
