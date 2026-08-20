#include <iostream>
#include <vector>
#include <tuple>
#include <fstream>
#include <cmath>
#include <graph/undirected/graph.hpp>
#include <graph/undirected/lw_graph.hpp>
#include <graph/util/kruskal.hpp>

#include "core/util.hpp"

std::tuple<std::shared_ptr<MeshTree>, std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createSceneFromNoise(
    NoiseConfig config,
    int intensity,
    float heightLimit,
    GLuint shader,
    Color floorColor = {0.5f, 0.5f, 0.5f, 1.0f},
    Color outlineColor = {0.8f, 0.8f, 0.8f, 0.8f}
);

std::tuple<std::shared_ptr<MeshTree>, std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createSceneFromHeightmap(
    const char* imagePath,
    int intensity,
    float heightLimit, 
    GLuint shader, 
    Color floorColor = {0.5f, 0.5f, 0.5f, 1.0f}, 
    Color outlineColor = {0.8f, 0.8f, 0.8f, 0.8f}
);

std::shared_ptr<Mesh> createMeshFromHeightmap(const char* imagePath, int intensity, GLuint shader, Color color = {0.5f, 0.5f, 0.5f, 1.0f}, GLenum drawMode = GL_TRIANGLES);
std::shared_ptr<Mesh> createMeshFromLwGraph(const common::lwGraph<Vertex3D>& graph, GLuint shader, Color color = {0.5f, 0.5f, 0.5f, 1.5f}, GLenum drawMode = GL_LINES);
std::shared_ptr<Mesh> createMeshFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, GLuint shader, Color color = {0.8f, 0.8f, 0.8f, 1.0f});

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
            grid->newVertex(std::make_pair(x, y));
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

common::Graph* createOneWayMazeGraph2D(int height, int width)
{
    auto g = createGridMap2D(height, width);
    auto* result = g->clone();

    auto openPath = util::Kruskal::getMST(g);
    
    for (auto* edge : openPath) {
        result->newEdge(edge->getFirstNode()->getId(), edge->getSecondNode()->getId());
    }

    delete g;
    return result;
};

common::Graph* createOneWayMazeGraph3D(int height, int width, int depth)
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

common::Graph* createRandomMazeGraph2D(int height, int width)
{
    // Cria o Grid2D
    auto g = createGridMap2D(height, width);
    // Resultado
    auto result = new undirected::Graph();

    // Adiciona os vértices ao resultado, mantendo os IDs
    for (int i = 0; i < g->getOrder(); i++) {
        auto current = g->getVertex(i);
        auto [valid, coord] = util::getCoords2D(current);

        if (!valid) continue;

        auto [x, y] = coord;

        result->newVertex(std::make_tuple(static_cast<float>(x), static_cast<float>(y), 25.0));
    }

    // Itera 3 vezes
    for (int i = 0; i < 1; i++) {
        // Pega o caminho atual possível
        auto openPath = util::Kruskal::getMST(g);
    
        // Para cara aresta (DO G) no MST
        for (auto* edge : openPath) {
            // Pega os IDs dos nós conectados por essa aresta
            auto firstNodeId = edge->getFirstNode()->getId();
            auto secondNodeId = edge->getSecondNode()->getId();

            // Pega as coordenadas 3D dos vértices do result com base no ID
            auto [valid1, coord1] = util::getCoords3D(result->getVertex(firstNodeId));
            auto [valid2, coord2] = util::getCoords3D(result->getVertex(secondNodeId));

            if (!valid1 || !valid2) continue;

            auto [x1, y1, z1] = coord1;
            auto [x2, y2, z2] = coord2;

            // Altera o Z do vértice do result para 1
            if (z1 != 5.0) result->getVertex(firstNodeId)->setData(std::make_tuple(static_cast<float>(x1), static_cast<float>(y1), 5.0));
            if (z2 != 5.0) result->getVertex(secondNodeId)->setData(std::make_tuple(static_cast<float>(x2), static_cast<float>(y2), 5.0));

            // Faz a aresta
            result->newEdge(firstNodeId, secondNodeId);
            // Remove a aresta do g para permitir outra busca
            g->removeEdge(edge);
        }
    }

    delete g;
    return result;
}

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

 std::pair<common::Graph*, std::pair<int, int>> createGrayscaleGraph(const char* imagePath, int intensity) {
    auto* graph = new undirected::Graph();

    int startId = -1, endId = -1;
    int width, height, channels;
    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    if (!data) {
        std::cerr << "Erro ao carregar a imagem: " << imagePath << std::endl;
        return {graph, {0, 0}};
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * intensity);
            graph->newVertex(std::make_tuple(static_cast<float>(x), static_cast<float>(y), static_cast<float>(z)));

            int currentId = y * width + x;
        }
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            common::Node* currentNode = graph->getVertex(currentId);

            auto [validCurrent, coordsCurrent] = util::getCoords3D(currentNode);
            if (!validCurrent) continue;
            auto [cx, cy, cz] = coordsCurrent;

            auto addEdgeWithCost = [&](int targetX, int targetY) {
                int targetId = targetY * width + targetX;

                common::Node* targetNode = graph->getVertex(targetId);

                auto [validTarget, coordsTarget] = util::getCoords3D(targetNode);
                if (!validTarget) return;
                auto [tx, ty, tz] = coordsTarget;
                if (tz == 0) return;
                float cost = std::sqrt(std::pow(cx - tx, 2) + std::pow(cy - ty, 2) + std::pow(cz - tz, 2));

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

            if (startId == -1 && cz != 0) startId = currentId;
            endId = currentId;
        }
    }

    stbi_image_free(data);  

    return {graph, {startId, endId}};
};

std::tuple<std::shared_ptr<MeshTree>, std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createSceneFromNoise(
    NoiseConfig config,
    int intensity,
    float heightLimit, 
    GLuint shader,
    Color floorColor, 
    Color outlineColor
) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    int startId = -1, endId = -1;
    
    auto data = generateNoiseMap(config);

    auto width = config.width;
    auto height = config.height;

    const std::string& savePath = "../results/noises/noise_temp.png";
    saveNoiseAsPNG(savePath, data, width, height);

    auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(width * height);

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] * intensity); 
            
            int currentId = y * width + x;
            
            vertices.emplace_back(x, y, z, floorColor.r, floorColor.g, floorColor.b, floorColor.a);
            
            graph->setVertex(currentId, {
                static_cast<float>(x), 
                static_cast<float>(y), 
                static_cast<float>(z)
            });
        }
    }

    for (int y = 0; y < height - 1; ++y) {
        for (int x = 0; x < width - 1; ++x) {
            int topLeft = y * width + x;
            int topRight = y * width + (x + 1);
            int bottomLeft = (y + 1) * width + x;
            int bottomRight = (y + 1) * width + (x + 1);

            indices.push_back(topLeft);
            indices.push_back(bottomLeft);
            indices.push_back(topRight);

            indices.push_back(topRight);
            indices.push_back(bottomLeft);
            indices.push_back(bottomRight);

            int currentId = y * width + x;
            const auto& currentData = graph->getVertexData(currentId);
            
            if (currentData.z == 0.0) continue;

            auto addEdgeWithCost = [&](int targetX, int targetY) {
                int targetId = targetY * width + targetX;
                const auto& targetData = graph->getVertexData(targetId);
                
                if (targetData.z == 0.0 || std::abs(targetData.z - currentData.z) > heightLimit) return;

                float cost = std::sqrt(std::pow(currentData.x - targetData.x, 2) + std::pow(currentData.y - targetData.y, 2) + std::pow(currentData.z - targetData.z, 2));
                
                graph->addEdge(currentId, targetId, cost);
            };

            if (x + 1 < width) addEdgeWithCost(x + 1, y);
            if (y + 1 < height) addEdgeWithCost(x, y + 1);
            if (x + 1 < width && y + 1 < height) addEdgeWithCost(x + 1, y + 1);
            if (x - 1 >= 0 && y + 1 < height) addEdgeWithCost(x - 1, y + 1);

            if (startId == -1) startId = currentId;
            endId = currentId;
        }
    }

    auto floor = std::make_shared<Mesh>(vertices, indices, shader);
    auto outline = createMeshFromLwGraph(*graph, shader, outlineColor, GL_LINES);
    outline->translate(0.0f, 0.0f, 0.6f);
    auto scene = std::make_shared<MeshTree>();
    scene->rotate(-3.14159f / 2, 1.0f, 0.0f, 0.0f);

    scene->addChild(floor);
    scene->addChild(outline);

    return {scene, graph, {startId, endId}};
};

std::tuple<std::shared_ptr<MeshTree>, std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createSceneFromHeightmap(
    const char* imagePath,
    int intensity,
    float heightLimit, 
    GLuint shader, 
    Color floorColor, 
    Color outlineColor
) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    int startId = -1, endId = -1;

    int width, height, channels;
    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    if (!data) {
        std::cerr << "Failed to load heightmap image: " << imagePath << std::endl;
        return {nullptr, nullptr, {0, 0}};
    }

    int numVertices = width * height;

    auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(numVertices);

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * intensity); 
            
            int currentId = y * width + x;
            
            vertices.emplace_back(x, y, z, floorColor.r, floorColor.g, floorColor.b, floorColor.a);
            
            graph->setVertex(currentId, {
                static_cast<float>(x), 
                static_cast<float>(y), 
                static_cast<float>(z)
            });
        }
    }

    for (int y = 0; y < height - 1; ++y) {
        for (int x = 0; x < width - 1; ++x) {
            int topLeft = y * width + x;
            int topRight = y * width + (x + 1);
            int bottomLeft = (y + 1) * width + x;
            int bottomRight = (y + 1) * width + (x + 1);

            indices.push_back(topLeft);
            indices.push_back(bottomLeft);
            indices.push_back(topRight);

            indices.push_back(topRight);
            indices.push_back(bottomLeft);
            indices.push_back(bottomRight);

            int currentId = y * width + x;
            const auto& currentData = graph->getVertexData(currentId);
            
            if (currentData.z == 0.0) continue;

            auto addEdgeWithCost = [&](int targetX, int targetY) {
                int targetId = targetY * width + targetX;
                const auto& targetData = graph->getVertexData(targetId);
                
                if (targetData.z == 0.0 || std::abs(targetData.z - currentData.z) > heightLimit) return;

                float cost = std::sqrt(std::pow(currentData.x - targetData.x, 2) + std::pow(currentData.y - targetData.y, 2) + std::pow(currentData.z - targetData.z, 2));
                
                graph->addEdge(currentId, targetId, cost);
            };

            if (x + 1 < width) addEdgeWithCost(x + 1, y);
            if (y + 1 < height) addEdgeWithCost(x, y + 1);
            if (x + 1 < width && y + 1 < height) addEdgeWithCost(x + 1, y + 1);
            if (x - 1 >= 0 && y + 1 < height) addEdgeWithCost(x - 1, y + 1);

            if (startId == -1) startId = currentId;
            endId = currentId;
        }
    }

    stbi_image_free(data);

    auto floor = std::make_shared<Mesh>(vertices, indices, shader);
    auto outline = createMeshFromLwGraph(*graph, shader, outlineColor, GL_LINES);
    outline->translate(0.0f, 0.0f, 0.6f);
    auto scene = std::make_shared<MeshTree>();
    scene->rotate(-3.14159f / 2, 1.0f, 0.0f, 0.0f);

    scene->addChild(floor);
    scene->addChild(outline);

    return {scene, graph, {startId, endId}};
};

std::shared_ptr<Mesh> createMeshFromHeightmap(const char* imagePath, int intensity, GLuint shader, Color color, GLenum drawMode) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;
    
    int width, height, channels;
    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    if (!data) {
        std::cerr << "Failed to load heightmap image: " << imagePath << std::endl;
        return nullptr;
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * intensity); 
            vertices.emplace_back(x, y, z, color.r, color.g, color.b, color.a);
        }
    }

    for (int y = 0; y < height - 1; ++y) {
        for (int x = 0; x < width - 1; ++x) {
            int topLeft = y * width + x;
            int topRight = y * width + (x + 1);
            int bottomLeft = (y + 1) * width + x;
            int bottomRight = (y + 1) * width + (x + 1);

            indices.push_back(topLeft);
            indices.push_back(bottomLeft);
            indices.push_back(topRight);

            indices.push_back(topRight);
            indices.push_back(bottomLeft);
            indices.push_back(bottomRight);
        }
    }

    stbi_image_free(data);

    auto mesh = std::make_shared<Mesh>(vertices, indices, shader, drawMode);
    return mesh;
}

std::shared_ptr<Mesh> createMeshFromLwGraph(const common::lwGraph<Vertex3D>& graph, GLuint shader, Color color, GLenum drawMode) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    int numVertices = graph.getOrder(); 

    for (int i = 0; i < numVertices; ++i) {
        const auto& data = graph.getVertexData(i);
        
        vertices.emplace_back(data.x, data.y, data.z, color.r, color.g, color.b, color.a);
    }

    if (drawMode == GL_TRIANGLES) {
        std::set<std::tuple<int, int, int>> uniqueTriangles;

        for (int i = 0; i < numVertices; ++i) {
            auto adjNodes = graph.adj(i); 
            
            for (size_t j = 0; j < adjNodes.size(); ++j) {
                for (size_t k = j + 1; k < adjNodes.size(); ++k) {
                    int id1 = i;
                    int id2 = adjNodes[j].target;
                    int id3 = adjNodes[k].target;

                    std::vector<int> tri = {id1, id2, id3};
                    std::sort(tri.begin(), tri.end());
                    uniqueTriangles.insert({tri[0], tri[1], tri[2]});
                }
            }
        }

        for (const auto& t : uniqueTriangles) {
            indices.push_back(std::get<0>(t));
            indices.push_back(std::get<1>(t));
            indices.push_back(std::get<2>(t));
        }
    } else {
        for (int i = 0; i < numVertices; ++i) {
            auto adjNodes = graph.adj(i);
            
            for (common::lwEdge neighbor : adjNodes) {
                if (i < neighbor.target) {
                    indices.push_back(i);
                    indices.push_back(neighbor.target);
                }
            }
        }
    }

    auto mesh = std::make_shared<Mesh>(vertices, indices, shader, drawMode);
    return mesh;
}

std::shared_ptr<Mesh> createMeshFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, GLuint shader, Color color) {
    auto [vertices, indices] = createMeshDataFromLwPath(graph, path, color);

    auto mesh = std::make_shared<Mesh>(vertices, indices, shader, GL_LINES);
    return mesh;
} 