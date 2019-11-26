#!/bin/bash

# This script sets up a development environment for this project.

set -eo pipefail

TSURUGI_HOME=$HOME/project-tsurugi
INSTALL_PREFIX=$HOME/.local

#BUILD_TYPE=Release
BUILD_TYPE=RelWithDebInfo
BINARY_DIR=build

#sudo apt update -y
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
#    uuid-dev

mkdir -p $TSURUGI_HOME
cd $TSURUGI_HOME
git clone git@github.com:project-tsurugi/shakujo.git
git clone git@github.com:project-tsurugi/sharksfin.git
git clone git@github.com:project-tsurugi/umikongo.git
git clone git@github.com:project-tsurugi/ogawayama.git

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
    -DSHARKSFIN_IMPLEMENTATION=memory \
    ..
ninja
ninja install

# ogawayama

cd $TSURUGI_HOME/ogawayama
git submodule update --init third_party/googletest

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DFORCE_INSTALL_RPATH=ON \
    ..
ninja
ninja install
