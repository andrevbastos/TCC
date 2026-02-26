include(FetchContent)

# --- Bibliotecas pessoais ---

# Adicione a busca pelo OpenGL antes de disponibilizar as libs
find_package(OpenGL REQUIRED)
find_package(glm REQUIRED)

# Se você não tiver o nlohmann_json instalado no sistema, 
# adicione ele via FetchContent também para o graph_project
FetchContent_Declare(
  json
  URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz
)
FetchContent_MakeAvailable(json)

FetchContent_Declare(
  ifcg
  GIT_REPOSITORY https://github.com/andrevbastos/ifcg.git
  GIT_TAG        main
)

FetchContent_Declare(
  graph_project
  GIT_REPOSITORY https://github.com/andrevbastos/graph.git
  GIT_TAG        main
)

# Torna as bibliotecas disponíveis no projeto
FetchContent_MakeAvailable(ifcg graph_project)

# --- Dependências de Teste ---

FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        v1.14.0
)
FetchContent_MakeAvailable(googletest)