#!/bin/bash

# This script sets up a development environment for this project.

set -eo pipefail

TSURUGI_HOME=$HOME/project-tsurugi
INSTALL_PREFIX=$HOME/.local
SCRIPT_PATH=$(cd $(dirname $0); pwd)

#BUILD_TYPE=Release
BUILD_TYPE=RelWithDebInfo
BINARY_DIR=build

SHARKSFIN_IMPLEMENTATION=memory

sudo apt update -y
sudo apt install -y $(cat $SCRIPT_PATH/ubuntu.deps)

if [ ! -d $TSURUGI_HOME ]; then
  mkdir -p $TSURUGI_HOME
fi
cd $TSURUGI_HOME

if [ ! -d $TSURUGI_HOME/manager ]; then
  git clone git@github.com:project-tsurugi/manager.git
fi

if [ ! -d $TSURUGI_HOME/shakujo ]; then
  git clone git@github.com:project-tsurugi/shakujo.git
fi

if [ ! -d $TSURUGI_HOME/shirakami ]; then
  git clone git@github.com:project-tsurugi/shirakami.git
fi

if [ ! -d $TSURUGI_HOME/sharksfin ]; then
  git clone git@github.com:project-tsurugi/sharksfin.git
fi

if [ ! -d $TSURUGI_HOME/takatori ]; then
  git clone git@github.com:project-tsurugi/takatori.git
fi

if [ ! -d $TSURUGI_HOME/yugawara ]; then
  git clone git@github.com:project-tsurugi/yugawara.git
fi

#if [ ! -d $TSURUGI_HOME/tateyama ]; then
#  git clone git@github.com:project-tsurugi/tateyama.git
#fi

if [ ! -d $TSURUGI_HOME/jogasaki ]; then
  git clone git@github.com:project-tsurugi/jogasaki.git
fi

if [ ! -d $TSURUGI_HOME/mizugaki ]; then
  git clone git@github.com:project-tsurugi/mizugaki.git
fi

if [ ! -d $TSURUGI_HOME/sandbox-performance-tools ]; then
  git clone git@github.com:project-tsurugi/sandbox-performance-tools.git
fi

if [ ! -d $TSURUGI_HOME/ogawayama ]; then
  git clone git@github.com:project-tsurugi/ogawayama.git
fi

# manager

echo -e "\nmanager started."
cd $TSURUGI_HOME/manager
git submodule update --init

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR

  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      ..
  ninja
  ninja install
fi

# shakujo

echo -e "\nshakujo started."
cd $TSURUGI_HOME/shakujo
git submodule update --init

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      ..
  ninja
  ninja install
fi

# shirakami

echo -e "\nshirakami started."
cd $TSURUGI_HOME/shirakami/
git submodule update --init 

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=ON \
      -DBUILD_DOCUMENTS=OFF \
      ..
  ninja
  ninja install
fi

# sharksfin

echo -e "\nsharksfin started."
cd $TSURUGI_HOME/sharksfin
git submodule update --init third_party/googletest

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_SHIRAKAMI=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      ..
  ninja
  ninja install
fi

# takatori

cd $TSURUGI_HOME/takatori
git submodule update --init --recursive

# fpdecimal(Sub module)
echo -e "\nfpdecimal started."
cd $TSURUGI_HOME/takatori/third_party/fpdecimal

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR

  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      ..
  ninja
  ninja install
fi

echo -e "\ntakatori started."
cd $TSURUGI_HOME/takatori

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      ..
  ninja
  ninja install
fi

# yugawara

echo -e "\nyugawara started."
cd $TSURUGI_HOME/yugawara
git submodule update --init --recursive

# hopscotch-map(Sub module)
cd $TSURUGI_HOME/yugawara/third_party/hopscotch-map

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR

  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      ..
  #cmake --build . --target install --clean-first
  ninja
  ninja install
fi

cd $TSURUGI_HOME/yugawara

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      ..
  #cmake --build . --target install --clean-first
  ninja
  ninja install
fi

# mizugaki
cd $TSURUGI_HOME/

echo -e "\nbison started."
if [ ! -d bison-3.5.1 ]; then
  curl http://ftp.jaist.ac.jp/pub/GNU/bison/bison-3.5.1.tar.gz | tar zxv
  cd bison-3.5.1
  ./configure --prefix=$INSTALL_PREFIX
  make -j4
  make install
fi

echo -e "\nmizukaki started."
cd $TSURUGI_HOME/mizugaki
git submodule update --init --recursive

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      ..
  #cmake --build . --target install --clean-first
  ninja
  ninja install
fi

# sandbox-performance-tools

echo -e "\nsandbox-performance-tools started."
cd $TSURUGI_HOME/sandbox-performance-tools
git submodule update --init

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR

  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      ..
  #cmake --build . --target install --clean-first
  ninja
  ninja install
fi

#
# concurrenqueue (moodycamael)
# 
cd $TSURUGI_HOME/jogasaki
git submodule update --init --recursive

echo -e "\nconcurrentqueue started."
cd $TSURUGI_HOME/jogasaki/third_party/concurrentqueue
if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      ..
  ninja
  ninja install
fi

#
# tateyama
#
echo -e "\ntateyama started."
cd $TSURUGI_HOME/jogasaki/third_party/tateyama
git submodule update --init --recursive
if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENT=OFF  \
      -DBUILD_EXAMPLES=OFF \
      -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
      ..
  ninja
  ninja install
fi

#
# jogasaki
#
echo -e "\njogasaki started."
cd $TSURUGI_HOME/jogasaki

if [ ! -d $BINARY_DIR ]; then
  rm -rf $BINARY_DIR
  mkdir $BINARY_DIR
  cd $BINARY_DIR
  cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
      ..
  #cmake --build . --target install --clean-first
  ninja
  ninja install
fi

# ogawayama
echo -e "\nogawayama started."
cd $TSURUGI_HOME/ogawayama
git submodule update --init 

rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_MODULE_PATH=$INSTALL_PREFIX \
    -DCMAKE_PREFIX_PATH=$TSURUGI_HOME/tateyama/build \
    -DFORCE_INSTALL_RPATH=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
    ..
ninja
ninja install

echo -e "\nbuild finished."
