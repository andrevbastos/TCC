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

common::Graph* createMazeGraph2D(int height, int width)
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


common::Graph* createMazeGraph3D(int height, int width, int depth)
{
    auto* g = new undirected::Graph();

    for (int z = 0; z < depth; ++z) {
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                g->newVertex(std::make_tuple(x, y, z));
            }
        }
    }

    auto result = g->clone();

    for (int z = 0; z < depth; ++z) {
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                int currentId = x + y * width + z * width * height;
                common::Node* currentNode = g->getVertex(currentId);

                // Right
                if (x + 1 < width) {
                    int rightId = (y * width + (x + 1)) + z * width * height;
                    g->newEdge(currentNode, g->getVertex(rightId), rand() % 100 + 1);
                }
                // Bottom
                if (y + 1 < height) {
                    int bottomId = (y + 1) * width + x + z * width * height;
                    g->newEdge(currentNode, g->getVertex(bottomId), rand() % 100 + 1);
                }
                // Front
                if (z + 1 < depth) {
                    int frontId = x + y * width + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(frontId), rand() % 100 + 1);
                }
                // Bottom Right
                if (x + 1 < width && y + 1 < height) {
                    int diagRightId = ((y + 1) * width + (x + 1)) + z * width * height;
                    g->newEdge(currentNode, g->getVertex(diagRightId), rand() % 100 + 1);
                }
                // Bottom Left
                if (x - 1 >= 0 && y + 1 < height) {
                    int diagLeftId = ((y + 1) * width + (x - 1)) + z * width * height;
                    g->newEdge(currentNode, g->getVertex(diagLeftId), rand() % 100 + 1);
                }
                // Front Right
                if (x + 1 < width && z + 1 < depth) {
                    int diagFrontRightId = (y * width + (x + 1)) + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(diagFrontRightId), rand() % 100 + 1);
                }
                // Front Left
                if (x - 1 >= 0 && z + 1 < depth) {
                    int diagFrontLeftId = (y * width + (x - 1)) + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(diagFrontLeftId), rand() % 100 + 1);
                }
                // Front Bottom
                if (y + 1 < height && z + 1 < depth) {
                    int diagFrontBottomId = ((y + 1) * width + x) + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(diagFrontBottomId), rand() % 100 + 1);
                }
                // Front Top
                if (y - 1 >= 0 && z + 1 < depth) {
                    int diagFrontTopId = ((y - 1) * width + x) + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(diagFrontTopId), rand() % 100 + 1);
                }
                // Front Bottom Right
                if (x + 1 < width && y + 1 < height && z + 1 < depth) {
                    int diagFrontBottomRightId = ((y + 1) * width + (x + 1)) + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(diagFrontBottomRightId), rand() % 100 + 1);
                }
                // Front Bottom Left
                if (x - 1 >= 0 && y + 1 < height && z + 1 < depth) {
                    int diagFrontBottomLeftId = ((y + 1) * width + (x - 1)) + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(diagFrontBottomLeftId), rand() % 100 + 1);
                }
                // Front Top Right
                if (x + 1 < width && y - 1 >= 0 && z + 1 < depth) {
                    int diagFrontTopRightId = ((y - 1) * width + (x + 1)) + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(diagFrontTopRightId), rand() % 100 + 1);
                }
                // Front Top Left
                if (x - 1 >= 0 && y - 1 >= 0 && z + 1 < depth) {
                    int diagFrontTopLeftId = ((y - 1) * width + (x - 1)) + (z + 1) * width * height;
                    g->newEdge(currentNode, g->getVertex(diagFrontTopLeftId), rand() % 100 + 1);
                }
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

common::Graph* createGridMap(int h, int w, int d) {
    auto* grid = new undirected::Graph();

    for (int z = 0; z < d; ++z) {
        for (int y = 0; y < h; ++y) {
            for (int x = 0; x < w; ++x) {
                grid->newVertex(std::make_tuple(x, y, z));
            }
        }
    }

    for (int z = 0; z < d; ++z) {
        for (int y = 0; y < h; ++y) {
            for (int x = 0; x < w; ++x) {
                int currentId = x + y * w + z * w * h;
                common::Node* currentNode = grid->getVertex(currentId);

                // Right
                if (x + 1 < w) {
                    int rightId = (y * w + (x + 1)) + z * w * h;
                    grid->newEdge(currentNode, grid->getVertex(rightId), rand() % 100 + 1);
                }
                // Bottom
                if (y + 1 < h) {
                    int bottomId = (y + 1) * w + x + z * w * h;
                    grid->newEdge(currentNode, grid->getVertex(bottomId), rand() % 100 + 1);
                }
                // Front
                if (z + 1 < d) {
                    int frontId = x + y * w + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid->getVertex(frontId), rand() % 100 + 1);
                }
                // Bottom Right
                if (x + 1 < w && y + 1 < h) {
                    int diagRightId = ((y + 1) * w + (x + 1)) + z * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagRightId), rand() % 100 + 1);
                }
                // Bottom Left
                if (x - 1 >= 0 && y + 1 < h) {
                    int diagLeftId = ((y + 1) * w + (x - 1)) + z * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagLeftId), rand() % 100 + 1);
                }
                // Front Right
                if (x + 1 < w && z + 1 < d) {
                    int diagFrontRightId = (y * w + (x + 1)) + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagFrontRightId), rand() % 100 + 1);
                }
                // Front Left
                if (x - 1 >= 0 && z + 1 < d) {
                    int diagFrontLeftId = (y * w + (x - 1)) + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagFrontLeftId), rand() % 100 + 1);
                }
                // Front Bottom
                if (y + 1 < h && z + 1 < d) {
                    int diagFrontBottomId = ((y + 1) * w + x) + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid ->getVertex(diagFrontBottomId), rand() % 100 + 1);
                }
                // Front Top
                if (y - 1 >= 0 && z + 1 < d) {
                    int diagFrontTopId = ((y - 1) * w + x) + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagFrontTopId), rand() % 100 + 1);
                }
                // Front Bottom Right
                if (x + 1 < w && y + 1 < h && z + 1 < d) {
                    int diagFrontBottomRightId = ((y + 1) * w + (x + 1)) + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagFrontBottomRightId), rand() % 100 + 1);
                }
                // Front Bottom Left
                if (x - 1 >= 0 && y + 1 < h && z + 1 < d) {
                    int diagFrontBottomLeftId = ((y + 1) * w + (x - 1)) + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagFrontBottomLeftId), rand() % 100 + 1);
                }
                // Front Top Right
                if (x + 1 < w && y - 1 >= 0 && z + 1 < d) {
                    int diagFrontTopRightId = ((y - 1) * w + (x + 1)) + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagFrontTopRightId), rand() % 100 + 1);
                }
                // Front Top Left
                if (x - 1 >= 0 && y - 1 >= 0 && z + 1 < d) {
                    int diagFrontTopLeftId = ((y - 1) * w + (x - 1)) + (z + 1) * w * h;
                    grid->newEdge(currentNode, grid->getVertex(diagFrontTopLeftId), rand() % 100 + 1);
                }
            }
        }
    }

    return grid;
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