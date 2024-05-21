#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.2_build/ghidra_10.2_PUBLIC_20221101.zip -O $RALPM_TMP_DIR/ghidra_10.2_PUBLIC_20221101.zip
  unzip $RALPM_TMP_DIR/ghidra_10.2_PUBLIC_20221101.zip -d $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/ghidra_10.2_PUBLIC_20221101.zip

  wget https://corretto.aws/downloads/resources/11.0.16.8.1/amazon-corretto-11.0.16.8.1-linux-x64.tar.gz -O $RALPM_TMP_DIR/amazon-corretto-11.0.16.8.1-linux-x64.tar.gz
  tar xf $RALPM_TMP_DIR/amazon-corretto-11.0.16.8.1-linux-x64.tar.gz -C $RALPM_PKG_INSTALL_DIR

  echo "#!/usr/bin/env sh" > $RALPM_PKG_BIN_DIR/ghidra
  echo "export PATH=$RALPM_PKG_INSTALL_DIR/amazon-corretto-11.0.16.8.1-linux-x64/bin/:\$PATH" >> $RALPM_PKG_BIN_DIR/ghidra
  echo "$RALPM_PKG_INSTALL_DIR/ghidra_10.2_PUBLIC/ghidraRun \"\$@\"" >> $RALPM_PKG_BIN_DIR/ghidra
  chmod +x $RALPM_PKG_BIN_DIR/ghidra
}

uninstall() {
  rm $RALPM_PKG_BIN_DIR/ghidra
  rm -rf $RALPM_PKG_INSTALL_DIR/ghidra_10.2_PUBLIC
  rm -rf $RALPM_PKG_INSTALL_DIR/amazon-corretto-11.0.16.8.1-linux-x64
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1