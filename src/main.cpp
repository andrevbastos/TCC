#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <vector>
#include <functional>
#include <atomic>
#include <CLI11/CLI11.hpp>
#include <ifcg/components/task.hpp>
#include <graph/common/lw_graph.hpp>
#include <graph/util/dijkstra.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/greedy.hpp>
#include <graph/util/weighted.hpp>
#include <graph/util/node_data.hpp>

#include "core/statistics.hpp"
#include "core/util.hpp"

namespace fs = std::filesystem;
using namespace perlin2D;

std::vector<AlgFunc> algorithms = {
    [](const common::lwGraph<Vertex3D>& graph, std::size_t start, std::size_t goal, HeuristicFuncLW heuristic) {
        return util::Dijkstra::lwGetPathTo(graph, start, goal);
    },
    util::lwAStar<Vertex3D>,
    util::lwGreedyBestFirst<Vertex3D>,
    [](const common::lwGraph<Vertex3D>& graph, std::size_t start, std::size_t goal, HeuristicFuncLW heuristic) {
        return util::lwWeightedAStar<Vertex3D>(graph, start, goal, heuristic, 1.5f);
    }
};

std::vector<Color> pathColors = {
    {1.0f, 0.0f, 0.0f, 1.0f},
    {0.0f, 1.0f, 0.0f, 1.0f},
    {0.0f, 0.0f, 1.0f, 1.0f},
    {1.0f, 1.0f, 0.0f, 1.0f}
};

struct Results {
    Statistics& stats;
    std::string algorithmName;

    uint generatedNodes = 0;
    bool success = false;
    std::optional<uint> exploredNodes = std::nullopt;
    std::optional<double> pathCost = std::nullopt;
    std::optional<double> executionTime = std::nullopt;
    std::optional<double> pathLength = std::nullopt;

    void saveAll(){
        stats.addEntry(algorithmName, "Nós Gerados", generatedNodes);
        stats.addEntry(algorithmName, "Sucesso", success ? 1 : 0);
        stats.addEntry(algorithmName, "Nós Expandidos", exploredNodes.value_or(0));
        stats.addEntry(algorithmName, "Custo Caminho", pathCost.value_or(0.0));
        stats.addEntry(algorithmName, "Tempo de Execução", executionTime.value_or(0.0));
        stats.addEntry(algorithmName, "Comprimento do Caminho", pathLength.value_or(0.0));
    }
};

void test(uint intensity, NoiseConfig noiseConfig, const std::string& saveDir);
// void stats(uint repetitions, uint steps, uint intensity, float heightLimit);

int main(int argc, char* argv[]) {   
    CLI::App app{"PATHFINDING EM MALHAS 3D, André Vitor Bastos de Macêdo"};

    uint repetitions = 5;
    uint steps = 4;
    uint intensity = 100;
    float heightLimit = 2.5f;
    std::string path = "../results/";
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
    testCmd->add_option("intensity", intensity, "Intensidade do ruído")->check(CLI::PositiveNumber)->required();
    testCmd->add_option("width,--width", noiseConfig.width, "Largura do mapa")->check(CLI::PositiveNumber);
    testCmd->add_option("height,--height", noiseConfig.height, "Altura do mapa")->check(CLI::PositiveNumber);
    testCmd->add_option("octaves,--octaves", noiseConfig.octaves, "Número de oitavas")->check(CLI::PositiveNumber);
    testCmd->add_option("freq, -f,--freq", noiseConfig.freq, "Frequência do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("lac,--lac", noiseConfig.lac, "Lacunaridade do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("amp,-a,--amp", noiseConfig.amp, "Amplitude do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("pers,--pers", noiseConfig.pers, "Persistência do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("exp,-e,--exp", noiseConfig.exp, "Exponente do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("seed,-s,--seed", noiseConfig.seed, "Semente do gerador de números aleatórios")->check(CLI::PositiveNumber);
    testCmd->add_option("savePath,--save", path, "Diretório para salvar os resultados")->check(CLI::ExistingDirectory);
    testCmd->callback([&]() { test(intensity, noiseConfig, path); });

    // auto statsCmd = app.add_subcommand("stats", "Executa aquisição de estatísticas");
    // statsCmd->add_option("repetitions", repetitions, "Número de repetições para cada teste")->check(CLI::PositiveNumber)->required();
    // statsCmd->add_option("steps", steps, "Número de passos para cada teste")->check(CLI::PositiveNumber)->required();
    // statsCmd->add_option("intensity", intensity, "Intensidade do ruído")->check(CLI::PositiveNumber)->required();
    // statsCmd->add_option("heightLimit", heightLimit, "Limite de altura para o caminho")->check(CLI::PositiveNumber)->required();
    // statsCmd->callback([&]() { stats(repetitions, steps, intensity, heightLimit); });

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

void test(uint intensity, NoiseConfig noiseConfig, const std::string& saveDir) {
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
	
	input.addKeyCallback(Key::SHIFT_L, KeyAction::HELD, [&camera]() {
        camera.setSpeed(1.0f);
    });

    input.addKeyCallback(Key::SHIFT_L, KeyAction::RELEASE, [&camera]() {
        camera.setSpeed(0.5f);
    });

    std::shared_ptr<Mesh> geometryPtr = nullptr;
    std::shared_ptr<Mesh> navigationPtr = nullptr;
    std::vector<std::shared_ptr<Mesh>> pathPtrs;

    struct GeometryResult {
        std::vector<float> noise;
        std::vector<Vertex> vertices;
        std::vector<GLuint> indices;
    };

    struct NavigationResult {
        std::shared_ptr<undirected::lwGraph<Vertex3D>> graph;
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
        std::cout << "Gerando geometria." << std::endl;

        noiseConfig.seed = static_cast<unsigned int>(time(NULL));
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
                    [&geometryPtr, currentConfig, noise = std::move(result.noise), intensity]() mutable {
                        // auto graph = createVoxelGraph(noise, currentConfig.width, intensity, currentConfig.height);
                        // auto graph = createGrid2_5D(noise, currentConfig.width, intensity, currentConfig.height);
                        // auto graph = createVertexToVertex(*geometryPtr);
                        auto graph = createPolygonToPolygon(*geometryPtr);

                        auto graphPtr = std::make_shared<undirected::lwGraph<Vertex3D>>(std::move(graph));
                        auto [verticesNav, indicesNav] = getMeshFromGraph(*graphPtr, intensity, {0.26f, 0.26f, 0.30f, 0.25f});

                        return NavigationResult {
                            .graph = std::move(graphPtr),
                            .vertices = std::move(verticesNav),
                            .indices = std::move(indicesNav)
                        };
                    },
                    [&, shader](NavigationResult navData) mutable {
                        auto graphPtr = std::move(navData.graph);

                        if (navigationPtr) {
                            std::cout << "Removendo navegação antiga." << std::endl;
                            renderer.removeMesh(navigationPtr);
                        }

                        std::cout << "Adicionando nova navegação." << std::endl;
                        navigationPtr = std::make_shared<Mesh>(std::move(navData.vertices), std::move(navData.indices), shader, GL_LINES);
                        navigationPtr->translate(0.0f, 0.2f, 0.0f);
                        renderer.addMesh(navigationPtr);

                        std::cout << "Gerando caminhos." << std::endl;
                        pathPtrs.resize(algorithms.size());

                        if (algorithms.empty()) {
                            isGenerating = false;
                            return;
                        }

                        auto pendingPaths = std::make_shared<std::atomic_size_t>(algorithms.size());

                        for (size_t algorithmIndex = 0; algorithmIndex < algorithms.size(); ++algorithmIndex) {
                            Engine::runAsyncThenMain(
                                [graphPtr, algorithmIndex, algFunc = algorithms[algorithmIndex]]() {
                                    const std::size_t startId = 0;
                                    const std::size_t endId = graphPtr->getOrder() - 1;
                                    const Color color = pathColors[algorithmIndex % pathColors.size()];

                                    HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) -> double {
                                        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
                                        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
                                        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
                                        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
                                    };

                                    auto path = algFunc(*graphPtr, startId, endId, heuristic);
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
                                        pathPtr->translate(0.0f, 0.4f, 0.0f);
                                        renderer.addMesh(pathPtr);
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
    input.addKeyCallback(Key::K, KeyAction::PRESS, generate);

	LoopConfig config = {
        .mode = LoopMode::Concurrent
    }; 

    Engine::loop(config);
	Engine::terminate();
};