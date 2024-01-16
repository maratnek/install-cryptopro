#!/bin/bash

################################################################
###### Work with Certificates ######    
# show root certificates
/opt/cprocsp/bin/amd64/certmgr -l -store uRoot

# work with certificates
# use this site to get the root certificates https://www.cryptopro.ru/sites/default/files/products/cades/demopage/cades_bes_sample.html
# install root certificate from CryptoPro
echo "o" | /opt/cprocsp/bin/amd64/certmgr -inst -store uRoot -file certnew.crt

# create own certificate base on the my store 
# create for siganture (attribute -sg)
/opt/cprocsp/bin/amd64/csptest -keyset -deletekeyset -cont '\\.\HDIMAGE\clientcont'
echo "o" | /opt/cprocsp/bin/amd64/cryptcp -createcert -rdn "E=zm@bank.ru,CN=ZM" -cont 'clientcont' -pin 1234 -certusage "1.3.6.1.4.1.311.10.3.12" -sg

# integrate to store uMy
# /opt/cprocsp/bin/amd64/certmgr -inst -file myreq.req cont 'clientcont' -at_signature
# export certificate to file to check in the certificate chain checking 
/opt/cprocsp/bin/amd64/certmgr -export -container 'clientcont' -at_signature -dest cer-test-clientcont.cer

# delete certificate in store my
# /opt/cprocsp/bin/amd64/certmgr -delete -store umy
# look all stores
/opt/cprocsp/bin/amd64/certmgr -l -store uRoot
/opt/cprocsp/bin/amd64/certmgr -enumstores all_locations

################################################################