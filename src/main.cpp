#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <vector>
#include <functional>
#include <atomic>
#include <stdexcept>
#include <limits>
#include <cstdlib>
#include <CLI11/CLI11.hpp>
#include <ifcg/components/task.hpp>
#include <graph/common/lw_graph.hpp>
#include <graph/util/node_data.hpp>

#include "core/statistics.hpp"
#include "core/util.hpp"

namespace fs = std::filesystem;
using namespace perlin2D;

std::vector<Algorithm> algorithms = {
    {
        "Dijkstra",
        [](const common::lwGraph<Vertex3D>& graph, std::size_t start, std::size_t goal, HeuristicFuncLW heuristic) {
            return search::dijkstra(graph, start, goal);
        }
    },
    {"A*", search::aStar<Vertex3D>},
    {"Greedy Best-First", search::greedyBestFirst<Vertex3D>},
    {
        "Weighted A*",
        [](const common::lwGraph<Vertex3D>& graph, std::size_t start, std::size_t goal, HeuristicFuncLW heuristic) {
            return search::weightedAStar<Vertex3D>(graph, start, goal, heuristic, 1.5);
        }
    }
};

std::vector<Color> pathColors = {
    {1.0f, 0.0f, 0.0f, 1.0f},
    {0.0f, 1.0f, 0.0f, 1.0f},
    {0.0f, 0.0f, 1.0f, 1.0f},
    {1.0f, 1.0f, 0.0f, 1.0f}
};

const std::vector<GraphModel> graphModels = {
    {
        "2_5d",
        false,
        [](const GraphBuildInput& input) {
            return createGrid2_5D(input.noise, input.width, input.heightScale, input.depth);
        }
    },
    {
        "voxel",
        false,
        [](const GraphBuildInput& input) {
            return createVoxelGraph(input.noise, input.width, input.heightScale, input.depth);
        }
    },
    {
        "vertex",
        true,
        [](const GraphBuildInput& input) {
            return createVertexToVertex(input.vertices, input.indices);
        }
    },
    {
        "dual",
        true,
        [](const GraphBuildInput& input) {
            return createPolygonToPolygon(input.vertices, input.indices);
        }
    }
};

const GraphModel& getGraphModel(const std::string& name) {
    const auto model = std::find_if(
        graphModels.begin(),
        graphModels.end(),
        [&name](const GraphModel& candidate) {
            return candidate.name == name;
        }
    );

    if (model == graphModels.end()) {
        throw std::invalid_argument("Modelo de grafo desconhecido: " + name);
    }

    return *model;
}

void test(uint intensity, NoiseConfig noiseConfig, const std::string& saveDir, const GraphModel& graphModel);
void save(const std::string& target, NoiseConfig noiseConfig, bool saveOctaves);
// void stats(uint repetitions, uint steps, uint intensity, float heightLimit);

int main(int argc, char* argv[]) {   
    CLI::App app{"PATHFINDING EM MALHAS 3D, André Vitor Bastos de Macêdo"};

    uint repetitions = 5;
    uint steps = 4;
    uint intensity = 100;
    uint pairCount = 10;
    std::string statsTestName;
    unsigned int statsSeed = static_cast<unsigned int>(time(NULL));
    float heightLimit = 2.5f;
    std::string path = "../results/";
    std::string graphModelName;
    NoiseConfig noiseConfig = {
        .width = 250,
        .height = 250,
        .freq = 1.0f,
        .amp = 1.0f,
        .exp = 1.0f,
        .seed = static_cast<unsigned int>(time(NULL)),
        .octaves = 5
    };

    auto testCmd = app.add_subcommand("test", "Executa o teste visual");
    testCmd->add_option("graph", graphModelName, "Representação do grafo")
        ->check(CLI::IsMember({"2_5d", "voxel", "vertex", "dual"}))
        ->required();
    testCmd->add_option("intensity,--intensity", intensity, "Intensidade do ruído")->check(CLI::Range(2u, std::numeric_limits<uint>::max()));
    testCmd->add_option("width,--width", noiseConfig.width, "Largura do mapa")->check(CLI::Range(2, std::numeric_limits<int>::max()));
    testCmd->add_option("height,--height", noiseConfig.height, "Altura do mapa")->check(CLI::Range(2, std::numeric_limits<int>::max()));
    testCmd->add_option("octaves,--octaves", noiseConfig.octaves, "Número de oitavas")->check(CLI::Range(1u, 16u));
    testCmd->add_option("freq, -f,--freq", noiseConfig.freq, "Frequência do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("lac,--lac", noiseConfig.lac, "Lacunaridade do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("amp,-a,--amp", noiseConfig.amp, "Amplitude do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("pers,--pers", noiseConfig.pers, "Persistência do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("exp,-e,--exp", noiseConfig.exp, "Exponente do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("seed,-s,--seed", noiseConfig.seed, "Semente do gerador de números aleatórios")->check(CLI::PositiveNumber);
    testCmd->add_option("savePath,--save", path, "Diretório para salvar os resultados")->check(CLI::ExistingDirectory);
    testCmd->callback([&]() {
        test(intensity, noiseConfig, path, getGraphModel(graphModelName));
    });

    std::string saveTarget;
    bool saveOctaves = false;
    auto saveCmd = app.add_subcommand("save", "Gera o ruído e salva como PNG");
    saveCmd->add_option("target", saveTarget, "Diretório ou arquivo de destino")->required();
    saveCmd->add_option("intensity,--intensity", intensity, "Intensidade do ruído (não afeta a imagem)")->check(CLI::Range(2u, std::numeric_limits<uint>::max()));
    saveCmd->add_option("width,--width", noiseConfig.width, "Largura do mapa")->check(CLI::Range(2, std::numeric_limits<int>::max()));
    saveCmd->add_option("height,--height", noiseConfig.height, "Altura do mapa")->check(CLI::Range(2, std::numeric_limits<int>::max()));
    saveCmd->add_option("octaves,--octaves", noiseConfig.octaves, "Número de oitavas")->check(CLI::Range(1u, 16u));
    saveCmd->add_option("freq,-f,--freq", noiseConfig.freq, "Frequência do ruído")->check(CLI::PositiveNumber);
    saveCmd->add_option("lac,--lac", noiseConfig.lac, "Lacunaridade do ruído")->check(CLI::PositiveNumber);
    saveCmd->add_option("amp,-a,--amp", noiseConfig.amp, "Amplitude do ruído")->check(CLI::PositiveNumber);
    saveCmd->add_option("pers,--pers", noiseConfig.pers, "Persistência do ruído")->check(CLI::PositiveNumber);
    saveCmd->add_option("exp,-e,--exp", noiseConfig.exp, "Exponente do ruído")->check(CLI::PositiveNumber);
    saveCmd->add_option("seed,-s,--seed", noiseConfig.seed, "Semente do gerador de números aleatórios")->check(CLI::PositiveNumber);
    saveCmd->add_flag("--save-octaves", saveOctaves, "Salva cada oitava em <destino>/octave_N.png");
    saveCmd->callback([&]() {
        save(saveTarget, noiseConfig, saveOctaves);
    });

    auto statsCmd = app.add_subcommand("stats", "Executa aquisição de estatísticas");
    statsCmd->add_option("test", statsTestName, "Variável de terreno testada")
        ->check(CLI::IsMember({"scale", "lac", "pers"}))
        ->required();
    statsCmd->add_option("graph", graphModelName, "Representação do grafo")
        ->check(CLI::IsMember({"2_5d", "voxel", "vertex", "dual"}))
        ->required();
    statsCmd->add_option("repetitions", repetitions, "Número de repetições para cada teste")->check(CLI::PositiveNumber)->required();
    statsCmd->add_option("steps", steps, "Número de passos para cada teste")->check(CLI::PositiveNumber)->required();
    statsCmd->add_option("--pairs", pairCount, "Pares início/fim por terreno")->check(CLI::PositiveNumber);
    statsCmd->add_option("-s,--seed", statsSeed, "Semente base dos terrenos e pares");
    statsCmd->add_option("savePath,--save", path, "Diretório para salvar os resultados")->check(CLI::ExistingDirectory);
    statsCmd->callback([&]() {
        std::cout << "Seed base: " << statsSeed << std::endl;
        const GraphModel& graphModel = getGraphModel(graphModelName);

        if (statsTestName == "scale") {
            testScale(steps, repetitions, pairCount, statsSeed, path, graphModel, algorithms);
        } else if (statsTestName == "lac") {
            testLacunarity(steps, repetitions, pairCount, statsSeed, path, graphModel, algorithms);
        } else if (statsTestName == "pers") {
            testPersistence(steps, repetitions, pairCount, statsSeed, path, graphModel, algorithms);
        }
    });

    CLI11_PARSE(app, argc, argv);

    return 0;
};

// void stats(uint repetitions, uint steps, uint intensity, float heightLimit) {
//     struct TestConfig {
//         std::string name;
//         Param paramSetter;
//         Stats statsSetter;
//     };

//     std::vector<TestConfig> testConfigs = {
//         {
//             "Escala",
//             [](int step) {
//                 std::random_device rd;
//                 std::mt19937 gen(rd());
//                 std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

//                 NoiseConfig config = {
//                     .width = (step + 1) * 200,
//                     .height = (step + 1) * 200,
//                     .freq = 4.0f,
//                     .amp = 1.0f,
//                     .exp = 1.0f,
//                     .seed = distSeed(gen),
//                     .octaves = 6
//                 };
                
//                 return config;
//             },
//             [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
//                 stats.addEntry(algName, "Tamanho do Mapa", (double)config.width);
//             }
//         }, {
//             "Lacunaridade",
//             [](int step) {
//                 std::random_device rd;
//                 std::mt19937 gen(rd());
//                 std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

//                 NoiseConfig config = {
//                     .width = 500,
//                     .height = 500,
//                     .freq = 1.0f + (step * 0.5f),
//                     .amp = 1.0f,
//                     .exp = 1.0f,
//                     .seed = distSeed(gen),
//                     .octaves = 6
//                 };
                
//                 return config;
//             },
//             [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
//                 stats.addEntry(algName, "Frequência", (double)config.freq);
//             }
//         }, {
//             "Persistência",
//             [](int step) {
//                 std::random_device rd;
//                 std::mt19937 gen(rd());
//                 std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

//                 NoiseConfig config = {
//                     .width = 500,
//                     .height = 500,
//                     .freq = 4.0f,
//                     .amp = 1.0f - (step * 0.15f),
//                     .exp = 1.0f,
//                     .seed = distSeed(gen),
//                     .octaves = 6
//                 };

//                 return config;
//             },
//             [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
//                 stats.addEntry(algName, "Amplitude", (double)config.amp);
//             }
//         }
//     };

//     for (const auto& config : testConfigs) {
//         auto testName = config.name;
//         auto paramSetter = config.paramSetter;
//         auto statsSetter = config.statsSetter;

//         runTests(
//             algorithms,
//             paramSetter,
//             statsSetter,
//             repetitions, steps,
//             intensity, heightLimit
//         );

//         std::cout << std::endl;
//     }
// };

void save(const std::string& target, NoiseConfig noiseConfig, bool saveOctaves) {
    std::string expanded = target;
    if (expanded.starts_with('~')) {
        if (const char* home = std::getenv("HOME")) {
            expanded = std::string(home) + expanded.substr(1);
        }
    }

    fs::path filePath(expanded);
    if (expanded.ends_with('/') || fs::is_directory(filePath)) {
        filePath /= "temp.png";
    } else if (filePath.extension() != ".png") {
        filePath.replace_extension(".png");
    }

    std::cout << "Seed: " << noiseConfig.seed << std::endl;
    const auto noise = generateNoiseMap(noiseConfig);
    saveNoiseAsPNG(filePath.string(), noise, noiseConfig.width, noiseConfig.height);
    std::cout << "Ruído salvo em " << filePath.string() << std::endl;

    if (saveOctaves) {
        const fs::path octaveDir = filePath.parent_path() / filePath.stem();
        const auto octaveMaps = generateOctaveMaps(noiseConfig);
        for (size_t i = 0; i < octaveMaps.size(); ++i) {
            const fs::path octavePath = octaveDir / ("octave_" + std::to_string(i + 1) + ".png");
            saveNoiseAsPNG(octavePath.string(), octaveMaps[i], noiseConfig.width, noiseConfig.height);
        }
        std::cout << "Oitavas salvas em " << octaveDir.string() << std::endl;
    }
};

void test(
    uint intensity,
    NoiseConfig noiseConfig,
    const std::string& saveDir,
    const GraphModel& graphModel
) {
    using namespace ifcg;

    srand(static_cast<unsigned>(time(NULL)));

    Engine::init(1200, 800, "TCC");
    Engine::setup3D();

    auto& input {Engine::getInputHandler()};
    auto& renderer {Engine::getRenderer()};
	auto& camera {renderer.getCamera()};
    camera.setPosition(glm::vec3(-25.0f, (float)intensity * 0.9f, -25.0f));
    camera.setOrientation(glm::vec3(0.6, -0.5, 0.6));
    renderer.setFarPlane(1000.0f);
    GLuint shader {renderer.getShaderID()};

    std::shared_ptr<Mesh> geometryPtr = nullptr;
    std::shared_ptr<Mesh> navigationPtr = nullptr;
    std::vector<std::shared_ptr<Mesh>> pathPtrs;
    bool showNavigation = true;
    bool showPaths = true;

    struct GeometryResult {
        std::vector<float> noise;
        std::vector<Vertex> vertices;
        std::vector<GLuint> indices;
    };

    struct NavigationResult {
        std::shared_ptr<undirected::lwGraph<Vertex3D>> graph;
        std::size_t startId;
        std::size_t goalId;
        std::vector<Vertex> vertices;
        std::vector<GLuint> indices;
    };

    struct PathResult {
        size_t algorithmIndex;
        std::vector<Vertex> vertices;
        std::vector<GLuint> indices;
    };

    bool isGenerating = false;
    auto generate = [&]() {
        if (isGenerating) {
            return;
        }

        isGenerating = true;
        std::cout << "Gerando geometria (seed " << noiseConfig.seed << ")." << std::endl;

        const NoiseConfig currentConfig = noiseConfig;

        for (auto& pathPtr : pathPtrs) {
            renderer.removeMesh(pathPtr);
        }
        pathPtrs.clear();

        Engine::runAsyncThenMain(
            [currentConfig, intensity]() {
                std::cout << "Gerando mapa." << std::endl;
                auto noise = generateNoiseMap(currentConfig);
                auto [verticesGeo, indicesGeo] = getMarchingCubeData(
                    noise,
                    currentConfig.width,
                    intensity,
                    currentConfig.height,
                    {0.42f, 0.42f, 0.48f, 1.0f}
                );

                return GeometryResult {
                    .noise = std::move(noise),
                    .vertices = std::move(verticesGeo),
                    .indices = std::move(indicesGeo)
                };
            },
            [&, shader, intensity, currentConfig](GeometryResult result) mutable {
                if (geometryPtr) {
                    std::cout << "Removendo geometria antiga." << std::endl;
                    renderer.removeMesh(geometryPtr);
                }

                std::cout << "Adicionando nova geometria." << std::endl;
                geometryPtr = std::make_shared<Mesh>(std::move(result.vertices), std::move(result.indices), shader, GL_TRIANGLES);
                renderer.addMesh(geometryPtr);

                std::cout << "Gerando navegação." << std::endl;
                Engine::runAsyncThenMain(
                    [&geometryPtr, currentConfig, noise = std::move(result.noise), intensity, graphModel]() mutable {
                        const GraphBuildInput graphInput {
                            .noise = noise,
                            .vertices = geometryPtr->getVertices(),
                            .indices = geometryPtr->getIndices(),
                            .width = currentConfig.width,
                            .heightScale = static_cast<int>(intensity),
                            .depth = currentConfig.height
                        };
                        auto graph = graphModel.create(graphInput);

                        auto graphPtr = std::make_shared<undirected::lwGraph<Vertex3D>>(std::move(graph));
                        auto [verticesNav, indicesNav] = getMeshFromGraph(*graphPtr, intensity, {0.26f, 0.26f, 0.30f, 0.25f});

                        const std::vector<char> snapMask = largestComponentMask(*graphPtr);
                        const QueryPair pair = generateQueryPairs(
                            noise, currentConfig.width, currentConfig.height, static_cast<int>(intensity), currentConfig.seed, 1
                        ).front();
                        const SnapResult start = nearestVertex(*graphPtr, pair.start, snapMask);
                        const SnapResult goal = nearestVertex(*graphPtr, pair.goal, snapMask);

                        return NavigationResult {
                            .graph = std::move(graphPtr),
                            .startId = start.id,
                            .goalId = goal.id,
                            .vertices = std::move(verticesNav),
                            .indices = std::move(indicesNav)
                        };
                    },
                    [&, shader](NavigationResult navData) mutable {
                        auto graphPtr = std::move(navData.graph);
                        const std::size_t startId = navData.startId;
                        const std::size_t goalId = navData.goalId;

                        if (navigationPtr) {
                            std::cout << "Removendo navegação antiga." << std::endl;
                            renderer.removeMesh(navigationPtr);
                        }

                        std::cout << "Adicionando nova navegação." << std::endl;
                        navigationPtr = std::make_shared<Mesh>(std::move(navData.vertices), std::move(navData.indices), shader, GL_LINES);
                        navigationPtr->translate(0.0f, 0.2f, 0.0f);
                        if (showNavigation) {
                            renderer.addMesh(navigationPtr);
                        }

                        if (graphPtr->getOrder() == 0) {
                            std::cout << "Grafo de navegação vazio; busca de caminhos ignorada." << std::endl;
                            isGenerating = false;
                            return;
                        }

                        std::cout << "Gerando caminhos." << std::endl;
                        pathPtrs.resize(algorithms.size());

                        if (algorithms.empty()) {
                            isGenerating = false;
                            return;
                        }

                        auto pendingPaths = std::make_shared<std::atomic_size_t>(algorithms.size());

                        for (size_t algorithmIndex = 0; algorithmIndex < algorithms.size(); ++algorithmIndex) {
                            Engine::runAsyncThenMain(
                                [graphPtr, startId, goalId, algorithmIndex, algFunc = algorithms[algorithmIndex].run]() {
                                    const Color color = pathColors[algorithmIndex % pathColors.size()];

                                    HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) -> double {
                                        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
                                        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
                                        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
                                        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
                                    };

                                    auto path = algFunc(*graphPtr, startId, goalId, heuristic).path;
                                    if (path.empty()) {
                                        std::cout << "Algoritmo " << algorithmIndex << " não encontrou caminho." << std::endl;
                                        return PathResult {
                                            .algorithmIndex = algorithmIndex,
                                            .vertices = {},
                                            .indices = {}
                                        };
                                    }
                                    auto [verticesPath, indicesPath] = getMeshFromPath(*graphPtr, path, color);

                                    return PathResult {
                                        .algorithmIndex = algorithmIndex,
                                        .vertices = std::move(verticesPath),
                                        .indices = std::move(indicesPath)
                                    };
                                },
                                [&, shader, pendingPaths](PathResult pathData) mutable {
                                    if (!pathData.vertices.empty() && !pathData.indices.empty()) {
                                        auto pathPtr = std::make_shared<Mesh>(std::move(pathData.vertices), std::move(pathData.indices), shader, GL_LINES);
                                        pathPtr->translate(0.0f, 0.4f + 0.15f * static_cast<float>(pathData.algorithmIndex), 0.0f);
                                        if (showPaths) {
                                            renderer.addMesh(pathPtr);
                                        }
                                        pathPtrs[pathData.algorithmIndex] = std::move(pathPtr);
                                    }

                                    if (pendingPaths->fetch_sub(1) == 1) {
                                        isGenerating = false;
                                    }
                                },
                                Priority::Medium
                            );
                        }
                    },
                    Priority::Medium
                );
            },
            Priority::High
        );
    };

    generate();
    std::mt19937 seedGenerator {std::random_device{}()};
    input.addKeyCallback(Key::K, KeyAction::PRESS, [&]() {
        if (isGenerating) {
            return;
        }

        noiseConfig.seed = static_cast<unsigned int>(seedGenerator());
        generate();
    });

    input.addKeyCallback(Key::I, KeyAction::PRESS, [&camera]() {
        camera.setPosition(glm::vec3(-0.350095, 89.6943, 22.1546));
        camera.setOrientation(glm::vec3(0.439334, -0.881492, -8.42847e-08));
    });

    float rotationStep {glm::radians(1.0f)};
    input.addKeyCallback(Key::LEFT, KeyAction::HELD, [&camera, rotationStep]() {
        camera.rotate(rotationStep, camera.getUp());
    });

    input.addKeyCallback(Key::RIGHT, KeyAction::HELD, [&camera, rotationStep]() {
        camera.rotate(-rotationStep, camera.getUp());
    });

    auto tilt = [&camera](float angle) {
        glm::vec3 orient {camera.getOrientation()};
        glm::vec3 up {camera.getUp()};
        glm::vec3 right {glm::normalize(glm::cross(orient, up))};
        glm::vec3 newOrient {glm::rotate(orient, angle, right)};

        if (std::abs(glm::dot(glm::normalize(newOrient), up)) < 0.99f) {
            camera.setOrientation(newOrient);
        }
    };

    input.addKeyCallback(Key::UP, KeyAction::HELD, [tilt, rotationStep]() {
        tilt(rotationStep);
    });

    input.addKeyCallback(Key::DOWN, KeyAction::HELD, [tilt, rotationStep]() {
        tilt(-rotationStep);
    });

	input.addKeyCallback(Key::SHIFT_L, KeyAction::HELD, [&camera, &rotationStep]() {
        rotationStep = glm::radians(4.0f);
        camera.setSpeed(1.0f);
    });

    input.addKeyCallback(Key::SHIFT_L, KeyAction::RELEASE, [&camera, &rotationStep]() {
        rotationStep = glm::radians(1.0f);
        camera.setSpeed(0.5f);
    });

    input.addKeyCallback(Key::O, KeyAction::PRESS, [&camera]() {
        glm::vec3 pos {camera.getPosition()};
        glm::vec3 orient {camera.getOrientation()};
        std::cout << "Posição: (" << pos.x << ", " << pos.y << ", " << pos.z << ")" << std::endl;
        std::cout << "Orientação: (" << orient.x << ", " << orient.y << ", " << orient.z << ")" << std::endl;
    });

    input.addKeyCallback(Key::Z, KeyAction::PRESS, [&]() {
        showNavigation = !showNavigation;
        if (!navigationPtr) {
            return;
        }

        if (showNavigation) {
            renderer.addMesh(navigationPtr);
        } else {
            renderer.removeMesh(navigationPtr);
        }
    });

    input.addKeyCallback(Key::X, KeyAction::PRESS, [&]() {
        showPaths = !showPaths;
        for (auto& pathPtr : pathPtrs) {
            if (!pathPtr) {
                continue;
            }

            if (showPaths) {
                renderer.addMesh(pathPtr);
            } else {
                renderer.removeMesh(pathPtr);
            }
        }
    });

	LoopConfig config = {
        .mode = LoopMode::Concurrent
    }; 

    Engine::loop(config);
	Engine::terminate();
};