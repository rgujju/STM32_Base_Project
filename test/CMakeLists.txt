# LICENSE
#
# The MIT License (MIT)
#
# Copyright (c) 2020 Rohit Gujarathi https://github.com/rgujju
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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


