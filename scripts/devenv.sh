#!/bin/bash

# This script sets up a development environment for this project.

set -eo pipefail

# Grobal variable
{
  TSURUGI_HOME=$HOME/project-tsurugi
  INSTALL_PREFIX=$HOME/.local
  SCRIPT_PATH=$(cd $(dirname $0); pwd)

  #BUILD_TYPE=Release
  BUILD_TYPE=RelWithDebInfo
  BINARY_DIR=build

  SHARKSFIN_IMPLEMENTATION=memory
}

package_install() {
  echo -e "\nInstall the required packages for project."

  sudo apt update -y
  sudo apt install -y $(cat $SCRIPT_PATH/ubuntu.deps)

  sudo apt autoremove -y
}

get_source_file() {
  local parent_dir=$(pwd)
  local module="$1"

  if [[ -z $module ]]; then
    get_source_file 'manager'
    get_source_file 'shakujo'
    get_source_file 'shirakami'
    get_source_file 'sharksfin' third_party/googletest
    get_source_file 'takatori' --recursive
    get_source_file 'yugawara' --recursive
    get_source_file 'mizugaki' --recursive
    get_source_file 'sandbox-performance-tools'
    get_source_file 'jogasaki' --recursive
    get_source_file 'ogawayama'
    return
  fi
  shift

  echo -e "\nGet the $module component from GitHub."
  
  if [[ -d $TSURUGI_HOME/$module ]]; then
    # Get (pull) the component from GitHub.
    cd $TSURUGI_HOME/$module
    git pull
  else
    # Get (clone) the component from GitHub.
    git clone git@github.com:project-tsurugi/$module.git $TSURUGI_HOME/$module
    cd $TSURUGI_HOME/$module
  fi

  # Update the submodule from GitHub.
  git submodule update --init $*

  cd $parent_dir
}

build() {
  local parent_dir=$(pwd)
  local build_path=$TSURUGI_HOME/$1/$BINARY_DIR

  echo -e "\nBuild the $(basename $1) component."

  mkdir -p $build_path
  cd $build_path

  cmake -G Ninja $* ..

  ninja | tee .ninja_tee
  if [[ $(cat .ninja_tee) != 'ninja: no work to do.' ]]; then
    ninja install
  fi
  rm -rf .ninja_tee > /dev/null 2>&1

  cd $parent_dir
}

build_module() {
  local parent_dir=$(pwd)
  local module="$1"

  if [[ -z $module ]]; then
    build_module 'manager'
    build_module 'shakujo'
    build_module 'shirakami'
    build_module 'sharksfin'
    build_module 'takatori'
    build_module 'yugawara'
    build_module 'mizugaki'
    build_module 'sandbox-performance-tools'
    build_module 'jogasaki'
    build_module 'ogawayama'
    return
  fi

  case "$module" in
  # tsurugi::manager
  'manager')
    # Build the manager.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::shakujo
  'shakujo')
    # Build the shakujo.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF
    ;;

  # tsurugi::shirakami
  'shirakami')
    # Build the shirakami.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=ON \
      -DBUILD_DOCUMENTS=OFF
#      -DBUILD_TESTS=OFF \
    ;;

  # tsurugi::sharksfin
  'sharksfin')
    # Build the sharksfin.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_SHIRAKAMI=OFF
    ;;

  # tsurugi::takatori
  'takatori')
    # fpdecimal (Sub module for takatori)
    build_module 'takatori/third_party/fpdecimal'

    # Build the takatori.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::decimal
  'takatori/third_party/fpdecimal')
    # Build the decimal.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::yugawara
  'yugawara')
    # hopscotch-map (Sub modules for yugawara)
    build_module 'yugawara/third_party/hopscotch-map'

    # Build the yugawara.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # Tessil::hopscotch-map
  'yugawara/third_party/hopscotch-map')
    # Build the hopscotch-map.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::mizugaki
  'mizugaki')
    # bison (Sub modules for mizugaki)
    build_module 'bison'

    # Build the mizugaki.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF
    ;;

  # tsurugi::sandbox-performance-tools
  'sandbox-performance-tools')
    # Build the sandbox-performance-tools.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF
    ;;

  # tsurugi::jogasaki
  'jogasaki')
    # moodycamel::ConcurrentQueue (Sub module for jogasaki)
    build_module 'jogasaki/third_party/concurrentqueue'

    # tateyama (Sub modules for jogasaki)
    build_module 'jogasaki/third_party/tateyama'

    # Build the jogasaki.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION
    ;;

  # moodycamel::ConcurrentQueue
  'jogasaki/third_party/concurrentqueue')
    # Build the concurrentqueue.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
    ;;

  # tsurugi::tateyama
  'jogasaki/third_party/tateyama')
    # Build the tateyama.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENT=OFF  \
      -DBUILD_EXAMPLES=OFF \
      -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION
    ;;

  # tsurugi::ogawayama
  'ogawayama')
    # Build the ogawayama.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DCMAKE_MODULE_PATH=$INSTALL_PREFIX \
      -DCMAKE_PREFIX_PATH=$TSURUGI_HOME/tateyama/build \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION
    ;;

  # GNU Bison
  'bison')
    if [[ ! -d $TSURUGI_HOME/bison-3.5.1 ]]; then
      cd $TSURUGI_HOME
      curl http://ftp.jaist.ac.jp/pub/GNU/bison/bison-3.5.1.tar.gz | tar zxv

      cd bison-3.5.1
      ./configure --prefix=$INSTALL_PREFIX
      make -j4
      make install
    fi
    ;;
  esac

  cd $parent_dir
}

usage_exit() {
  echo -e "Usage:\n  $0 [options]\n" 1>&2
  echo  "Options:" 1>&2
  echo "  -f, --force    Forces the build to run." 1>&2
  echo "  -c, --clean    Clean the project directory." 1>&2
  echo "  -h, --help     Displays help." 1>&2
  echo 1>&2
  exit $1
}

script_main() {
  echo -e "\nBuild script started.\n"

  mkdir -p $TSURUGI_HOME
  cd $TSURUGI_HOME

  # Install the required packages.
  package_install

  # Get the source file.
  get_source_file

  # Build the components.
  build_module

  echo -e "\nBuild script finished."
}

script_main
