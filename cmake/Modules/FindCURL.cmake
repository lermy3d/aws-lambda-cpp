# FindCURL.cmake - Custom find module for CURL on Windows (x64, DLL version)

if(DEFINED ENV{CURL_PATH})
    set(CURL_ENV $ENV{CURL_PATH})
    message(STATUS "CURL_PATH is set to: ${CURL_ENV}")
else()
    message(FATAL_ERROR "CURL_PATH environment variable has not been defined.")
endif()

# Check if CURL_INCLUDE_DIR and CURL_LIBRARY are set
if(NOT CURL_INCLUDE_DIRS)
    set(CURL_INCLUDE_DIRS "${CURL_ENV}/install/include")
endif()

if(NOT CURL_LIBRARIES)
    # Check if the platform is Windows
    if(WIN32)
        # On Windows, use the .dll library
        set(CURL_LIBRARIES "${CURL_ENV}/install/bin/libcurl.dll")
    elseif(UNIX)
        # On UNIX (Linux/macOS), use the .so library
        set(CURL_LIBRARIES "${CURL_ENV}/install/lib/libcurl.so")
    else()
        # Handle other platforms
        message(WARNING "Unsupported platform for CURL linking.")
    endif()
endif()

# Check if the import library (for linking to the DLL) exists
if(NOT CURL_IMPORT_LIB)
	if(WIN32)
		set(CURL_IMPORT_LIB "${CURL_ENV}/install/lib/libcurl_imp.lib")
	elseif(UNIX)
        # On UNIX (Linux/macOS), use the .so library
        set(CURL_IMPORT_LIB "${CURL_ENV}/install/lib/libcurl.a")
    else()
        # Handle other platforms
        message(WARNING "Unsupported platform for CURL linking.")
    endif()
endif()

# Check that the CURL headers and library paths are valid
if (NOT EXISTS ${CURL_INCLUDE_DIRS}/curl/curl.h)
    message(FATAL_ERROR "CURL header files not found at ${CURL_INCLUDE_DIRS}")
endif()

if (NOT EXISTS ${CURL_IMPORT_LIB})
    message(FATAL_ERROR "CURL import library not found at ${CURL_IMPORT_LIB}")
endif()

# Set the CURL version (optional)
set(CURL_VERSION "8.11.1") # Change this to match your installed version

# Provide the found configuration to CMake
set(CURL_FOUND TRUE)
set(CURL_INCLUDE_DIRS ${CURL_INCLUDE_DIRS} CACHE STRING "CURL include directory")
set(CURL_LIBRARIES ${CURL_LIBRARIES} CACHE STRING "CURL library (DLL version)")
set(CURL_IMPORT_LIB ${CURL_IMPORT_LIB} CACHE STRING "CURL import library for DLL linkage")

# Create a target for CURL::libcurl that links to the import library
add_library(CURL::libcurl UNKNOWN IMPORTED)
set_target_properties(CURL::libcurl PROPERTIES
  IMPORTED_LOCATION "${CURL_IMPORT_LIB}"
  INTERFACE_INCLUDE_DIRECTORIES "${CURL_INCLUDE_DIRS}"
)

# Provide the version of CURL (optional, but may be useful for debugging)
message(STATUS "Found CURL version: ${CURL_VERSION}")
message(STATUS "CURL include directory: ${CURL_INCLUDE_DIRS}")
message(STATUS "CURL import library: ${CURL_IMPORT_LIB}")
message(STATUS "CURL shared library (DLL version): ${CURL_LIBRARIES}")

# Indicate that CURL was found
mark_as_advanced(CURL_INCLUDE_DIRS CURL_LIBRARIES CURL_IMPORT_LIB)
