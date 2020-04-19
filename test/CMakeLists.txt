# List of tests and their flags
# Add new tests like this
list(APPEND tests_names "test_simple_module")
list(APPEND tests_flags " ")


# Declare all tests targets
list(LENGTH tests_names count)
math(EXPR count "${count} - 1")
foreach(i RANGE ${count})
    list(GET tests_names ${i} test_name)
    list(GET tests_flags ${i} test_flags)
    add_executable(${test_name} ${test_name}.c)
    string(REGEX REPLACE "^test_" "" cut ${test_name})
    target_link_libraries(${test_name}
        ${cut}
        unity
        )
    target_include_directories(${test_name}
        PRIVATE
        ${PROJECT_SOURCE_DIR}/components/fff
        )
    if(test_flags STREQUAL " ")
    else()
        target_link_libraries(${test_name}
            ${test_flags}
            )
    endif()
    add_test(${test_name} ${test_name})
endforeach()


