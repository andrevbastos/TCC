#include <iostream>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#include "a_star_mod.hpp"
#include "statistics.hpp"
#include "graph_gen.hpp"
#include "util.hpp"

const int iterations = 10;
const int imageSize = 32;

void warmUp();

int main(int argc, char* argv[]) {
    srand(static_cast<unsigned>(time(NULL)));

    char* imagePath = nullptr;
    if (argc > 1) {
        imagePath = argv[1];
    } else {
        std::cerr << "Uso: " << argv[0] << " <caminho_da_imagem.png>" << std::endl;
        return 1;
    }

    warmUp();

    IFCG::init(800, 600, "TCC");
    IFCG::setup3D();

    auto* input = IFCG::getInputHandler();
    auto* renderer = IFCG::getRenderer();
    GLuint shader = renderer->getShaderID();

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    auto [g, startId, endId] = createGrayscaleGraph(imagePath, 0, 0, imageSize - 1, imageSize - 1);

    if (startId == -1 || endId == -1) {
        std::cerr << "Erro: Coordenadas de início ou fim estão fora dos limites da imagem!" << std::endl;
        return 1;
    }

    auto a_star_path = aStarMod(g, startId, endId, util::AStar::chebyshevHeuristic3D);

    auto* graph = createMeshFromGraph(g, 0.0f, 1.0f, 1.0f, 1.0f, shader);
    graph->scale(-imageSize / 2.0f, -imageSize / 2.0f, 1.0f);
    renderer->addMesh(graph);

    auto* path = createMeshFromPath(a_star_path, 1.0f, 0.0f, 0.0f, 1.0f, shader);
    path->translate(0.0f, 0.0f, 0.05f);
    path->scale(-imageSize / 2.0f, -imageSize / 2.0f, 1.0f);
    renderer->addMesh(path);

    // Statistics stats(iterations);
    // for (int i = 0; i < iterations; ++i) {
    //     auto start = std::chrono::steady_clock::now();
    //     auto a_start = util::AStar::getPath(grid, startId, endId, util::AStar::euclideanHeuristic3D);
    //     auto end = std::chrono::steady_clock::now();
    //     auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    //     stats.addEntry("A Star", "Path Length", a_start.size());
    //     stats.addEntry("A Star", "Execution Time", duration.count());

    //     start = std::chrono::steady_clock::now();
    //     auto a_mod = aStarMod(grid, startId, endId, util::AStar::chebyshevHeuristic3D);
    //     end = std::chrono::steady_clock::now();
    //     duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    //     stats.addEntry("A Star Modified", "Path Length", a_mod.size());
    //     stats.addEntry("A Star Modified", "Execution Time", duration.count());
    // }

    // stats.makeCSV("./results/statistics.csv");

    IFCG::loop([&]() {});
    IFCG::terminate();

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