#include <iostream>
#include <map>
#include <vector>
#include <chrono>
#include <tuple>
#include <cmath>
#include <any>
#include <graph/util/a_star.hpp>
#include <graph/undirected/graph.hpp>

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

                auto [x1, y1, z1] = std::any_cast<std::tuple<int, int, int>>(P1->getData());
                auto [x2, y2, z2] = std::any_cast<std::tuple<int, int, int>>(P2->getData());
                auto [x3, y3, z3] = std::any_cast<std::tuple<int, int, int>>(P3->getData());

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
                
                auto [ax, ay, az] = std::any_cast<std::tuple<int, int, int>>(AV->getData());
                auto [nx, ny, nz] = std::any_cast<std::tuple<int, int, int>>(neighbor->getData());
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