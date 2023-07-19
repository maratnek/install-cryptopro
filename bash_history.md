 ```bash
 919  cd install-cryptopro/
  920  ls
  921  cd linux-amd64_deb/
  922  mc
  923  cd ..
  924  code .
  925  openssl 
  926  openssl -h
  927  openssl md5 
  928  ls
  929  /opt/cprocsp/bin/amd64/genkpim 2 00000001 /var/opt/cprocsp/dsrf/
  930  /opt/cprocsp/bin/amd64/genkpim 2 00000001 /var/opt/cprocsp/dsrf
  931  sudo /opt/cprocsp/bin/amd64/genkpim 2 00000001 /var/opt/cprocsp/dsrf
  932  /opt/cprocsp/sbin/amd64/cpconfig -hardware rndm -add cpsd -name 'cpsd rng' -level 3
  933  sudo /opt/cprocsp/sbin/amd64/cpconfig -hardware rndm -add cpsd -name 'cpsd rng' -level 3
  934  sudo /opt/cprocsp/sbin/amd64/cpconfig -hardware rndm -configure cpsd -add string /db1/kis_1 /var/opt/cprocsp/dsrf/db1/kis_1
  935  sudo /opt/cprocsp/sbin/amd64/cpconfig -hardware rndm -configure cpsd -add string /db2/kis_1 /var/opt/cprocsp/dsrf/db2/kis_1
  936  /opt/cprocsp/bin/amd64/csptest -keyset -newkeyset -machinekeyset -password 123456 -hard_rng -container 'HDIMAGE\\dummy1'
  937  /opt/cprocsp/bin/amd64/csptest -keyset -newkeyset -machinekeyset -password 123456 -hard_rng -container 'HDIMAGE\\dummy2'
  938  /opt/cprocsp/bin/amd64/csptest -keyset -newkeyset -machinekeyset -password 123456 -hard_rng -container 'HDIMAGE\\dummy3'
  939  /opt/cprocsp/bin/amd64/csptest -keyset -enum_cont -fqcn -verifyc
  940  /opt/cprocsp/bin/amd64/csptest -keyset -enum_cont 
  941  /opt/cprocsp/bin/amd64/csptest -keyset -enum_cont -machinekeyset
  942  /opt/cprocsp/bin/amd64/csptest -keyset -enum_cont -machinekeyset -hard_rng
  943  /opt/cprocsp/bin/amd64/csptest -keyset -machinekeyset -hard_rng
  944  /opt/cprocsp/bin/amd64/csptest --help
  945  /opt/cprocsp/bin/amd64/csptest -keyset -help
  946  cd /var/opt/cprocsp/
  947  ls
  948  cd dsrf/
  949  ls
  950  cat kpim 
  951  cd db1/
  952  ls
  953  cat kis_1 
  954  cd ..
  955  ls
  956  cat kpim 
  957  sudo /opt/cprocsp/sbin/amd64/cpconfig -defprov -setdef -provtype 80 -provname 'Crypto-Pro GOST R 34.10-2012 KC1 CSP'
  958  tar -xzf go1.20.3.linux-amd64.tar.gz 
  959  ls
  960  cd go/
  961  ls
  962  cd ..
  963  sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz
  964  ls
  965  sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz
  966  sudo rm -rf /usr/local/go
  967  sudo tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz
  968  go version
  969  history

```