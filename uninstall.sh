#!/bin/bash

tar zxvf ./linux-amd64_deb.tgz
bash ./linux-amd64_deb/uninstall.sh
rm -f /var/opt/cprocsp/tmp/.reqistry_lock
rm -rf /opt/cprocsp
rm -rf /etc/opt/cprocsp
rm -rf /var/opt/cprocsp

rm -rf linux-amd64_deb 