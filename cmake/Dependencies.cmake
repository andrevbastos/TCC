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
  GIT_TAG        6dc69ea3215eb74984701782e085d2aa7f69f612 # versão usada na coleta
)

FetchContent_Declare(
  graph_project
  GIT_REPOSITORY https://github.com/andrevbastos/graph.git
  GIT_TAG        98cdadf2cea312e8e65ea6816a992892bc5623ee # versão usada na coleta
)

FetchContent_MakeAvailable(ifcg graph_project)