#!/bin/bash

## script for cross-compiling the current workspace
## accepts as argument the path to the toolchain file to be used
## if no argument is provided, it looks for a default toolchain in the current directory.

source /root/.bashrc

if [ -z "$1" ]; then
    TOOLCHAIN_PATH=`pwd`/toolchainfile.cmake
    echo "Using toolchain ${TOOLCHAIN_PATH}"
else
    TOOLCHAIN_PATH=$1
fi

# this is needed to avoid https://stackoverflow.com/questions/72978485
git config --global --add safe.directory '*'

# clear out everything first
#rm -rf build install log

ROS2_SETUP=/root/sysroot/setup.bash
if [ -f "$ROS2_SETUP" ]; then
    source $ROS2_SETUP
fi

ARCH_SPECIFIC_TOOLCHAIN=/root/cc_export.sh
if [ -f "$ARCH_SPECIFIC_TOOLCHAIN" ]; then
    source $ARCH_SPECIFIC_TOOLCHAIN
fi

# Note: maybe these should be set from the toolchain CMake file, but it didn't work
PYTHON_LIBRARY_ARG=""
if [ ! -z ${PYTHON_LIBRARY} ]; then
    PYTHON_LIBRARY_ARG="-DPYTHON_LIBRARY=${PYTHON_LIBRARY}"
    echo "Using python library ${PYTHON_LIBRARY_ARG}"
fi
PYTHON_INCLUDE_DIR_ARG=""
if [ ! -z ${PYTHON_INCLUDE_DIR} ]; then
    PYTHON_INCLUDE_DIR_ARG="-DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}"
    echo "Using python include ${PYTHON_INCLUDE_DIR_ARG}"
fi

COLCON_CMD="colcon \
                build \
                --merge-install \
                --cmake-force-configure \
                --cmake-args \
                ${PYTHON_LIBRARY_ARG} ${PYTHON_INCLUDE_DIR_ARG} \
                -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_PATH \
                -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
                -DTHIRDPARTY=ON \
                -DBUILD_TESTING:BOOL=OFF"

# --merge-install is used to avoid creation of nested install dirs for each package

# Create exit code
EXIT_CODE=0

if ! $COLCON_CMD; then
  echo "Error: colcon command failed"
  EXIT_CODE=1
fi


# Set Read+Write+Execute permissions to workspace, to avoid
# having to be sudo to tar or remove the cross-compiled workspace
chmod -R a+rwx $(ls -I src)

# Exit
exit $EXIT_CODE
