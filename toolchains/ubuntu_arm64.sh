export TARGET_ARCH=aarch64

export CROSS_COMPILER_C="aarch64-linux-gnu-gcc"
export CROSS_COMPILER_CXX="aarch64-linux-gnu-g++"

export SYSROOT="/root/sysroot"
export CMAKE_LIBRARY_PATH="${SYSROOT}/lib/aarch64-linux-gnu"
export PYTHON_LIBRARY="${SYSROOT}/usr/lib/aarch64-linux-gnu/libpython3.10.so"
export PYTHON_INCLUDE_DIR="${SYSROOT}/usr/include/python3.10"
export PYTHON_SOABI="cpython-310-aarch64-linux-gnu"

CC_FLAGS="-O3"

export TARGET_C_FLAGS=${CC_FLAGS}
export TARGET_CXX_FLAGS=${CC_FLAGS}
