#!/bin/bash

_FDW_DEPS_INSTALL_DIR=$1/..

_SCRIPTS_DIR=$(cd "$(dirname $0)" && pwd)
_THIRD_PARTY_DIR=${_SCRIPTS_DIR}/../third_party

TG_CMAKE_BUILD_TYPE="RelWithDebInfo"
TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g"
TG_COMMON_CMAKE_BUILD_OPTIONS="-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"

_TSURUGI_FDW_DIR="${_SCRIPTS_DIR}/.."
_OGAWAYAMA_DIR="${_THIRD_PARTY_DIR}/ogawayama"
_METADATA_MANAGER_DIR="${_THIRD_PARTY_DIR}/metadata-manager"
_TAKATORI_DIR="${_THIRD_PARTY_DIR}/takatori"
_MESSAGE_MANAGER_DIR="${_THIRD_PARTY_DIR}/message-manager"

if ldconfig -p | grep -F --quiet libmpdec++; then
  echo -e "\n[SKIPPED Install_mpdecimal]"
else
  echo -e "\nThe dependency module (mpdecimal) for takatori is not installed."
  echo -e "Please follow the takatori README to install mpdecimal.\n"
  exit 1
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

PROJECT_URL=https://github.com/project-tsurugi
BUILD_TIMESTAMP=`TZ=JST-9 date +"%Y%m%d%H%M"`

BUILDINFO="BUILD_TIMESTAMP:${BUILD_TIMESTAMP}
###### tsurugi_fdw and dependent modules
- tsurugi_fdw $(git -C ${_TSURUGI_FDW_DIR} log --pretty="format:[%h - %s](${PROJECT_URL}/tsurugi_fdw/commit/%H)" -1 HEAD)
- metadata-manager $(git -C ${_METADATA_MANAGER_DIR} log --pretty="format:[%h - %s](${PROJECT_URL}/metadata-manager/commit/%H)" -1 HEAD)
- message-manager $(git -C ${_MESSAGE_MANAGER_DIR} log --pretty="format:[%h - %s](${PROJECT_URL}/message-manager/commit/%H)" -1 HEAD)
- ogawayama $(git -C ${_OGAWAYAMA_DIR} log --pretty="format:[%h - %s](${PROJECT_URL}/ogawayama/commit/%H)" -1 HEAD)
- takatori $(git -C ${_TAKATORI_DIR} log --pretty="format:[%h - %s](${PROJECT_URL}/takatori/commit/%H)" -1 HEAD)
"
echo "${BUILDINFO}" > "${_SCRIPTS_DIR}/FDW_BUILDINFO.md"
echo "------------------------------------"
cat "${_SCRIPTS_DIR}/FDW_BUILDINFO.md"
echo "------------------------------------"
