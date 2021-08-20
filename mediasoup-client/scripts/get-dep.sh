#!/usr/bin/env bash

set -e

PROJECT_PWD=${PWD}
DEP=$1

current_dir_name=${PROJECT_PWD##*/}
if [ "${current_dir_name}" != "mediasoup-client" ]; then
  echo ">>> [ERROR] $(basename $0) must be called from mediasoup-client/ root directory" >&2
  exit 1
fi

function get_dep() {
  GIT_REPO="$1"
  GIT_TAG="$2"
  DEST="$3"

  echo ">>> [INFO] getting dep '${DEP}' ..."
  echo ">>> [INFO] from ${GIT_REPO}  $GIT_TAG  to ${DEST}"

  if [ -d "${DEST}/.git" ]; then
    echo ">>> [INFO] exist dir ${DEST}/.git ..."
    cd ${DEST}
    git remote set-url origin ${GIT_REPO}
  else
    echo ">>> [INFO] cloning ${GIT_REPO} ..."
    rm -rf ${DEST}
    git clone ${GIT_REPO} ${DEST}
    cd ${DEST}
  fi

  pwd

  if [ -z '${GIT_TAG}' ]; then
    echo ">>> [INFO] setting '${GIT_TAG} is null ,then exit"
    exit 1
  else
    echo ">>> [INFO] git checkout -B dep_branch --quiet  ${GIT_TAG}"
    git checkout -B dep_branch ${GIT_TAG}
    git clean -df
    git checkout .
    set -e
  fi

  echo ">>> [INFO] got dep '${DEP}' finish---------------"

  cd ${PROJECT_PWD}
}

function get_libmediasoupclient() {
  GIT_REPO="https://github.com/versatica/libmediasoupclient.git"
  #GIT_TAG=m79
  DEST="deps/libmediasoupclient"

  get_dep "${GIT_REPO}" "${GIT_TAG}" "${DEST}"
}

function get_webrtc() {
  GIT_REPO="https://github.com/haiyangwu/webrtc-mirror.git"
  GIT_TAG="origin/m79"
  DEST="deps/webrtc/src"

  get_dep "${GIT_REPO}" "${GIT_TAG}" "${DEST}"
}

function get_abseil-cpp() {
  GIT_REPO="https://github.com/abseil/abseil-cpp.git"
  GIT_TAG="189d55a"
  DEST="deps/webrtc/src/third_party/abseil-cpp"

  get_dep "${GIT_REPO}" "${GIT_TAG}" "${DEST}"
}

function get_webrtc-libs() {
  GIT_REPO="https://github.com/haiyangwu/webrtc-android-build.git"
  GIT_TAG="babbbaf78e00b7c2acbd526f5760394ae3b0bb92"
  DEST="deps/webrtc/lib"

  get_dep "${GIT_REPO}" "${GIT_TAG}" "${DEST}"
}

case "${DEP}" in
'-h')
  echo "Usage:"
  echo "  ./scripts/$(basename $0) [libmediasoupclient|webrtc|abseil-cpp|webrtc-libs]"
  echo
  ;;
libmediasoupclient)
  get_libmediasoupclient
  ;;
webrtc)
  get_webrtc
  ;;
abseil-cpp)
  get_abseil-cpp
  ;;
webrtc-libs)
  get_webrtc-libs
  ;;
*)
  echo ">>> [ERROR] unknown dep '${DEP}'" >&2
  echo "Usage:"
  echo "  ./scripts/$(basename $0) [libmediasoupclient|webrtc|abseil-cpp|webrtc-libs]"
  exit 1
  ;;
esac

if [ $? -eq 0 ]; then
  echo ">>> [INFO] done"
else
  echo ">>> [ERROR] failed" >&2
  exit 1
fi
