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

int main() {
    std::cout << "Iniciando testes paralelos...\n" << std::endl;

    const uint repetitions = 50;
    const uint numSteps = 4;

    const uint intensity = 100;
    const float heightLimit = 5.0f;

    auto startTime = std::chrono::high_resolution_clock::now();
    runTestsPar(
        "Escala",
        {
            {"A Star", util::lwAStar<Vertex3D>}
        },
        [](int step) {
            std::random_device rd;
            std::mt19937 gen(rd());
            std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);
            
            int currentSize = (step + 1) * 125;

            NoiseConfig config = {
                .width = currentSize,
                .height = currentSize,
                .wave = currentSize / 4,
                .freq = 1.0f,
                .amp = 1.0f,
                .exp = 1.0f,
                .seed = distSeed(gen),
                .octaves = 4
            };

            return config;
        },
        [](Statistics& stats, const std::string& group, const NoiseConfig& config) {
            stats.addEntry(group, "Tamanho", (double)config.width);
        },
        repetitions, numSteps,
        intensity, heightLimit
    );
    auto endTime = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = endTime - startTime;
    double execTime = elapsed.count();

    std::cout << "Concluídos em " << execTime << " s." << std::endl;

    std::cout << "\nIniciando testes sequenciais..." << std::endl;

    startTime = std::chrono::high_resolution_clock::now();
    runTestsSeq(
        "Escala",
        {
            {"A Star", util::lwAStar<Vertex3D>}
        },
        [](int step) {
            std::random_device rd;
            std::mt19937 gen(rd());
            std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);
            
            int currentSize = (step + 1) * 125;

            NoiseConfig config = {
                .width = currentSize,
                .height = currentSize,
                .wave = currentSize / 4,
                .freq = 1.0f,
                .amp = 1.0f,
                .exp = 1.0f,
                .seed = distSeed(gen),
                .octaves = 4
            };

            return config;
        },
        [](Statistics& stats, const std::string& group, const NoiseConfig& config) {
            stats.addEntry(group, "Tamanho", (double)config.width);
        },
        repetitions, numSteps,
        intensity, heightLimit
    );
    endTime = std::chrono::high_resolution_clock::now();
    elapsed = endTime - startTime;
    execTime = elapsed.count();

    std::cout << "\nConcluídos em " << execTime << " s." << std::endl;

    return 0;
}