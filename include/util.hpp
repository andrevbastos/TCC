#include <iostream>
#include <set>
#include <tuple>
#include <algorithm>
#include <vector>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>

Mesh* createMeshFromGraph(common::Graph* graph, float r, float g, float b, float a, GLuint shader, GLenum drawMode = GL_LINES) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;
    
    std::unordered_map<int, int> idToIndex; 

    auto graphNodes = graph->getVertices();
    for (int i = 0; i < graphNodes.size(); ++i) {
        auto* node = graphNodes[i];

        auto [valid, coords] = util::AStar::getCoords3D(node);
        if (!valid) continue;
        auto [x, y, z] = coords;
        
        Vertex vertex(x, y, z, r, g, b, a);
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

    auto* mesh = new Mesh(vertices, indices, shader, drawMode);
    return mesh;
};

Mesh* createMeshFromPath(std::vector<common::Node*> path, float r, float g, float b, float a, GLuint shader)
{
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (int i = 0; i < path.size(); ++i) {
        auto [valid, coords] = util::AStar::getCoords3D(path[i]);
        if (!valid) continue;
        auto [x, y, z] = coords;
        
        Vertex vertex(x, y, z, r, g, b, a);
        vertices.push_back(vertex);
        
        if (i < path.size() - 1) {
            indices.push_back(i);
            indices.push_back(i + 1);
        }
    }

    auto* mesh = new Mesh(
        vertices, 
        indices,
        shader,
        GL_LINES
    );

    return mesh;
};

common::Graph* createGraphFromMesh(Mesh* mesh) {
    auto* graph = new undirected::Graph();

    auto vertices = mesh->getVertices();
    auto indices = mesh->getIndices();

    for (int i = 0; i < vertices.size(); i++) {
        graph->newVertex(std::make_tuple(vertices[i].x, vertices[i].y, vertices[i].z));
    }

    auto addEdgeWithCost = [&](int v1_idx, int v2_idx) {
        auto* n1 = graph->getVertex(v1_idx);
        auto* n2 = graph->getVertex(v2_idx);
        
        auto [valid1, coords1] = util::AStar::getCoords3D(n1);
        auto [valid2, coords2] = util::AStar::getCoords3D(n2);

        if (!valid1 || !valid2) return;

        auto [x1, y1, z1] = coords1;
        auto [x2, y2, z2] = coords2;
        
        double cost = std::sqrt(std::pow(x1 - x2, 2) + std::pow(y1 - y2, 2) + std::pow(z1 - z2, 2));
        
        graph->newEdge(n1, n2, cost);
    };

    for (int i = 0; i < indices.size(); i += 3) {
        int v1 = indices[i];
        int v2 = indices[i + 1];
        int v3 = indices[i + 2];
        
        addEdgeWithCost(v1, v2);
        addEdgeWithCost(v2, v3);
        addEdgeWithCost(v3, v1);
    }

    return graph;
};