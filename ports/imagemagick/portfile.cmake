# ImageMagick vcpkg port
# Uses autotools on all platforms (including Windows via MSYS2).
# On Windows/MSVC: cl_wrapper.sh translates GCC-style flags to MSVC for libtool.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ImageMagick/ImageMagick
    REF 7.1.2-35
    SHA512 caba66e1e1265b280245d5bedf641570876bc7f2c7bbe9113981fd6c4eb677acca4ef6719c0ff9fe3b315e1621f526276ad912bfc9c56353d29c65c9261836ac
    HEAD_REF main
    PATCHES
        patches/0001-fix-zstd-pkgconfig-prefix.patch
        patches/0002-fix-fallthrough-msvc-c-mode.patch
        patches/0003-fix-cppflags-crt-conflict.patch
        patches/0005-fix-warning-directive-msvc.patch
        patches/0006-fix-winpathscript-init-order.patch
)

# ── Feature → configure flag mapping ──────────────────────────────────────────
macro(_im_feature_flag _feature _flag)
    if("${_feature}" IN_LIST FEATURES)
        list(APPEND _configure_args "--with-${_flag}=yes")
    else()
        list(APPEND _configure_args "--with-${_flag}=no")
    endif()
endmacro()

set(_configure_args "")

# HDRI and quantum depth
if("hdri" IN_LIST FEATURES)
    list(APPEND _configure_args "--enable-hdri=yes")
    set(_im_hdri ON)
    set(_im_hdri_val 1)
else()
    list(APPEND _configure_args "--enable-hdri=no")
    set(_im_hdri OFF)
    set(_im_hdri_val 0)
endif()

# Quantum depth — mutually exclusive (q8, q16, q32)
set(_im_q_count 0)
foreach(_q q8 q16 q32)
    if("${_q}" IN_LIST FEATURES)
        math(EXPR _im_q_count "${_im_q_count} + 1")
    endif()
endforeach()
if(_im_q_count GREATER 1)
    message(FATAL_ERROR "Features q8, q16 and q32 are mutually exclusive — select at most one.")
endif()

if("q32" IN_LIST FEATURES)
    set(_im_qdepth 32)
elseif("q8" IN_LIST FEATURES)
    set(_im_qdepth 8)
else()
    set(_im_qdepth 16)
endif()
list(APPEND _configure_args "--with-quantum-depth=${_im_qdepth}")

# Build the lib suffix: e.g. Q16HDRI, Q8, Q32HDRI
set(_im_qsuffix "Q${_im_qdepth}")
if(_im_hdri)
    string(APPEND _im_qsuffix "HDRI")
endif()

# Shared/static
message(STATUS "imagemagick library linkage: ${VCPKG_LIBRARY_LINKAGE}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND _configure_args "--enable-shared=yes" "--enable-static=no")
else()
    list(APPEND _configure_args "--enable-shared=no" "--enable-static=yes")
endif()

# Delegate libraries
list(APPEND _configure_args "--with-zlib=yes")  # always on (base dependency)
_im_feature_flag(bzip2      bzlib)
_im_feature_flag(lzma       lzma)
_im_feature_flag(zstd       zstd)
_im_feature_flag(png        png)
_im_feature_flag(jpeg       jpeg)
_im_feature_flag(tiff       tiff)
_im_feature_flag(webp       webp)
_im_feature_flag(freetype   freetype)
_im_feature_flag(xml2       xml)
_im_feature_flag(lcms       lcms)
_im_feature_flag(openexr    openexr)
_im_feature_flag(heif       heic)
_im_feature_flag(openjp2    openjp2)
_im_feature_flag(jxl        jxl)
_im_feature_flag(raw        raw)
_im_feature_flag(uhdr       uhdr)
_im_feature_flag(fontconfig fontconfig)
_im_feature_flag(fftw       fftw)
_im_feature_flag(pango      pango)
_im_feature_flag(zip        zip)
_im_feature_flag(jbig       jbig)
_im_feature_flag(raqm       raqm)
_im_feature_flag(rsvg       rsvg)
_im_feature_flag(gvc        gvc)

# X11 — only meaningful on Unix
if("x11" IN_LIST FEATURES)
    list(APPEND _configure_args "--with-x=yes")
else()
    list(APPEND _configure_args "--without-x")
endif()

# OpenMP — available on MSVC and GCC; Clang (all platforms) lacks it by default
if("openmp" IN_LIST FEATURES)
    list(APPEND _configure_args "--enable-openmp=yes")
else()
    list(APPEND _configure_args "--enable-openmp=no")
endif()

# Zero-configuration: embed config in binary, no external XML files needed
if("zero-configuration" IN_LIST FEATURES)
    list(APPEND _configure_args "--enable-zero-configuration")
else()
    list(APPEND _configure_args "--disable-zero-configuration")
endif()

# Always-disabled delegates (no vcpkg port exists)
list(APPEND _configure_args
    "--without-perl"
    "--with-magick-plus-plus=yes"
    "--with-modules=no"
    "--disable-docs"
    "--disable-installed"
    "--with-utilities=no"
    "--without-djvu"
    "--without-lqr"
    "--without-wmf"
    "--without-autotrace"
    "--without-flif"
    "--without-fpx"
    "--without-dps"
    "--without-gslib"
    "--without-dmr"
)

# Windows-specific libtool workaround: skip file_magic format checks
# (MSVC .lib are MS-COFF, not ELF/PE)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND _configure_args "lt_cv_deplibs_check_method=pass_all")
endif()

# ── MSVC/clang-cl-specific setup ──────────────────────────────────────────────
if(VCPKG_TARGET_IS_WINDOWS)
    # Install cl/lib wrapper scripts for libtool MSVC mode
    set(_wrapper_dir "${CURRENT_BUILDTREES_DIR}/cl_wrappers")
    file(REMOVE_RECURSE "${_wrapper_dir}")
    file(MAKE_DIRECTORY "${_wrapper_dir}")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/cl_wrapper.sh" DESTINATION "${_wrapper_dir}")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/lib_wrapper.sh" DESTINATION "${_wrapper_dir}")
    file(RENAME "${_wrapper_dir}/cl_wrapper.sh" "${_wrapper_dir}/cl")
    file(RENAME "${_wrapper_dir}/lib_wrapper.sh" "${_wrapper_dir}/lib")

    # Make wrappers executable (needed by MSYS2 bash)
    execute_process(COMMAND chmod +x "${_wrapper_dir}/cl" "${_wrapper_dir}/lib"
                    ERROR_QUIET)

    # Convert Windows paths to MSYS2 /drive/... format for configure
    string(REGEX REPLACE "^([A-Za-z]):" "/\\1" _msys_wrapper_dir "${_wrapper_dir}")
    string(REPLACE "\\" "/" _msys_wrapper_dir "${_msys_wrapper_dir}")

    list(APPEND _configure_args
        "CC=${_msys_wrapper_dir}/cl"
        "CXX=${_msys_wrapper_dir}/cl"
    )

    # Detect compiler: clang-cl vs MSVC cl.exe
    if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "clang-cl")
        set(_real_cc "clang-cl.exe")
        set(_real_lib "llvm-lib.exe")
    else()
        set(_real_cc "cl.exe")
        set(_real_lib "lib.exe")
    endif()

    # CXXCPP needs -nologo to suppress banner that confuses configure sanity check
    list(APPEND _configure_args "CXXCPP=${_real_cc} -nologo -E")

    set(ENV{CXXFLAGS} "$ENV{CXXFLAGS} -EHsc")

    # Tell wrappers where to find the real compiler/archiver
    set(ENV{REAL_CC} "${_real_cc}")
    set(ENV{REAL_LIB} "${_real_lib}")

    # Pre-seed configure cache to avoid failing AC_CHECK_LIB tests
    if("bzip2" IN_LIST FEATURES)
        list(APPEND _configure_args "ac_cv_lib_bz2_BZ2_bzDecompress=yes")
    endif()
    if("jpeg" IN_LIST FEATURES)
        list(APPEND _configure_args "ac_cv_lib_jpeg_jpeg_read_header=yes")
    endif()

    # Tell configure the compiler understands -c -o together.
    # Our cl_wrapper.sh translates -o → -Fo/-Fe, so config/compile is not needed.
    # This prevents automake from inserting config/compile into the build chain,
    # which has incomplete library resolution (misses lib-prefixed .lib, debug
    # suffixes, and versioned names).  All -l/-L flags now go through cl_wrapper.sh.
    list(APPEND _configure_args "am_cv_prog_cc_c_o=yes")

    # Windows system libraries (cl wrapper translates -lfoo → foo.lib)
    set(ENV{LDFLAGS} "$ENV{LDFLAGS} -ladvapi32 -lgdi32 -luser32 -lole32 -loleaut32")
endif()

# ── Autotools configure + build ──────────────────────────────────────────────
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${_configure_args}
)

# Post-configure fixup: patch config/compile for MSVC library name resolution.
# Must be applied AFTER vcpkg_configure_make (which runs autoreconf and regenerates config/compile)
# but BEFORE vcpkg_build_make.  The automake compile script's func_cl_dashl() misses:
#   - lib-prefixed .lib files  (e.g. libde265.lib  for -lde265)
#   - debug-suffixed .lib files (e.g. bz2d.lib     for -lbz2)
#   - versioned .lib files      (e.g. openjph.0.27d.lib for -lopenjph)
# NOTE: This is now bypassed by am_cv_prog_cc_c_o=yes which prevents config/compile
#       from being inserted.  Kept as fallback in case the approach is reverted.
if(FALSE AND VCPKG_TARGET_IS_WINDOWS)
    set(_compile_script "${SOURCE_PATH}/config/compile")
    if(EXISTS "${_compile_script}")
        file(READ "${_compile_script}" _compile_content)
        # Inject additional candidates after the "$lib.lib" block, before "lib$lib.a"
        string(REPLACE
[[    if test -f "$dir/lib$lib.a"; then]]
[[    if test -f "$dir/lib$lib.lib"; then
      found=yes
      lib=$dir/lib$lib.lib
      break
    fi
    # Debug-suffix candidates (e.g. bz2d.lib for -lbz2, raw_rd.lib for -lraw_r)
    if test -f "$dir/${lib}d.lib"; then
      found=yes
      lib=$dir/${lib}d.lib
      break
    fi
    if test -f "$dir/lib${lib}d.lib"; then
      found=yes
      lib=$dir/lib${lib}d.lib
      break
    fi
    # Versioned candidates (e.g. openjph.0.27d.lib for -lopenjph).
    # Only accept when exactly one file matches the glob.
    set -- "$dir/$lib".*.lib
    if test $# -eq 1 && test -f "$1"; then
      found=yes
      lib=$1
      break
    fi
    set -- "$dir/lib$lib".*.lib
    if test $# -eq 1 && test -f "$1"; then
      found=yes
      lib=$1
      break
    fi
    if test -f "$dir/lib$lib.a"; then]]
            _compile_content "${_compile_content}"
        )
        file(WRITE "${_compile_script}" "${_compile_content}")
    endif()
endif()

# Post-configure Makefile fixups (Windows only)
if(VCPKG_TARGET_IS_WINDOWS)
    foreach(_buildtype IN ITEMS "rel" "dbg")
        if(_buildtype STREQUAL "rel")
            set(_makefile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Makefile")
        else()
            set(_makefile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Makefile")
        endif()

        if(EXISTS "${_makefile}")
            file(READ "${_makefile}" _mk_content)

            # 1. Compile coders/emf.c as C++ (needs <gdiplus.h> with namespaces)
            string(APPEND _mk_content
                "\n# Per-file C++ mode for emf.c (needs <gdiplus.h>)\n"
                "coders/MagickCore_libMagickCore_7_${_im_qsuffix}_la-emf.lo: CFLAGS += -TP\n"
                "coders/emf_la-emf.lo: CFLAGS += -TP\n"
            )

            # 2. Inject _DLL/_LIB, _MT, and ssize_t defines
            # Note: _DLL is intentionally NOT defined here — it conflicts with
            # static CRT (-MT). ImageMagick uses _MAGICKLIB_ for dllexport
            # (already set by configure). _DLL would make CRT headers expect
            # the dynamic CRT import library.
            set(_extra_cppflags "-D_MT -Dssize_t=ptrdiff_t")
            if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
                string(APPEND _extra_cppflags " -D_LIB")
            endif()
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                string(APPEND _extra_cppflags " -DWIN64")
            endif()
            string(REPLACE "\nCPPFLAGS = " "\nCPPFLAGS = ${_extra_cppflags} " _mk_content "${_mk_content}")

            file(WRITE "${_makefile}" "${_mk_content}")
        endif()
    endforeach()
endif()

vcpkg_build_make()
vcpkg_install_make()
if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB _pkgconfig_files
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc"
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc"
    )
    foreach(_pkgconfig_file IN LISTS _pkgconfig_files)
        file(READ "${_pkgconfig_file}" _pkgconfig_content)
        string(REPLACE "Cflags: " "Cflags: -Dssize_t=ptrdiff_t " _pkgconfig_content "${_pkgconfig_content}")
        file(WRITE "${_pkgconfig_file}" "${_pkgconfig_content}")
    endforeach()
endif()
vcpkg_fixup_pkgconfig()

# The *-config shell scripts contain absolute build paths (harmless, they are
# developer helper tools for autotools consumers, not used by vcpkg consumers)
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Remove .la files
file(GLOB _la_files "${CURRENT_PACKAGES_DIR}/lib/*.la" "${CURRENT_PACKAGES_DIR}/debug/lib/*.la")
if(_la_files)
    file(REMOVE ${_la_files})
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# ── Install CMake config (imagemagick) ────────────────────────────────────────
# Always use Unix-style pkg-config output (-I, -D, -L, -l) — the CMake config
# template parses these uniformly and CMake handles MSVC flag translation.
x_vcpkg_pkgconfig_get_modules(PREFIX MAGICK_MagickCore MODULES MagickCore LIBS INCLUDE_DIRS CFLAGS)
x_vcpkg_pkgconfig_get_modules(PREFIX MAGICK_MagickWand MODULES MagickWand LIBS INCLUDE_DIRS CFLAGS)
x_vcpkg_pkgconfig_get_modules(PREFIX MAGICK_Magick++ MODULES Magick++ LIBS INCLUDE_DIRS CFLAGS)

# Helper: find the full path of the link library (.lib/.a/.so/.dylib), given a path list and its name
function(find_link_library OUT_VAR PATHS NAME)
    # find_library() stores its result in a CACHE variable, so reusing the same cache name across calls makes every subsequent
    # call return the first first hit.
    # Use a unique cache name per (NAME, PATHS) tuple and clear it before the call so each invocation actually performs a search.
    string(MD5 _key "${NAME}|${PATHS}")
    set(_cache_var "_find_link_library_${_key}")
    unset(${_cache_var} CACHE)
    find_library(${_cache_var}
                 NAMES ${NAME}
                 PATHS ${PATHS}
                 NO_DEFAULT_PATH
    )
    set(_found "${${_cache_var}}")
    unset(${_cache_var} CACHE)
    if(_found)
        set(${OUT_VAR} "${_found}" PARENT_SCOPE)
    else()
        set(${OUT_VAR} "${NAME}" PARENT_SCOPE)
    endif()
endfunction()

# Helper: find the full path of the runtime library (.dll/.so/.dylib), given a path list and its name
function(find_runtime_library OUT_VAR PATHS NAME)
    get_filename_component(NAME "${NAME}" NAME_WLE)
    foreach(_path IN LISTS PATHS)
        set(_candidates)
        if(VCPKG_TARGET_IS_WIN32)
            file(GLOB _candidates
                 LIST_DIRECTORIES FALSE
                 "${_path}/${NAME}.dll"
                 "${_path}/${NAME}*.dll"
            )
        elseif(VCPKG_TARGET_IS_APPLE)
            file(GLOB _candidates
                 LIST_DIRECTORIES FALSE
                 "${_path}/lib${NAME}.dylib"
                 "${_path}/${NAME}.dylib"
                 "${_path}/lib${NAME}*.dylib"
                 "${_path}/${NAME}*.dylib"
            )
        else()
            file(GLOB _candidates
                 LIST_DIRECTORIES FALSE
                 "${_path}/lib${NAME}.so"
                 "${_path}/${NAME}.so"
                 "${_path}/lib${NAME}.so*"
                 "${_path}/${NAME}.so*"
                 "${_path}/lib${NAME}*.so"
                 "${_path}/${NAME}*.so"
                 "${_path}/lib${NAME}*.so*"
                 "${_path}/${NAME}*.so*"
            )
        endif()
        foreach(_candidate IN LISTS _candidates)
            if(EXISTS "${_candidate}")
                set(${OUT_VAR} "${_candidate}" PARENT_SCOPE)
                return()
            endif()
        endforeach()
    endforeach()
    set(${OUT_VAR} "" PARENT_SCOPE)
endfunction()

# Helper: set variables for cmake_configure() for a single primary library
# The -l entry matching _libname is the primary lib (→ IMPLIB + LOCATION)
# Other -l entries that resolve in the install tree are assumed covered by the dependency chain (set up after the targets are created)
# Unresolved -l entries (system libs like -lm) go into INTERFACE_LINK_LIBRARIES
# Variables set:
#  - _<target>_TARGET_NAME             : the target name, including namespace (e.g. ImageMagick::MagickCore)
#  - _<target>_INCLUDE_DIRS            : list of paths to include dirs, from pkg-config -I flags
#  - _<target>_DEBUG_IMLIB             : path to the debug link library of the target
#  - _<target>_RELEASE_IMLIB           : path to the release link library of the target
#  - _<target>_DEBUG_LOCATION          : path to the debug runtime library of the target (when dynamic linking)
#  - _<target>_RELEASE_LOCATION        : path to the release runtime library of the target (when dynamic linking)
#  - _<target>_COMPILE_OPTIONS_DEBUG   : list of compile options from pkg-config CFLAGS for debug
#  - _<target>_COMPILE_OPTIONS_RELEASE : list of compile options from pkg-config CFLAGS for release
#  - _<target>_DEFINES_DEBUG           : list of preprocessor definitions from pkg-config CFLAGS for debug
#  - _<target>_DEFINES_RELEASE         : list of preprocessor definitions from pkg-config CFLAGS for release
#  - _<target>_LINK_OPTIONS_DEBUG      : list of link options (e.g. OpenMP flags) from pkg-config LIBS for debug
#  - _<target>_LINK_OPTIONS_RELEASE    : list of link options (e.g. OpenMP flags) from pkg-config LIBS for release
#  - _<target>_SYSTEM_LIBS_DEBUG       : list of unresolved -l flags (system libs like -lm)
#  - _<target>_SYSTEM_LIBS_RELEASE     : list of unresolved -l flags (system libs like -lm) - should be identicylal to debug, but separated for clarity
function(_im_setup_target _target _libname)
    set(_${_libname}_TARGET_NAME "${_target}" PARENT_SCOPE)
message("Configuring target ${_target} with:")
message("-debug CFlags  : ${MAGICK_${_libname}_CFLAGS_DEBUG}")
message("-release CFlags: ${MAGICK_${_libname}_CFLAGS_RELEASE}")
message("-includes: ${MAGICK_${_libname}_INCLUDE_DIRS_RELEASE}")
message("-debug libs  : ${MAGICK_${_libname}_LIBS_DEBUG}")
message("-release libs: ${MAGICK_${_libname}_LIBS_RELEASE}")
    # 1. parse include dirs — always Unix-style (-I) from pkg-config
    set(_INCLUDE_DIRS "")
    separate_arguments(_inc_flags UNIX_COMMAND "${MAGICK_${_libname}_INCLUDE_DIRS_RELEASE}")
    foreach(_flag IN LISTS _inc_flags)
        if(_flag MATCHES "^-I")
            string(SUBSTRING "${_flag}" 2 -1 _path)
            cmake_path(NORMAL_PATH _path)
            list(APPEND _INCLUDE_DIRS "${_path}")
        endif()
    endforeach()
    set(_${_libname}_INCLUDE_DIRS "${_INCLUDE_DIRS}" PARENT_SCOPE)

    # 2. parse CFlags → defines + compile options (skip -I, already in include dirs)
    set(_DEFINES_DEBUG "")
    set(_DEFINES_RELEASE "")
    set(_COMPILE_OPTIONS_DEBUG "")
    set(_COMPILE_OPTIONS_RELEASE "")
    foreach(_mode DEBUG RELEASE)
        separate_arguments(_cflag_list UNIX_COMMAND "${MAGICK_${_libname}_CFLAGS_${_mode}}")
        foreach(_flag IN LISTS _cflag_list)
            if(_flag MATCHES "^-D")
                string(SUBSTRING "${_flag}" 2 -1 _def)
                # Filter out MSVC pkg-config noise that must not be propagated to consumers:
                # `_DLL` / `_MT` switch the MSVC standard headers (math.h, stdio.h, ...) into dllimport mode,
                # which breaks any consumer compiled with the static CRT (/MT) by producing unresolved
                # `__imp_lroundf`, `__imp__wmkdir`, `__imp__CrtDbgReport`, etc.
                # The CRT linkage must come from the consumer's own /MD or /MT flag, not from a transitively
                # propagated define.
                if(_def STREQUAL "_DLL" OR _def STREQUAL "_MT")
                    continue()
                endif()
                list(APPEND _DEFINES_${_mode} "${_def}")
            elseif(_flag MATCHES "^-I")
                # skip — handled via INCLUDE_DIRS
            else()
                list(APPEND _COMPILE_OPTIONS_${_mode} "${_flag}")
            endif()
        endforeach()
    endforeach()
    set(_${_libname}_DEFINES_DEBUG "${_DEFINES_DEBUG}" PARENT_SCOPE)
    set(_${_libname}_DEFINES_RELEASE "${_DEFINES_RELEASE}" PARENT_SCOPE)
    set(_${_libname}_COMPILE_OPTIONS_DEBUG "${_COMPILE_OPTIONS_DEBUG}" PARENT_SCOPE)
    set(_${_libname}_COMPILE_OPTIONS_RELEASE "${_COMPILE_OPTIONS_RELEASE}" PARENT_SCOPE)

    # 3. parse LIBS → primary lib (single file) + system libs + link options
    set(_primary_IMPLIB_DEBUG "")
    set(_primary_IMPLIB_RELEASE "")
    set(_primary_LOCATION_DEBUG "")
    set(_primary_LOCATION_RELEASE "")
    set(_SYSTEM_LIBS_DEBUG "")
    set(_SYSTEM_LIBS_RELEASE "")
    set(_LINK_OPTIONS_DEBUG "")
    set(_LINK_OPTIONS_RELEASE "")
    foreach(_mode DEBUG RELEASE)
        set(_LIB_PATHS "")
        set(_DLL_PATHS "")
        separate_arguments(_lib_flags UNIX_COMMAND "${MAGICK_${_libname}_LIBS_${_mode}}")
        foreach(_flag IN LISTS _lib_flags)
            if(_flag MATCHES "^-L")
                string(SUBSTRING "${_flag}" 2 -1 _path)
                cmake_path(NORMAL_PATH _path)
                list(APPEND _LIB_PATHS "${_path}")
                list(APPEND _DLL_PATHS "${_path}")
                cmake_path(SET _binpath "${_path}/../bin")
                cmake_path(NORMAL_PATH _binpath)
                list(APPEND _DLL_PATHS "${_binpath}")
            elseif(_flag MATCHES "^-l")
                string(SUBSTRING "${_flag}" 2 -1 _name)
                # Match primary lib by _libname (e.g. "MagickCore" matches "MagickCore-7.Q16HDRI")
                string(FIND "${_name}" "${_libname}" _match_pos)
                if(NOT _primary_IMPLIB_${_mode} AND NOT _match_pos EQUAL -1)
                    find_link_library(_implib "${_LIB_PATHS}" "${_name}")
                    set(_primary_IMPLIB_${_mode} "${_implib}")
                    find_runtime_library(_dll "${_DLL_PATHS}" "${_name}")
                    set(_primary_LOCATION_${_mode} "${_dll}")
                else()
                    # Extra lib: if NOT found in install tree → system lib
                    find_link_library(_lib "${_LIB_PATHS}" "${_name}")
                    if(NOT EXISTS "${_lib}")
                        list(APPEND _SYSTEM_LIBS_${_mode} "${_name}")
                    else()
                    endif()
                endif()
            elseif(_flag MATCHES "^-")
                list(APPEND _LINK_OPTIONS_${_mode} "${_flag}")
            endif()
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES _SYSTEM_LIBS_DEBUG)
    list(REMOVE_DUPLICATES _SYSTEM_LIBS_RELEASE)
    set(_${_libname}_DEBUG_IMPLIB "${_primary_IMPLIB_DEBUG}" PARENT_SCOPE)
    set(_${_libname}_RELEASE_IMPLIB "${_primary_IMPLIB_RELEASE}" PARENT_SCOPE)
    set(_${_libname}_DEBUG_LOCATION "${_primary_LOCATION_DEBUG}" PARENT_SCOPE)
    set(_${_libname}_RELEASE_LOCATION "${_primary_LOCATION_RELEASE}" PARENT_SCOPE)
    set(_${_libname}_LINK_OPTIONS_DEBUG "${_LINK_OPTIONS_DEBUG}" PARENT_SCOPE)
    set(_${_libname}_LINK_OPTIONS_RELEASE "${_LINK_OPTIONS_RELEASE}" PARENT_SCOPE)
    set(_${_libname}_SYSTEM_LIBS_DEBUG "${_SYSTEM_LIBS_DEBUG}" PARENT_SCOPE)
    set(_${_libname}_SYSTEM_LIBS_RELEASE "${_SYSTEM_LIBS_RELEASE}" PARENT_SCOPE)
endfunction()

# Generate CMake config targets for MagickCore, MagickWand and Magick++
_im_setup_target(ImageMagick::MagickCore "MagickCore")
_im_setup_target(ImageMagick::MagickWand "MagickWand")
_im_setup_target(ImageMagick::Magick++   "Magick++")
configure_file("${CMAKE_CURRENT_LIST_DIR}/imagemagickConfig.cmake.in"
               "${CURRENT_PACKAGES_DIR}/share/imagemagick/imagemagickConfig.cmake"
               @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/imagemagickConfig.cmake.in"
               "${CURRENT_PACKAGES_DIR}/debug/share/imagemagick/imagemagickConfig.cmake"
               @ONLY)
vcpkg_cmake_config_fixup()

# ── Install config files (policy.xml, delegates.xml, etc.) ────────────────────
if("zero-configuration" IN_LIST FEATURES)
    # Zero-configuration mode: config is embedded in the binary, remove external files
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
    file(GLOB _im_lib_dirs "${CURRENT_PACKAGES_DIR}/lib/ImageMagick-*")
    if(_im_lib_dirs)
        file(REMOVE_RECURSE ${_im_lib_dirs})
    endif()
    file(GLOB _im_lib_dirs_dbg "${CURRENT_PACKAGES_DIR}/debug/lib/ImageMagick-*")
    if(_im_lib_dirs_dbg)
        file(REMOVE_RECURSE ${_im_lib_dirs_dbg})
    endif()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/usage-zero-config.in"
                   "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
                   @ONLY)
else()
    # Standard mode: XML config files needed at runtime for initialization.
    # Collect from etc/ and lib/ImageMagick-*/config-* into share/imagemagick/config
    set(_config_dest "${CURRENT_PACKAGES_DIR}/share/${PORT}/config")
    file(MAKE_DIRECTORY "${_config_dest}")

    # Autotools installs policy, type maps, etc. to etc/ImageMagick-7/
    file(GLOB _etc_configs "${CURRENT_PACKAGES_DIR}/etc/ImageMagick-7/*.xml")
    if(_etc_configs)
        file(COPY ${_etc_configs} DESTINATION "${_config_dest}")
    endif()

    # Built-in config (configure.xml with compile-time paths) is in lib/ImageMagick-<ver>/config-Q16[HDRI]/
    file(GLOB_RECURSE _lib_configs "${CURRENT_PACKAGES_DIR}/lib/ImageMagick-*/config*/*.xml")
    if(_lib_configs)
        file(COPY ${_lib_configs} DESTINATION "${_config_dest}")
    endif()

    # Clean up original locations (consumers should use share/imagemagick/config)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
    file(GLOB _im_lib_dirs "${CURRENT_PACKAGES_DIR}/lib/ImageMagick-*")
    if(_im_lib_dirs)
        file(REMOVE_RECURSE ${_im_lib_dirs})
    endif()
    file(GLOB _im_lib_dirs_dbg "${CURRENT_PACKAGES_DIR}/debug/lib/ImageMagick-*")
    if(_im_lib_dirs_dbg)
        file(REMOVE_RECURSE ${_im_lib_dirs_dbg})
    endif()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/usage.in"
                   "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
                   @ONLY)
endif()
