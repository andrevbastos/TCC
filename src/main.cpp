#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <graph/common/lw_grid.hpp>
#include <graph/common/lw_graph.hpp>
#include <graph/util/dijkstra.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/jps.hpp>

#include "statistics.hpp"
#include "util.hpp"

namespace fs = std::filesystem;

const int repetitions = 10;
const int intensity = 100;
const float heightLimit = 2.0f;

void warmUp();

void runTests();
void gridBattery(
    const std::string& batteryName,
    const std::string& outputCSV,
    std::function<void(NoiseConfig&, int step)> paramSetter,
    std::function<void(Statistics&, const std::string&, NoiseConfig&)> specificStat,
    int numSteps
);
void terrainBattery(
    const std::string& batteryName,
    const std::string& outputCSV,
    std::function<void(NoiseConfig&, int step)> paramSetter,
    std::function<void(Statistics&, const std::string&, NoiseConfig&)> specificStat,
    int numSteps
);

int main() {
    runTests();

    return 0;
}

void runTests() {
    warmUp();

    // Variação de Parâmetros de Grid
    std::cout << "Iniciando Bateria de Grid: Escala (Crescimento do Grafo)..." << std::endl;
    gridBattery("Densidade", "../results/grids/stats_densidade.csv", [](NoiseConfig& config, int step) {
        config.width = 100 + (step * 100);
        config.height = config.width;
        config.wave = config.width / 2;
    }, [](Statistics& stats, const std::string& group, NoiseConfig& config) {
        stats.addEntry(group, "Tamanho", (double)config.width);
    }, 10);

    std::cout << "\nIniciando Bateria de Grid 2: Frequência (Densidade de Obstáculos)..." << std::endl;
    gridBattery("Frequencia", "../results/grids/stats_frequencia.csv", [](NoiseConfig& config, int step) {
        config.freq = 1.0f + (step * 0.5f);
        config.octaves *= (1.0f + (step * 0.1f));
    }, [](Statistics& stats, const std::string& group, NoiseConfig& config) {
        stats.addEntry(group, "Frequência", (double)config.freq);
        stats.addEntry(group, "Octaves", (double)config.octaves);
    }, 10);

    // Variação de Parâmetros do Terreno
    std::cout << "\nIniciando Bateria de Terreno 1: Escala (Crescimento do Grafo)..." << std::endl;
    terrainBattery("Escala", "../results/terrain/stats_escala.csv", [](NoiseConfig& config, int step) {
        config.width = 100 + (step * 100);
        config.height = config.width;
        config.wave = config.width / 2;
    }, [](Statistics& stats, const std::string& group, NoiseConfig& config) {
        stats.addEntry(group, "Tamanho", (double)config.width);
    }, 10);
    
    std::cout << "\nIniciando Bateria de Terreno 2: Frequência (Densidade de Obstáculos)..." << std::endl;
    terrainBattery("Frequencia", "../results/terrain/stats_frequencia.csv", [](NoiseConfig& config, int step) {
        config.freq = 1.0f + (step * 0.5f);
        config.octaves *= (1.0f + (step * 0.1f));
    }, [](Statistics& stats, const std::string& group, NoiseConfig& config) {
        stats.addEntry(group, "Frequência", (double)config.freq);
        stats.addEntry(group, "Octaves", (double)config.octaves);
    }, 10);    
}

void gridBattery(
    const std::string& batteryName,
    const std::string& outputCSV,
    std::function<void(NoiseConfig&, int step)> paramSetter,
    std::function<void(Statistics&, const std::string&, NoiseConfig&)> specificStat,
    int numSteps
) {
    Statistics stats(numSteps * repetitions);

    using HeuristicFuncLW = std::function<float(const Vertex3D&, const Vertex3D&)>;
    using AlgFunc = std::function<std::vector<int>(const common::lwGraph<Vertex3D>&, int, int, HeuristicFuncLW)>;

    AlgFunc dijkstra = [](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW) {
        return util::lwAStar<Vertex3D>(graph, startId, endId, [](const Vertex3D&, const Vertex3D&) { return 0.0f; });
    };

    std::unordered_map<std::string, AlgFunc> algorithms = {
        {"Dijkstra", dijkstra},
        {"A Star", util::lwAStar<Vertex3D>},
        {"A Star Modified", util::lwAStarMod<Vertex3D>},
        {"JPS", AlgFunc{}}
    };

    int nosAvaliados {0};
    auto trackingHeuristic = [&](const auto& a, const auto& b) -> float {
        nosAvaliados++;
        return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
    };
    
    auto jpsHeuristic = [&](const util::Vertex2D& a, const util::Vertex2D& b) {
        nosAvaliados++;
        return std::abs(a.x - b.x) + std::abs(a.y - b.y);
    };

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

    std::string folderPath = "../results/grids/" + batteryName;
    fs::create_directories(folderPath);

    for (int step = 0; step < numSteps; ++step) {
        for (int rep = 0; rep < repetitions; ++rep) {
            // Config melhor para garantir que vá ter um caminho ponta a ponta
            NoiseConfig noiseConfig;
            noiseConfig.width = 500;
            noiseConfig.height = 500;
            noiseConfig.octaves = 4;
            noiseConfig.wave = 250;
            noiseConfig.freq = 3.0f;
            noiseConfig.amp = 1.5f;
            noiseConfig.exp = 1.0f;
            noiseConfig.seed = distSeed(gen);
            
            paramSetter(noiseConfig, step);

            auto noise = generateNoiseMap(noiseConfig);
            std::vector<unsigned int> binaryGrid(noise.size());
            for (int y = 0; y < noiseConfig.height; ++y) {
                for (int x = 0; x < noiseConfig.width; ++x) {
                    int i = y * noiseConfig.width + x;
                    bool isBorder = (x == 0 || x == (noiseConfig.width - 1) || y == 0 || y == (noiseConfig.height - 1));
                    binaryGrid[i] = isBorder ? 1 : ((noise[i] > 0.55f) ? 0 : 1);
                    noise[i] = (float)binaryGrid[i];
                }
            }

            std::string fileName = "step" + std::to_string(step + 1) + "_rep" + std::to_string(rep + 1) + ".png";
            saveNoiseAsPNG(folderPath + "/" + fileName, noise, noiseConfig.width, noiseConfig.height);

            auto graph = createlwGraphFromNoise(noise, noiseConfig.width, noiseConfig.height, heightLimit, intensity);

            common::lwGrid grid(noiseConfig.width, noiseConfig.height, binaryGrid);
            util::JumpPointSearchLw jps(grid);

            if (!graph) {
                std::cout << " Erro: Não foi possível carregar o mapa!" << std::endl;
                continue;
            }

            int startId = 0;
            int endId = noiseConfig.width * noiseConfig.height - 1;

            std::cout << "\r" << batteryName << " - Passo " << step + 1 << "/" << numSteps << " (Rep " << rep + 1 << "/" << repetitions << ")" << std::flush;

            for (const auto& alg : algorithms) {
                if (alg.first == "Dijkstra");
                nosAvaliados = 0;
                
                std::vector<int> path;

                auto startTime = std::chrono::high_resolution_clock::now();
                if (alg.first == "JPS") {
                    path = jps.find(startId, endId, jpsHeuristic);
                } else {
                    path = alg.second(*graph, startId, endId, trackingHeuristic);
                }
                auto endTime = std::chrono::high_resolution_clock::now();
                
                std::chrono::duration<double, std::milli> elapsed = endTime - startTime;
                double execTime = elapsed.count();
                double pathCost = (double)calculatePathCostLW(path, *graph);

                stats.addEntry(alg.first, "Tempo de Execução", execTime);
                stats.addEntry(alg.first, "Custo do Caminho", pathCost);
                stats.addEntry(alg.first, "Número de Nós Expandidos", (double)nosAvaliados);
                
                specificStat(stats, alg.first, noiseConfig);
            }

            graph.reset();
        }
    }

    std::cout << " concluído!" << std::endl;
    stats.saveToCSV(folderPath + "/stats.csv");
}

void terrainBattery(
    const std::string& batteryName,
    const std::string& outputCSV,
    std::function<void(NoiseConfig&, int step)> paramSetter,
    std::function<void(Statistics&, const std::string&, NoiseConfig&)> specificStat,
    int numSteps
) {
    Statistics stats(numSteps * repetitions);

    using HeuristicFuncLW = std::function<float(const Vertex3D&, const Vertex3D&)>;
    using AlgFunc = std::function<std::vector<int>(const common::lwGraph<Vertex3D>&, int, int, HeuristicFuncLW)>;

    AlgFunc dijkstra = [](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW) {
        return util::lwAStar<Vertex3D>(graph, startId, endId, [](const Vertex3D&, const Vertex3D&) { return 0.0f; });
    };

    std::unordered_map<std::string, AlgFunc> algorithms = {
        {"Dijkstra", dijkstra},
        {"A Star", util::lwAStar<Vertex3D>},
        {"A Star Modified", util::lwAStarMod<Vertex3D>}
    };

    int nosAvaliados {0};
    auto trackingHeuristic = [&](const auto& a, const auto& b) -> float {
        nosAvaliados++;
        return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
    };

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

    std::string folderPath = "../results/terrain/" + batteryName;
    fs::create_directories(folderPath);

    for (int step = 0; step < numSteps; ++step) {
        for (int rep = 0; rep < repetitions; ++rep) {
            NoiseConfig noiseConfig;
            noiseConfig.width = 500;
            noiseConfig.height = 500;
            noiseConfig.octaves = 4;
            noiseConfig.wave = 250;
            noiseConfig.freq = 1.0f;
            noiseConfig.amp = 2.0f;
            noiseConfig.exp = 1.0f;
            noiseConfig.seed = distSeed(gen);
            
            paramSetter(noiseConfig, step);

            auto noise = generateNoiseMap(noiseConfig);
            

            std::string fileName = "step" + std::to_string(step + 1) + "_rep" + std::to_string(rep + 1) + ".png";
            saveNoiseAsPNG(folderPath + "/" + fileName, noise, noiseConfig.width, noiseConfig.height);

            auto graph = createlwGraphFromNoise(noise, noiseConfig.width, noiseConfig.height, heightLimit, intensity);

            if (!graph) {
                std::cout << " Erro: Não foi possível carregar o mapa!" << std::endl;
                continue;
            }

            int startId = 0;
            int endId = noiseConfig.width * noiseConfig.height - 1;

            std::cout << "\r" << batteryName << " - Passo " << step + 1 << "/" << numSteps << " (Rep " << rep + 1 << "/" << repetitions << ")" << std::flush;

            for (const auto& alg : algorithms) {
                nosAvaliados = 0;

                auto startTime = std::chrono::high_resolution_clock::now();
                auto path = alg.second(*graph, startId, endId, trackingHeuristic);
                auto endTime = std::chrono::high_resolution_clock::now();
                
                std::chrono::duration<double, std::milli> elapsed = endTime - startTime;
                double execTime = elapsed.count();
                double pathCost = (double)calculatePathCostLW(path, *graph);

                stats.addEntry(alg.first, "Tempo de Execução", execTime);
                stats.addEntry(alg.first, "Custo do Caminho", pathCost);
                stats.addEntry(alg.first, "Número de Nós Expandidos", (double)nosAvaliados);
                
                stats.addEntry(alg.first, "Width", (double)noiseConfig.width);
                stats.addEntry(alg.first, "Octaves", (double)noiseConfig.octaves);
                stats.addEntry(alg.first, "Freq", (double)noiseConfig.freq);
            }

            graph.reset();
        }
    }

    std::cout << " concluído!" << std::endl;
    stats.saveToCSV(folderPath + "/stats.csv");
}

void warmUp() {
    undirected::Graph warmUpGraph;
    for (int i = 0; i < 10; ++i) {
        warmUpGraph.newVertex(std::make_tuple(i, 0, 0));
    }
    for (int i = 0; i < 9; ++i) {
        warmUpGraph.newEdge(warmUpGraph.getVertex(i), warmUpGraph.getVertex(i + 1));
    }

    for (int w_i = 0; w_i < 5; ++w_i) {
        util::AStar(&warmUpGraph, 0, 9, util::heuristics::euclideanHeuristic3D);
        util::AStarMod(&warmUpGraph, 0, 9, util::heuristics::chebyshevHeuristic3D);
    }
};