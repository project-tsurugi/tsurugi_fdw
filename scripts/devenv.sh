#!/bin/bash

# This script sets up a development environment for this project.

set -eo pipefail

# Grobal variable
{
  TSURUGI_HOME=$HOME/project-tsurugi
  INSTALL_PREFIX=$HOME/.local
  ALREADY_BUILD_MODULES=$TSURUGI_HOME/.build_modules
  SCRIPT_PATH=$(cd $(dirname $0); pwd)

  #BUILD_TYPE=Release
  BUILD_TYPE=RelWithDebInfo
  BINARY_DIR=build

  SHARKSFIN_IMPLEMENTATION=memory
}

# Install the required packages for project.
package_install() {
  [[ $OPT_CLEAN == 1 ]] && return

  echo -e "\nInstall the required packages for project."

  sudo apt update -y
  sudo apt install -y $(cat $SCRIPT_PATH/ubuntu.deps)

  sudo apt autoremove -y
}

# Get (clone/pull) the component from GitHub.
get_module_source() {
  local module="$1"
  shift

  if [[ $OPT_CLEAN == 1 ]]; then
    echo "[$module] Cleaned."
    rm -rf  $TSURUGI_HOME/$module
    return
  fi

  echo -e "\nGet the $module component from GitHub."
  (
    if [[ $OPT_FORCE == 1 ]]; then
      rm -rf  $TSURUGI_HOME/$module
    fi

    if [[ -d $TSURUGI_HOME/$module ]]; then
      # Get (pull) the component from GitHub.
      cd $TSURUGI_HOME/$module
      git pull
    else
      # Get (clone) the component from GitHub.
      git clone git@github.com:project-tsurugi/$module.git $TSURUGI_HOME/$module
      cd $TSURUGI_HOME/$module
    fi
  )
}

# Update the submodule from GitHub.
get_submodule_source() {
  if [[ ! -d third_party ]]; then
    return
  fi

  local modules
  modules+=($(cd third_party; ls -d */))

  local module
  local pids

  pods=()
  for module in ${modules[@]}; do
    module=$(echo $module | sed -e "s/\/$//")
    echo "Get the $module subcomponent from GitHub."
    (git submodule update --init third_party/$module) &
    pids+=($!)
    sleep 0.5
  done

  for pid in ${pids[@]}; do
    wait $pid
    if [ $? -ne 0 ]; then
      exit 1
    fi
  done
}

# Build the component.
build() {
  local module="$1"

  echo -e "\nBuild the $(basename $module) component."
  (
    local install=0

    if [[ ! -d $BINARY_DIR ]]; then
      install=1
      mkdir -p $BINARY_DIR
    fi
    cd $BINARY_DIR

    cmake -G Ninja $* ..

    ninja | tee .ninja_tee
    if [[ ($install == 1) || ($(cat .ninja_tee) != 'ninja: no work to do.') ]]; then
      ninja install
    fi
    rm -rf .ninja_tee > /dev/null 2>&1
  )
  touch $ALREADY_BUILD_MODULES/$module
}

# Controller to build the component.
build_module() {
  [[ $OPT_CLEAN == 1 ]] && return

  local parent_dir=$(pwd)
  local module="$1"

  echo -e "\nStart the build process of the $module component."

  if [[ -f "$ALREADY_BUILD_MODULES/$module" ]]; then
    echo " --> Already built."
    return
  fi

  if [[ -d "$module" ]]; then
    cd $module
    # Get submodules.
    get_submodule_source

    # Building submodules.
    if [[ -d 'third_party' ]]; then
      (
        cd third_party

        local submodules
        submodules+=($(ls -d */ | sed -e "s/\/$//"))

        local submodule
        for submodule in ${submodules[@]}; do
          build_module "$submodule"
        done
      )
    fi
  fi

  case "$module" in
  # tsurugi::ogawayama
  'ogawayama')
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

  # tsurugi::manager
  'manager')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::jogasaki
  'jogasaki')
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
  'concurrentqueue')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
    ;;

  # tsurugi::mizugaki
  'mizugaki')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF
    ;;

  # GNU Bison
  'bison')
    if [[ (! -d $TSURUGI_HOME/bison-3.5.1) || $OPT_FORCE == 1 ]]; then
      cd $TSURUGI_HOME
      curl http://ftp.jaist.ac.jp/pub/GNU/bison/bison-3.5.1.tar.gz | tar zxv

      cd bison-3.5.1
      ./configure --prefix=$INSTALL_PREFIX
      make -j4
      make install
    fi
    ;;

  # Tessil::hopscotch-map
  'hopscotch-map')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::shakujo
  'shakujo')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF
    ;;

  # tsurugi::yugawara
  'yugawara')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::takatori
  'takatori')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::decimal
  'fpdecimal')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::sandbox-performance-tools
  'performance-tools' | 'sandbox-performance-tools')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF
    ;;

  # tsurugi::sharksfin
  'sharksfin')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_SHIRAKAMI=OFF
    ;;

  # tsurugi::shirakami
  'shirakami')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=ON \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::tateyama
  'tateyama')
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENT=OFF  \
      -DBUILD_EXAMPLES=OFF \
      -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION
    ;;
  *)
    echo " --> Not build."
    ;;
  esac

  cd $parent_dir
}

# Display the usage instructions.
usage_exit() {
  local format='  %-24s  %s\n'

  echo -e "Usage:\n  $0 [options]\n" 1>&2
  echo  "Options:" 1>&2
  printf "$format" '-c, --clean' 'Clean the project directory.' 1>&2
  printf "$format" '-f, --force' 'Forces the build to run.' 1>&2
  printf "$format" '-t, --target <component>' 'Build the specified component.' 1>&2
  printf "$format" '-h, --help' 'Displays help.' 1>&2
  echo 1>&2
  exit $1
}

# Check the options.
option_check() {
  set +e

  local options
  options=$(getopt -o cft:h -l clean,force,target:,help -- "$@")
  [[ $? == 0 ]] || usage_exit 1

  eval set -- "$options"
  while [[ "$1" != "--" ]]; do
    case "$1" in
    '-c' | '--clean')
      OPT_CLEAN=1
      ;;
    '-f' | '--force')
      OPT_FORCE=1
      ;;
    '-t' | '--target')
      shift
      BUILD_MODULE="$1"
      ;;
    '-h' | '--help')
      usage_exit 0
      ;;
    *)
      usage_exit 1
      ;;
    esac
    shift
  done

  set -e
}

# Main processing of the script.
script_main() {
  echo "Build script started."

  mkdir -p $TSURUGI_HOME

  rm -rf $ALREADY_BUILD_MODULES
  mkdir -p $ALREADY_BUILD_MODULES

  cd $TSURUGI_HOME

  # Install the required packages.
  package_install

  # Get the source file.
  get_module_source $BUILD_MODULE

  # Build the components.
  build_module $BUILD_MODULE

  rm -rf $ALREADY_BUILD_MODULES

  echo -e "\nBuild script finished."
}

BUILD_MODULE='ogawayama'
option_check $*

script_main
