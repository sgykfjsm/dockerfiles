#!/bin/bash

set -eu

[ $(whoami) = 'root' ] || {
  echo This script is root only >&2
  exit 1
}

## default
XMX=1g
XMS=1g
XMN=256m
GC_PARAM='-XX:+UseConcMarkSweepGC'
NORIKRA_DIR=$(env | grep -i norikra_dir | cut -d"=" -f2)
NORIKRA_LEVEL='micro'
NORIKRA_PIDFILE=/var/run/norikra/norikra.pid
RUBY_VERSION=$(env | grep -i ruby_version | cut -d"=" -f2)
JRUBY_VERSION=$(env | grep -i jruby_version | cut -d"=" -f2)

init () {
  local norikra_bin=$(which norikra ||:)
  [ -n "${norikra_bin}" ] || {
    echo Maybe, Norikra is not installed >&2
    exit 1
  }

  [ -e "${norikra_bin}" ] || {
    echo Norikra is missing >&2
    exit 1
  }

  [ -x "${norikra_bin}" ] || {
    echo Norikra is not exeutable. >&2
    echo Norikra is $(stat -c %a) >&2
    exit 1
  }

  local rbenv_bin=$(which rbenv ||:)
  [ -n "${rbenv_bin}" ] || {
    echo Maybe, rbenv is not installed >&2
    exit 1
  }

  [ -e "${rbenv_bin}" ] || {
    echo rbenv is missing >&2
    exit 1
  }

  [ -x "${rbenv_bin}" ] || {
    echo rbenv is not exeutable. >&2
    echo rbenv is $(stat -c %a) >&2
    exit 1
  }

  while [ $# -gt 0 ]
  do
    case $1 in
      -mx )
        XMX=$2
        ;;
      -ms )
        XMS=$2
        ;;
      -mn )
        XMN=$2
        ;;
      -gc )
        GC_PARAM=$2
        ;;
      -d )
        NORIKRA_DIR=$2
        ;;
      -l )
        NORIKRA_LEVEL=$2
        ;;
      -ruby )
        RUBY_VERSION=$2
        ;;
      -jruby )
        JRUBY_VERSION=$2
        ;;
      -h | --help )
          usage
          exit 0
          ;;
      * )
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
    shift && shift
  done

  if [ -z "${RUBY_VERSION}" ]; then
    echo RUBY_VERSION is unset >&2
    echo Please Set RUBY_VERSION in environment variables >&2
    echo Or Specify argument: -ruby 'ruby-version' for this script >&2
    exit 1
  else
    export JRUBY_VERSION=${JRUBY_VERSION}
  fi

  if [ -z "${JRUBY_VERSION}" ]; then
    echo JRUBY_VERSION is unset >&2
    echo Please Set JRUBY_VERSION in environment variables >&2
    echo Or Specify argument: -jruby 'jruby-version' for this script >&2
    exit 1
  else
    export JRUBY_VERSION=${JRUBY_VERSION}
  fi

  [ -n "${NORIKRA_DIR}" ] || {
    echo NORIKRA_DIR is unset >&2
    NORIKRA_DIR=$(mktemp --directory /tmp/norikra.XXXXXXXX)
    echo Using NORIKRA_DIR is ${NORIKRA_DIR}
  }

  return 0
}

norikra_start() {

  for d in "${NORIKRA_DIR}/log" "${NORIKRA_DIR}/out" \
      "${NORIKRA_DIR}/stats" "${NORIKRA_PIDFILE%%/norikra.pid}"
  do
    [ -d "${d}" ] || { mkdir -p "${d}"; echo "${d} is created"; }
  done

  set -x
  rbenv local ${JRUBY_VERSION}
  rbenv rehash
  #    --outfile=${NORIKRA_DIR}/out/norikra.out \
  # norikra start --daemonize \
  # norikra start \
  exec norikra start --daemonize \
     -Xmx${XMX} \
     -Xms${XMS} \
     -Xmn${XMN} \
     ${GC_PARAM} \
     --pidfile=${NORIKRA_PIDFILE} \
     --stats=${NORIKRA_DIR}/stats/norikra.json \
     --logdir=${NORIKRA_DIR}/log \
     --outfile=${NORIKRA_DIR}/out/norikra.out \
     --${NORIKRA_LEVEL}
     # --${NORIKRA_LEVEL} >> ${NORIKRA_DIR}/out/norikra.out 2>&1

  set +x
  echo "Please wait for waking up"
  until [ -f "${NORIKRA_PIDFILE}" ]
  do
    sleep 3
    printf '.'
  done
  echo
  echo "Norikra is running(pid: $(cat ${NORIKRA_PIDFILE}) from ${NORIKRA_PIDFILE})"
  rbenv local ${RUBY_VERSION}
  rbenv rehash

  return 0
}

norikra_stop() {
  norikra_pid=
  [ -f "${NORIKRA_PIDFILE}" ] \
      && norikra_pid=$(cat "${NORIKRA_PIDFILE}") \
      || norikra_pid=$(pidof -s norikra)

  [ -n "${norikra_pid}" ] || {
    echo Norikra is not running
    return 0
  }

  set -x
  rbenv local ${JRUBY_VERSION}
  rbenv rehash
  norikra stop &
  set +x
  echo "Please wait for stopping"
  while [ $(ps -ef | grep -c "${norikra_pid}") -gt 0 ]
  do
    sleep 3
    printf '.'
  done
  echo
  echo "Norikra is stopping."
  rbenv local ${RUBY_VERSION}
  rbenv rehash
  return 0
}

norikra_status() {
    if [ -f "${NORIKRA_PIDFILE}" ]; then
        echo "Norikra is running(pid: $(cat ${NORIKRA_PIDFILE}) from ${NORIKRA_PIDFILE})"
        return 0
    else
        echo "${NORIKRA_PIDFILE} is missing."
    fi

    norikra_pids=$(pidof norikra ||:)
    if [ -n "${norikra_pids}" ]; then
        echo "But, Maybe Norikra is running(pid: $(cat ${NORIKRA_PIDFILE})) from \`pidof norikra\`"
    else
        echo Norikra is not running
    fi

    return 0
}

usage() {
  # TODO: add
  echo Usage:
  echo !!! Not Implemented. !!!
}

[ $# -gt 0 ] || {
    usage
    exit 1
}

kind=$1
shift
case ${kind} in
    start )
        init $@
        norikra_start $@
        ;;
    stop )
        init $@
        norikra_stop
        ;;
    status )
        norikra_status
        ;;
    * )
        exit
esac

exit $?
