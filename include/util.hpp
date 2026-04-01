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
        auto [x, y, z] = std::any_cast<std::tuple<int, int, int>>(node->getData());
        
        Vertex vertex(x, y, z, r, g, b, a);
        vertices.push_back(vertex);
        
        idToIndex[node->getId()] = i; 
    }

    if (drawMode == GL_TRIANGLES) {
        std::set<std::tuple<int, int, int>> uniqueTriangles;

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