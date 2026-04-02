#include <iostream>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>
#include <ifcg/graphics/primitives/sphere.hpp>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#include "a_star_mod.hpp"
#include "statistics.hpp"
#include "graph_gen.hpp"
#include "util.hpp"

const int iterations = 10;

void warmUp();

int main(int argc, char* argv[]) {
    srand(static_cast<unsigned>(time(NULL)));

    char* imagePath = nullptr;
    int imageSize = 32;
    if (argc > 2) {
        imagePath = argv[1];
        imageSize = std::stoi(argv[2]);
    } else {
        std::cerr << "Uso: " << argv[0] << " <caminho_da_imagem.png> <tamanho_da_imagem>" << std::endl;
        return 1;
    }

    warmUp();

    IFCG::init(1200, 800, "TCC");
    IFCG::setup3D();

    auto* input = IFCG::getInputHandler();
    auto* renderer = IFCG::getRenderer();
    GLuint shader = renderer->getShaderID();

    auto [g, startId, endId] = createGrayscaleGraph(imagePath, 0, 0, imageSize - 1, imageSize - 1);

    if (startId == -1 || endId == -1) {
        std::cerr << "Erro: Coordenadas de início ou fim estão fora dos limites da imagem!" << std::endl;
        return 1;
    }

    auto a_star_path = util::AStar::getPath(g, startId, endId, util::AStar::chebyshevHeuristic3D);
    auto a_star_mod_path = aStarMod(g, startId, endId, util::AStar::chebyshevHeuristic3D);

    auto* floor = createMeshFromGraph(g, 0.5f, 0.5f, 0.5f, 1.0f, shader, GL_TRIANGLES);
    
    auto* outline = createMeshFromGraph(g, 0.8f, 0.8f, 0.8f, 1.0f, shader, GL_LINES);
    outline->translate(0.0f, 0.0f, 0.6f);

    auto* path1 = createMeshFromPath(a_star_path, 1.0f, 0.0f, 0.0f, 1.0f, shader);
    path1->translate(0.0f, 0.0f, 1.5f);

    auto* path2 = createMeshFromPath(a_star_mod_path, 0.0f, 1.0f, 0.0f, 1.0f, shader);
    path2->translate(0.0f, 0.0f, 2.5f);

    auto* scene = new MeshTree();
    scene->addChild(floor);
    scene->addChild(outline);
    scene->addChild(path1);
    scene->addChild(path2);

    scene->rotate(-3.14159f / 2, 1.0f, 0.0f, 0.0f);

    renderer->addMesh(scene);

    auto* camera = renderer->getCamera();
    camera->setPos(glm::vec3(0.0f, 30.0f, 0.0f));
    camera->rotate(-1.0f, glm::vec3(1.0f, 1.0f, 0.0f));

    input->addKeyCallback(GLFW_KEY_LEFT_SHIFT, [camera, input]() {
        if (input->isKeyHeld(GLFW_KEY_LEFT_SHIFT)){
            camera->setSpeed(0.5f);
        } else {
            camera->setSpeed(0.1f);
        }
    });

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