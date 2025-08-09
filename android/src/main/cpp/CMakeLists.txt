cmake_minimum_required(VERSION 3.10.2)
project("biometrics")

set(OPENSSL_LIB_DIR "${CMAKE_SOURCE_DIR}/../libs")
set(OPENSSL_INCLUDE_DIR "${OPENSSL_LIB_DIR}/include")

include_directories(${OPENSSL_INCLUDE_DIR})
include_directories("../../../../shared/crypto")

add_library(crypto STATIC IMPORTED)
set_target_properties(crypto PROPERTIES IMPORTED_LOCATION "${OPENSSL_LIB_DIR}/${ANDROID_ABI}/libcrypto.a")

add_library(ssl STATIC IMPORTED)
set_target_properties(ssl PROPERTIES IMPORTED_LOCATION "${OPENSSL_LIB_DIR}/${ANDROID_ABI}/libssl.a")

add_library(
    cryptohelper
    SHARED
    native-lib.cpp
    ../../../../shared/crypto/CryptoHelper.cpp
)

find_library(
    log-lib
    log
)

target_link_libraries(
    cryptohelper
    crypto
    ssl
    ${log-lib}
)

target_include_directories(cryptohelper PRIVATE "${CMAKE_SOURCE_DIR}/libs/include")
