add_executable(tcc_tests tests.cpp)

target_link_libraries(tcc_tests PRIVATE 
    ifcg_core 
    graph_core 
    GTest::gtest_main
)

add_test(NAME TCCUnitTests COMMAND tcc_tests)