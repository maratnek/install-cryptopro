#!/bin/bash

rm -rf linux-amd64_deb 

tar zxvf ./linux-amd64_deb.tgz
bash ./linux-amd64_deb/uninstall.sh
rm -f /var/opt/cprocsp/tmp/.reqistry_lock
rm -rf /opt/cprocsp
rm -rf /etc/opt/cprocsp
rm -rf /var/opt/cprocsp

pushd linux-amd64_deb
echo Install cryptopro csp

sudo bash ./install.sh lsb-cprocsp-devel

# dpkg -i cprocsp-curl* lsb-cprocsp-base* lsb-cprocsp-capilite* lsb-cprocsp-kc1* lsb-cprocsp-rdr-64*
# dpkg -i cprocsp-rdr-rutoken* cprocsp-rdr-pcsc* 

# dpkg -i lsb-cprocsp-ca-certs*
# dpkg -i lsb-cprocsp-devel*


echo Install cades plugins
dpkg -i cprocsp-pki-cades*
dpkg -i cprocsp-pki-plugin*

popd

# rm -rf linux-amd64_deb 
sudo /opt/cprocsp/sbin/amd64/cpconfig -defprov -setdef -provtype 80 -provname 'Crypto-Pro GOST R 34.10-2012 KC1 CSP'

/opt/cprocsp/sbin/amd64/cpconfig -license -view 

echo Create container brc

# /opt/cprocsp/sbin/amd64/csptest -keyset -provtype 80 -newkeyset -cont '\\.\HDIMAGE\bcr' 
echo Show container brc
/opt/cprocsp/bin/amd64/csptest -keyset -enum_cont -fqcn -veryfic | iconv -f cp1251 

# create container for delete
/opt/cprocsp/bin/amd64/csptest -keyset -newkeyset -cont 'for delete' -pass 1234
# show container for delete
/opt/cprocsp/bin/amd64/csptest -keyset -enum_cont -fqcn -verifyc
# own self signed certificates
/opt/cprocsp/bin/amd64/csptest -keyset -makecert -container 'for delete'
# look for self signed certificates
/opt/cprocsp/bin/amd64/certmgr -list -cont 'for delete'
# sudo bash ./install.sh

# delete container
/opt/cprocsp/bin/amd64/csptest -keyset -deletekeyset -cont '\\.\HDIMAGE\test'