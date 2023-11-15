#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

CPCONFIG=/opt/cprocsp/sbin/amd64/cpconfig
CSPTEST=/opt/cprocsp/bin/amd64/csptest
KIS_1=/var/opt/cprocsp/dsrf/db1/kis_1
KIS_2=/var/opt/cprocsp/dsrf/db2/kis_1

KIS_SAMPLE="W+bji05lOwHfTXYJcd5SpS4+30j5sgneR5Zyl3rI//1rnR+veFeiCvM66Yobd9dTj0K66M1s2p1G/NpG0sIxV3Pj2C+QNyIy"

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Override paths
  CPCONFIG=/opt/cprocsp/sbin/cpconfig
  CSPTEST=/opt/cprocsp/bin/csptest
fi

function install() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing.."
    hdiutil attach ru.cryptopro.csp-4.0.9963.dmg
    installer -package /Volumes/ru.cryptopro.csp-4.0.9963/ru.cryptopro.csp-4.0.9963.mpkg -target /
    hdiutil detach /Volumes/ru.cryptopro.csp-4.0.9963
  else
    apt-get update
    apt-get install -y clang llvm build-essential git language-pack-ru libssl-dev pkg-config
    (tar xzvf linux-amd64_deb.tgz && cd linux-amd64_deb && bash ./install.sh lsb-cprocsp-devel)
    rm -rf linux-amd64_deb
    $CPCONFIG -defprov -setdef -provtype 80 -provname 'Crypto-Pro GOST R 34.10-2012 KC1 CSP'
  fi
}

function install_cades() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing cades.."
    hdiutil attach cprocsp-pki-2.0.0.dmg
    installer -package /Volumes/cprocsp-pki-2.0.0/cprocsp-pki-2.0.0.mpkg -target /
    hdiutil detach /Volumes/cprocsp-pki-2.0.0
  else
    tar xzvf linux-amd64_deb.tgz
    cd linux-amd64_deb
    dpkg -i cprocsp-rdr-gui-gtk-64_5.0.12922-7_amd64.deb 
    dpkg -i cprocsp-pki-cades-64_2.0.14927-1_amd64.deb
    dpkg -i cprocsp-pki-phpcades_2.0.14927-1_all.deb
    dpkg -i cprocsp-pki-plugin-64_2.0.14927-1_amd64.deb
    cd ..
    rm -rf linux-amd64_deb
    # dpkg -i cprocsp-pki-cades-64_2.0.14815-1_amd64.deb
    # dpkg -i cprocsp-pki-cades_2.0.0-1_amd64.deb
  fi
}

function uninstall() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Uninstalling.."
    hdiutil attach ru.cryptopro.csp-4.0.9963.dmg
    /Volumes/ru.cryptopro.csp-4.0.9963/uninstall_csp.app/Contents/MacOS/applet
    hdiutil detach /Volumes/ru.cryptopro.csp-4.0.9963
  else
    (tar xzvf linux-amd64_deb.tgz && cd linux-amd64_deb && bash ./uninstall.sh)
    rm -rf linux-amd64_deb
  fi
}

function check_and_fix_license() {
  echo "Check and fix license..."
  if [[ $($CPCONFIG -license -view 2>&1) == *"Error code"* ]]; then
    echo "Fixing license.."
    rm /etc/opt/cprocsp/license.ini
    uninstall
    install
  fi

  if [[ $($CPCONFIG -license -view 2>&1) == *"Error code"* ]]; then
    return 1
  else
    return 0
  fi
}

function check_and_fix_rng() {
  echo "Check and fix RNG..."
  if [[ $($CSPTEST -keyset -newkeyset -password 123456 -hard_rng -container 'HDIMAGE\\dummy68' -silent 2>&1) == *"80090022"* ]]; then
    echo "Fixing RNG.."
    $CPCONFIG -hardware rndm -add cpsd -name 'cpsd rng' -level 3

    for x in {1..100}; do
      echo $KIS_SAMPLE | base64 --decode >>$KIS_1
    done

    for x in {1..1000}; do
      cat $KIS_1 >>$KIS_2
    done

    cp $KIS_2 $KIS_1

    chmod 666 $KIS_1
    chmod 666 $KIS_2
  else
    $CSPTEST -keyset -deletekeyset -password 123456 -hard_rng -container 'HDIMAGE\\dummy68' -silent 2>&1 >/dev/null
  fi

  if [[ $($CSPTEST -keyset -newkeyset -password 123456 -hard_rng -container 'HDIMAGE\\dummy68' -silent 2>&1) == *"80090022"* ]]; then
    return 1
  else
    $CSPTEST -keyset -deletekeyset -password 123456 -hard_rng -container 'HDIMAGE\\dummy68' -silent 2>&1 >/dev/null
    return 0
  fi
}

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

if [[ ! -f $CPCONFIG || ! -f $CSPTEST ]]; then
  # CryptoPro is not istalled
  install
fi

install_cades

if ! check_and_fix_license; then
  echo "FATAL: Can't fix license"
  exit 1
fi

if ! check_and_fix_rng; then
  echo "FATAL: Can't fix RNG"
  exit 1
fi

$CPCONFIG -loglevel ocsp -mask 0xF
$CPCONFIG -loglevel tsp -mask 0xF
$CPCONFIG -loglevel cades -mask 0xF
$CPCONFIG -loglevel cpcsp -mask 0xF
$CPCONFIG -loglevel capi10 -mask 0xF
$CPCONFIG -loglevel cprdr -mask 0xF
$CPCONFIG -loglevel cpext -mask 0xF
$CPCONFIG -loglevel capi20 -mask 0xF
$CPCONFIG -loglevel capilite -mask 0xF


if [[ "$OSTYPE" == "darwin"* ]]; then
  LIB_PATH=/opt/cprocsp/lib
  CADES_PATH=/Applications/CryptoPro_ECP.app/Contents/MacOS/lib
  echo -e "\n${GREEN}Done!${NC} Do not forget to properly setup the environment:"
  echo -e "  ${YELLOW}export DYLD_LIBRARY_PATH=\"${LIB_PATH}:${CADES_PATH}:\$DYLD_LIBRARY_PATH\"${NC}"
else
  echo -e "\n${GREEN}Done!${NC} Please relogin to setup the environment."
  rm -f /etc/ld.so.conf.d/cpcsp.conf
  echo "/opt/cprocsp/lib/amd64" >> /etc/ld.so.conf.d/cpcsp.conf
  exit 0
fi
