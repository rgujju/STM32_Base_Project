#include "unity.h"
#include "simple_module.h"
#include "fff.h"
DEFINE_FFF_GLOBALS;

FAKE_VALUE_FUNC(uint8_t,add);

void setUp(void) {
    // set stuff up here
}

void tearDown(void) {
    // clean stuff up here
}

void test_SomethingSimple(void) {
    //test stuff
    // The function SomethingSimple depends on add, which is defined in utilities.c
    // So we have to fake that functio
    uint8_t myReturnVals[1] = { 3 };
    SET_RETURN_SEQ(add, myReturnVals, 1);
    
    TEST_ASSERT_EQUAL_INT(10,SomethingSimple(2,5)); 
    TEST_ASSERT_EQUAL_INT(1,add_fake.call_count);
}

void test_AnotherSimpleThing(void) {
    // more test stuffl
    TEST_ASSERT_EQUAL_INT(2,AnotherSimpleThing());
}

// not needed when using generate_test_runner.rb
int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_SomethingSimple);
    RUN_TEST(test_AnotherSimpleThing);
    return UNITY_END();
}
