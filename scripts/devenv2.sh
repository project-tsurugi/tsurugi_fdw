#!/bin/bash

# This script sets up a development environment for this project.

set -eo pipefail

TSURUGI_HOME=$HOME/project-tsurugi
INSTALL_PREFIX=$HOME/tsurugi/tsurugi

BUILD_TYPE=RelWithDebInfo
BINARY_DIR=build

SHARKSFIN_IMPLEMENTATION=shirakami

sudo apt update -y
sudo apt install -y $(cat scripts/ubuntu.deps)

mkdir -p $TSURUGI_HOME
cd $TSURUGI_HOME

if [[ -d $TSURUGI_HOME/metadata-manager ]]; then
  cd $TSURUGI_HOME
else
  git clone -b feature/timestamp git@github.com:project-tsurugi/metadata-manager.git
fi

if [[ -d $TSURUGI_HOME/message-manager ]]; then
  cd $TSURUGI_HOME
else
  git clone git@github.com:project-tsurugi/message-manager.git
fi

if [[ -d $TSURUGI_HOME/ogawayama ]]; then
  cd $TSURUGI_HOME
else
  git clone -b feature/timestamp git@github.com:project-tsurugi/ogawayama.git
fi

###
### Build for git@github.com:project-tsurugi/metadata-manager.git
###
cd $TSURUGI_HOME/metadata-manager
git submodule update --init --recursive

# Install metadata-manager
echo -e "*************************************"
echo -e "***** Install metadata-manager ******"
echo -e "*************************************"
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DFORCE_INSTALL_RPATH=ON \
    -DDATA_STORAGE=json \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

###
### Build for git@github.com:project-tsurugi/message-manager.git
###
cd $TSURUGI_HOME/message-manager
git submodule update --init --recursive

# Install_manager
echo -e "*************************************"
echo -e "****** Install message-manager ******"
echo -e "*************************************"
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

###
### Build for git@github.com:project-tsurugi/ogawayama.git
###
cd $TSURUGI_HOME/ogawayama
git submodule update --init --recursive

# Install_ogawayama
echo -e "***************************************"
echo -e "********** Install_ogawayama **********"
echo -e "***************************************"
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_MODULE_PATH=$INSTALL_PREFIX \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install
