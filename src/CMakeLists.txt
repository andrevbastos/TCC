# Coleta os fontes
file(GLOB TCC_SOURCES "*.cpp")

# Configurações de supressão de avisos para bibliotecas externas
if(TARGET graph_core)
    target_compile_options(graph_core PRIVATE -Wno-error)
endif()

if(TARGET ifcg_core)
    target_compile_options(ifcg_core PRIVATE -Wno-error)
endif()

# Itera sobre cada arquivo e cria um executável dinamicamente
foreach(SOURCE_FILE ${TCC_SOURCES})
    # Obtém o nome do arquivo sem a extensão
    get_filename_component(EXE_NAME ${SOURCE_FILE} NAME_WE)

    # Padroniza: 'main.cpp' vira o executável 'tcc', os outros mantêm o nome do arquivo
    if(EXE_NAME STREQUAL "main")
        set(TARGET_NAME "tcc")
    else()
        set(TARGET_NAME ${EXE_NAME})
    endif()

    # Cria o executável para o arquivo atual
    add_executable(${TARGET_NAME} ${SOURCE_FILE})

    # Linka com os cores das bibliotecas importadas via FetchContent
    target_link_libraries(${TARGET_NAME} PRIVATE 
        ifcg_core 
        graph_core 
    )

    # Inclui os headers do projeto
    target_include_directories(${TARGET_NAME} PRIVATE "${PROJECT_SOURCE_DIR}/include")

    # Copia recursos da engine ifcg para o diretório de build de cada executável (Essencial para Shaders)
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${ifcg_SOURCE_DIR}/resources $<TARGET_FILE_DIR:${TARGET_NAME}>/resources
    )
endforeach()
