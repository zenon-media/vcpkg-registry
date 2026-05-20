# dtoa-milo is a single-header library from miloyip/dtoa-benchmark.

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO miloyip/dtoa-benchmark
    REF bf1fb58ade01658c908a498679e47f0b4e89aff7
    SHA512 184e59d1a449cf96dae1dfcba3cb88fc83c3cb3ba016b7b422ad27f457294ba15196e66b0724e91441eff68937faa9d634ea8724eb3d7195039753f1f543b21a
    HEAD_REF master
    PATCHES patches/001-msvc-compat.patch
)

file(INSTALL "${SOURCE_PATH}/src/milo/dtoa_milo.h"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include/dtoa-milo")

# CMake config so consumers can find_package(dtoa-milo)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/dtoa-miloConfig.cmake"
[=[
add_library(dtoa-milo::dtoa-milo INTERFACE IMPORTED)
target_include_directories(dtoa-milo::dtoa-milo INTERFACE "${CMAKE_CURRENT_LIST_DIR}/../../include")
]=])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")

# Install license
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright"
"MIT License

Copyright (c) 2014 Milo Yip

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
")

# CMake config so consumers can find_package(dtoa-milo)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/dtoa-miloConfig.cmake"
[=[
add_library(dtoa-milo::dtoa-milo INTERFACE IMPORTED)
target_include_directories(dtoa-milo::dtoa-milo INTERFACE "${CMAKE_CURRENT_LIST_DIR}/../../include")
]=])
