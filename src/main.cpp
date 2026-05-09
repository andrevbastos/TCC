#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/dijkstra.hpp>

#include "statistics.hpp"
#include "util.hpp"

namespace fs = std::filesystem;

const int repetitions = 5;
const int intensity = 50;
const float heightLimit = 5.0f;

void warmUp();

void runBattery(
    const std::string& batteryName,
    const std::string& outputCSV,
    std::function<void(NoiseConfig&, int step)> paramSetter,
    int numSteps
);

int main() {
    warmUp();

    std::cout << "\nIniciando Bateria 1: Escala (Crescimento do Grafo)..." << std::endl;
    runBattery("Escala", "../results/statistics/stats_escala.csv", [](NoiseConfig& config, int step) {
        config.width = 100 + (step * 100);
        config.height = config.width;
        config.octaves = 4;
        config.amp = 2.0f;
        config.freq = 1.5f;
        config.wave = config.width / 2;
    }, 10); // 100, 200, ..., 1000

    std::cout << "\nIniciando Bateria 2: Rugosidade (Testando Mínimos Locais)..." << std::endl;
    runBattery("Rugosidade", "../results/statistics/stats_rugosidade.csv", [](NoiseConfig& config, int step) {
        config.width = 500;
        config.height = 500;
        config.octaves = 1 + step;
        config.amp = 2.0f;
        config.freq = 1.5f;
        config.wave = 250;
    }, 12); // 1, 2, ..., 12

    std::cout << "\nIniciando Bateria 3: Frequência (Densidade de Obstáculos)..." << std::endl;
    runBattery("Frequencia", "../results/statistics/stats_frequencia.csv", [](NoiseConfig& config, int step) {
        config.width = 500;
        config.height = 500;
        config.octaves = 4;
        config.amp = 2.0f;
        config.freq = 1.0f + (step * 0.5f);
        config.wave = 250;
    }, 9);

    return 0;
}

void runBattery(
    const std::string& batteryName,
    const std::string& outputCSV,
    std::function<void(NoiseConfig&, int step)> paramSetter,
    int numSteps
) {
    Statistics stats(numSteps * repetitions);

    using HeuristicFuncLW = std::function<float(const Vertex3D&, const Vertex3D&)>;
    using AlgFunc = std::function<std::vector<int>(const common::lwGraph<Vertex3D>&, int, int, HeuristicFuncLW)>;

    std::unordered_map<std::string, AlgFunc> algorithms = {
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

    for (int step = 0; step < numSteps; ++step) {
        for (int rep = 0; rep < repetitions; ++rep) {
            NoiseConfig noiseConfig;
            paramSetter(noiseConfig, step);
            noiseConfig.seed = distSeed(gen);
            noiseConfig.exp = 1.0f;

            auto noise = generateNoiseMap(noiseConfig);
            
            std::string folderPath = "../results/noises/" + batteryName;
            fs::create_directories(folderPath);

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
    stats.saveToCSV(outputCSV);
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