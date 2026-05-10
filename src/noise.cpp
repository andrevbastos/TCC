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

using namespace ifcg;

int main(int argc, char* argv[]) {
    NoiseConfig noiseConfig;
    int intensity;
    float heightLimit;

    if (argc > 2) {
        intensity = std::stoi(argv[1]);
        heightLimit = std::stod(argv[2]);
        noiseConfig.width = (argc > 3) ? std::stoi(argv[3]) : 100;
        noiseConfig.height = (argc > 4) ? std::stoi(argv[4]) : 100;
        noiseConfig.octaves = (argc > 5) ? std::stoi(argv[5]) : 3;
        noiseConfig.wave = (argc > 6) ? std::stoi(argv[6]) : 50;
        noiseConfig.freq = (argc > 7) ? std::stof(argv[7]) : 4.0f;
        noiseConfig.amp = (argc > 8) ? std::stof(argv[8]) : 1.0f;
        noiseConfig.exp = (argc > 9) ? std::stof(argv[9]) : 1.0f;
        noiseConfig.seed = (argc > 10) ? std::stoul(argv[10]) : static_cast<unsigned int>(time(NULL));
    } else {
        std::cerr << "Usage: " << argv[0] << " <intensity> <heightLimit> <width> <height> <octaves> <wave> <freq> <amp> <exp> [seed]" << std::endl;
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
        auto data = generateNoiseMap(noiseConfig);
        
        auto width = noiseConfig.width;
        auto height = noiseConfig.height;
        
        auto graph = createlwGraphFromNoise(data, width, height, heightLimit, intensity);

        const std::string& savePath = "../results/noises/noise_temp.png";
        saveNoiseAsPNG(savePath, data, width, height);

        int startId = 0;
        int endId = width * height - 1;

        auto [floorVertices, floorIndices] = createMeshDataFromNoise(data, width, height, intensity, {0.6f, 0.6f, 0.6f, 1.0f});
        auto floorModel = glm::mat4(1.0f);
        floorModel = glm::rotate(floorModel, -3.14159f / 2, glm::vec3(1.0f, 0.0f, 0.0f));

        auto [outlineVertices, outlineIndices] = createMeshDataFromLwGraph(*graph, (float)intensity, {1.0f, 1.0f, 1.0f, 1.0f});
        auto outlineModel = glm::mat4(1.0f);
        outlineModel = glm::rotate(outlineModel, -3.14159f / 2, glm::vec3(1.0f, 0.0f, 0.0f));
        outlineModel = glm::translate(outlineModel, glm::vec3(0.0f, 0.0f, 0.6f));

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
            model = glm::rotate(model, -3.14159f / 2, glm::vec3(1.0f, 0.0f, 0.0f));
            model = glm::translate(model, glm::vec3(0.0f, 0.0f, 0.5f * currentPathIdx));

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
            model = glm::rotate(model, -3.14159f / 2, glm::vec3(1.0f, 0.0f, 0.0f));
            model = glm::translate(model, glm::vec3(0.0f, 0.0f, 0.5f * currentPathIdx));

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
            }
        }
    };
    
    Engine::loop(config);

    Engine::terminate();

    return 0;
}