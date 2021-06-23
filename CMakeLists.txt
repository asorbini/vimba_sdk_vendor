cmake_minimum_required(VERSION 3.5)
project(vimba_sdk_vendor VERSION "4.2.0")

set(VIMBA_CMAKE_DIR     "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

if(NOT "${VIMBA_CMAKE_DIR}" IN_LIST CMAKE_MODULE_PATH)
  list(APPEND CMAKE_MODULE_PATH "${VIMBA_CMAKE_DIR}")
endif()

# Try to load the VimbaCPP library.
find_package(VimbaSDK COMPONENTS VimbaCPP)

if(NOT VimbaSDK_FOUND)
  message(WARNING "Failed to load Vimba SDK")
endif()

install(FILES
    "${VIMBA_CMAKE_DIR}/FindVimbaSDK.cmake"
    "${VIMBA_CMAKE_DIR}/VimbaSDKTargetArchitecture.cmake"
  DESTINATION
    "share/${PROJECT_NAME}/cmake")

configure_file("vimba_sdk_vendorConfig.cmake.in"
  "${PROJECT_BINARY_DIR}/vimba_sdk_vendorConfig.cmake" @ONLY)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${PROJECT_BINARY_DIR}/vimba_sdk_vendorConfig-version.cmake"
  COMPATIBILITY AnyNewerVersion)

install(FILES
    package.xml
  DESTINATION
    "share/${PROJECT_NAME}")

install(FILES
    "${PROJECT_BINARY_DIR}/vimba_sdk_vendorConfig.cmake"
    "${PROJECT_BINARY_DIR}/vimba_sdk_vendorConfig-version.cmake"
  DESTINATION
    "share/${PROJECT_NAME}/cmake")
