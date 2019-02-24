#!/bin/bash

DOCKER_CONTAINER_NAME="ansible-role-test"
SSH_PUBLIC_KEY_FILE=ansible/ssh/id_rsa.pub
SSH_PUBLIC_KEY=$(cat "$SSH_PUBLIC_KEY_FILE")

docker run --rm -ti --privileged --name $DOCKER_CONTAINER_NAME -d -p 5000:22 -e AUTHORIZED_KEYS="$SSH_PUBLIC_KEY" local/centos7-systemd

cd ansible && ansible-playbook -i env/local_docker site.yml --private-key ssh/id_rsa
