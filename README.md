
# Testing Ansible Playbooks with Docker

With Docker, we can test any Ansible playbook against any version of any Linux distribution without the help of Vagrant.

## Let's build our docker image first

### Explanation

* We base this on the [official centos7 image](https://github.com/docker-library/docs/tree/master/centos)
* The ugly hack starting at the RUN command and below is needed to get systemd working, see the docs at [Dockerfile for systemd integration base image](https://github.com/docker-library/docs/tree/master/centos#systemd-integration)
* We install openssh-server and passwd and sudo (this enables us to create a ssh user)
* We enable sshd service with systemctl so it starts at boot
* We run a script called start.sh (see below) that will create a user, called user, and add it to sudoers
* We create an environment variable, AUTHORIZED_KEYS, which we will inject our public ssh key when the containers starts that ansible will use to authenticate
* run.sh checks if AUTHORIZED_KEYS environment variable is set, if true it takes the value and popluate authorized_keys file.
* Then it runs exec /usr/sbin/init

### Build command

```
docker build -f docker/Dockerfile -t local/centos7-systemd ./docker
```

## Run ansible-playbook against a container
Now we’re ready to start a container from the image we created and run ansible-playbook against it.
For convenience we’ll put all the commands in a shell script, container-start-and-playbook-run.sh, that way it’s easy to chain everything together:

```
DCKER_CONTAINER_NAME="ansible-role-test"
SSH_PUBLIC_KEY_FILE=ansible/ssh/id_rsa.pub
SSH_PUBLIC_KEY=$(cat "$SSH_PUBLIC_KEY_FILE")
```

```
docker run -ti --privileged --name $DOCKER_CONTAINER_NAME -d -p 5000:22 -e AUTHORIZED_KEYS="$SSH_PUBLIC_KEY" local/centos7-systemd
```

```
cd ansible && ansible-playbook -i env/local_docker site.yml --private-key ssh/id_rsa
```

Note:

The container needs to mount systemd cgroups on the host as a volume (Note that it can not run on distos using another init system or OSX).
