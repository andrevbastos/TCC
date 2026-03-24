#include <iostream>
#include <random>
#include <vector>
#include <ctime>

#include "graph/graph.hpp"

std::vector<common::Node *> aStarMod(common::Graph *graph, int startId, int endId, util::AStar::HeuristicFunc heuristic);

std::vector<common::Node*> objects = {};
int main() {
    srand(static_cast<unsigned>(time(NULL)));

    auto* g = new undirected::Graph();

    int h, w;
    std::cout << "Largura: ";
    std::cin >> w;
    std::cout << "Altura: ";
    std::cin >> h;
    std::cout << std::endl;

    const int totalNodes = w * h;

    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            auto newNode = g->newVertex(std::make_pair(x, y));
        }
    }

    std::vector<bool> obstacleGrid(totalNodes, false);
    for (int i = 0; i < totalNodes; ++i) {
        int roll = rand() % 100;
        if (roll < 20) {
            obstacleGrid[i] = true;
            objects.push_back(g->getVertex(i));
        }
    }

    int startX, startY, endX, endY;
    std::cout << "Coordenadas de início (x y): ";
    std::cin >> startX >> startY;
    std::cout << "Coordenadas de fim (x y): ";
    std::cin >> endX >> endY;
    
    int startId = startY * w + startX;
    int endId = endY * w + endX;

    if (startId < 0 || startId >= totalNodes || endId < 0 || endId >= totalNodes) {
        std::cerr << "Erro: Coordenadas fora dos limites." << std::endl;
        delete g;
        return 1;
    }

    obstacleGrid[startId] = false;
    obstacleGrid[endId] = false;

    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            int currentId = y * w + x;
            if (obstacleGrid[currentId]) continue; 

            common::Node* currentNode = g->getVertex(currentId);

            if (x + 1 < w) {
                int rightId = y * w + (x + 1);
                if (!obstacleGrid[rightId]) {
                    g->newEdge(currentNode, g->getVertex(rightId));
                }
            }

            if (y + 1 < h) {
                int bottomId = (y + 1) * w + x;
                if (!obstacleGrid[bottomId]) {
                    g->newEdge(currentNode, g->getVertex(bottomId));
                }
            }
        }
    }

    std::cout << "Buscando caminho de (" << startX << "," << startY << ") para (" << endX << "," << endY << ")..." << std::endl;
    auto path = util::AStar::getPath(g, startId, endId, util::AStar::euclideanHeuristic2D);
    auto VL = aStarMod(g, startId, endId, util::AStar::euclideanHeuristic2D);
    std::vector<common::Node*> PL;
    if (!VL.empty()) {
        PL.push_back(VL[0]);
        for (size_t i = 1; i < VL.size()-1; ++i) {
            auto P1 = PL.back();
            auto P2 = VL[i];
            auto P3 = VL[i+1];
            if (P2->adjTo(P1) && P2->adjTo(P3) || g->getWeights()[P1->getEdgeTo(P2)] != 1) {
                PL.push_back(P2);
            }
        }
    }
    std::reverse(PL.begin(), PL.end());

    std::cout << "Caminho de (" << startX << "," << startY << ") para (" << endX << "," << endY << "):" << std::endl;
    for (const auto& node : path) {
        auto [row, col] = std::any_cast<std::pair<int, int>>(node->getData());
        std::cout << "(" << row << "," << col << ") ";
    }
    std::cout << std::endl;

    std::vector<bool> isPath(totalNodes, false);
    for (const auto& node : path) {
        isPath[node->getId()] = true;
    }

    std::cout << "\nGrid:\n";
    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            int currentId = y * w + x;
            if (obstacleGrid[currentId]) {
                std::cout << "# ";
            } else if (isPath[currentId]) {
                std::cout << "O ";
            } else {
                std::cout << ". ";
            }
        }
        std::cout << "\n";
    }
    
    delete g;
    return 0;
}

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
