cmake_minimum_required(VERSION 3.20)
project(MyProject
  LANGUAGES CXX
  VERSION 0.0.1
  DESCRIPTION "My description"
  HOMEPAGE_URL "https://example.com")
set(EXECUTABLE_NAME ${PROJECT_NAME})

# Put all binaries in the same directory, including DLLs.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

#### DEPENDENCIES ####

option(fetchSFML "Download and compile SFML automatically" ON)
if(fetchSFML)
  message(STATUS "Fetching SFML")
  include(FetchContent)
  FetchContent_Declare(SFML
    GIT_REPOSITORY https://github.com/SFML/SFML.git
    GIT_TAG 2.6.x
    GIT_SHALLOW TRUE)
  FetchContent_MakeAvailable(SFML)
else()
  find_package(SFML 2.6 REQUIRED COMPONENTS graphics)
endif()

option(fetchBoost "Download and compile Boost automatically" ON)
set(BOOST_VERSION 1.82.0)
if(fetchBoost)
  message(STATUS "Fetching Boost")
  set(BOOST_INCLUDE_LIBRARIES dll)
  include(FetchContent)
  FetchContent_Declare(Boost
    URL https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}.tar.xz
    URL_MD5 9ef03341798f1caf9ac910bb60cde9d6
    DOWNLOAD_EXTRACT_TIMESTAMP ON
  )
  FetchContent_MakeAvailable(Boost)
else()
  # Boost::dll is a header-only library that depends on Boost::filesystem
  find_package(Boost ${BOOST_VERSION} REQUIRED
    COMPONENTS headers filesystem) # Won't work if BOOST_VERSION is below 1.82.0
endif()

# Set DATA_PATH
option(USE_RELATIVE_PATHS "Set some variables as relative paths to install directory" OFF)
include(GNUInstallDirs)
if (USE_RELATIVE_PATHS)
  cmake_path(RELATIVE_PATH CMAKE_INSTALL_FULL_DATADIR
    BASE_DIRECTORY ${CMAKE_INSTALL_FULL_BINDIR}
    OUTPUT_VARIABLE DATA_PATH)
  cmake_path(APPEND DATA_PATH ${PROJECT_NAME})
else()
  cmake_path(APPEND PROJECT_SOURCE_DIR "data" OUTPUT_VARIABLE DATA_PATH)
endif()

#### ADD EXECUTABLE ####

file(GLOB SRCS CONFIGURE_DEPENDS
  "${PROJECT_SOURCE_DIR}/src/*.cpp"
  "${PROJECT_SOURCE_DIR}/src/include/*.h*")
add_executable(${EXECUTABLE_NAME} ${SRCS})
target_include_directories(${EXECUTABLE_NAME} PRIVATE "${PROJECT_SOURCE_DIR}/src/include")
configure_file("${PROJECT_SOURCE_DIR}/src/include/config.hpp.in" "${PROJECT_SOURCE_DIR}/src/include/config.hpp" @ONLY)
target_compile_features(${EXECUTABLE_NAME} PRIVATE cxx_std_20)
# Defined in CMakePresets.json
target_link_options(${EXECUTABLE_NAME} PRIVATE ${SUBSYSTEM_LINKER_OPTIONS})

#### LINK LIBRARIES ####

target_link_libraries(${EXECUTABLE_NAME} PRIVATE sfml-graphics)
if(fetchBoost)
  target_link_libraries(${EXECUTABLE_NAME} PRIVATE Boost::dll)
else()
  target_link_libraries(${EXECUTABLE_NAME} PRIVATE Boost::headers Boost::filesystem)
endif()

#### PLATFORM SPECIFIC ####

if(WIN32)
  add_custom_command(
    TARGET ${EXECUTABLE_NAME}
    COMMENT "Copy OpenAL DLL"
    PRE_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${SFML_SOURCE_DIR}/extlibs/bin/$<IF:$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,x64,x86>/openal32.dll $<TARGET_FILE_DIR:${EXECUTABLE_NAME}>
    VERBATIM)

  # Enable Hot reload if supported
  if (MSVC AND NOT MSVC_VERSION VERSION_LESS 142)
    target_link_options(${EXECUTABLE_NAME} PRIVATE $<$<CONFIG:Debug>:/INCREMENTAL>)
    target_compile_options(${EXECUTABLE_NAME} PRIVATE $<$<CONFIG:Debug>:/ZI>)
  endif()

  # Make __VA_OPT__ macro work on MSVC
  target_compile_options(${EXECUTABLE_NAME} PRIVATE $<IF:$<CXX_COMPILER_ID:MSVC>,/Zc:preprocessor,>)
endif()

#### INSTALL && PACKAGING ####

include(InstallRequiredSystemLibraries)
install(TARGETS ${EXECUTABLE_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY "${PROJECT_SOURCE_DIR}/data/" DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME})
if(BUILD_SHARED_LIBS AND fetchBoost)
  install(TARGETS boost_filesystem RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()

file(COPY_FILE ${PROJECT_SOURCE_DIR}/LICENSE ${PROJECT_BINARY_DIR}/LICENSE.txt)
set(CPACK_RESOURCE_FILE_LICENSE ${PROJECT_BINARY_DIR}/LICENSE.txt)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "Author name")
set(CPACK_PACKAGE_EXECUTABLES "${EXECUTABLE_NAME}" "installedExecutableName")
set(CPACK_PACKAGE_ICON "${PROJECT_SOURCE_DIR}/data/icon.png")
set(CPACK_SOURCE_IGNORE_FILES ${PROJECT_SOURCE_DIR}/.git/
    ${CMAKE_BINARY_DIR}/ ${PROJECT_BINARY_DIR}/
)

# WIX (MSI)
set(CPACK_WIX_PRODUCT_ICON ${CPACK_PACKAGE_ICON})
set(CPACK_WIX_PROGRAM_MENU_FOLDER ".")

include(CPack)

option(CONFIG_PACKAGING "Generate packaging files" OFF)
if (CONFIG_PACKAGING)
  configure_file("${PROJECT_SOURCE_DIR}/tools/nix/derivation.nix.in" "${PROJECT_SOURCE_DIR}/tools/nix/derivation.nix" @ONLY)
  configure_file("${PROJECT_SOURCE_DIR}/tools/appimage/app.desktop.in" "${PROJECT_SOURCE_DIR}/tools/appimage/${PROJECT_NAME}.desktop" @ONLY)
  configure_file("${PROJECT_SOURCE_DIR}/tools/appimage/Dockerfile.in" "${PROJECT_SOURCE_DIR}/tools/appimage/Dockerfile" @ONLY)
endif()
