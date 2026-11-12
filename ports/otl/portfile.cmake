# Overlay port for otl — adds get_shell() to the ODBC otl_stream class.
# Based on vcpkg upstream port (4.0.509) with a single patch.

set(OTL_VERSION 40509)

vcpkg_download_distfile(ARCHIVE
    URLS "https://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}.zip"
    SHA512 235536b9f49fb05016bf118c610fd1f078bde961a69ba56f6d746c30ec2ee1753c1d0d72948fd73c7aa5a38ec8e605c133544789ccdee0d678751bb62872d3c2
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
    PATCHES
        add-odbc-get-shell.patch
)

file(INSTALL "${SOURCE_PATH}/otlv${OTL_VERSION}.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}"
    RENAME otlv4.h)

file(READ "${SOURCE_PATH}/otlv${OTL_VERSION}.h" copyright_contents)
string(FIND "${copyright_contents}" "#ifndef OTL_H" start_of_source)
if(start_of_source EQUAL "-1")
    message(FATAL_ERROR "Could not find start of source; the header file has changed in a way that we cannot get the license text.")
endif()
string(SUBSTRING "${copyright_contents}" 0 "${start_of_source}" copyright_contents)
string(REGEX REPLACE "// ?" "" copyright_contents "${copyright_contents}")
string(REGEX REPLACE "=+\n" "" copyright_contents "${copyright_contents}")

file(WRITE
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright"
    "${copyright_contents}"
)
