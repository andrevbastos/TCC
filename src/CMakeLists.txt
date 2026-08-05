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
add_executable(main main.cpp)

# Linka com os cores das bibliotecas importadas via FetchContent
target_link_libraries(main PRIVATE 
    ifcg_core 
    graph_core 
)

# Inclui os headers do projeto
target_include_directories(main PRIVATE "${PROJECT_SOURCE_DIR}/include")

# Cria o executável para o terrain_viewer.cpp
add_executable(terrain_viewer terrain_viewer.cpp)

# Linka com os cores das bibliotecas importadas via FetchContent
target_link_libraries(terrain_viewer PRIVATE 
    ifcg_core 
    graph_core 
)

# Inclui os headers do projeto
target_include_directories(terrain_viewer PRIVATE "${PROJECT_SOURCE_DIR}/include")
