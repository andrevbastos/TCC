#include <iostream>
#include <map>
#include <vector>
#include <chrono>
#include <tuple>
#include <graph/util/a_star.hpp>
#include <graph/util/dijkstra.hpp>
#include <graph/util/kruskal.hpp>
#include <graph/undirected/graph.hpp>

#include "statistics.hpp"
#include "graph_gen.hpp"

const int w = 50, h = 50;
const int startX = 0, startY = 0, endX = w - 1, endY = h - 1;
const int startId = startY * w + startX, endId = endY * w + endX;
const int iterations = 10;

void warmUp();
std::vector<common::Node *> aStarMod(common::Graph *graph, int startId, int endId, util::AStar::HeuristicFunc heuristic);

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
        auto* g = createMazeGraph(h, w);
        exportMazeToTxt(g, w, h, graphsDir + "maze_" + std::to_string(i+1) + ".txt");

        auto start = std::chrono::steady_clock::now();
        auto a_start = util::AStar::getPath(g, startId, endId, util::AStar::euclideanHeuristic2D);
        auto end = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
        stats.addEntry("A Star", "Path Length", a_start.size());
        stats.addEntry("A Star", "Execution Time", duration.count());

        start = std::chrono::steady_clock::now();
        auto dijkstra = util::Dijkstra::getPathTo(g, g->getVertex(startId), g->getVertex(endId));
        end = std::chrono::steady_clock::now();
        duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
        stats.addEntry("Dijkstra", "Path Length", dijkstra.size());
        stats.addEntry("Dijkstra", "Execution Time", duration.count());

        delete g;
    }

    stats.makeCSV(outputFile);

    return 0;
};

void warmUp() 
{
    undirected::Graph warmUpGraph;
    for (int i = 0; i < 10; ++i) {
        warmUpGraph.newVertex(std::make_pair(i, 0));
    }
    for (int i = 0; i < 9; ++i) {
        warmUpGraph.newEdge(warmUpGraph.getVertex(i), warmUpGraph.getVertex(i + 1));
    }

    for (int w_i = 0; w_i < 5; ++w_i) {
        util::AStar::getPath(&warmUpGraph, 0, 9, util::AStar::euclideanHeuristic2D);
        util::Dijkstra::getPathTo(&warmUpGraph, warmUpGraph.getVertex(0), warmUpGraph.getVertex(9));
    }
};

std::vector<common::Node*> aStarMod(common::Graph *graph, int startId, int endId, util::AStar::HeuristicFunc heuristic)
{
    auto* SV = graph->getVertex(startId);
    auto* EV = graph->getVertex(endId);
    auto W = graph->getWeights();

    std::unordered_map<common::Node*, common::Node*> VM;
    std::unordered_map<common::Node*, double> CM;
    std::priority_queue<std::pair<common::Node*, double>, std::vector<std::pair<common::Node*, double>>, std::greater<>> VPQ;

    VPQ.push({SV, 0});
    VM[SV] = nullptr;
    CM[SV] = 0;

    while (!VPQ.empty()) {
        auto AV = VPQ.top().first;
        if (AV == EV) {
            std::vector<common::Node*> path;
            for (auto* node = EV; node != nullptr; node = VM[node]) {
                path.push_back(node);
            }
            std::reverse(path.begin(), path.end());
            return path;
        }
        auto NV = AV->adj();
        for (auto* neighbor : NV) {
            auto VC = W[SV->getEdgeTo(neighbor)];
            if (CM.find(neighbor) == CM.end() || VC < CM[neighbor]) {
                CM[neighbor] = VC;
                auto M = W[neighbor->getEdgeTo(AV)];
                auto NVP = CM[neighbor] + heuristic(neighbor, EV) * M;
                CM[neighbor] = NVP;
                VPQ.push({neighbor, NVP});
                VM[neighbor] = AV;
            }
        }
    }
    return {};
};