#!/usr/bin/env bash

set -e

mkdir -p /usr/local/bin
mkdir /projects
pip install -U podman-compose
pip install -U cekit
chmod 755 /entrypoint.sh
#
# Setup for root-less podman
#
mkdir -p ${HOME}
chown -R 1000:1000 ${HOME}
echo "user:x:1000:1000:devspaces user:${HOME}:/bin/bash" >> /etc/passwd
echo "user:x:1000:" >> /etc/group
echo "user:1001:64535" >> /etc/subuid
echo "user:1001:64535" >> /etc/subgid
setcap cap_setuid+ep /usr/bin/newuidmap
setcap cap_setgid+ep /usr/bin/newgidmap
#
# Create Sym Links for OpenShift CLI (Assumed to be retrieved by an init-container)
#
ln -s /projects/bin/oc /usr/local/bin/oc
ln -s /projects/bin/kubectl /usr/local/bin/kubectl