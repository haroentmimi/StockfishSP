# Cross toolchain for the RG35XXSP (Allwinner H700, Cortex-A53, aarch64).
# SYSROOT holds link-time SDL2 (headers + libSDL2-2.0.so); at runtime the
# device's own libSDL2 is used.
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER   aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

set(SFSP_SYSROOT "${CMAKE_CURRENT_LIST_DIR}/../sysroot/aarch64" CACHE PATH "SDL2 link sysroot")
list(APPEND CMAKE_PREFIX_PATH "${SFSP_SYSROOT}")
list(APPEND CMAKE_FIND_ROOT_PATH "${SFSP_SYSROOT}" /usr/aarch64-linux-gnu)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_C_FLAGS_INIT   "-mcpu=cortex-a53")
set(CMAKE_CXX_FLAGS_INIT "-mcpu=cortex-a53")
