#include <iostream>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>

#include "a_star_mod.hpp"
#include "statistics.hpp"
#include "graph_gen.hpp"

const int w = 50, h = 50, d = 50;
const int startX = 0, startY = 0, startZ = 0, endX = w - 1, endY = h - 1, endZ = d - 1;
const int startId = startZ * w * h + startY * w + startX, endId = endZ * w * h + endY * w + endX;
const int iterations = 5;

void warmUp();

int main(int argc, char* argv[]) {
    srand(static_cast<unsigned>(time(NULL)));

    std::string outputFile = "./results.csv";
    if (argc > 1) {
        outputFile = argv[1];
    }
    std::string graphsDir = "./graphs/";
    if (argc > 2) {
        graphsDir = argv[2];
    }

    warmUp();
    
    Statistics stats(iterations);
    for (int i = 0; i < iterations; ++i) {
        auto* g = createMazeGraph3D(h, w, d);

        auto start = std::chrono::steady_clock::now();
        auto a_start = util::AStar::getPath(g, startId, endId, util::AStar::euclideanHeuristic3D);
        auto end = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
        stats.addEntry("A Star", "Path Length", a_start.size());
        stats.addEntry("A Star", "Execution Time", duration.count());

        start = std::chrono::steady_clock::now();
        auto a_mod = aStarMod(g, startId, endId, util::AStar::chebyshevHeuristic3D);
        end = std::chrono::steady_clock::now();
        duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
        stats.addEntry("A Star Modified", "Path Length", a_mod.size());
        stats.addEntry("A Star Modified", "Execution Time", duration.count());

        delete g;
    }

    stats.makeCSV(outputFile);

    return 0;
};

void warmUp() 
{
    undirected::Graph warmUpGraph;
    for (int i = 0; i < 10; ++i) {
        warmUpGraph.newVertex(std::make_tuple(i, 0, 0));
    }
    for (int i = 0; i < 9; ++i) {
        warmUpGraph.newEdge(warmUpGraph.getVertex(i), warmUpGraph.getVertex(i + 1));
    }

    for (int w_i = 0; w_i < 5; ++w_i) {
        util::AStar::getPath(&warmUpGraph, 0, 9, util::AStar::euclideanHeuristic3D);
        aStarMod(&warmUpGraph, 0, 9, util::AStar::chebyshevHeuristic3D);
    }
};