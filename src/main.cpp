#include <iostream>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>

#include "a_star_mod.hpp"
#include "statistics.hpp"
#include "graph_gen.hpp"

const int w = 5, h = 5, d = 5;
const int startX = 0, startY = 0, startZ = 0, endX = w - 1, endY = h - 1, endZ = d - 1;
const int startId = startZ * w * h + startY * w + startX, endId = endZ * w * h + endY * w + endX;
const int iterations = 5;

void warmUp();

int main(int argc, char* argv[]) {
    srand(static_cast<unsigned>(time(NULL)));

    std::string outputFile = "./results.csv";
    if (argc > 1) {
        outputFile = argv[1];
    }
    std::string graphsDir = "./graphs/";
    if (argc > 2) {
        graphsDir = argv[2];
    }

    warmUp();
    
    IFCG::init(800, 600, "TCC");
    IFCG::setup3D();

    auto* input = IFCG::getInputHandler();
    auto* renderer = IFCG::getRenderer();
    GLuint shader = renderer->getShaderID();

    auto* g = createMazeGraph3D(h, w, d);
    auto a_start = aStarMod(g, startId, endId, util::AStar::chebyshevHeuristic3D);

    std::vector<Vertex> verticesA;
    std::vector<GLuint> indicesA;

    std::vector<Vertex> verticesB;
    std::vector<GLuint> indicesB;

    verticesA.clear();
    indicesA.clear();
    auto nodes = g->getVertices();
    for (auto* node : nodes) {
        auto [x, y, z] = std::any_cast<std::tuple<int, int, int>>(node->getData());
        Vertex vertex(x / static_cast<float>(w), y / static_cast<float>(h), z / static_cast<float>(d), 0.0f, 1.0f, 0.0f, 0.7f);
        verticesA.push_back(vertex);
    }
    auto edges = g->getEdges();
    for (auto* edge : edges) {
        auto [v1, v2] = g->getNodesFromEdge(edge);
        int id1 = v1->getId();
        int id2 = v2->getId();
        indicesA.push_back(id1);
        indicesA.push_back(id2);
    }

    verticesB.clear();
    indicesB.clear();
    for (int i = 0; i < a_start.size(); ++i) {
        auto [x, y, z] = std::any_cast<std::tuple<int, int, int>>(a_start[i]->getData());
        verticesB.push_back(Vertex(x / (float)w, y / (float)h, z / (float)d, 1.0f, 0.0f, 0.0f));
        
        if (i < a_start.size() - 1) {
            indicesB.push_back(i);
            indicesB.push_back(i + 1);
        }
    }

    auto* graph = new Mesh(
        verticesA, 
        indicesA,
        shader,
        GL_LINES
    );

    auto* path = new Mesh(
        verticesB, 
        indicesB,
        shader,
        GL_LINES
    );

    renderer->addMesh(graph);
    renderer->addMesh(path);

    IFCG::loop([&]() {});

    IFCG::terminate();
    return 0;

    // Statistics stats(iterations);
    // for (int i = 0; i < iterations; ++i) {
    //     auto* g = createMazeGraph3D(h, w, d);

    //     auto start = std::chrono::steady_clock::now();
    //     auto a_start = util::AStar::getPath(g, startId, endId, util::AStar::euclideanHeuristic3D);
    //     auto end = std::chrono::steady_clock::now();
    //     auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    //     stats.addEntry("A Star", "Path Length", a_start.size());
    //     stats.addEntry("A Star", "Execution Time", duration.count());

    //     start = std::chrono::steady_clock::now();
    //     auto a_mod = aStarMod(g, startId, endId, util::AStar::chebyshevHeuristic3D);
    //     end = std::chrono::steady_clock::now();
    //     duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    //     stats.addEntry("A Star Modified", "Path Length", a_mod.size());
    //     stats.addEntry("A Star Modified", "Execution Time", duration.count());

    //     delete g;
    // }

    // stats.makeCSV(outputFile);

    return 0;
};

void warmUp() 
{
    undirected::Graph warmUpGraph;
    for (int i = 0; i < 10; ++i) {
        warmUpGraph.newVertex(std::make_tuple(i, 0, 0));
    }
    for (int i = 0; i < 9; ++i) {
        warmUpGraph.newEdge(warmUpGraph.getVertex(i), warmUpGraph.getVertex(i + 1));
    }

    for (int w_i = 0; w_i < 5; ++w_i) {
        util::AStar::getPath(&warmUpGraph, 0, 9, util::AStar::euclideanHeuristic3D);
        aStarMod(&warmUpGraph, 0, 9, util::AStar::chebyshevHeuristic3D);
    }
};