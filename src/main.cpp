#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <vector>
#include <functional>
#include <graph/common/lw_grid.hpp>
#include <graph/common/lw_graph.hpp>
#include <graph/util/dijkstra.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/jps.hpp>
#include <graph/util/node_data.hpp>

#include "statistics.hpp"
#include "util.hpp"
#include "task.hpp"

namespace fs = std::filesystem;

struct TestConfig {
    std::string name;
    Param paramSetter;
    Stats statsSetter;
};

int main() {
    const uint repetitions = 5;
    const uint numSteps = 4;

    const uint intensity = 100;
    const float heightLimit = 2.5f;

    std::unordered_map<std::string, AlgFunc> algorithms = {
        {"A Star", util::lwAStar<Vertex3D>},
        {"A Star Mod", util::lwAStarMod<Vertex3D>},
        {"Theta Star", [heightLimit](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW heuristic) {
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
                    if (std::abs(currentZ - lastZ) > heightLimit) {
                        return false;
                    }
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
        }},
        {"JPS", [heightLimit](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW heuristic) {
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
                return std::abs(fromData.z - toData.z) <= heightLimit;
            };
            util::JumpPointSearchLw jps(grid, validator);
            auto jpsHeuristic = [](const util::Vertex2D& a, const util::Vertex2D& b) -> double {
                return std::sqrt(std::pow(a.x - b.x, 2) + std::pow(a.y - b.y, 2));
            };
            auto path = jps.find(startId, endId, jpsHeuristic);
            return reconstructPathLW(path, width);
        }}
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

        runTestsParClean(
            testName,
            algorithms,
            paramSetter,
            statsSetter,
            repetitions, numSteps,
            intensity, heightLimit
        );

        std::cout << std::endl;
    }

    return 0;
}