#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <vector>
#include <functional>
#include <CLI11/CLI11.hpp>
#include <graph/common/lw_grid.hpp>
#include <graph/common/lw_graph.hpp>
#include <graph/util/dijkstra.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/jps.hpp>
#include <graph/util/node_data.hpp>

#include "core/statistics.hpp"
#include "core/util.hpp"
#include "core/task.hpp"

namespace fs = std::filesystem;

std::vector<AlgFunc> algorithms = {
    util::lwAStar<Vertex3D>,
    util::lwAStarMod<Vertex3D>,
    [](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW heuristic) {
        int width = graph.getOrder();
        for (int i = 0; i < graph.getOrder(); ++i) {
            if (graph.getVertexData(i).y > 0.0f) {
                width = i;
                break;
            }
        }
        std::function<bool(int, int)> los = [&](int start, int end) -> bool {
            int w = width;
            int x0 = start % w;
            int y0 = start / w;
            int x1 = end % w;
            int y1 = end / w;
            int dx = std::abs(x1 - x0);
            int dy = std::abs(y1 - y0);
            int sx = (x0 < x1) ? 1 : -1;
            int sy = (y0 < y1) ? 1 : -1;
            int err = dx - dy;
            int x = x0;
            int y = y0;
            float lastZ = graph.getVertexData(start).z;
            while (true) {
                int currentId = y * w + x;
                float currentZ = graph.getVertexData(currentId).z;
                lastZ = currentZ;
                if (x == x1 && y == y1) {
                    break;
                }
                int e2 = 2 * err;
                if (e2 > -dy) {
                    err -= dy;
                    x += sx;
                }
                if (e2 < dx) {
                    err += dx;
                    y += sy;
                }
            }
            return true;
        };
        auto path = util::lwThetaStar<Vertex3D>(graph, startId, endId, heuristic, los);
        return reconstructPathLW(path, width);
    },
    [](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW heuristic) {
        int width = graph.getOrder();
        for (int i = 0; i < graph.getOrder(); ++i) {
            if (graph.getVertexData(i).y > 0.0f) {
                width = i;
                break;
            }
        }
        int height = graph.getOrder() / width;
        std::vector<unsigned int> gridData(width * height, 1);
        common::lwGrid grid(width, height, gridData);
        auto validator = [&](int fromId, int toId) {
            const auto& fromData = graph.getVertexData(fromId);
            const auto& toData = graph.getVertexData(toId);
            return std::abs(fromData.z - toData.z) <= 1.0f;
        };
        util::JumpPointSearchLw jps(grid, validator);
        auto jpsHeuristic = [](const util::Vertex2D& a, const util::Vertex2D& b) -> double {
            return std::sqrt(std::pow(a.x - b.x, 2) + std::pow(a.y - b.y, 2));
        };
        auto path = jps.find(startId, endId, jpsHeuristic);
        return reconstructPathLW(path, width);
    }
};

std::vector<Color> pathColors = {
    {1.0f, 0.0f, 0.0f, 1.0f},
    {0.0f, 1.0f, 0.0f, 1.0f},
    {0.0f, 0.0f, 1.0f, 1.0f},
    {1.0f, 1.0f, 0.0f, 1.0f}
};

void test(uint intensity, NoiseConfig noiseConfig, const std::string& saveDir);
void stats(uint repetitions, uint steps, uint intensity, float heightLimit);

int main(int argc, char* argv[]) {   
    CLI::App app{"PATHFINDING EM MALHAS 3D, André Vitor B. de Macêdo"};

    uint repetitions = 5;
    uint steps = 4;
    uint intensity = 100;
    float heightLimit = 2.5f;
    std::string path = "../results/";
    NoiseConfig noiseConfig = {
        .width = 250,
        .height = 250,
        .wave = 50,
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
    testCmd->add_option("wave,-w,--wave", noiseConfig.wave, "Tamanho da onda")->check(CLI::PositiveNumber);
    testCmd->add_option("freq, -f,--freq", noiseConfig.freq, "Frequência do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("amp,-a,--amp", noiseConfig.amp, "Amplitude do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("exp,-e,--exp", noiseConfig.exp, "Exponente do ruído")->check(CLI::PositiveNumber);
    testCmd->add_option("seed,-s,--seed", noiseConfig.seed, "Semente do gerador de números aleatórios")->check(CLI::PositiveNumber);
    testCmd->add_option("savePath,--save", path, "Diretório para salvar os resultados")->check(CLI::ExistingDirectory);
    testCmd->callback([&]() { test(intensity, noiseConfig, path); });

    auto statsCmd = app.add_subcommand("stats", "Executa aquisição de estatísticas");
    statsCmd->add_option("repetitions", repetitions, "Número de repetições para cada teste")->check(CLI::PositiveNumber)->required();
    statsCmd->add_option("steps", steps, "Número de passos para cada teste")->check(CLI::PositiveNumber)->required();
    statsCmd->add_option("intensity", intensity, "Intensidade do ruído")->check(CLI::PositiveNumber)->required();
    statsCmd->add_option("heightLimit", heightLimit, "Limite de altura para o caminho")->check(CLI::PositiveNumber)->required();
    statsCmd->callback([&]() { stats(repetitions, steps, intensity, heightLimit); });

    CLI11_PARSE(app, argc, argv);

    return 0;
};

void stats(uint repetitions, uint steps, uint intensity, float heightLimit) {
    struct TestConfig {
        std::string name;
        Param paramSetter;
        Stats statsSetter;
    };

    std::vector<TestConfig> testConfigs = {
        {
            "Escala",
            [](int step) {
                std::random_device rd;
                std::mt19937 gen(rd());
                std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

                NoiseConfig config = {
                    .width = (step + 1) * 200,
                    .height = (step + 1) * 200,
                    .wave = (step + 1) * 50,
                    .freq = 4.0f,
                    .amp = 1.0f,
                    .exp = 1.0f,
                    .seed = distSeed(gen),
                    .octaves = 6
                };
                
                return config;
            },
            [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
                stats.addEntry(algName, "Tamanho do Mapa", (double)config.width);
            }
        }, {
            "Lacunaridade",
            [](int step) {
                std::random_device rd;
                std::mt19937 gen(rd());
                std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

                NoiseConfig config = {
                    .width = 500,
                    .height = 500,
                    .wave = 50,
                    .freq = 1.0f + (step * 0.5f),
                    .amp = 1.0f,
                    .exp = 1.0f,
                    .seed = distSeed(gen),
                    .octaves = 6
                };
                
                return config;
            },
            [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
                stats.addEntry(algName, "Frequência", (double)config.freq);
            }
        }, {
            "Persistência",
            [](int step) {
                std::random_device rd;
                std::mt19937 gen(rd());
                std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

                NoiseConfig config = {
                    .width = 500,
                    .height = 500,
                    .wave = 50,
                    .freq = 4.0f,
                    .amp = 1.0f - (step * 0.15f),
                    .exp = 1.0f,
                    .seed = distSeed(gen),
                    .octaves = 6
                };

                return config;
            },
            [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
                stats.addEntry(algName, "Amplitude", (double)config.amp);
            }
        }
    };

    for (const auto& config : testConfigs) {
        auto testName = config.name;
        auto paramSetter = config.paramSetter;
        auto statsSetter = config.statsSetter;

        // runTestsParClean(
        //     testName,
        //     algorithms,
        //     paramSetter,
        //     statsSetter,
        //     repetitions, steps,
        //     intensity, heightLimit
        // );

        std::cout << std::endl;
    }
};

void test(uint intensity, NoiseConfig noiseConfig, const std::string& saveDir) {
    using namespace ifcg;

    srand(static_cast<unsigned>(time(NULL)));

    Engine::init(1200, 800, "TCC");
    Engine::setup3D();
    
    glEnable(GL_BLEND);                                                                             
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

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

    TaskMaster tm;
    std::mutex mtx;

    std::queue<std::function<void()>> bodyQueue;

    std::shared_ptr<Mesh> geometryPtr = nullptr;
    std::shared_ptr<Mesh> navigationPtr = nullptr;

    bool isGenerating = false;
    auto generate = [&]() {
        std::cout << "Gerando geometria." << std::endl;
        {
            std::lock_guard<std::mutex> lock(mtx);
            if (isGenerating) {
                return;
            }
            isGenerating = true;
        }

        tm.addTask([&]() {
            std::cout << "Gerando mapa." << std::endl;
            noiseConfig.seed = static_cast<unsigned int>(time(NULL));
            auto noise = generateNoiseMap(noiseConfig);
            auto [verticesGeo, indicesGeo] = getMarchingCubeData(noise, noiseConfig.width, intensity, noiseConfig.height, {0.42f, 0.42f, 0.48f, 1.0f});

            std::lock_guard<std::mutex> lock(mtx);
            bodyQueue.push([&, noise = std::move(noise), verticesGeo = std::move(verticesGeo), indicesGeo = std::move(indicesGeo)]() mutable {
                {
                    std::lock_guard<std::mutex> lock(mtx);
                    if (geometryPtr) {
                        std::cout << "Removendo geometria antiga." << std::endl;
                        renderer.removeMesh(geometryPtr);
                    }
                    std::cout << "Adicionando nova geometria." << std::endl;
                    geometryPtr = std::make_shared<Mesh>(std::move(verticesGeo), std::move(indicesGeo), shader, GL_TRIANGLES);
                    renderer.addMesh(geometryPtr);
                }

                std::cout << "Gerando navegação." << std::endl;
                tm.addTask([&, noise = std::move(noise)]() {
                    auto graph = undirected::lwGraph<Vertex3D>(1);
                    {
                        std::lock_guard<std::mutex> lock(mtx);
                        // graph = createVoxelGraph(noise, noiseConfig.width, intensity, noiseConfig.height);
                        // graph = createGrid3D(noise, noiseConfig.width, intensity, noiseConfig.height);
                        // graph = createVertexToVertex(*geometryPtr);
                        graph = createPolygonToPolygon(*geometryPtr);
                    }
                    auto [verticesNav, indicesNav] = getMeshFromGraph(graph, intensity, {0.26f, 0.26f, 0.30f, 0.25f});

                    std::lock_guard<std::mutex> lock(mtx);
                    bodyQueue.push([&mtx, &navigationPtr, &renderer, &shader, verticesNav = std::move(verticesNav), indicesNav = std::move(indicesNav)]() mutable {       
                            std::lock_guard<std::mutex> lock(mtx);
                            if (navigationPtr) {
                                std::cout << "Removendo navegação antiga." << std::endl;
                                renderer.removeMesh(navigationPtr);
                            }
                            std::cout << "Adicionando nova navegação." << std::endl;
                            navigationPtr = std::make_shared<Mesh>(std::move(verticesNav), std::move(indicesNav), shader, GL_LINES);
                            navigationPtr->translate(0.0f, 0.2f, 0.0f);
                            renderer.addMesh(navigationPtr);
                    });
                });
            });
        });
    };

    generate();
    input.addKeyCallback(Key::K, KeyAction::PRESS, generate);

	LoopConfig config = {
        .loopBody = [&bodyQueue]() {
            if (!bodyQueue.empty()) {
                auto body = std::move(bodyQueue.front());
                bodyQueue.pop();
                body();
            }
        }
    }; 

    Engine::loop(config);
	Engine::terminate();
};
