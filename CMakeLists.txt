cmake_minimum_required(VERSION 3.16)
project(StockfishSP CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

find_package(SDL2 REQUIRED CONFIG)

add_compile_options(-Wall -Wextra)
if(CMAKE_CROSSCOMPILING)
  # Avoid depending on the device's libstdc++/libgcc versions; libc and SDL2
  # stay dynamic and come from the device.
  add_link_options(-static-libstdc++ -static-libgcc)
endif()

add_executable(hello src/hello/main.cpp)
target_link_libraries(hello PRIVATE SDL2::SDL2)

install(TARGETS hello RUNTIME DESTINATION .)
