# AudioScience HPI SDK — prebuilt headers + import libraries.
# The SDK archive is a flat 7z with headers and .lib files at the root.

set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# The AudioScience web server rejects default User-Agent strings.
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.audioscience.com/internet/download/sdk/ASIHPK_42019.7z"
    FILENAME "ASIHPK_42019.7z"
    SKIP_SHA512
    HEADERS "User-Agent: Mozilla/5.0 (Windows NT 10.0\\; Win64\\; x64) AppleWebKit/537.36 (KHTML\\, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)

# Extract the 7z archive
vcpkg_find_acquire_program(7Z)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src")
file(REMOVE_RECURSE "${SOURCE_PATH}")
file(MAKE_DIRECTORY "${SOURCE_PATH}")
vcpkg_execute_required_process(
    COMMAND "${7Z}" e "${ARCHIVE}" "-o${SOURCE_PATH}" -y
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME extract
)

# Install headers — nest under include/asihpi/ for #include <asihpi/hpi.h>
set(_headers hpi.h hpidebug.h hpirds.h hpiconfig.h hpi_adapters.h hpi_version.h)
foreach(_h IN LISTS _headers)
    file(INSTALL "${SOURCE_PATH}/${_h}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/asihpi")
endforeach()

# Install import libraries — pick the correct bitness
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    file(INSTALL "${SOURCE_PATH}/asihpi64.lib"    DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/asihpiudp64.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
    file(INSTALL "${SOURCE_PATH}/asihpi32.lib"    DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/asihpiudp32.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

# Link libraries are referenced by the CMake config (no auto-link via #pragma).
# Provide a minimal config for find_package(asihpi).
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(_asihpi_main "asihpi64")
    set(_asihpi_udp  "asihpiudp64")
else()
    set(_asihpi_main "asihpi32")
    set(_asihpi_udp  "asihpiudp32")
endif()
configure_file("${CMAKE_CURRENT_LIST_DIR}/asihpiConfig.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/asihpiConfig.cmake" @ONLY)

# License
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright"
"Proprietary — AudioScience Inc.
See https://www.audioscience.com/internet/download/sdk/SDKLicense.rtf
")
