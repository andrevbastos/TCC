#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

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

#include "statistics.hpp"
#include "monitor.hpp"
#include "util.hpp"

int main(int argc, char* argv[]) {
    char* imagePath;
    int intensity;
    float heightLimit;

    if (argc > 3) {
        imagePath = argv[1];
        intensity = std::stoi(argv[2]);
        heightLimit = std::stod(argv[3]);
    } else {
        std::cerr << "Usage: " << argv[0] << " <imagePath> <intensity> <heightLimit>" << std::endl;
        return 1;
    }

    srand(static_cast<unsigned>(time(NULL)));

    Engine::init(1200, 800, "TCC");
    Engine::setup3D();

    auto& input {Engine::getInputHandler()};
    auto& renderer {Engine::getRenderer()};
    GLuint shader {renderer.getShaderID()};

    Monitor monitor;
    std::queue<std::tuple<std::vector<Vertex>, std::vector<GLuint>, GLenum, glm::mat4>> newMeshesQueue;
    std::vector<std::shared_ptr<MeshBase>> activeMeshes;
    std::mutex meshesMutex;

    std::function<void()> createScene = [imagePath, intensity, heightLimit, shader, &meshesMutex, &newMeshesQueue, &monitor]() {
        auto [graph, startId, endId] = createLwGraphFromHeightmap(imagePath, intensity, heightLimit);
        
        if (!graph) return;

        int width, height, channels;

        auto [floorVertices, floorIndices] = createMeshDataFromHeightmap(imagePath, (float)intensity, {0.5f, 0.5f, 0.5f, 1.0f});
        auto floorModel = glm::mat4(1.0f);

        auto [outlineVertices, outlineIndices] = createMeshDataFromLwGraph(*graph, (float)intensity, {0.8f, 0.8f, 0.8f, 0.8f});
        auto outlineModel = glm::mat4(1.0f);
        outlineModel = glm::translate(outlineModel, glm::vec3(0.0f, 0.6f, 0.0f));

        {
            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(floorVertices, floorIndices, GL_TRIANGLES, floorModel));
            newMeshesQueue.push(std::make_tuple(outlineVertices, outlineIndices, GL_LINES, outlineModel));
        }

        auto stats = std::make_shared<Statistics>(1);
        auto pathCounter = std::make_shared<int>(1);

        auto aStarFunc = [graph, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter]() {
            int visitedNodes = 0;

            auto chebyshevHeuristic = [&](const auto& a, const auto& b) -> float {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            };
            
            auto startTime = std::chrono::high_resolution_clock::now();
            auto path = util::lwAStar<Vertex3D>(*graph, startId, endId, chebyshevHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;
        
            if (path.empty()) {
                std::cout << "A Star: Nenhum caminho encontrado de " << startId << " para " << endId << std::endl;
                return;
            }

            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                (*pathCounter)++;
                currentPathIdx = *pathCounter;
            }

            stats->addEntry("A Star", "Tempo de Execução", elapsed.count());
            stats->addEntry("A Star", "Custo do Caminho", calculatePathCostLW(path, *graph));
            stats->addEntry("A Star", "Número de Nós Expandidos", visitedNodes);

            stats->makeCSV("../results/statistics");

            int r = ((currentPathIdx + 1) >> 2) & 1;
            int g = ((currentPathIdx + 1) >> 1) & 1;
            int b = ((currentPathIdx + 1) >> 0) & 1;

            auto [pathVertices, pathIndices] = createMeshDataFromLwPath(*graph, path, {(float)r, (float)g, (float)b, 1.0f});
            auto model = glm::mat4(1.0f);
            model = glm::translate(model, glm::vec3(0.0f, 0.5f * currentPathIdx, 0.0f));

            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model)); 
        };

        auto aStarModFunc = [graph, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter]() {
            int visitedNodes = 0;

            auto chebyshevHeuristic = [&](const auto& a, const auto& b) -> float {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            };

            auto startTime = std::chrono::high_resolution_clock::now();
            auto path = util::lwAStarMod<Vertex3D>(*graph, startId, endId, chebyshevHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;

            if (path.empty()) {
                std::cout << "A Star Modified: Nenhum caminho encontrado de " << startId << " para " << endId << std::endl;
                return;
            }

            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                (*pathCounter)++;
                currentPathIdx = *pathCounter;
            }

            stats->addEntry("A Star Modified", "Tempo de Execução", elapsed.count());
            stats->addEntry("A Star Modified", "Custo do Caminho", calculatePathCostLW(path, *graph));
            stats->addEntry("A Star Modified", "Número de Nós Expandidos", visitedNodes);
            
            stats->makeCSV("../results/statistics");
            
            int r = ((currentPathIdx + 1) >> 2) & 1;
            int g = ((currentPathIdx + 1) >> 1) & 1;
            int b = ((currentPathIdx + 1) >> 0) & 1;

            auto [pathVertices, pathIndices] = createMeshDataFromLwPath(*graph, path, {(float)r, (float)g, (float)b, 1.0f});
            auto model = glm::mat4(1.0f);
            model = glm::translate(model, glm::vec3(0.0f, 0.5f * currentPathIdx, 0.0f));

            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model));
        };

        monitor.addTask(aStarFunc, Priority::Medium);
        monitor.addTask(aStarModFunc, Priority::Medium);
    };

    auto& camera {renderer.getCamera()};
    camera.setPosition(glm::vec3(-25.0f, (float)intensity * 0.9f, -25.0f));
    camera.setOrientation(glm::vec3(0.6, -0.5, 0.6));
    renderer.setFarPlane(1000.0f);

    monitor.addTask(createScene, Priority::High);

    input.addKeyCallback(Key::K, KeyAction::PRESS, [&]() {
        for (auto& mesh : activeMeshes) {
            renderer.removeMesh(mesh);
        }
        activeMeshes.clear();
        
        {
            std::lock_guard<std::mutex> lock(meshesMutex);
            while(!newMeshesQueue.empty()) newMeshesQueue.pop();
        }
        
        monitor.addTask(createScene, Priority::High);

        camera.setPosition(glm::vec3(-25.0f, (float)intensity * 0.9f, -25.0f));
        camera.setOrientation(glm::vec3(0.6, -0.5, 0.6));
    });

    input.addKeyCallback(Key::SHIFT_L, KeyAction::HELD, [&camera]() {
        camera.setSpeed(1.0f);
    });

    input.addKeyCallback(Key::SHIFT_L, KeyAction::RELEASE, [&camera]() {
        camera.setSpeed(0.5f);
    });

    LoopConfig config {
        .loopBody = [&]() {
            std::shared_ptr<MeshBase> newMesh;
            bool hasNewMesh = false;

            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                if (!newMeshesQueue.empty()) {
                    newMesh = std::make_shared<Mesh>(std::get<0>(newMeshesQueue.front()), std::get<1>(newMeshesQueue.front()), shader, std::get<2>(newMeshesQueue.front()));
                    newMesh->setModel(std::get<3>(newMeshesQueue.front()));
                    newMeshesQueue.pop();
                    hasNewMesh = true;
                }
            }

            if (hasNewMesh) {
                renderer.addMesh(newMesh);
                activeMeshes.push_back(newMesh);
            }
        }
    };
    
    Engine::loop(config);
    Engine::terminate();

    return 0;
}