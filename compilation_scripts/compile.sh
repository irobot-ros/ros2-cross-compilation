#!/bin/bash

## script for compiling the current workspace

source /root/.bashrc

# clear out everything first
rm -rf build install log

ROS2_SETUP=/root/sysroot/setup.bash
if [ -f "$ROS2_SETUP" ]; then
    source $ROS2_SETUP
fi

COLCON_CMD="colcon \
                build \
                --merge-install \
                --cmake-force-configure \
                --cmake-args \
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
