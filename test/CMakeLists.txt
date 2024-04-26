cmake_minimum_required(VERSION 3.20)

file(GLOB TEST_SRCS CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
set(TEST_BIN "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/test")
get_target_property(LINK_LIBS ${EXECUTABLE_NAME} LINK_LIBRARIES)

foreach(testSrc ${TEST_SRCS})
  # Extract the filename without an extension, this will be the test name
  get_filename_component(testName ${testSrc} NAME_WE)
  add_executable(${testName} ${testSrc})
  target_link_libraries(${testName}
    Boost::unit_test_framework ${LINK_LIBS})
  # Move testing binaries into a testBin directory
  set_target_properties(${testName} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${TEST_BIN})
  # Finally add it to test execution
  add_test(NAME ${testName}
    WORKING_DIRECTORY ${TEST_BIN}
    COMMAND ${TEST_BIN}/${testName})
endforeach(testSrc)
