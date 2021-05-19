#!/bin/bash

# This script sets up a development environment for this project.

set -eo pipefail

TSURUGI_HOME=$HOME/project-tsurugi
INSTALL_PREFIX=$HOME/.local

#BUILD_TYPE=Release
BUILD_TYPE=RelWithDebInfo
BINARY_DIR=build

SHARKSFIN_IMPLEMENTATION=memory

sudo apt update -y
#sudo apt install -y \
#    build-essential \
#    cmake \
#    doxygen \
#    git \
#    libboost-filesystem-dev \
#    libboost-serialization-dev \
#    libboost-system-dev \
#    libgflags-dev \
#    libgoogle-glog-dev \
#    libleveldb-dev \
#    libmsgpack-dev \
#    ninja-build \
#    openjdk-8-jdk \
#    pkg-config \
#    uuid-dev \
#    libboost-thread-dev
sudo apt install -y $(cat scripts/ubuntu.deps)

mkdir -p $TSURUGI_HOME
cd $TSURUGI_HOME
git clone git@github.com:project-tsurugi/manager.git
git clone git@github.com:project-tsurugi/masstree-beta.git
git clone git@github.com:project-tsurugi/kvs_charkey.git
git clone git@github.com:project-tsurugi/shakujo.git
git clone git@github.com:project-tsurugi/shirakami.git
git clone git@github.com:project-tsurugi/sharksfin.git
git clone git@github.com:project-tsurugi/umikongo.git
git clone git@github.com:project-tsurugi/ogawayama.git

# manager

cd $TSURUGI_HOME/manager
git submodule update --init

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR

cmake -G 'Unix Makefiles' \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DFORCE_INSTALL_RPATH=ON \
    ..
make
make install

# mastree

cd $TSURUGI_HOME/masstree-beta
git submodule update --init

#./bootstrap.sh
#./configure
#make
#make install

# kvs_charkey

cd $TSURUGI_HOME/kvs_charkey
git submodule update --init

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR

#cmake -G Ninja \
#    -DFORCE_INSTALL_RPATH=ON \
#    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
#    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
#    ..
#ninja
#ninja install

# shakujo

cd $TSURUGI_HOME/shakujo
git submodule update --init

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DFORCE_INSTALL_RPATH=ON \
    -DBUILD_TESTS=OFF \
    ..
ninja
ninja install

# shirakami

cd $TSURUGI_HOME/shirakami/
git submodule update --init 

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DFORCE_INSTALL_RPATH=ON \
    -DBUILD_TESTS=ON \
    ..
ninja
ninja install

# sharksfin

cd $TSURUGI_HOME/sharksfin
git submodule update --init third_party/googletest

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DFORCE_INSTALL_RPATH=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_KVS=OFF \
    ..
ninja
ninja install

# umikongo

cd $TSURUGI_HOME/umikongo
git submodule update --init third_party/googletest

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DFORCE_INSTALL_RPATH=ON \
    -DFIXED_PAYLOAD_SIZE=ON \
    -DBUILD_TESTS=OFF \
    -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
    ..
ninja
ninja install

# ogawayama

cd $TSURUGI_HOME/ogawayama
git submodule update --init 

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DFORCE_INSTALL_RPATH=ON \
    -DBUILD_TESTS=OFF \
    -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
    -DCMAKE_MODULE_PATH=$INSTALL_PREFIX \
    ..
ninja
ninja install
