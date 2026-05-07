#pragma once

#include <iostream>
#include <set>
#include <tuple>
#include <algorithm>
#include <vector>
#include <graph/undirected/graph.hpp>
#include <graph/undirected/lw_graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>

#include "ray_cast.hpp"
#include "noise_gen.hpp"

using namespace ifcg;

struct Vertex3D {
    double x, y, z;
};

struct Color {
    float r, g, b, a;
};

std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, Color color);
std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwGraph(const common::lwGraph<Vertex3D>& graph, GLuint shader, Color color = {0.5f, 0.5f, 0.5f, 1.5f});

std::pair<std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createLwGraphFromHeightmap(const char* imagePath, int intensity, double heightLimit);

std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (size_t i = 0; i < path.size(); ++i) {
        int nodeId = path[i];
        
        const auto& data = graph.getVertexData(nodeId);
        
        vertices.emplace_back(data.x, data.y, data.z, color.r, color.g, color.b, color.a);
        
        if (i < path.size() - 1) {
            indices.push_back(i);
            indices.push_back(i + 1);
        }
    }

    return {vertices, indices};
}

std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwGraph(const common::lwGraph<Vertex3D>& graph, GLuint shader, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    int numVertices = graph.getOrder(); 

    for (int i = 0; i < numVertices; ++i) {
        const auto& data = graph.getVertexData(i);
        
        vertices.emplace_back(data.x, data.y, data.z, color.r, color.g, color.b, color.a);
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

std::pair<std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createLwGraphFromHeightmap(const char* imagePath, int intensity, double heightLimit) {
    int startId = -1, endId = -1;

    int width, height, channels;
    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    if (!data) {
        std::cerr << "Erro ao carregar a imagem: " << imagePath << std::endl;
        return {nullptr, {0, 0}};
    }

    int numVertices = width * height;
    
    auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(numVertices);

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * intensity); 
            int currentId = y * width + x;

            graph->setVertex(currentId, {
                static_cast<double>(x), 
                static_cast<double>(y), 
                static_cast<double>(z)
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

                double cost = std::sqrt(std::pow(currentData.x - targetData.x, 2) + std::pow(currentData.y - targetData.y, 2) + std::pow(currentData.z - targetData.z, 2));
                
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
    return {graph, {startId, endId}};
}