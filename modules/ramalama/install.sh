#!/usr/bin/env bash
pip3 install black flake8 argcomplete wheel huggingface_hub codespell
chmod -R g=u ${HOME}
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf install -y golang-github-cpuguy83-md2man-devel