cmake_minimum_required(VERSION 3.20)

set(CMAKE_CXX_FLAGS "-Wall -pedantic -Wextra -Wshadow-compatible-local -Werror")
set(CMAKE_C_FLAGS ${CMAKE_CXX_FLAGS})
set(CMAKE_CXX_STANDARD 23)

project(demo)

add_executable(demo demo.cpp)

