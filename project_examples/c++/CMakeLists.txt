set(CMAKE_CXX_FLAGS "-Wall -pedantic -Wextra -Wshadow-compatible-local -Werror")
set(CMAKE_C_FLAGS ${CMAKE_CXX_FLAGS})

project(demo)

add_executable(demo demo.cpp)

