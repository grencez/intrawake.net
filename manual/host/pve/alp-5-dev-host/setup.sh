#!/bin/sh

sed -i "s:/v[0-9.]*/:/latest-stable/:" /etc/apk/repositories
apk update
apk upgrade
apk add build-base cmake git  # For Fildesh build.
apk add python3  # For Ansible.
apk add valgrind
apk add alpine-sdk
reboot

adduser -D -G users gendeux
printf "permit nopass %s as %s\n" root gendeux >/etc/doas.d/gendeux.conf
# Prepare user to build stuff Alpine packages.
addgroup gendeux abuild
doas -u gendeux abuild-keygen -n -a
install -m u=rw,go=r -t /etc/apk/keys/ "/home/gendeux/.abuild/$(ls -t /home/gendeux/.abuild/ | grep -m 1 -E -e '.rsa.pub$')"

doas -u gendeux ash
cd
mkdir code
cd code
git clone https://github.com/fildesh/fildesh.git
cd fildesh
mkdir bld
cd bld
cmake .. -D CMAKE_BUILD_TYPE=Release
cmake --build .


cd "${HOME}/code/fildesh/pkg/alpine"
abuild
# https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package
