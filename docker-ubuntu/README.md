A Docker image based on `ubuntu` that runs `systemd` with a minimal set of
services.

**This image is meant for development use only. We strongly recommend against
running it in production!**

## Supported tags

* `18.04`, `bionic`

## But why?

The short answer: use `local/ubuntu-18.04-systemd` for running applications that
need to be run in a full Ubuntu system and not on their own as PID 1.

The long answer: `local/ubuntu-systemd` might be a better choice than the
stock `ubuntu` image if one of the following is true:

- You want to test a provisioning or deployment script that configures and
  starts `systemd` services.

- You want to run multiple services in the same container.

- You want to solve the [the PID 1 zombie reaping problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/).

If you just want to run a single, short-lived process in a container, you
should probably use the stock `ubuntu` image instead.

## Setup

Before you start your first `systemd` container, run the following command to
set up your Docker host. It uses [special privileges](https://docs.docker.com/engine/reference/run/#/runtime-privilege-and-linux-capabilities)
to create a cgroup hierarchy for `systemd`. We do this in a separate setup
step so we can run `systemd` in unprivileged containers.

    docker run --rm --privileged -v /:/host local/ubuntu-systemd setup

## Running

You need to add a couple of flags to the `docker run` command to make `systemd`
play nice with Docker.

We must disable seccomp because `systemd` uses system calls that are not
allowed by Docker's default seccomp profile:

    --security-opt seccomp=unconfined

Ubuntu's `systemd` expects `/run` and `/run/lock` to be `tmpfs` file systems,
but it can't mount them itself in an unprivileged container:

    --tmpfs /run
    --tmpfs /run/lock

`systemd` needs read-only access to the kernel's cgroup hierarchies:

    -v /sys/fs/cgroup:/sys/fs/cgroup:ro

Allocating a pseudo-TTY is not strictly necessary, but it gives us pretty
color-coded logs that we can look at with `docker logs`:

    -t

## Testing

This image is useless as it's only meant to serve as a base for your own
images, but you can still create a container from it. First set up your Docker
host as described in Setup above. Then run the following command:

    docker run -d --name systemd --security-opt seccomp=unconfined --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro -t local/ubuntu-systemd

Check the logs to see if `systemd` started correctly:

    docker logs systemd

If everything worked, the output should look like this:

    systemd 229 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ -LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN)
    Detected virtualization docker.
    Detected architecture x86-64.

    Welcome to Ubuntu 18.04.2 LTS!

    Set hostname to <aad1d41c3a2e>.
    Initializing machine ID from random generator.
    [  OK  ] Created slice System Slice.
    [  OK  ] Reached target Slices.
    [  OK  ] Listening on Journal Socket.
    [  OK  ] Listening on Journal Socket (/dev/log).
    [  OK  ] Reached target Local File Systems.
             Starting Journal Service...
             Starting Create Volatile Files and Directories...
    [  OK  ] Reached target Swap.
    [  OK  ] Reached target Sockets.
    [  OK  ] Reached target Paths.
    [  OK  ] Started Create Volatile Files and Directories.
    [  OK  ] Started Journal Service.

Also check the journal logs:

    docker exec systemd journalctl

The output should look clean without any error.

To check for clean shutdown, in one terminal run:

    docker exec systemd journalctl -f

And in another shut down `systemd`:

    docker stop systemd

The journalctl logs should look as a clean shutdown.

## Known issues

There's [a bug](https://github.com/docker/docker/issues/22327) in Docker
versions < 1.12.0 that randomly causes `/run` and `/run/lock` to be mounted in
the wrong order. In this case the output of `docker logs` looks like this:

    Failed to mount tmpfs at /run/lock: Permission denied
    [!!!!!!] Failed to mount API filesystems, freezing.
    Freezing execution.

If this happens to you, `docker kill` the container (it won't listen for the
shutdown signal) and start it again with `docker start`. Better luck next time!

## Credit

* [Solita](http://www.solita.fi). See [the README.md](https://github.com/solita/docker-systemd/blob/master/README.md).
