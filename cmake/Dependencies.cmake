include(FetchContent)

# --- Bibliotecas pessoais ---

find_package(OpenGL REQUIRED)
find_package(glm REQUIRED)

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

FetchContent_MakeAvailable(ifcg graph_project)

# --- Dependências de Teste ---

FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        v1.14.0
)
FetchContent_MakeAvailable(googletest)