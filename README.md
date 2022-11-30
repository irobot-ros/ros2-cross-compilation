# ROS 2 cross-compilation framework

This is a Docker-based framework for cross-compiling ROS 2 packages for a variety of platforms.
The pros of this framework are its modularity, that allows to easily add support for new architectures, and the possibility of integrating it into CI jobs.

In the following sections you can find instructions for cross-compiling ROS 2 packages and running the cross-compiled executables on your target platform.

Instructions for adding new packages or dependencies or adding support for new architectures can be found in the [advanced section](advanced.md).

If you are interested in additional resources about cross-compilation, check the [**ROS 2 Cross-compilation official guide**](https://index.ros.org/doc/ros2/Tutorials/Cross-compilation) or the references at the bottom of this page.

A list of common cross-compilation issues and solutions is provided in the [troubleshooting page](troubleshooting.md).

## Support

**NOTE:** the following names are keywords! Write them exactly as they are here.

The supported ROS 2 distributions are:

 - `foxy`
 - `master`

The supported architectures are:

 - `raspbian` (Debian Stretch, tested on RaspberryPi 2 and RaspberryPi 3, **not** working on RaspberryPi 1)
 - `x86_64` (Ubuntu 18.04)


## Requirements

This tool requires a Linux-based OS.
It is tested only on Ubuntu 20.04, other distributions may or may not work.

 - Install Docker following official instructions https://docs.docker.com/desktop/install/linux-install/
 - Manage Docker as non-root user (log out and log back in after running the commands)
 ```
 sudo groupadd docker
 sudo usermod -aG docker $USER
 ```
 - Install qemu dependencies
 ```
 sudo apt-get update && sudo apt-get install qemu binfmt-support qemu-user-static
 docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --credential yes
 docker run --rm -t arm64v8/ubuntu uname -m
 ```
 - Install additional minor requirements
 ```
 sudo apt-get update && sudo apt-get install -y curl gnupg2 lsb-release software-properties-common
 sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
 echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
 sudo apt-get update && sudo apt-get install -y python3-vcstool wget
 ```

## Build the Framework

```
bash build.sh
```

This will build the cross-compilation framework.
It mainly consists of a bunch of `Dockerfile`s which provide a Docker environment with all the cross-compilation dependencies installed for each of the supported architectures.

## Cross-compile ROS 2 SDK

**NOTE:** there is an automated script for cross-compiling specific versions of the ROS 2 SDK.
For example you can run:

```
export TARGET=raspbian
export ROS2_DISTRO=foxy
bash automatic_cross_compile.sh
```

You can find the output in the directory `ROS2_SDKs/"$ROS2_BRANCH"_"$HEAD"_"$TARGET"`.

Let's go through an example showing how to manually cross-compile ROS 2 Foxy SDK for `raspbian` architecture.

Source the environment variables for this architecture using

```
source env.sh raspbian
```

Create a sysroot for the architecture.
This command will download a sysroot for the archicture specified by the `TARGET_ARCHITECTURE` environment variable (the argument passed to the `env.sh` script above, `raspbian` in this case).
Note that if you already have a sysroot with the same name inside the `sysroots` directory, it will be overwritten by the new one.

If you want to use your own sysroot, instead of generating a new one, you can skip the last instruction and just place your sysroot in the `sysroots` directory. Your sysroot directory must be renamed to `raspbian` or as the specified `TARGET_ARCHITECTURE` that you passed to `env.sh`.

```
bash get_sysroot.sh
```

Create a ROS 2 workspace that you want to cross-compile.
 - The cross-compilation script will mount the workspace as a Docker volume. This does not go well with symbolic links. For this reason ensure that the workspace contains the whole source code and not a symlink to the repositories.
 - It is recommended that the workspace contains the source code of all the ROS 2 dependencies of your packages. However, you can also cross-compile individual packages if you already have the cross-compiled dependencies, see the [advanced section](advanced.md).

We provide convenient scripts for downloading the ROS 2 sources for a specific distribution.
If you want to cross-compile generic ROS 2 packages, see the [advanced section](advanced.md).

```
bash get_ros2_sources.sh --distro=foxy --ros2-path=~/ros2_cc_ws
```

Cross-compile the workspace

```
bash cc_workspace.sh ~/ros2_cc_ws
```

The result of the cross-compilation will be found in `~/ros2_cc_ws/install`.

#### Debug options

If you are runing the compilation steps one by one, you can also add a debug flag to the last command:

```
bash cc_workspace.sh ~/ros2_cc_ws --debug
```

This will let you go inside the Docker container used for compilation rather than starting the compilation process.
Once you are inside you can start building using any of the following scripts, depending on your target architecture:

```
/root/compilation_scripts/compile.sh
/root/compilation_scripts/cross_compile.sh
```

Running in this debug mode also allows you to easily modify these scripts.
Common modifications are the following:
 - Comment the line at the beginning where it clears the build directory.
 - Add arguments to the colcon command, for example `--packages-select XX` to build only that package or `--packages-up-to XX` to build only that package and its dependencies.

## Use cross-compiled ROS 2 packages

Copy the `install` directory from the cross-compiled workspace to your target platform.

```
cd ~/ros2_cc_ws
tar -czf install.tar.gz install
scp install.tar.gz user@hostname:~/
```

If you only need to run individual executables and you don't need ROS 2 command line tools (or you don't have Python3 in your target platform), you can simply add the libraries of the cross-compiled workspace to the dynamic libraries path.

```
export LD_LIBRARY_PATH=~/install/lib

~/install/lib/examples_rclcpp_minimal_publisher/publisher_lambda
```

If you want access the ROS 2 command line tools, you will have to source the cross-compiled workspace.

```
export COLCON_CURRENT_PREFIX=~/install
source $COLCON_CURRENT_PREFIX/setup.sh

ros2 run examples_rclcpp_minimal_publisher publisher_lambda
```

## References

 - [ROS 2 cross-compilation official tools](https://github.com/ros2/cross_compile)
 - [ROS 2 step by step cross-compilation on ARM](https://github.com/ros2-for-arm/ros2/wiki/ROS2-on-arm-architecture)
 - [ROS 2 RaspberryPi cross-compilation](https://github.com/alsora/ros2-raspberrypi)
