# Coleta os fontes
file(GLOB TCC_SOURCES "*.cpp")

# Configurações de supressão de avisos para bibliotecas externas
if(TARGET graph_core)
    target_compile_options(graph_core PRIVATE -Wno-error)
endif()

if(TARGET ifcg_core)
    target_compile_options(ifcg_core PRIVATE -Wno-error)
endif()

# Cria o executável para o main.cpp
add_executable(tcc main.cpp stb_impl.cpp)

# Linka com os cores das bibliotecas importadas via FetchContent
target_link_libraries(tcc PRIVATE 
    ifcg_core 
    graph_core 
)

# Inclui os headers do projeto
target_include_directories(tcc PRIVATE "${PROJECT_SOURCE_DIR}/include")

# Copia recursos da engine ifcg para o diretório de build de cada executável (Essencial para Shaders)
add_custom_command(TARGET tcc POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${ifcg_SOURCE_DIR}/resources $<TARGET_FILE_DIR:tcc>/resources
)

# Cria o executável para o terrain_viewer.cpp
add_executable(terrain_viewer terrain_viewer.cpp stb_impl.cpp)

# Linka com os cores das bibliotecas importadas via FetchContent
target_link_libraries(terrain_viewer PRIVATE 
    ifcg_core 
    graph_core 
)

# Inclui os headers do projeto
target_include_directories(terrain_viewer PRIVATE "${PROJECT_SOURCE_DIR}/include")

add_custom_command(TARGET terrain_viewer POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${ifcg_SOURCE_DIR}/resources $<TARGET_FILE_DIR:terrain_viewer>/resources
)