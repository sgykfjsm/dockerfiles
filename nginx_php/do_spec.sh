#!/bin/bash

set -eu

#
vagrant_cmd=$(which vagrant)
vagrant_hostname=nginx_php5fpm

#
ssh_cmd=$(which ssh)
ssh_config_to_vagrant=$(pwd)/.ssh_config
${vagrant_cmd} ssh-config --host ${vagrant_hostname} > ${ssh_config_to_vagrant}
ssh_opts="-F ${ssh_config_to_vagrant} -q"
ssh_cmd="${ssh_cmd} ${ssh_opts}"

#
docker_cmd=$(ssh -F ${ssh_config_to_vagrant} ${vagrant_hostname} 'which docker')
docker_opts="-H :5432"
docker_cmd="${docker_cmd} ${docker_opts}"
docker_share_dir_base=/opt/docker # on docker host
docker_repository_name=sgykfjsm
base_container_name=base_ubuntu
data_container_name=data
app_container_name=nginx_php5fpm
docker_data_dir=${docker_share_dir_base}/${data_container_name}
#
rake_cmd=$(which rake)

echo "Initialize:"
for cid in $(${ssh_cmd} ${vagrant_hostname} "${docker_cmd} ps -a -q --no-trunc")
do
    echo ${cid}
    ${ssh_cmd} ${vagrant_hostname} " \
        ${docker_cmd} stop ${cid} > /dev/null \
        && ${docker_cmd} rm ${cid} > /dev/null
    "
done
${ssh_cmd} ${vagrant_hostname} "sudo rm -rf ${docker_data_dir}"

echo "Pull docker image(${base_container_name}):"
${ssh_cmd} ${vagrant_hostname} \
    "${docker_cmd} pull ${docker_repository_name}/${base_container_name}"
echo

echo "Build docker image(${app_container_name}):"
${ssh_cmd} ${vagrant_hostname} \
    "${docker_cmd} build -t ${docker_repository_name}/${app_container_name} /vagrant/docker/."
echo

echo "Run container:"
${ssh_cmd} ${vagrant_hostname} <<EOF
sudo rm -rf ${docker_data_dir}
sudo mkdir -m 755 -p ${docker_data_dir}/var/log/{nginx,monit,php}

# data container
${docker_cmd} run -i -d -t -P \
    --name ${data_container_name} \
    -v ${docker_data_dir}/var/log:/var/log \
    -v /etc/localtime:/etc/localtime:ro \
    ${docker_repository_name}/${base_container_name}

# application container
${docker_cmd} run -i -d -t \
    -p 12812:2812 \
    -p 10080:80 \
    --name ${app_container_name} \
    --volumes-from ${data_container_name} \
    -v /etc/localtime:/etc/localtime:ro \
    ${docker_repository_name}/${app_container_name}
EOF

sleep 10

set +e
echo "Run rspec test:"
${rake_cmd} spec
echo

set -e
echo "Backup data container:"
${ssh_cmd} ${vagrant_hostname} " \
    ${docker_cmd} run --rm \
        --volumes-from ${data_container_name} \
        -v /tmp/:/backup \
        ubuntu:14.04 \
        tar zcf /backup/$(date '+%Y%m%d%H%M%S.%Z')_backup.tar /var/log \
"

# echo "Delete container:"
#
# for cid in $(${ssh_cmd} ${vagrant_hostname} "${docker_cmd} ps -a -q --no-trunc")
# do
#     echo ${cid}
#     ${ssh_cmd} ${vagrant_hostname} " \
#         ${docker_cmd} stop ${cid} > /dev/null \
#         && ${docker_cmd} rm ${cid} > /dev/null
#     "
# done
# ${ssh_cmd} ${vagrant_hostname} "sudo rm -rf ${docker_data_dir}"
#
rm -f ${ssh_config_to_vagrant}
exit
