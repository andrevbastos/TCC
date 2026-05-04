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

using namespace ifcg;

struct Vertex3D {
    double x, y, z;
};

struct Color {
    float r, g, b, a;
};

std::tuple<std::shared_ptr<MeshTree>, std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createSceneFromHeightmap(
    const char* imagePath,
    int intensity,
    double heightLimit, 
    GLuint shader, 
    ifcg::Keys& input,
    Color floorColor = {0.5f, 0.5f, 0.5f, 1.0f}, 
    Color outlineColor = {0.8f, 0.8f, 0.8f, 0.8f}
);
std::shared_ptr<Mesh> createMeshFromHeightmap(const char* imagePath, int intensity, GLuint shader, Color color = {0.5f, 0.5f, 0.5f, 1.0f}, GLenum drawMode = GL_TRIANGLES);
std::shared_ptr<Mesh> createMeshFromGraph(std::shared_ptr<common::Graph> graph, GLuint shader, Color color = {0.5f, 0.5f, 0.5f, 1.0f}, GLenum drawMode = GL_LINES);
std::shared_ptr<Mesh> createMeshFromLwGraph(const common::lwGraph<Vertex3D>& graph, GLuint shader, Color color = {0.5f, 0.5f, 0.5f, 1.5f}, GLenum drawMode = GL_LINES);
std::shared_ptr<Mesh> createMeshFromPath(std::vector<common::Node*> path, GLuint shader, Color color = {0.8f, 0.8f, 0.8f, 1.0f});
std::shared_ptr<Mesh> createMeshFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, GLuint shader, Color color = {0.8f, 0.8f, 0.8f, 1.0f});

std::pair<std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createGraphFromMesh(std::shared_ptr<Mesh> mesh, double heightLimit);
std::pair<std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createLwGraphFromHeightmap(const char* imagePath, int intensity, double heightLimit);

std::tuple<std::shared_ptr<MeshTree>, std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createSceneFromHeightmap(
    const char* imagePath,
    int intensity,
    double heightLimit, 
    GLuint shader, 
    ifcg::Keys& input,
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
                static_cast<double>(x), 
                static_cast<double>(y), 
                static_cast<double>(z)
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

    auto floor = std::make_shared<Mesh>(vertices, indices, shader);
    auto outline = createMeshFromLwGraph(*graph, shader, outlineColor, GL_LINES);
    outline->translate(0.0f, 0.0f, 0.6f);
    auto scene = std::make_shared<MeshTree>();
    scene->rotate(-3.14159f / 2, 1.0f, 0.0f, 0.0f);

    scene->addChild(floor);
    scene->addChild(outline);

    input.addKeyCallback(GLFW_KEY_Z, [&floor, &input]() {
        if (input.isKeyHeld(GLFW_KEY_Z)) {
            auto hitVertex = getClosestVertex(*floor);
            if (hitVertex) {
                std::cout << "Hit vertex at (" << hitVertex->x << ", " << hitVertex->y << ", " << hitVertex->z << ")\n";
            } else {
                std::cout << "No vertex hit.\n";
            }
        }
    });

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

std::shared_ptr<Mesh> createMeshFromGraph(std::shared_ptr<common::Graph> graph, GLuint shader, Color color, GLenum drawMode) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;
    
    std::unordered_map<int, int> idToIndex; 

    auto graphNodes = graph->getVertices();
    for (int i = 0; i < graphNodes.size(); ++i) {
        auto* node = graphNodes[i];

        auto [valid, coords] = util::getCoords3D(node);
        if (!valid) continue;
        auto [x, y, z] = coords;
        
        Vertex vertex(x, y, z, color.r, color.g, color.b, color.a);
        vertices.push_back(vertex);
        
        idToIndex[node->getId()] = i; 
    }

    if (drawMode == GL_TRIANGLES) {
        std::set<std::tuple<float, float, float>> uniqueTriangles;

        for (auto* node : graphNodes) {
            auto adjNodes = node->adj();
            for (int i = 0; i < adjNodes.size(); ++i) {
                for (int j = i + 1; j < adjNodes.size(); ++j) {
                    int id1 = node->getId();
                    int id2 = adjNodes[i]->getId();
                    int id3 = adjNodes[j]->getId();

                    std::vector<int> tri = {id1, id2, id3};
                    std::sort(tri.begin(), tri.end());
                    uniqueTriangles.insert({tri[0], tri[1], tri[2]});
                }
            }
        }

        for (const auto& t : uniqueTriangles) {
            indices.push_back(idToIndex[std::get<0>(t)]);
            indices.push_back(idToIndex[std::get<1>(t)]);
            indices.push_back(idToIndex[std::get<2>(t)]);
        }
    } else {
        auto graphEdges = graph->getEdges();
        for (auto* edge : graphEdges) {
            auto [v1, v2] = graph->getNodesFromEdge(edge);
            
            indices.push_back(idToIndex[v1->getId()]);
            indices.push_back(idToIndex[v2->getId()]);
        }
    }

    auto mesh = std::make_shared<Mesh>(vertices, indices, shader, drawMode);
    return mesh;
};

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

std::shared_ptr<Mesh> createMeshFromPath(std::vector<common::Node*> path, GLuint shader, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (int i = 0; i < path.size(); ++i) {
        auto [valid, coords] = util::getCoords3D(path[i]);
        if (!valid) continue;
        auto [x, y, z] = coords;
        
        Vertex vertex(x, y, z, color.r, color.g, color.b, color.a);
        vertices.push_back(vertex);
        
        if (i < path.size() - 1) {
            indices.push_back(i);
            indices.push_back(i + 1);
        }
    }

    auto mesh = std::make_shared<Mesh>(vertices, indices, shader, GL_LINES);
    return mesh;
};

std::shared_ptr<Mesh> createMeshFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, GLuint shader, Color color) {
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

    auto mesh = std::make_shared<Mesh>(vertices, indices, shader, GL_LINES);
    return mesh;
}

std::pair<std::shared_ptr<common::lwGraph<Vertex3D>>, std::pair<int, int>> createGraphFromMesh(std::shared_ptr<Mesh> mesh, double heightLimit) {
    auto vertices = mesh->getVertices();
    auto indices = mesh->getIndices();

    auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(vertices.size());
    int startId = -1, endId = -1;

    for (int i = 0; i < vertices.size(); i++) {
        double x = static_cast<double>(vertices[i].x);
        double y = static_cast<double>(vertices[i].y);
        double z = static_cast<double>(vertices[i].z);
        if (z != 0) {
            if (startId == -1) startId = i;
            endId = i;
        }
        graph->setVertex(i, {x, y, z});
    }

    auto addEdgeWithCost = [&](int v1, int v2) {
        const auto& coords1 = graph->getVertexData(v1);
        const auto& coords2 = graph->getVertexData(v2);

        auto [x1, y1, z1] = coords1;
        auto [x2, y2, z2] = coords2;
        
        if (std::abs(z1 - z2) > heightLimit) return;

        double cost = std::sqrt(std::pow(x1 - x2, 2) + std::pow(y1 - y2, 2) + std::pow(z1 - z2, 2));
        
        graph->addEdge(v1, v2, cost);
    };

    for (int i = 0; i < indices.size(); i += 3) {
        int v1 = indices[i];
        int v2 = indices[i + 1];
        int v3 = indices[i + 2];
        
        addEdgeWithCost(v1, v2);
        addEdgeWithCost(v2, v3);
        addEdgeWithCost(v3, v1);
    }

    return std::make_pair(graph, std::make_pair(startId, endId));
};

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