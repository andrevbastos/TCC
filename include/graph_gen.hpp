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


common::Graph* createGridMap2D(int h, int w) {
    auto* grid = new undirected::Graph();

    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            grid->newVertex(std::make_tuple(x, y));
        }
    }

    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            int currentId = y * w + x;
            common::Node* currentNode = grid->getVertex(currentId);

            // Right
            if (x + 1 < w) {
                int rightId = y * w + (x + 1);
                grid->newEdge(currentNode, grid->getVertex(rightId), rand() % 100 + 1);
            }
            // Bottom
            if (y + 1 < h) {
                int bottomId = (y + 1) * w + x;
                grid->newEdge(currentNode, grid->getVertex(bottomId), rand() % 100 + 1);
            }
            // Bottom Right
            if (x + 1 < w && y + 1 < h) {
                int diagRightId = ((y + 1) * w + (x + 1));
                grid->newEdge(currentNode, grid->getVertex(diagRightId), rand() % 100 + 1);
            }
            // Bottom Left
            if (x - 1 >= 0 && y + 1 < h) {
                int diagLeftId = ((y + 1) * w + (x - 1));
                grid->newEdge(currentNode, grid->getVertex(diagLeftId), rand() % 100 + 1);
            }
        }
    }

    return grid;
}

common::Graph* createGridMap3D(int h, int w, int d) {
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

common::Graph* createMazeGraph2D(int height, int width)
{
    auto g = createGridMap2D(height, width);
    auto result = g->clone();

    auto openPath = util::Kruskal::getMST(g);
    
    for (auto* edge : openPath) {
        result->newEdge(edge->getFirstNode()->getId(), edge->getSecondNode()->getId());
    }

    delete g;
    return result;
};

common::Graph* createMazeGraph3D(int height, int width, int depth)
{
    auto g = createGridMap3D(height, width, depth);
    auto result = g->clone();

    auto openPath = util::Kruskal::getMST(g);
    
    for (auto* edge : openPath) {
        result->newEdge(edge->getFirstNode()->getId(), edge->getSecondNode()->getId());
    }

    delete g;
    return result;
};

common::Graph* createRandomGraph(int numVertices, int numEdges) {
    auto* graph = new undirected::Graph();

    for (int i = 0; i < numVertices; ++i) {
        graph->newVertex(i);
    }

    for (int i = 0; i < numEdges; ++i) {
        int v1 = rand() % numVertices;
        int v2 = rand() % numVertices;
        if (v1 != v2 && !areNodesConnected(graph, v1, v2)) {
            graph->newEdge(graph->getVertex(v1), graph->getVertex(v2), rand() % 100 + 1);
        }
    }

    return graph;
};

std::tuple<common::Graph*, int, int> createGrayscaleGraph(const char* imagePath, int startX, int startY, int endX, int endY) {
    auto* graph = new undirected::Graph();
    int startId = -1;
    int endId = -1;

    int width, height, channels;
    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    
    if (!data) {
        std::cerr << "Erro ao carregar a imagem: " << imagePath << std::endl;
        return {graph, startId, endId};
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * 25); 
            graph->newVertex(std::make_tuple(static_cast<float>(x), static_cast<float>(y), z));
            
            int currentId = y * width + x;
            if (x == startX && y == startY) {
                startId = currentId;
            }
            if (x == endX && y == endY) {
                endId = currentId;
            }
        }
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            common::Node* currentNode = graph->getVertex(currentId);
            
            auto [cx, cy, cz] = std::any_cast<std::tuple<float, float, float>>(currentNode->getData());

            auto addEdgeWithCost = [&](int targetX, int targetY) {
                int targetId = targetY * width + targetX;
                common::Node* targetNode = graph->getVertex(targetId);
                auto [tx, ty, tz] = std::any_cast<std::tuple<float, float, float>>(targetNode->getData());
                if (tz == 0) return;

                double cost = std::sqrt(std::pow(cx - tx, 2) + std::pow(cy - ty, 2) + std::pow(cz - tz, 2));
                graph->newEdge(currentNode, targetNode, cost);
            };

            // Right
            if (x + 1 < width && cz != 0) addEdgeWithCost(x + 1, y);
            // Bottom
            if (y + 1 < height && cz != 0) addEdgeWithCost(x, y + 1);
            // Bottom Right
            if (x + 1 < width && y + 1 < height && cz != 0) addEdgeWithCost(x + 1, y + 1);
            // Bottom Left
            if (x - 1 >= 0 && y + 1 < height && cz != 0) addEdgeWithCost(x - 1, y + 1);
        }
    }

    stbi_image_free(data);  
    return {graph, startId, endId};
};