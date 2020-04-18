set(MODULE_NAME simple_module)

file(GLOB SOURCES ./*.c)

add_library(${MODULE_NAME} STATIC
    ${SOURCES}
    )

target_include_directories(${MODULE_NAME}
    PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
    ${PROJECT_SOURCE_DIR}/include
    )
