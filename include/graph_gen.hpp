#include <iostream>
#include <vector>
#include <tuple>
#include <fstream>
#include <graph/undirected/graph.hpp>
#include <graph/util/kruskal.hpp>

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

            if (x + 1 < width && y + 1 < height) {
                int diagRightId = (y + 1) * width + (x + 1);
                g->newEdge(currentNode, g->getVertex(diagRightId), rand() % 100 + 1);
            }

            if (y + 1 < height) {
                int bottomId = (y + 1) * width + x;
                g->newEdge(currentNode, g->getVertex(bottomId), rand() % 100 + 1);
            }

            if (x - 1 >= 0 && y + 1 < height) {
                int diagLeftId = (y + 1) * width + (x - 1);
                g->newEdge(currentNode, g->getVertex(diagLeftId), rand() % 100 + 1);
            }
        }
    }

    auto openPath = util::Kruskal::getMST(g);
    
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

    for (int y = 0; y < height; ++y) {
        
        for (int x = 0; x < width; ++x) {
            outFile << "+";

            if (x + 1 < width) {
                int currentId = y * width + x;
                int rightId = y * width + (x + 1);
                
                if (areNodesConnected(maze, currentId, rightId)) {
                    outFile << "---";
                } else {
                    outFile << "   ";
                }
            }
        }
        outFile << std::endl;

        if (y + 1 < height) {
            for (int x = 0; x < width; ++x) {
                int currentId = y * width + x;
                int bottomId = (y + 1) * width + x;

                if (areNodesConnected(maze, currentId, bottomId)) {
                    outFile << "|";
                } else {
                    outFile << " ";
                }

                if (x + 1 < width) {
                    int rightId = y * width + (x + 1);
                    int bottomRightId = (y + 1) * width + (x + 1);
                    
                    bool diag1 = areNodesConnected(maze, currentId, bottomRightId);
                    bool diag2 = areNodesConnected(maze, rightId, bottomId);

                    if (diag1 && diag2) {
                        outFile << " X ";
                    } else if (diag1) {
                        outFile << " \\ ";
                    } else if (diag2) {
                        outFile << " / ";
                    } else {
                        outFile << "   ";
                    }
                }
            }
            outFile << std::endl;
        }
    }

    outFile.close();
}