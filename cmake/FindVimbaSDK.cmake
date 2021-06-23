################################################################################
# Helper function to log messages only if not running in quiet mode
################################################################################
function(_find_log lvl)
  if(VimbaSDK_FIND_QUIETLY)
    return()
  endif()
  message(${lvl} ${ARGN})
endfunction()

################################################################################
# This module doesn't support Windows
################################################################################
if(WIN32)
  _find_log(WARNING "This cmake module does not support Windows yet.")
  return()
endif()

################################################################################
# Check that some components were requested and are supported
################################################################################
set(VIMBA_SDK_COMPONENTS
  VimbaCPP
  VimbaC)
if(NOT VimbaSDK_FIND_COMPONENTS)
  _find_log(WARNING "No component request. Please specify at least one of: ${VIMBA_SDK_COMPONENTS}")
  return()
endif()

################################################################################
# Determine location of Vimba SDK.
################################################################################
if(NOT DEFINED VIMBA_DIR)
  if(DEFINED ENV{VIMBA_DIR})
    file(TO_CMAKE_PATH "$ENV{VIMBA_DIR}" VIMBA_DIR)
  else()
    # Default to an arbitrary, but likely installation path
    set(VIMBA_DIR "/opt/Vimba_4.2")
  endif()
endif()

if(NOT EXISTS "${VIMBA_DIR}")
  _find_log(WARNING "Vimba SDK installation not found: ${VIMBA_DIR}")
  return()
endif()

################################################################################
# Determine identifier of target build architecture.
################################################################################
include(VimbaSDKTargetArchitecture)
vimba_sdk_target_architecture(VIMBA_ARCH)
if("${VIMBA_ARCH}" STREQUAL i386)
  set(VIMBA_ARCH_DIR    x86_32bit)
elseif("${VIMBA_ARCH}" STREQUAL x86_64)
  set(VIMBA_ARCH_DIR    x86_64bit)
elseif("${VIMBA_ARCH}" STREQUAL armv7)
  set(VIMBA_ARCH_DIR    arm_32bit)
elseif("${VIMBA_ARCH}" STREQUAL armv8)
  set(VIMBA_ARCH_DIR    arm_64bit)
else()
  _find_log(STATUS "Unsupported architecture for Vimba SDK: ${VIMBA_ARCH}")
  return()
endif()

################################################################################
# Add components which are implicitly required by others
################################################################################
if(VimbaCPP IN_LIST VimbaSDK_FIND_COMPONENTS AND
   NOT VimbaC IN_LIST VimbaSDK_FIND_COMPONENTS)
  list(APPEND VimbaSDK_FIND_COMPONENTS VimbaC)
endif()

################################################################################
# Imported target for VimbaC API
################################################################################
if(VimbaC IN_LIST VimbaSDK_FIND_COMPONENTS)
  set(VIMBA_C_DIR         "${VIMBA_DIR}/VimbaC")
  set(VIMBA_C_LIB_DIR     "${VIMBA_C_DIR}/DynamicLib/${VIMBA_ARCH_DIR}")
  set(VIMBA_C_INCLUDES    "${VIMBA_C_DIR}/Include")
  set(VIMBA_C_DEFINES     )
  set(VIMBA_C_DEPENDS     )

  find_library(libVimbaC
    NAMES
      libVimbaC
    PATHS
      "${VIMBA_C_LIB_DIR}"
    NO_DEFAULT_PATH
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
  )

  if(libVimbaC-NOTFOUND)
    _find_log(STATUS "VimbaC not found in ${VIMBA_C_LIB_DIR}")
    return()
  endif()

  add_library(VimbaSDK::VimbaC SHARED IMPORTED)
  set_target_properties(VimbaSDK::VimbaC
    PROPERTIES
      IMPORTED_NO_SONAME TRUE
      IMPORTED_LOCATION "${libVimbaC}"
      INTERFACE_INCLUDE_DIRECTORIES
        "${VIMBA_C_INCLUDES}"
      INTERFACE_COMPILE_DEFINITIONS
        "${VIMBA_C_DEFINES}"
      INTERFACE_LINK_LIBRARIES
        "${VIMBA_C_DEPENDS}"
  )
endif()

################################################################################
# Imported target for VimbaCPP API
################################################################################
if(VimbaCPP IN_LIST VimbaSDK_FIND_COMPONENTS)
  set(VIMBA_CPP_DIR       "${VIMBA_DIR}/VimbaCPP")
  set(VIMBA_CPP_LIB_DIR   "${VIMBA_CPP_DIR}/DynamicLib/${VIMBA_ARCH_DIR}")
  set(VIMBA_CPP_INCLUDES  "${VIMBA_CPP_DIR}/Include")
  set(VIMBA_CPP_DEFINES   )
  set(VIMBA_CPP_DEPENDS   VimbaSDK::VimbaC)

  find_library(libVimbaCPP
    NAMES
      libVimbaCPP
    PATHS
      "${VIMBA_CPP_LIB_DIR}"
    NO_DEFAULT_PATH
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
  )

  if(libVimbaCPP-NOTFOUND)
    _find_log(STATUS "VimbaCPP not found in ${VIMBA_CPP_LIB_DIR}")
    return()
  endif()

  add_library(VimbaSDK::VimbaCPP SHARED IMPORTED)
  set_target_properties(VimbaSDK::VimbaCPP
    PROPERTIES
      IMPORTED_NO_SONAME TRUE
      IMPORTED_LOCATION "${libVimbaCPP}"
      INTERFACE_INCLUDE_DIRECTORIES
        "${VIMBA_CPP_INCLUDES}"
      INTERFACE_COMPILE_DEFINITIONS
        "${VIMBA_CPP_DEFINES}"
      INTERFACE_LINK_LIBRARIES
        "${VIMBA_CPP_DEPENDS}"
  )
endif()

################################################################################
# Check that all requested components have been imported and
# set output variable accordingly
################################################################################
set(VimbaSDK_MISSING_COMPONENTS)
foreach(component IN LISTS VimbaSDK_FIND_COMPONENTS)
  if(NOT "${component}" IN_LIST VIMBA_SDK_COMPONENTS)
    _find_log(WARNING "unsupported Vimba SDK component: ${component}")
    return()
  endif()
  if(NOT TARGET VimbaSDK::${component})
    list(APPEND VimbaSDK_MISSING_COMPONENTS ${component})
  endif()
endforeach()

if(NOT VimbaSDK_MISSING_COMPONENTS)
  set(VimbaSDK_FOUND TRUE)
endif()
