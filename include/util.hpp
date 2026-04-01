#include <iostream>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>

Mesh* createMeshFromGraph(common::Graph* graph, float r, float g, float b, float a, GLuint shader) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    auto graphNodes = graph->getVertices();
    for (auto* node : graphNodes) {
        auto [x, y, z] = std::any_cast<std::tuple<int, int, int>>(node->getData());
        Vertex vertex(x, y, z, r, g, b, a);
        vertices.push_back(vertex);
    }
    auto graphEdges = graph->getEdges();
    for (auto* edge : graphEdges) {
        auto [v1, v2] = graph->getNodesFromEdge(edge);
        int id1 = v1->getId();
        int id2 = v2->getId();
        indices.push_back(id1);
        indices.push_back(id2);
    }

    auto* mesh = new Mesh(
        vertices, 
        indices,
        shader,
        GL_LINES
    );

    return mesh;
};

Mesh* createMeshFromPath(std::vector<common::Node*> path, float r, float g, float b, float a, GLuint shader)
{
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (int i = 0; i < path.size(); ++i) {
        auto [x, y, z] = std::any_cast<std::tuple<int, int, int>>(path[i]->getData());
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