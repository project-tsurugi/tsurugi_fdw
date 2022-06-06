#!/bin/bash

# This script sets up a development environment for this project.

set -eo pipefail

TSURUGI_HOME=$HOME/project-tsurugi-boot
BOOTSTRAP_HOME=$TSURUGI_HOME/tateyama-bootstrap
INSTALL_PREFIX=$HOME/.local

BUILD_TYPE=RelWithDebInfo
BINARY_DIR=build

SHARKSFIN_IMPLEMENTATION=memory

sudo apt update -y
sudo apt install -y $(cat scripts/ubuntu.deps)

mkdir -p $TSURUGI_HOME
cd $TSURUGI_HOME

if [[ -d $TSURUGI_HOME/tateyama-bootstrap ]]; then
  cd $TSURUGI_HOME
else
  git clone git@github.com:project-tsurugi/tateyama-bootstrap.git
fi

if [[ -d $TSURUGI_HOME/ogawayama ]]; then
  cd $TSURUGI_HOME
else
  git clone -b wip/message_receiver git@github.com:project-tsurugi/ogawayama.git
fi

# tateyama-bootstrap
cd $BOOTSTRAP_HOME
git submodule update --init --recursive

# Install_limestone
echo -e "***************************************"
echo -e "********** Install_limestone **********"
echo -e "***************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/tateyama/third_party/limestone
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_shirakami
echo -e "***************************************"
echo -e "********** Install_shirakami **********"
echo -e "***************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/sharksfin/third_party/shirakami
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DENABLE_SANITIZER=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_sharksfin
echo -e "***************************************"
echo -e "********** Install_sharksfin **********"
echo -e "***************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/sharksfin
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTS=OFF \
    -DBUILD_DOCUMENTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_fpdecimal
echo -e "***************************************"
echo -e "********** Install_fpdecimal **********"
echo -e "***************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/mizugaki/third_party/yugawara/third_party/takatori/third_party/fpdecimal
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTS=OFF \
    -DBUILD_DOCUMENTS=OFF \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_takatori
echo -e "**************************************"
echo -e "********** Install_takatori **********"
echo -e "**************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/mizugaki/third_party/yugawara/third_party/takatori
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTS=OFF \
    -DBUILD_DOCUMENTS=OFF \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_hopscotch-map
echo -e "*******************************************"
echo -e "********** Install_hopscotch-map **********"
echo -e "*******************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/mizugaki/third_party/hopscotch-map
rm -rf ../../build-hopscotch-map
mkdir -p ../../build-hopscotch-map
cd ../../build-hopscotch-map
cmake -G Ninja \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ../third_party/hopscotch-map
ninja
ninja install

# Install_yugawara
echo -e "**************************************"
echo -e "********** Install_yugawara **********"
echo -e "**************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/mizugaki/third_party/yugawara
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTS=OFF \
    -DBUILD_DOCUMENTS=OFF \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_shakujo
echo -e "*************************************"
echo -e "********** Install_shakujo **********"
echo -e "*************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/mizugaki/third_party/shakujo
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTS=OFF \
    -DBUILD_DOCUMENTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_bison
echo -e "***********************************"
echo -e "********** Install_bison **********"
echo -e "***********************************"
cd $TSURUGI_HOME/
rm -rf bison-3.5.1
curl http://ftp.jaist.ac.jp/pub/GNU/bison/bison-3.5.1.tar.gz | tar zxv
cd bison-3.5.1
./configure --prefix=$INSTALL_PREFIX
make -j4
make install

# Install_mizugaki
echo -e "**************************************"
echo -e "********** Install_mizugaki **********"
echo -e "**************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/mizugaki
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTS=OFF \
    -DBUILD_DOCUMENTS=OFF \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_performance_tools
echo -e "***********************************************"
echo -e "********** Install_performance_tools **********"
echo -e "***********************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/performance-tools
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTS=OFF \
    -DBUILD_DOCUMENTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_moodycamel_concurrentqueue
echo -e "********************************************************"
echo -e "********** Install_moodycamel_concurrentqueue **********"
echo -e "********************************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/concurrentqueue
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_tateyama
echo -e "**************************************"
echo -e "********** Install_tateyama **********"
echo -e "**************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki/third_party/tateyama
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
    -DBUILD_TESTS=OFF \
    -DBUILD_DOCUMENTS=OFF \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_jogasaki
echo -e "**************************************"
echo -e "********** Install_jogasaki **********"
echo -e "**************************************"
cd $BOOTSTRAP_HOME/third_party/jogasaki
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
    ..
ninja
ninja install

# Install_manager
echo -e "*************************************"
echo -e "********** Install_manager **********"
echo -e "*************************************"
cd $BOOTSTRAP_HOME/third_party/ogawayama/third_party/manager
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

# Install_ogawayama
echo -e "***************************************"
echo -e "********** Install_ogawayama **********"
echo -e "***************************************"
cd $TSURUGI_HOME/ogawayama
git submodule update --init
### cd $BOOTSTRAP_HOME/third_party/ogawayama
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

# CMake_Build
echo -e "*********************************"
echo -e "********** CMake_Build **********"
echo -e "*********************************"
cd $BOOTSTRAP_HOME
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION \
    -DOGAWAYAMA=ON \
    -DFORCE_INSTALL_RPATH=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
    ..
ninja
ninja install
