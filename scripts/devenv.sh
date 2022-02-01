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

# Install the required packages for project.
package_install() {
  [[ $OPT_CLEAN == 1 ]] && return

  echo -e "\nInstall the required packages for project."

  sudo apt update -y
  sudo apt install -y $(cat $SCRIPT_PATH/ubuntu.deps)

  sudo apt autoremove -y
}

# Get (clone/pull) the component from GitHub.
get_module() {
  local module="$1"
  shift

  if [[ $OPT_CLEAN == 1 ]]; then
    echo -e "[$module] Cleaned."
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
get_submodule() {
  if [[ ! -d third_party ]]; then
    return
  fi

  local modules
  modules+=($(cd third_party; ls -d */))

  local module
  local pids
  for module in ${modules[@]}; do
    module=$(echo $module | sed -e "s/\/$//")
    echo -e "\nGet the $module subcomponent from GitHub."
    (git submodule update --init third_party/$module) &
    pids+=($!)
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
  echo -e "\nBuild the $(basename $1) component."
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
}

# Controller to build the component.
build_module() {
  [[ $OPT_CLEAN == 1 ]] && return

  local parent_dir=$(pwd)
  local module="$1"

  if [[ -d "$module" ]]; then
    cd $module
    # Get submodules.
    get_submodule
  fi

  case "$module" in
  # tsurugi::ogawayama
  'ogawayama')
    # Building submodules.
    (
      cd third_party
      build_module 'manager'
      build_module 'jogasaki'
    )

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

  # tsurugi::jogasaki
  'jogasaki')
    # Building submodules.
    (
      cd third_party
      build_module 'concurrentqueue'
      build_module 'mizugaki'
      build_module 'performance-tools'
      build_module 'sharksfin'
      build_module 'tateyama'
    )

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
  'concurrentqueue')
    # Build the concurrentqueue.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
    ;;

  # tsurugi::mizugaki
  'mizugaki')
    # Building submodules.
    (
      cd third_party
      build_module 'bison'
      build_module 'shakujo'
      build_module 'yugawara'
    )

    # Build the mizugaki.
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

  # tsurugi::yugawara
  'yugawara')
    # Building submodules.
    (
      cd third_party
      build_module 'hopscotch-map'
      build_module 'takatori'
    )

    # Build the yugawara.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # Tessil::hopscotch-map
  'hopscotch-map')
    # Build the hopscotch-map.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::takatori
  'takatori')
    # Building submodules.
    (
      cd third_party
      build_module 'fpdecimal'
    )

    # Build the takatori.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::decimal
  'fpdecimal')
    # Build the decimal.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::sandbox-performance-tools
  'performance-tools')
    # Build the sandbox-performance-tools.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENTS=OFF \
      -DBUILD_EXAMPLES=OFF
    ;;

  # tsurugi::sharksfin
  'sharksfin')
    # Building submodules.
    (
      cd third_party
      build_module 'shirakami'
    )

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

  # tsurugi::shirakami
  'shirakami')
    # Build the shirakami.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DFORCE_INSTALL_RPATH=ON \
      -DBUILD_TESTS=ON \
      -DBUILD_DOCUMENTS=OFF
    ;;

  # tsurugi::tateyama
  'tateyama')
    # Build the tateyama.
    build $module \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DBUILD_TESTS=OFF \
      -DBUILD_DOCUMENT=OFF  \
      -DBUILD_EXAMPLES=OFF \
      -DSHARKSFIN_IMPLEMENTATION=$SHARKSFIN_IMPLEMENTATION
    ;;
  esac

  cd $parent_dir
}

# Display the usage instructions.
usage_exit() {
  echo -e "Usage:\n  $0 [options]\n" 1>&2
  echo  "Options:" 1>&2
  echo "  -f, --force    Forces the build to run." 1>&2
  echo "  -c, --clean    Clean the project directory." 1>&2
  echo "  -h, --help     Displays help." 1>&2
  echo 1>&2
  exit $1
}

# Check the options.
option_check() {
  while getopts fch-: opt; do
    if [[ $opt == "-" ]]; then
      opt=$(echo ${OPTARG})
    fi

    case "$opt" in
    f | force)
      OPT_FORCE=1
      ;;
    c | crean)
      OPT_CLEAN=1
      ;;
    h | help)
      usage_exit 0
      ;;
    *)
      usage_exit 1
      ;;
    esac
  done  
}

# Main processing of the script.
script_main() {
  echo -e "\nBuild script started.\n"

  mkdir -p $TSURUGI_HOME
  cd $TSURUGI_HOME

  # Install the required packages.
  package_install

  # Get the source file.
  get_module 'ogawayama'

  # Build the components.
  build_module 'ogawayama'

  echo -e "\nBuild script finished."
}

option_check $*
script_main
