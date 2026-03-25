#include <iostream>
#include <vector>
#include <tuple>
#include <fstream>
#include <graph/undirected/graph.hpp>
#include <graph/util/kruskal.hpp>

bool areNodesConnected(common::Graph* maze, int idA, int idB);

common::Graph* createObstacleGraph(int obstaclePercentage, int width, int height)
{
    srand(static_cast<unsigned>(time(NULL)));

    auto* g = new undirected::Graph();
    std::vector<common::Node*> objects = {};

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            g->newVertex(std::make_tuple(x, y));
        }
    }

    const int totalNodes = width * height;

    std::vector<bool> obstacleGrid(totalNodes, false);
    for (int i = 0; i < totalNodes; ++i) {
        int roll = rand() % 100;
        if (roll < 20) {
            obstacleGrid[i] = true;
            objects.push_back(g->getVertex(i));
        }
    }

    const int startX = 0, startY = 0, endX = width - 1, endY = height - 1;
    const int startId = startY * width + startX, endId = endY * width + endX;

    obstacleGrid[startId] = false;
    obstacleGrid[endId] = false;

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            if (obstacleGrid[currentId]) continue; 

            common::Node* currentNode = g->getVertex(currentId);

            if (x + 1 < width) {
                int rightId = y * width + (x + 1);
                if (!obstacleGrid[rightId]) {
                    g->newEdge(currentNode, g->getVertex(rightId));
                }
            }

            if (y + 1 < height) {
                int bottomId = (y + 1) * width + x;
                if (!obstacleGrid[bottomId]) {
                    g->newEdge(currentNode, g->getVertex(bottomId));
                }
            }
        }
    }

    return g;
};

common::Graph* createMazeGraph(int height, int width)
{
    auto* g = new undirected::Graph();

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            g->newVertex(std::make_tuple(x, y));
        }
    }

    auto result = g->clone();

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            common::Node* currentNode = g->getVertex(currentId);

            if (x + 1 < width) {
                int rightId = y * width + (x + 1);
                g->newEdge(currentNode, g->getVertex(rightId), rand() % 100 + 1);
            }

            if (y + 1 < height) {
                int bottomId = (y + 1) * width + x;
                g->newEdge(currentNode, g->getVertex(bottomId), rand() % 100 + 1);
            }
        }
    }

    auto openPath = util::Kruskal::getMST(g);
    auto w = g->getWeights();
    for (auto* edge : openPath) {
        result->newEdge(edge->getFirstNode()->getId(), edge->getSecondNode()->getId());
    }

    delete g;
    return result;
};

void exportMazeToTxt(common::Graph* maze, int width, int height, const std::string& filename) {
    std::ofstream outFile(filename);

    if (!outFile.is_open()) {
        std::cerr << "Erro ao criar/abrir o arquivo: " << filename << std::endl;
        return;
    }

    for (int x = 0; x < width; ++x) outFile << "+---";
    outFile << "+" << std::endl;

    for (int y = 0; y < height; ++y) {
        outFile << "|"; 
        
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            outFile << "   ";

            if (x + 1 < width) {
                int rightId = y * width + (x + 1);
                if (areNodesConnected(maze, currentId, rightId)) {
                    outFile << " "; 
                } else {
                    outFile << "|"; 
                }
            } else {
                outFile << "|";
            }
        }
        outFile << std::endl;

        for (int x = 0; x < width; ++x) {
            outFile << "+";
            int currentId = y * width + x;
            
            if (y + 1 < height) {
                int bottomId = (y + 1) * width + x;
                if (areNodesConnected(maze, currentId, bottomId)) {
                    outFile << "   "; 
                } else {
                    outFile << "---"; 
                }
            } else {
                outFile << "---";
            }
        }
        outFile << "+" << std::endl;
    }

    outFile.close();
}

bool areNodesConnected(common::Graph* maze, int idA, int idB) {
    common::Node* nodeA = maze->getVertex(idA);
    if (!nodeA) return false;

    for (auto* neighbor : nodeA->adj()) {
        if (neighbor->getId() == idB) {
            return true;
        }
    }
    return false;
};