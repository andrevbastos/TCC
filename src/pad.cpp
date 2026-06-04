// rodar com `~/facul/programacao-de-alto-desempenho/benchmark.sh`

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <vector>
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

int main(int argc, char* argv[]) {
    if (argc < 2 || (argv[1] != std::string("paralelo") && argv[1] != std::string("sequencial"))) {
        std::cerr << "Uso: " << argv[0] << " [paralelo | sequencial]" << std::endl;
        return 1;
    }

    std::string mode = argv[1];

    const uint repetitions = 20;
    const uint numSteps = 8;

    const uint intensity = 100;
    const float heightLimit = 5.0f;

    std::unordered_map<std::string, AlgFunc> algorithms = {
        {"Dijkstra", [](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW) {
            return util::lwAStar<Vertex3D>(graph, startId, endId, [](const Vertex3D&, const Vertex3D&) { return 0.0f; });
        }},
        {"A Star Mod", util::lwAStarMod<Vertex3D>},
        {"A Star", util::lwAStar<Vertex3D>}
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
        }
    };

    for (const auto& config : testConfigs) {
        auto testName = config.name;
        auto paramSetter = config.paramSetter;
        auto statsSetter = config.statsSetter;

        if (mode == "paralelo") {
            std::cout << "Iniciando testes paralelizados de " << testName << "... " << std::flush;
            
            auto startTime = std::chrono::steady_clock::now();
            runTestsParClean(
                testName,
                algorithms,
                paramSetter,
                statsSetter,
                repetitions, numSteps,
                intensity, heightLimit
            );
            auto endTime = std::chrono::steady_clock::now();
            std::chrono::duration<double> elapsed = endTime - startTime;
            double execTime = elapsed.count();
            
            std::cout << "Concluídos em " << execTime << "s" << std::endl;
        } else {
            std::cout << "Iniciando testes sequenciais de " << testName << "..." << std::flush;
            
            auto startTime = std::chrono::steady_clock::now();
            runTestsSeqClean(
                testName,
                algorithms,
                paramSetter,
                statsSetter,
                repetitions, numSteps,
                intensity, heightLimit
            );
            auto endTime = std::chrono::steady_clock::now();
            std::chrono::duration<double> elapsed = endTime - startTime;
            double execTime = elapsed.count();

            std::cout << "Concluídos em " << execTime << "s" << std::endl;
        }
    }
    
    return 0;
}