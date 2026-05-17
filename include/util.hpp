#pragma once

#include <iostream>
#include <set>
#include <tuple>
#include <algorithm>
#include <vector>
#include <memory>
#include <cmath>
#include <graph/undirected/graph.hpp>
#include <graph/undirected/lw_graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>

#include "ray_cast.hpp"
#include "noise_gen.hpp"
#include "stb_image.h"

using namespace ifcg;

struct Vertex3D {
    float x, y, z;
};

struct Color {
    float r, g, b, a;

    Color operator*(float f) const {
        return {r * f, g * f, b * f, a};
    };
};

std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwGraph(const common::lwGraph<Vertex3D>& graph, float maxZ, Color color = {1.0f, 1.0f, 1.0f, 1.0f});
std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, Color color);
std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromHeightmap(const char* imagePath, float intensity, Color color = {1.0f, 1.0f, 1.0f, 1.0f});
std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromNoise(
    const std::vector<float>& noise, 
    const int width, 
    const int height, 
    float intensity, 
    Color color = {1.0f, 1.0f, 1.0f, 1.0f}
);

std::tuple<std::shared_ptr<common::lwGraph<Vertex3D>>, int, int> createLwGraphFromHeightmap(const char* imagePath, int intensity, float heightLimit);
std::shared_ptr<common::lwGraph<Vertex3D>> createlwGraphFromNoise(
    const std::vector<float>& data, 
    const int width, 
    const int height, 
    float heightLimit, 
    int intensity
);

inline float calculatePathCostLW(const std::vector<int>& path, const common::lwGraph<Vertex3D>& graph) {
    if (path.size() < 2) return 0.0; 
    
    float totalCost = 0.0;
    for (size_t i = 0; i < path.size() - 1; ++i) {
        int currentId = path[i];
        int nextId = path[i + 1];
        
        for (const auto& edge : graph.adj(currentId)) {
            if (edge.target == nextId) {
                totalCost += edge.weight;
                break;
            }
        }
    }
    return totalCost;
}

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (size_t i = 0; i < path.size(); ++i) {
        int nodeId = path[i];
        
        const auto& data = graph.getVertexData(nodeId);
        
        // Swap Y and Z: data.x, data.z, data.y
        vertices.emplace_back(data.x, data.z, data.y, color.r, color.g, color.b, color.a);
        
        if (i < path.size() - 1) {
            indices.push_back(i);
            indices.push_back(i + 1);
        }
    }

    return {vertices, indices};
}

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwGraph(const common::lwGraph<Vertex3D>& graph, float maxZ, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    int numVertices {graph.getOrder()}; 

    for (int i = 0; i < numVertices; ++i) {
        const auto& data {graph.getVertexData(i)};
        
        float decay = std::max(0.5f, data.z / maxZ);
        Color vColor = color * decay;
        // Swap Y and Z: data.x, data.z, data.y
        vertices.emplace_back(data.x, data.z, data.y, vColor.r, vColor.g, vColor.b, color.a);
    }

    for (int i = 0; i < numVertices; ++i) {
        auto adjNodes = graph.adj(i);
        
        for (common::lwEdge neighbor : adjNodes) {
            if (i < neighbor.target) {
                indices.push_back(i);
                indices.push_back(neighbor.target);
            }
        }
    }

    return {vertices, indices};
}

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromHeightmap(const char* imagePath, float intensity, Color color) {
    int width, height, channels;

    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    if (!data) {
        std::cerr << "Erro ao carregar a imagem: " << imagePath << std::endl;
        return {{}, {}};
    }

    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * intensity); 

            float decay = std::max(0.5f, data[y * width + x] / 255.0f);
            Color vColor = color * decay;

            // Swap Y and Z: x, z, y
            vertices.emplace_back(x, z, y, vColor.r, vColor.g, vColor.b, color.a);
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
    return {vertices, indices};
};

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromNoise(const std::vector<float>& noise, const int width, const int height, float intensity, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            float z = noise[currentId] * intensity;

            float decay = std::max(0.5f, noise[currentId]);
            Color vColor = color * decay;

            // Swap Y and Z: x, z, y
            vertices.emplace_back(x, z, y, vColor.r, vColor.g, vColor.b, color.a);
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

    return {vertices, indices};
}

inline std::shared_ptr<common::lwGraph<Vertex3D>> createlwGraphFromNoise(const std::vector<float>& data, const int width, const int height, float heightLimit, int intensity) {
    auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(width * height);
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            float z = (data[currentId] * intensity); 

            graph->setVertex(currentId, {
                static_cast<float>(x), 
                static_cast<float>(y), 
                static_cast<float>(z)
            });
        }
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            const auto& currentData = graph->getVertexData(currentId);
            
            auto addEdgeWithCost = [&](int targetX, int targetY) {
                int targetId = targetY * width + targetX;
                const auto& targetData = graph->getVertexData(targetId);
                
                if (std::abs(targetData.z - currentData.z) >  heightLimit) return;

                float cost = std::sqrt(std::pow(currentData.x - targetData.x, 2) + std::pow(currentData.y - targetData.y, 2) + std::pow(currentData.z - targetData.z, 2));
                graph->addEdge(currentId, targetId, cost);
            };

            if (x + 1 < width) addEdgeWithCost(x + 1, y);
            if (y + 1 < height) addEdgeWithCost(x, y + 1);
            if (x + 1 < width && y + 1 < height) addEdgeWithCost(x + 1, y + 1);
            if (x - 1 >= 0 && y + 1 < height) addEdgeWithCost(x - 1, y + 1);
        }
    }

    return graph;
}

inline std::tuple<std::shared_ptr<common::lwGraph<Vertex3D>>, int, int> createLwGraphFromHeightmap(const char* imagePath, int intensity, float heightLimit) {
    int startId = -1, endId = -1;

    int width, height, channels;
    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    if (!data) {
        std::cerr << "Erro ao carregar a imagem: " << imagePath << std::endl;
        return {nullptr, -1, -1};
    }

    int numVertices = width * height;
    auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(numVertices);

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * intensity); 
            int currentId = y * width + x;

            graph->setVertex(currentId, {
                static_cast<float>(x), 
                static_cast<float>(y), 
                static_cast<float>(z)
            });
        }
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
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
    return {graph, startId, endId};
}