#include <iostream>
#include <filesystem>
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

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include "statistics.hpp"
#include "deprecated.hpp"
#include "ray_cast.hpp"
#include "monitor.hpp"
#include "util.hpp"

double calculatePathCostLW(const std::vector<int>& path, const common::lwGraph<Vertex3D>& graph);

int main(int argc, char* argv[]) {
    NoiseConfig noiseConfig;
    int intensity;
    double heightLimit;

    if (argc > 2) {
        intensity = std::stoi(argv[1]);
        heightLimit = std::stod(argv[2]);
        noiseConfig.width = (argc > 3) ? std::stoi(argv[3]) : 100;
        noiseConfig.height = (argc > 4) ? std::stoi(argv[4]) : 100;
        noiseConfig.wave = (argc > 5) ? std::stoi(argv[5]) : 50;
        noiseConfig.freq = (argc > 6) ? std::stof(argv[6]) : 4.0f;
        noiseConfig.amp = (argc > 7) ? std::stof(argv[7]) : 1.0f;
        noiseConfig.exp = (argc > 8) ? std::stof(argv[8]) : 1.0f;
    } else {
        std::cerr << "Usage: " << argv[0] << " <intensity> <heightLimit> <width> <height> <gridSize> <freq> <amp> <exp>" << std::endl;
        return 1;
    }

    srand(static_cast<unsigned>(time(NULL)));

    Engine::init(1200, 800, "TCC");
    Engine::setup3D();

    auto& input {Engine::getInputHandler()};
    auto& renderer {Engine::getRenderer()};
    GLuint shader {renderer.getShaderID()};

    Monitor monitor;
    
    
    auto [scene, graph, ids] = createSceneFromNoise(noiseConfig, intensity, heightLimit, shader, {0.5f, 0.5f, 0.5f, 1.0f}, {0.8f, 0.8f, 0.8f, 0.8f});
    
    if (!scene || !graph) {
        std::cerr << "Erro: Falha ao criar a cena ou o grafo. Verifique se a imagem existe." << std::endl;
        Engine::terminate();
        return 1;
    }

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

    monitor.addTask(aStarFunc, Priority::Medium);
    monitor.addTask(aStarModFunc, Priority::Medium);
    
    Engine::loop(config);

    Engine::terminate();

    return 0;
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