#!/bin/bash

echo "Build docker image:"
# vagrant ssh-config --host docker_tdd >> ~/.ssh/config
ssh docker_tdd "docker -H :5432 build -t sgykfjsm/nginx_ubuntu /vagrant/docker/nginx/."
echo

echo "Run rspec test:"
rake spec
echo

