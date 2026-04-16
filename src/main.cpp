#include <iostream>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/dijkstra.hpp>
#include <filesystem>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>
#include <ifcg/graphics/primitives/sphere.hpp>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#include "a_star_mod.hpp"
#include "jps.hpp"
#include "statistics.hpp"
#include "graph_gen.hpp"
#include "util.hpp"

namespace fs = std::filesystem;

const int iterations = 10;

void getStatistics();
void renderScene(char* imagePath, int intensity);
void warmUp();
double calculatePathCost(const std::vector<common::Node*>& path, common::Graph* graph);

int main(int argc, char* argv[]) {
    if (argc > 2) {
        char* imagePath = argv[1];
        int intensity = std::stoi(argv[2]);
        renderScene(imagePath, intensity);
    } else {
        getStatistics();
    }

    return 0;
};

void getStatistics()
{
    warmUp();

    int intensity = 50;
    Statistics stats(iterations);
    std::string path = "../resources/grayscales";
    std::unordered_map<std::string, std::function<std::vector<common::Node*>(common::Graph*, int, int, util::AStar::HeuristicFunc)>> algorithms = {
        {"Jump Point Search", jumpPointSearch},
        {"A Star", util::AStar::getPath},
        {"A Star Modified", aStarMod}
    };
    for (const auto& entry : fs::directory_iterator(path)) {
        if (entry.path().extension() != ".png") continue;

        std::cout << entry.path().filename().string() << std::flush;
        
        auto [g, ids] = createGrayscaleGraph(entry.path().c_str(), intensity);
        auto [startId, endId] = ids;
        
        if (startId == -1 || endId == -1) {
            std::cout << "Erro: Coordenadas de início ou fim estão fora dos limites da imagem!" << std::endl;
            continue;
        }
        
        std::cout << ":" << std::endl;
        
        for (const auto& alg : algorithms) {
            std::cout << "\t" << alg.first << "..." << std::flush;

            auto startTime = std::chrono::high_resolution_clock::now();
            auto path = alg.second(g, startId, endId, util::AStar::chebyshevHeuristic3D);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double> elapsed = endTime - startTime;

            stats.addEntry(alg.first, "Tempo de Execução", elapsed.count());
            stats.addEntry(alg.first, "Custo do Caminho", calculatePathCost(path, g));
            stats.addEntry(alg.first, "Número de Nós Expandidos", path.size());

            std::cout << " concluído!" << std::endl;
        }
        delete g;
    }

    stats.makeCSV("./results/statistics.csv");
};

void renderScene(char* imagePath, int intensity)
{
    srand(static_cast<unsigned>(time(NULL)));

    IFCG::init(1200, 800, "TCC");
    IFCG::setup3D();

    auto* input = IFCG::getInputHandler();
    auto* renderer = IFCG::getRenderer();
    GLuint shader = renderer->getShaderID();

    auto [g, ids] = createGrayscaleGraph(imagePath, intensity);
    auto [startId, endId] = ids;

    if (startId == -1 || endId == -1) {
        std::cerr << "Erro: Coordenadas de início ou fim estão fora dos limites da imagem!" << std::endl;
        IFCG::terminate();
        return;
    }

    auto* floor = createMeshFromGraph(g, 0.5f, 0.5f, 0.5f, 1.0f, shader, GL_TRIANGLES);
    
    auto* outline = createMeshFromGraph(g, 0.8f, 0.8f, 0.8f, 1.0f, shader, GL_LINES);
    outline->translate(0.0f, 0.0f, 0.6f);

    auto* scene = new MeshTree();
    scene->addChild(floor);
    scene->addChild(outline);

    scene->rotate(-3.14159f / 2, 1.0f, 0.0f, 0.0f);

    std::vector<std::vector<common::Node*>> paths;

    paths.push_back(util::AStar::getPath(g, startId, endId, util::AStar::chebyshevHeuristic3D));
    paths.push_back(aStarMod(g, startId, endId, util::AStar::chebyshevHeuristic3D));
    paths.push_back(jumpPointSearch(g, startId, endId, util::AStar::chebyshevHeuristic3D));

    std::cout << "AStar = Vermelho\nAStarMod = Verde\nJump Point Search = Azul" << std::endl;
    for (int i = 0; i < paths.size(); ++i) {
        float r = (i == 0) ? 1.0f : 0.0f;
        float g = (i == 1) ? 1.0f : 0.0f;
        float b = (i == 2) ? 1.0f : 0.0f;

        auto* pathMesh = createMeshFromPath(paths[i], r, g, b, 1.0f, shader);
        pathMesh->translate(0.0f, 0.0f, 1.5f + i * 0.5f);
        scene->addChild(pathMesh);
    }

    renderer->addMesh(scene);

    auto* camera = renderer->getCamera();
    camera->setPos(glm::vec3(0.0f, (float)intensity, 0.0f));
    camera->rotate(-1.0f, glm::vec3(1.0f, 1.0f, 0.0f));

    input->addKeyCallback(GLFW_KEY_LEFT_SHIFT, [camera, input]() {
        if (input->isKeyHeld(GLFW_KEY_LEFT_SHIFT)){
            camera->setSpeed(0.5f);
        } else {
            camera->setSpeed(0.1f);
        }
    });

    IFCG::loop([&]() {});
    IFCG::terminate();
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

double calculatePathCost(const std::vector<common::Node*>& path, common::Graph* graph) {
    double totalCost = 0.0;
    for (size_t i = 0; i < path.size() - 1; ++i) {
        common::Node* current = path[i];
        common::Node* next = path[i + 1];
        common::Edge* edge = current->getEdgeTo(next);
        if (edge) {
            totalCost += graph->getWeights().at(edge);
        }
    }
    return totalCost;
}