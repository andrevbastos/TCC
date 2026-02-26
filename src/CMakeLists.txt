# Coleta os fontes
file(GLOB_RECURSE TCC_SOURCES "*.cpp")

# No src/CMakeLists.txt do seu TCC
if(TARGET graph_core)
    # Remove a obrigatoriedade de tratar avisos como erros nas bibliotecas externas
    target_compile_options(graph_core PRIVATE -Wno-error)
endif()

if(TARGET ifcg_core)
    target_compile_options(ifcg_core PRIVATE -Wno-error)
endif()

add_executable(tcc main.cpp)

# Linka com os cores das bibliotecas importadas via FetchContent
# Nota: Verifique se o nome do target exportado por 'graph' é 'graph_project' ou similar
target_link_libraries(tcc PRIVATE 
    ifcg_core 
    graph_core 
)

# Se o seu TCC tiver seus próprios headers
target_include_directories(tcc PRIVATE "${PROJECT_SOURCE_DIR}/include")

# Copia recursos da engine ifcg para o binário do TCC (Importante para Shaders)
add_custom_command(TARGET tcc POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${ifcg_SOURCE_DIR}/resources $<TARGET_FILE_DIR:tcc>/resources
    COMMENT "Copiando recursos da engine IFCG para o diretório de build do TCC..."
)