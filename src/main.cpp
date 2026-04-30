#include <iostream>
#include <filesystem>
#include <atomic>
#include <thread>
#include <chrono>
#include <mutex>
#include <graph/undirected/graph.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/dijkstra.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>
#include <ifcg/graphics/primitives/sphere.hpp>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#include "statistics.hpp"
#include "graph_gen.hpp"
#include "monitor.hpp"
#include "util.hpp"

namespace fs = std::filesystem;

const int iterations = 10;

void getStatistics();
void renderScene(char* imagePath, int intensity, double heightLimit);
void warmUp();
double calculatePathCost(const std::vector<common::Node*>& path, common::Graph* graph);
double calculatePathCostLW(const std::vector<int>& path, const common::lwGraph<Vertex3D>& graph);

int main(int argc, char* argv[]) {
    if (argc > 3) {
        char* imagePath = argv[1];
        int intensity = std::stoi(argv[2]);
        double heightLimit = std::stod(argv[3]);
        renderScene(imagePath, intensity, heightLimit);
    } else if (argc == 0) {
        getStatistics();
    } else {
        std::cerr << "Usage: " << argv[0] << " <imagePath> <intensity> <heightLimit>" << std::endl;
        std::cerr << "Or run without arguments to get statistics." << std::endl;
    }

    return 0;
};

void getStatistics() {
    warmUp();

    int intensity = 50;
    Statistics stats(iterations);
    std::string path = "../resources/grayscales";
    
    using HeuristicFuncLW = std::function<double(const Vertex3D&, const Vertex3D&)>;
    using AlgFunc = std::function<std::vector<int>(const common::lwGraph<Vertex3D>&, int, int, HeuristicFuncLW)>;

    std::unordered_map<std::string, AlgFunc> algorithms = {
        {"A Star", util::lwAStar<Vertex3D>},
        {"A Star Modified", util::lwAStarMod<Vertex3D>}
    };

    int nosAvaliados = 0;
    auto trackingHeuristic = [&](const auto& a, const auto& b) -> double {
        nosAvaliados++;
        return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
    };

    for (const auto& entry : fs::directory_iterator(path)) {
        if (entry.path().extension() != ".png") continue;

        std::cout << entry.path().filename().string() << std::flush;
        
        auto [g, ids] = createLwGraphFromHeightmap(entry.path().c_str(), intensity, intensity / 10.0);
        auto [startId, endId] = ids;
        
        if (startId == -1 || endId == -1) {
            std::cout << " Erro: Fora dos limites!" << std::endl;
            g.reset();
            continue;
        }
        
        std::cout << ":" << std::endl;
        
        for (const auto& alg : algorithms) {
            nosAvaliados = 0;

            std::cout << "\t" << alg.first << "..." << std::flush;

            auto startTime = std::chrono::high_resolution_clock::now();
            
            auto path = alg.second(*g, startId, endId, trackingHeuristic);
            
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double> elapsed = endTime - startTime;

            stats.addEntry(alg.first, "Tempo de Execução", elapsed.count());
            stats.addEntry(alg.first, "Custo do Caminho", calculatePathCostLW(path, *g));
            stats.addEntry(alg.first, "Número de Nós Expandidos", nosAvaliados);

            std::cout << " concluído!" << std::endl;
            std::cout << "\tTempo de Execução: " << elapsed.count() << " segundos" << std::endl;
            std::cout << "\tCusto do Caminho: " << calculatePathCostLW(path, *g) << std::endl;
            std::cout << "\tNúmero de Nós Expandidos: " << nosAvaliados << "\n" << std::endl;
        }

        g.reset();
    }

    stats.makeCSV("../results/statistics");
}

void renderScene(char* imagePath, int intensity, double heightLimit) {
    srand(static_cast<unsigned>(time(NULL)));

    IFCG::init(1200, 800, "TCC");
    IFCG::setup3D();

    auto& input {IFCG::getInputHandler()};
    auto& renderer {IFCG::getRenderer()};
    GLuint shader {renderer.getShaderID()};

    auto [scene, graph, ids] = createSceneFromHeightmap(imagePath, intensity, heightLimit, shader);
    auto [startId, endId] = ids;

    renderer.addMesh(scene);

    auto& camera {renderer.getCamera()};
    camera.setPos(glm::vec3(0.0f, (float)intensity, 0.0f));
    camera.rotate(-1.0f, glm::vec3(1.0f, 1.0f, 0.0f));
    renderer.setFarPlane(1000.0f);

    input.addKeyCallback(GLFW_KEY_LEFT_SHIFT, [&camera, &input]() {
        if (input.isKeyHeld(GLFW_KEY_LEFT_SHIFT)){
            camera.setSpeed(0.5f);
        } else {
            camera.setSpeed(0.1f);
        }
    });

    std::queue<std::pair<int, std::vector<int>>> readyPathsQueue;
    std::mutex pathsMutex;

    Statistics stats(1);
    
    std::function<void()> aStarFunc = [&]() {
        int visitedNodes = 0;

        auto chebyshevHeuristic {
            [&](const auto& a, const auto& b) -> double {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            }
        };
        
        auto startTime = std::chrono::high_resolution_clock::now();
        auto path = util::lwAStar<Vertex3D>(*graph, startId, endId, chebyshevHeuristic);
        auto endTime = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> elapsed = endTime - startTime;
        
        stats.addEntry("A Star", "Tempo de Execução", elapsed.count());
        stats.addEntry("A Star", "Custo do Caminho", calculatePathCostLW(path, *graph));
        stats.addEntry("A Star", "Número de Nós Expandidos", visitedNodes);
        
        std::lock_guard<std::mutex> lock(pathsMutex);
        readyPathsQueue.push({0, std::move(path)}); 
    };

    std::function<void()> aStarModFunc = [&]() {
        int visitedNodes = 0;

        auto chebyshevHeuristic {
            [&](const auto& a, const auto& b) -> double {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            }
        };

        auto startTime = std::chrono::high_resolution_clock::now();
        auto path = util::lwAStarMod<Vertex3D>(*graph, startId, endId, chebyshevHeuristic);
        auto endTime = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> elapsed = endTime - startTime;

        stats.addEntry("A Star Modified", "Tempo de Execução", elapsed.count());
        stats.addEntry("A Star Modified", "Custo do Caminho", calculatePathCostLW(path, *graph));
        stats.addEntry("A Star Modified", "Número de Nós Expandidos", visitedNodes);

        std::lock_guard<std::mutex> lock(pathsMutex);
        readyPathsQueue.push({1, std::move(path)});
    };

    LoopConfig config {
        .loopBody = [&]() {
            std::pair<int, std::vector<int>> newPath;
            bool hasNewPath = false;

            {
                std::lock_guard<std::mutex> lock(pathsMutex);
                if (!readyPathsQueue.empty()) {
                    newPath = std::move(readyPathsQueue.front());
                    readyPathsQueue.pop();
                    hasNewPath = true;
                }
            }

            if (hasNewPath) {
                int i = newPath.first;
                const auto& pathNodes = newPath.second;
                
                int r = ((i + 1) >> 2) & 1;
                int g = ((i + 1) >> 1) & 1;
                int b = ((i + 1) >> 0) & 1;

                auto pathMesh = createMeshFromLwPath(*graph, pathNodes, shader, {(float)r, (float)g, (float)b, 1.0f});
                
                pathMesh->translate(0.0f, 0.0f, 1.5f + i * 0.5f);
                scene->addChild(pathMesh);
                stats.makeCSV("../results/statistics");
            }
        }
    };

    Monitor monitor;
    monitor.addTask(aStarFunc, Priority::Medium);
    monitor.addTask(aStarModFunc, Priority::Medium);
    
    IFCG::loop(config);

    IFCG::terminate();
}

void warmUp() {
    undirected::Graph warmUpGraph;
    for (int i = 0; i < 10; ++i) {
        warmUpGraph.newVertex(std::make_tuple(i, 0, 0));
    }
    for (int i = 0; i < 9; ++i) {
        warmUpGraph.newEdge(warmUpGraph.getVertex(i), warmUpGraph.getVertex(i + 1));
    }

    for (int w_i = 0; w_i < 5; ++w_i) {
        util::AStar(&warmUpGraph, 0, 9, util::heuristics::euclideanHeuristic3D);
        util::AStarMod(&warmUpGraph, 0, 9, util::heuristics::chebyshevHeuristic3D);
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

double calculatePathCostLW(const std::vector<int>& path, const common::lwGraph<Vertex3D>& graph) {
    if (path.size() < 2) return 0.0; 
    
    double totalCost = 0.0;
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