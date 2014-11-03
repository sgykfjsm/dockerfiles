#!/bin/bash

set -eu

#
vagrant_cmd=$(which vagrant)
vagrant_hostname=docker_tdd

#
ssh_cmd=$(which ssh)
ssh_config_to_vagrant=$(pwd)/.ssh_config
${vagrant_cmd} ssh-config --host ${vagrant_hostname} > ${ssh_config_to_vagrant}
ssh_opts="-F ${ssh_config_to_vagrant} -q"
ssh_cmd="${ssh_cmd} ${ssh_opts}"

#
docker_cmd=$(ssh -F ${ssh_config_to_vagrant} docker_tdd 'which docker')
docker_opts="-H :5432"
docker_cmd="${docker_cmd} ${docker_opts}"
docker_share_dir=/opt/docker # on docker host
docker_repository_name=sgykfjsm
data_container_name=data
app_container_name=nginx
etc_container_name=td

#
rake_cmd=$(which rake)

echo "Initialize:"
for cid in $(${ssh_cmd} ${vagrant_hostname} "${docker_cmd} ps -a -q --no-trunc")
do
    echo ${cid}
    ${ssh_cmd} ${vagrant_hostname} " \
        ${docker_cmd} stop ${cid} > /dev/null \
        && ${docker_cmd} rm ${cid} > /dev/null \
    "
done
${ssh_cmd} ${vagrant_hostname} " \
    sudo rm -rf ${docker_share_dir}/${data_container_name} \
        && sudo mkdir -m 777 -p ${docker_share_dir}/${data_container_name}/var/log/{nginx,monit,td-agent} \
"

for cn in ${data_container_name} \
    ${app_container_name} \
    ${etc_container_name}
do
    dockerfile=
    case "${cn}" in
        "data" )
            dockerfile="/vagrant/docker/data/."
            ;;
        "nginx" )
            dockerfile="/vagrant/docker/nginx/."
            ;;
        "td" )
            dockerfile="/vagrant/docker/td/."
            ;;
        * )
            echo "unknown container name: ${cn}" >&2
            exit 1
            ;;
    esac

    echo "Build docker image(${cn}):"
    ${ssh_cmd} ${vagrant_hostname} \
        "${docker_cmd} build -t ${docker_repository_name}/${cn} ${dockerfile}"
    echo
done


echo "Run container:"
${ssh_cmd} ${vagrant_hostname} <<EOF
echo -n "data container: "
${docker_cmd} run -i -d -t -P \
    --name ${data_container_name} \
    -v ${docker_share_dir}/${data_container_name}/var/log:/var/log \
    -v /etc/localtime:/etc/localtime:ro \
    ${docker_repository_name}/${data_container_name}

echo -n "application container: "
${docker_cmd} run -i -d -t \
    -p 12812:2812 \
    -p 10080:80 \
    --name ${app_container_name} \
    --volumes-from ${data_container_name} \
    -v /etc/localtime:/etc/localtime:ro \
    ${docker_repository_name}/${app_container_name}

echo -n "td-agent container: "
${docker_cmd} run -i -d -t \
    --name ${etc_container_name} \
    --volumes-from ${data_container_name} \
    -v /etc/localtime:/etc/localtime:ro \
    ${docker_repository_name}/${etc_container_name}
EOF

# sleep 10

# set +e
# echo "Run rspec test:"
# ${rake_cmd} spec
# echo
#
# set -e
# echo "Backup data container:"
# ${ssh_cmd} ${vagrant_hostname} " \
#     ${docker_cmd} run --rm \
#         --volumes-from ${data_container_name} \
#         -v /tmp/:/backup \
#         ubuntu:14.04 \
#         tar zcf /backup/$(date '+%Y%m%d%H%M%S.%Z')_backup.tar /var/log \
# "

# echo "Delete container:"
#
# for cid in $(${ssh_cmd} ${vagrant_hostname} "${docker_cmd} ps -a -q --no-trunc")
# do
#     echo ${cid}
#     ${ssh_cmd} ${vagrant_hostname} " \
#         ${docker_cmd} stop ${cid} > /dev/null \
#         && ${docker_cmd} rm ${cid} > /dev/null \
#         && sudo rm -rf ${docker_share_dir}/${data_container_name} \
#     "
# done
#
rm -f ${ssh_config_to_vagrant}
exit
