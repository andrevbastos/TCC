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
    std::queue<std::tuple<std::vector<Vertex>, std::vector<GLuint>, GLenum, glm::mat4>> newMeshesQueue;
    std::mutex meshesMutex;

    std::function<void()> createScene = [&]() {
        std::vector<Vertex> vertices;
        std::vector<GLuint> indices;

        int startId = -1, endId = -1;
        
        auto data = generateNoiseMap(noiseConfig);

        auto width = noiseConfig.width;
        auto height = noiseConfig.height;

        const std::string& savePath = "../results/noises/noise_temp.png";
        saveNoiseAsPNG(savePath, data, width, height);

        auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(width * height);

        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                float z = (data[y * width + x] * intensity); 
                
                int currentId = y * width + x;
                
                vertices.emplace_back(x, y, z, 0.5f, 0.5f, 0.5f, 1.0f);
                
                graph->setVertex(currentId, {
                    static_cast<double>(x), 
                    static_cast<double>(y), 
                    static_cast<double>(z)
                });
            }
        }

        for (int y = 0; y < height - 1; ++y) {
            for (int x = 0; x < width - 1; ++x) {
                int topLeft = y * width + x;
                int topRight = y * width + (x + 1);
                int bottomLeft = (y + 1) * width + x;
                int bottomRight = (y + 1) * width + (x + 1);

                indices.push_back(topLeft);
                indices.push_back(bottomLeft);
                indices.push_back(topRight);

                indices.push_back(topRight);
                indices.push_back(bottomLeft);
                indices.push_back(bottomRight);

                int currentId = y * width + x;
                const auto& currentData = graph->getVertexData(currentId);
                
                if (currentData.z == 0.0) continue;

                auto addEdgeWithCost = [&](int targetX, int targetY) {
                    int targetId = targetY * width + targetX;
                    const auto& targetData = graph->getVertexData(targetId);
                    
                    if (targetData.z == 0.0 || std::abs(targetData.z - currentData.z) > heightLimit) return;

                    double cost = std::sqrt(std::pow(currentData.x - targetData.x, 2) + std::pow(currentData.y - targetData.y, 2) + std::pow(currentData.z - targetData.z, 2));
                    
                    graph->addEdge(currentId, targetId, cost);
                };

                if (x + 1 < width) addEdgeWithCost(x + 1, y);
                if (y + 1 < height) addEdgeWithCost(x, y + 1);
                if (x + 1 < width && y + 1 < height) addEdgeWithCost(x + 1, y + 1);
                if (x - 1 >= 0 && y + 1 < height) addEdgeWithCost(x - 1, y + 1);

                if (startId == -1) startId = currentId;
                endId = currentId;
            }
        }

        auto floorModel = glm::mat4(1.0f);
        floorModel = glm::rotate(floorModel, -3.14159f / 2, glm::vec3(1.0f, 0.0f, 0.0f));

        auto outlineModel = glm::mat4(1.0f);
        outlineModel = glm::rotate(outlineModel, -3.14159f / 2, glm::vec3(1.0f, 0.0f, 0.0f));
        outlineModel = glm::translate(outlineModel, glm::vec3(0.0f, 0.0f, 0.6f));

        auto floor = std::make_shared<Mesh>(vertices, indices, shader);
        auto [verticesOutline, indicesOutline] = createMeshDataFromLwGraph(*graph, shader, {0.8f, 0.8f, 0.8f, 0.8f});

        {
            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(vertices, indices, GL_TRIANGLES, floorModel));
            newMeshesQueue.push(std::make_tuple(verticesOutline, indicesOutline, GL_LINES, outlineModel));
        }

        auto stats = std::make_shared<Statistics>(1);
        int pathCounter = 1;

        auto aStarFunc = [graph, startId, endId, stats, &meshesMutex, &newMeshesQueue, &pathCounter]() mutable {
            int visitedNodes = 0;

            auto chebyshevHeuristic = [&](const auto& a, const auto& b) -> double {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            };
            
            auto startTime = std::chrono::high_resolution_clock::now();
            auto path = util::lwAStar<Vertex3D>(*graph, startId, endId, chebyshevHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double> elapsed = endTime - startTime;
        
            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                pathCounter++;
                currentPathIdx = pathCounter;
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
            model = glm::rotate(model, -3.14159f / 2, glm::vec3(1.0f, 0.0f, 0.0f));
            model = glm::translate(model, glm::vec3(0.0f, 0.0f, 2.0f * currentPathIdx));

            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model)); 
        };

        auto aStarModFunc = [graph, startId, endId, stats, &meshesMutex, &newMeshesQueue, &pathCounter]() mutable {
            int visitedNodes = 0;

            auto chebyshevHeuristic = [&](const auto& a, const auto& b) -> double {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            };

            auto startTime = std::chrono::high_resolution_clock::now();
            auto path = util::lwAStarMod<Vertex3D>(*graph, startId, endId, chebyshevHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double> elapsed = endTime - startTime;

            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                pathCounter++;
                currentPathIdx = pathCounter;
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
            model = glm::rotate(model, -3.14159f / 2, glm::vec3(1.0f, 0.0f, 0.0f));
            model = glm::translate(model, glm::vec3(0.0f, 0.0f, 2.0f * currentPathIdx));

            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model));
        };

        monitor.addTask(aStarFunc, Priority::Medium);
        monitor.addTask(aStarModFunc, Priority::Medium);
    };

    monitor.addTask(createScene, Priority::High);
    
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
            }
        }
    };
    
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