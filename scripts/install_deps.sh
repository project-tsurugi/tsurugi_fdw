#!/bin/bash

_FDW_DEPS_INSTALL_DIR=$1

_SCRIPTS_DIR=$(cd "$(dirname $0)" && pwd)
_THIRD_PARTY_DIR=${_SCRIPTS_DIR}/../third_party

TG_CMAKE_BUILD_TYPE="RelWithDebInfo"
TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g"
TG_COMMON_CMAKE_BUILD_OPTIONS="-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"

_TAKATORI_DIR="${_THIRD_PARTY_DIR}/takatori"
_METADATA_MANAGER_DIR="${_THIRD_PARTY_DIR}/metadata-manager"
_MESSAGE_MANAGER_DIR="${_THIRD_PARTY_DIR}/message-manager"
_OGAWAYAMA_DIR="${_THIRD_PARTY_DIR}/ogawayama"

if ldconfig -p | grep -F --quiet libmpdec++; then
  echo -e "\n[SKIPPED Install_mpdecimal]"
else
  echo -e "\n[Install mpdecimal]"
  cd "${_THIRD_PARTY_DIR}"
  rm -fr build-mpdecimal
  mkdir build-mpdecimal
  cd build-mpdecimal
  curl -OL https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.tar.gz
  tar xf ${_THIRD_PARTY_DIR}/build-mpdecimal/mpdecimal-2.5.1.tar.gz
  cd mpdecimal-2.5.1
  ./configure --prefix="${_FDW_DEPS_INSTALL_DIR}"
  make
  make install
  cd ../..
  rm -fr build-mpdecimal
fi

echo -e "\n[Install Takatori]"
cd "${_TAKATORI_DIR}"
rm -fr build
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=${TG_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO}" -DBUILD_TESTS=OFF -DBUILD_DOCUMENTS=OFF -DFORCE_INSTALL_RPATH=ON -DCMAKE_PREFIX_PATH="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_INSTALL_PREFIX="${_FDW_DEPS_INSTALL_DIR}" ${TG_COMMON_CMAKE_BUILD_OPTIONS} ..
cmake --build . --target install

echo -e "\n[Install Metadata Manager]"
cd "${_METADATA_MANAGER_DIR}"
rm -fr build
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=${TG_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO}" -DBUILD_TESTS=OFF -DFORCE_INSTALL_RPATH=ON -DCMAKE_PREFIX_PATH="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_INSTALL_PREFIX="${_FDW_DEPS_INSTALL_DIR}" -DDATA_STORAGE=postgresql ${TG_COMMON_CMAKE_BUILD_OPTIONS} ..
cmake --build . --target install

echo -e "\n[Install Message Manager]"
cd "${_MESSAGE_MANAGER_DIR}"
rm -fr build
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=${TG_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO}" -DBUILD_TESTS=OFF -DFORCE_INSTALL_RPATH=ON -DCMAKE_PREFIX_PATH="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_INSTALL_PREFIX="${_FDW_DEPS_INSTALL_DIR}" ${TG_COMMON_CMAKE_BUILD_OPTIONS} ..
cmake --build . --target install

echo -e "\n[Install Ogawayama Stub]"
cd ${_OGAWAYAMA_DIR}
rm -fr build
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=${TG_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO}" -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DSHARKSFIN_IMPLEMENTATION=shirakami -DFORCE_INSTALL_RPATH=ON -DCMAKE_PREFIX_PATH="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_INSTALL_PREFIX="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_MODULE_PATH="${_FDW_DEPS_INSTALL_DIR}" -DBUILD_STUB_ONLY=ON ${TG_COMMON_CMAKE_BUILD_OPTIONS} ..
cmake --build . --target install
