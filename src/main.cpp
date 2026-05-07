#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/dijkstra.hpp>

#include "statistics.hpp"
#include "util.hpp"

namespace fs = std::filesystem;

const int iterations = 10;

void warmUp();

int main() {
    warmUp();

    int intensity = 50;
    Statistics stats(iterations);
    std::string path = "../resources/grayscales";
    
    using HeuristicFuncLW = std::function<float(const Vertex3D&, const Vertex3D&)>;
    using AlgFunc = std::function<std::vector<int>(const common::lwGraph<Vertex3D>&, int, int, HeuristicFuncLW)>;

    std::unordered_map<std::string, AlgFunc> algorithms = {
        {"A Star", util::lwAStar<Vertex3D>},
        {"A Star Modified", util::lwAStarMod<Vertex3D>}
    };

    int nosAvaliados = 0;
    auto trackingHeuristic = [&](const auto& a, const auto& b) -> float {
        nosAvaliados++;
        return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
    };

    for (const auto& entry : fs::directory_iterator(path)) {
        if (entry.path().extension() != ".png") continue;

        std::cout << entry.path().filename().string() << std::flush;
        
        auto [g, startId, endId] = createLwGraphFromHeightmap(entry.path().c_str(), intensity, (float)intensity / 10.0f);
        
        if (!g) {
            std::cout << " Erro: Não foi possível carregar o mapa!" << std::endl;
            continue;
        }

        if (startId == -1 || endId == -1) {
            std::cout << " Erro: Fora dos limites!" << std::endl;
            g.reset();
            continue;
        }
        
        std::cout << ":" << std::endl;
        
        for (const auto& alg : algorithms) {
            nosAvaliados = 0;

            std::cout << "\t" << alg.first << "..." << std::flush;

            auto startTime = std::chrono::high_resolution_clock::now();
            
            auto path = alg.second(*g, startId, endId, trackingHeuristic);
            
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double> elapsed = endTime - startTime;

            stats.addEntry(alg.first, "Tempo de Execução", elapsed.count());
            stats.addEntry(alg.first, "Custo do Caminho", calculatePathCostLW(path, *g));
            stats.addEntry(alg.first, "Número de Nós Expandidos", nosAvaliados);

            std::cout << " concluído!" << std::endl;
            std::cout << "\tTempo de Execução: " << elapsed.count() << " segundos" << std::endl;
            std::cout << "\tCusto do Caminho: " << calculatePathCostLW(path, *g) << std::endl;
            std::cout << "\tNúmero de Nós Expandidos: " << nosAvaliados << "\n" << std::endl;
        }

        g.reset();
    }

    stats.makeCSV("../results/statistics");

    return 0;
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