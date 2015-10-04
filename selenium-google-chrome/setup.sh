#!/usr/bin/env bash

set -eu

_OLDPWD=$(pwd)
test -d "${BASH_SOURCE[0]%/*}" && { cd "${BASH_SOURCE[0]%/*}" || exit 1; }

SCRIPT_DIR="$(pwd)"
JENKINS_CLI="/var/lib/jenkins/cli/jenkins-cli.jar"

if which wget > /dev/null; then
    yum install -y wget
fi

_echo() {
    echo "$(date '+%FT%T.%Z'):$@"
}

echo_info() {
    _echo "INFO" $*
}

echo_error() {
    _echo "ERROR" $*
}

error_exit() {
    echo_error $*
    exit 1
}

install_jdk(){
    yum install -y java-1.8.0-openjdk-devel.x86_64 java-1.8.0-openjdk-headless.x86_64
}

install_jenkins(){
    wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
    rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
    yum install -y jenkins
}

start_jenkins(){
    chkconfig jenkins on
    service jenkins start
}

get_jenkins_cli(){
    if [ -f "${JENKINS_CLI}" ]; then
        echo_info "${JENKINS_CLI} is already there"
        return
    fi

    if [ ! -d "$(dirname ${JENKINS_CLI})" ]; then
        mkdir -pv "$(dirname ${JENKINS_CLI})"
    fi
    cd "$(dirname ${JENKINS_CLI})"

    for i in {0..9}
    do
        wget --quiet http://localhost:8080/jnlpJars/jenkins-cli.jar || :
        if [ -f "${JENKINS_CLI}" ]; then
            break
        else
            echo_info "It seems that Jenkins does not wake up"
            echo_info "waiting for 30 seconds..."
            sleep 30
        fi
    done

    if [ ! -f "${JENKINS_CLI}" ]; then
        error_exit "Failed to download jenkins-cli.jar"
    fi
    cd - > /dev/null
}

install_jenkins_plugin(){
    java -jar ${JENKINS_CLI} -s http://localhost:8080 install-plugin git
    service jenkins restart
}

install_docker(){
    yum install -y docker-io.x86_64
    if [ -f "/etc/sysconfig/docker" ]; then
        sed -i.org -e "s/^other_args=.*/other_args=\"-H 0.0.0.0:5432\"/g" /etc/sysconfig/docker
    fi
    chkconfig docker on

    set +e
    service docker status > /dev/null 2>&1
    local ret_val=$?
    if [ "${ret_val}" = 0 ] ; then
        service docker stop
    fi
    service docker start
    set -e
}

main() {
    yum update -y
    yum install -y git
    service iptables stop
    setenforce 0 || :
    if [ -f /etc/sysconfig/selinux ]; then
        sed -i.org -e "s/^SELINUX=.*/SELINUX=disabled/g" /etc/sysconfig/selinux
    fi
    install_jdk
    install_jenkins
    start_jenkins
    get_jenkins_cli
    install_jenkins_plugin
    install_docker
}

main $@

[ -n "${_OLDPWD-}" ] && cd ${_OLDPWD}

exit
# EOF
