#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Illegal number of parameters. Required to specify distribution and path."
    exit 1
fi

DISTRIBUTION="$1"
WORKSPACE_DIR_PATH="$2"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

DISTRIBUTION_SPECIFIC_SCRIPT="$THIS_DIR/ubuntu_arm64/$DISTRIBUTION/get_sources.sh"
if [ -f $DISTRIBUTION_SPECIFIC_SCRIPT ]; then
    # Run architecture specific, distribution specific script
    bash $DISTRIBUTION_SPECIFIC_SCRIPT $WORKSPACE_DIR_PATH
else
    cd $WORKSPACE_DIR_PATH

    # Download sources
    wget https://raw.githubusercontent.com/ros2/ros2/$DISTRIBUTION/ros2.repos
    vcs import src < ros2.repos
fi

# Ignore some packages
cd $WORKSPACE_DIR_PATH
touch \
    src/eclipse-cyclonedds/cyclonedds/COLCON_IGNORE \
    src/eclipse-iceoryx/iceoryx/COLCON_IGNORE \
    src/ros/kdl_parser/COLCON_IGNORE \
    src/ros/resource_retriever/COLCON_IGNORE \
    src/ros/robot_state_publisher/COLCON_IGNORE \
    src/ros/ros_tutorials/COLCON_IGNORE \
    src/ros-visualization/COLCON_IGNORE \
    src/ros2/common_interfaces/actionlib_msgs/COLCON_IGNORE \
    src/ros2/common_interfaces/diagnostic_msgs/COLCON_IGNORE \
    src/ros2/common_interfaces/shape_msgs/COLCON_IGNORE \
    src/ros2/common_interfaces/std_srvs/COLCON_IGNORE \
    src/ros2/common_interfaces/stereo_msgs/COLCON_IGNORE \
    src/ros2/common_interfaces/trajectory_msgs/COLCON_IGNORE \
    src/ros2/common_interfaces/visualization_msgs/COLCON_IGNORE \
    src/ros2/demos/COLCON_IGNORE \
    src/ros2/geometry2/examples_tf2_py/COLCON_IGNORE \
    src/ros2/geometry2/test_tf2/COLCON_IGNORE \
    src/ros2/geometry2/tf2_bullet/COLCON_IGNORE \
    src/ros2/geometry2/tf2_eigen/COLCON_IGNORE \
    src/ros2/geometry2/tf2_eigen_kdl/COLCON_IGNORE \
    src/ros2/geometry2/tf2_kdl/COLCON_IGNORE \
    src/ros2/geometry2/tf2_geometry_msgs/COLCON_IGNORE \
    src/ros2/geometry2/tf2_sensor_msgs/COLCON_IGNORE \
    src/ros2/geometry2/tf2_tools/COLCON_IGNORE \
    src/ros2/orocos_kdl_vendor/COLCON_IGNORE
    src/ros2/rcl_interfaces/test_msgs/COLCON_IGNORE \
    src/ros2/rcl_logging/rcl_logging_log4cxx/COLCON_IGNORE \
    src/ros2/rcl/rcl/test/COLCON_IGNORE \
    src/ros2/rosbag2/COLCON_IGNORE \
    src/ros2/ros1_bridge/COLCON_IGNORE \
    src/ros2/rviz/COLCON_IGNORE \

touch \
    src/ros2/geometry2/tf2_py/COLCON_IGNORE \
    src/ros2/rclpy/COLCON_IGNORE
