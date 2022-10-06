#!/bin/bash

# This script sets up a development environment for this project.

set -eo pipefail

TSURUGI_HOME=$HOME/project-tsurugi
JOGASAKI_HOME=$TSURUGI_HOME/jogasaki
INSTALL_PREFIX=$HOME/.local

BUILD_TYPE=RelWithDebInfo
BINARY_DIR=build

SHARKSFIN_IMPLEMENTATION=shirakami

sudo apt update -y
sudo apt install -y $(cat scripts/ubuntu.deps)

mkdir -p $TSURUGI_HOME
cd $TSURUGI_HOME

if [[ -d $TSURUGI_HOME/jogasaki ]]; then
  cd $TSURUGI_HOME
else
  git clone git@github.com:project-tsurugi/jogasaki.git
fi

if [[ -d $TSURUGI_HOME/metadata-manager ]]; then
  cd $TSURUGI_HOME
else
  git clone -b feature/table_metadata git@github.com:project-tsurugi/metadata-manager.git
fi

if [[ -d $TSURUGI_HOME/message-manager ]]; then
  cd $TSURUGI_HOME
else
  git clone git@github.com:project-tsurugi/message-manager.git
fi

if [[ -d $TSURUGI_HOME/ogawayama ]]; then
  cd $TSURUGI_HOME
else
#  git clone git@github.com:project-tsurugi/ogawayama.git
  git clone git@github.com:koh-okada/ogawayama.git
fi

if [[ -d $TSURUGI_HOME/tateyama-bootstrap ]]; then
  cd $TSURUGI_HOME
else
  git clone git@github.com:project-tsurugi/tateyama-bootstrap.git
fi

###
### Build for git@github.com:project-tsurugi/jogasaki.git
###
cd $JOGASAKI_HOME
git submodule update --init --recursive

# Install_limestone
echo -e "***************************************"
echo -e "********** Install_limestone **********"
echo -e "***************************************"
cd $JOGASAKI_HOME/third_party/tateyama/third_party/sharksfin/third_party/shirakami/third_party/limestone
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
cd $JOGASAKI_HOME/third_party/tateyama/third_party/sharksfin/third_party/shirakami
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
cd $JOGASAKI_HOME/third_party/tateyama/third_party/sharksfin
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

# Install_mpdecimal
echo -e "***************************************"
echo -e "********** Install_mpdecimal **********"
echo -e "***************************************"
cd $TSURUGI_HOME/
rm -rf mpdecimal-2.5.1
wget https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.tar.gz -e https_proxy=http://proxygate2.nic.nec.co.jp:8080/ --no-check-certificate
tar zxf mpdecimal-2.5.1.tar.gz
rm mpdecimal-2.5.1.tar.gz

cd mpdecimal-2.5.1/
./configure --prefix=$INSTALL_PREFIX
make
make install

# Install_takatori
echo -e "**************************************"
echo -e "********** Install_takatori **********"
echo -e "**************************************"
cd $JOGASAKI_HOME/third_party/mizugaki/third_party/yugawara/third_party/takatori
rm -rf $BINARY_DIR
mkdir $BINARY_DIR
cd $BINARY_DIR
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Debug \
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
cd $JOGASAKI_HOME/third_party/mizugaki/third_party/hopscotch-map
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
cd $JOGASAKI_HOME/third_party/mizugaki/third_party/yugawara
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
cd $JOGASAKI_HOME/third_party/mizugaki/third_party/shakujo
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
cd $JOGASAKI_HOME/third_party/mizugaki
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
cd $JOGASAKI_HOME/third_party/performance-tools
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
cd $JOGASAKI_HOME/third_party/concurrentqueue
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
cd $JOGASAKI_HOME/third_party/tateyama
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
cd $JOGASAKI_HOME
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
    -DCMAKE_CXX_FLAGS="-w" \
    ..
ninja
ninja install

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
    -DDATA_STORAGE=postgresql \
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

###
### Build for git@github.com:project-tsurugi/tateyama-bootstrap.git
###
cd $TSURUGI_HOME/tateyama-bootstrap
git submodule update --init --recursive

# Install_tateyama-bootstrap
echo -e "************************************************"
echo -e "********** Install_tateyama-bootstrap **********"
echo -e "************************************************"
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
