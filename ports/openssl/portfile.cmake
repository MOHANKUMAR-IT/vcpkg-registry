vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openssl/openssl
    REF "openssl-${VERSION}"
    SHA512 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    HEAD_REF master
    PATCHES
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path("${NASM_EXE_PATH}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(OPENSSL_SHARED shared)
else()
    set(OPENSSL_SHARED no-shared)
endif()

set(CONFIGURE_OPTIONS
    ${OPENSSL_SHARED}
    no-ssl3
    no-weak-ssl-ciphers
    no-tests
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(OPENSSL_ARCH VC-WIN64A)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(OPENSSL_ARCH VC-WIN32)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(OPENSSL_ARCH VC-WIN64-ARM)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(OPENSSL_ARCH VC-WIN32-ARM)
    endif()
else()
    set(OPENSSL_ARCH linux-generic64)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_ADDITIONAL_PATHS
    DETERMINE_BUILD_TRIPLET
    BUILD_TRIPLET "${OPENSSL_ARCH}"
    OPTIONS
        ${CONFIGURE_OPTIONS}
        --prefix=${CURRENT_PACKAGES_DIR}
        --openssldir=${CURRENT_PACKAGES_DIR}/etc/ssl
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/etc"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
