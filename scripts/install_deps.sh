#!/bin/bash

_FDW_DEPS_INSTALL_DIR=$1/..

_SCRIPTS_DIR=$(cd "$(dirname $0)" && pwd)
_THIRD_PARTY_DIR=${_SCRIPTS_DIR}/../third_party

TG_CMAKE_BUILD_TYPE="RelWithDebInfo"
TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g"

_TSURUGI_FDW_DIR="${_SCRIPTS_DIR}/.."
_OGAWAYAMA_DIR="${_THIRD_PARTY_DIR}/ogawayama"
_METADATA_MANAGER_DIR="${_THIRD_PARTY_DIR}/metadata-manager"
_TAKATORI_DIR="${_THIRD_PARTY_DIR}/takatori"
_MESSAGE_MANAGER_DIR="${_THIRD_PARTY_DIR}/message-manager"

if ldconfig -p | grep -F --quiet libmpdec++; then
  echo -e "\n[SKIPPED Install_mpdecimal]"
else
  echo -e "\n[Install_mpdecimal]"
  if [ ! -f "${_SCRIPTS_DIR}/mpdecimal-2.5.1.tar.gz" ]; then
    cd ${_SCRIPTS_DIR}
    curl --retry 3 --retry-all-errors -OL https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.tar.gz
    cd $OLDPWD
  fi
  rm -fr build-mpdecimal
  mkdir build-mpdecimal
  cd build-mpdecimal
  tar xf ${_SCRIPTS_DIR}/mpdecimal-2.5.1.tar.gz
  cd mpdecimal-2.5.1
  ./configure --prefix="${_FDW_DEPS_INSTALL_DIR}"
  make -j4
  make install
  cd ../..
  rm -fr build-mpdecimal
fi

echo -e "\n[Install Takatori]"
cd "${_TAKATORI_DIR}"
rm -fr build
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=${TG_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO}" -DBUILD_TESTS=OFF -DBUILD_DOCUMENTS=OFF -DCMAKE_PREFIX_PATH="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_INSTALL_PREFIX="${_FDW_DEPS_INSTALL_DIR}" ..
cmake --build . --target install

echo -e "\n[Install Metadata Manager]"
cd "${_METADATA_MANAGER_DIR}"
rm -fr build
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=${TG_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO}" -DBUILD_TESTS=OFF -DCMAKE_PREFIX_PATH="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_INSTALL_PREFIX="${_FDW_DEPS_INSTALL_DIR}" -DDATA_STORAGE=postgresql ..
cmake --build . --target install

echo -e "\n[Install Message Manager]"
cd "${_MESSAGE_MANAGER_DIR}"
rm -fr build
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=${TG_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO}" -DBUILD_TESTS=OFF -DCMAKE_PREFIX_PATH="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_INSTALL_PREFIX="${_FDW_DEPS_INSTALL_DIR}" ..
cmake --build . --target install

echo -e "\n[Install Ogawayama Stub]"
cd ${_OGAWAYAMA_DIR}
rm -fr build
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=${TG_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${TG_CMAKE_CXX_FLAGS_RELWITHDEBINFO}" -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DSHARKSFIN_IMPLEMENTATION=shirakami -DCMAKE_PREFIX_PATH="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_INSTALL_PREFIX="${_FDW_DEPS_INSTALL_DIR}" -DCMAKE_MODULE_PATH="${_FDW_DEPS_INSTALL_DIR}" -DBUILD_STUB_ONLY=ON ..
cmake --build . --target install

echo -e "\n[Generate header file for protobuf]"
_PROTO_HOME="${_OGAWAYAMA_DIR}/src"
_PROTO_SRCDIR="jogasaki/proto/sql"
_PROTO_SRCS="common.proto error.proto response.proto"
_GENERATED_HOME="${_TSURUGI_FDW_DIR}/include/proto"
cd ${_TSURUGI_FDW_DIR}
mkdir -p ${_GENERATED_HOME}
for proto_file in ${_PROTO_SRCS}; do
  protoc --proto_path=${_PROTO_HOME} --cpp_out=${_GENERATED_HOME} ${_PROTO_HOME}/${_PROTO_SRCDIR}/${proto_file}
done
find ${_GENERATED_HOME} -type f -name "*.pb.cc" -delete

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
