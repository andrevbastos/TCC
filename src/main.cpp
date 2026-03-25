#include <iostream>
#include <map>
#include <vector>
#include <chrono>
#include <tuple>
#include <cmath>
#include <any>
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

        start = std::chrono::steady_clock::now();
        auto a_mod = aStarMod(g, startId, endId, util::AStar::chebyshevHeuristic2D);
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
    
    std::priority_queue<std::pair<double, common::Node*>, std::vector<std::pair<double, common::Node*>>, std::greater<>> VPQ;

    VPQ.push({0.0, SV});
    VM[SV] = nullptr;
    CM[SV] = 0.0;

    while (!VPQ.empty()) {
        auto AV = VPQ.top().second;
        VPQ.pop();

        if (AV == EV) {
            std::vector<common::Node*> VL;
            for (auto* node = EV; node != nullptr; node = VM[node]) {
                VL.push_back(node);
            }
            std::reverse(VL.begin(), VL.end());

            if (VL.size() <= 2) return VL;

            std::vector<common::Node*> PL;
            PL.push_back(VL[0]);

            for (size_t i = 1; i < VL.size() - 1; ++i) {
                common::Node* P1 = PL.back();
                common::Node* P2 = VL[i];
                common::Node* P3 = VL[i+1];

                auto [x1, y1] = std::any_cast<std::tuple<int, int>>(P1->getData());
                auto [x2, y2] = std::any_cast<std::tuple<int, int>>(P2->getData());
                auto [x3, y3] = std::any_cast<std::tuple<int, int>>(P3->getData());

                long long crossProduct = 1LL * (x2 - x1) * (y3 - y2) - 1LL * (y2 - y1) * (x3 - x2);
                bool isCollinear = (crossProduct == 0);

                if (!isCollinear) {
                    PL.push_back(P2);
                }
            }
            
            PL.push_back(VL.back());
            return PL; 
        }

        auto NV = AV->adj();
        for (auto* neighbor : NV) {
            auto VC = CM[AV] + W[AV->getEdgeTo(neighbor)];
            
            if (CM.find(neighbor) == CM.end() || VC < CM[neighbor]) {
                CM[neighbor] = VC;
                
                auto [ax, ay] = std::any_cast<std::tuple<int, int>>(AV->getData());
                auto [nx, ny] = std::any_cast<std::tuple<int, int>>(neighbor->getData());
                bool isDiagonal = (ax != nx) && (ay != ny);
                
                double M = isDiagonal ? std::sqrt(2.0) : 1.0; 
                auto NVP = VC + heuristic(neighbor, EV) * M;
                
                VPQ.push({NVP, neighbor});
                VM[neighbor] = AV;
            }
        }
    }
    
    return {};
}