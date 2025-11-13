cmake_minimum_required(VERSION 3.22.1)
project(native_processor)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# OpenCV
# Expect OpenCV_DIR passed from Gradle: -DOpenCV_DIR=<sdk>/sdk/native/jni
find_package(OpenCV REQUIRED)

add_library(native-processor SHARED
    processor.cpp
    processor_jni.cpp
)

find_library(log-lib log)
find_library(android-lib android)
find_library(jnigraphics-lib jnigraphics)

include_directories(${OpenCV_INCLUDE_DIRS})

# Define macros
add_definitions(-DGL_GLEXT_PROTOTYPES)

# Link libraries
target_link_libraries(native-processor
    ${OpenCV_LIBS}
    ${log-lib}
    ${android-lib}
    ${jnigraphics-lib}
)
