#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <vector>
#include <functional>
#include <CLI11/CLI11.hpp>
#include <graph/common/lw_grid.hpp>
#include <graph/common/lw_graph.hpp>
#include <graph/util/dijkstra.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/jps.hpp>
#include <graph/util/node_data.hpp>

#include "statistics.hpp"
#include "util.hpp"
#include "task.hpp"

namespace fs = std::filesystem;

void noise(uint intensity, float heightLimit, NoiseConfig noiseConfig, const std::string& saveDir);
void map(const char* imagePath, uint intensity, float heightLimit);
void stats(uint repetitions, uint steps, uint intensity, float heightLimit);

int main(int argc, char* argv[]) {   
    CLI::App app{"PATHFINDING EM MALHAS 3D, André Vitor B. de Macêdo"};

    uint repetitions = 5;
    uint steps = 4;
    uint intensity = 100;
    float heightLimit = 2.5f;
    std::string path = "../results/";
    NoiseConfig noiseConfig = {
        .width = 250,
        .height = 250,
        .wave = 50,
        .freq = 1.0f,
        .amp = 1.0f,
        .exp = 1.0f,
        .seed = static_cast<unsigned int>(time(NULL)),
        .octaves = 5
    };

    auto noiseCmd = app.add_subcommand("noise", "Executa o teste de ruído");
    noiseCmd->add_option("intensity", intensity, "Intensidade do ruído")->check(CLI::PositiveNumber)->required();
    noiseCmd->add_option("heightLimit", heightLimit, "Limite de altura para o caminho")->check(CLI::PositiveNumber)->required();
    noiseCmd->add_option("width,--width", noiseConfig.width, "Largura do mapa")->check(CLI::PositiveNumber);
    noiseCmd->add_option("height,--height", noiseConfig.height, "Altura do mapa")->check(CLI::PositiveNumber);
    noiseCmd->add_option("octaves,--octaves", noiseConfig.octaves, "Número de oitavas")->check(CLI::PositiveNumber);
    noiseCmd->add_option("wave,-w,--wave", noiseConfig.wave, "Tamanho da onda")->check(CLI::PositiveNumber);
    noiseCmd->add_option("freq, -f,--freq", noiseConfig.freq, "Frequência do ruído")->check(CLI::PositiveNumber);
    noiseCmd->add_option("amp,-a,--amp", noiseConfig.amp, "Amplitude do ruído")->check(CLI::PositiveNumber);
    noiseCmd->add_option("exp,-e,--exp", noiseConfig.exp, "Exponente do ruído")->check(CLI::PositiveNumber);
    noiseCmd->add_option("seed,-s,--seed", noiseConfig.seed, "Semente do gerador de números aleatórios")->check(CLI::PositiveNumber);
    noiseCmd->add_option("savePath,--save", path, "Diretório para salvar os resultados")->check(CLI::ExistingDirectory);
    noiseCmd->callback([&]() { noise(intensity, heightLimit, noiseConfig, path); });

    auto mapCmd = app.add_subcommand("map", "Executa o teste de mapa");
    mapCmd->add_option("imagePath", path, "Caminho para a imagem do mapa")->check(CLI::ExistingFile)->required();
    mapCmd->add_option("intensity", intensity, "Intensidade do ruído")->check(CLI::PositiveNumber)->required();
    mapCmd->add_option("heightLimit", heightLimit, "Limite de altura para o caminho")->check(CLI::PositiveNumber)->required();
    mapCmd->callback([&]() { map(path.c_str(), intensity, heightLimit); });

    auto statsCmd = app.add_subcommand("stats", "Executa os testes de estatísticas");
    statsCmd->add_option("repetitions", repetitions, "Número de repetições para cada teste")->check(CLI::PositiveNumber)->required();
    statsCmd->add_option("steps", steps, "Número de passos para cada teste")->check(CLI::PositiveNumber)->required();
    statsCmd->add_option("intensity", intensity, "Intensidade do ruído")->check(CLI::PositiveNumber)->required();
    statsCmd->add_option("heightLimit", heightLimit, "Limite de altura para o caminho")->check(CLI::PositiveNumber)->required();
    statsCmd->callback([&]() { stats(repetitions, steps, intensity, heightLimit); });

    CLI11_PARSE(app, argc, argv);

    return 0;
};

void noise(uint intensity, float heightLimit, NoiseConfig noiseConfig, const std::string& saveDir) {
    using namespace ifcg;

    srand(static_cast<unsigned>(time(NULL)));

    Engine::init(1200, 800, "TCC");
    Engine::setup3D();

    auto& input {Engine::getInputHandler()};
    auto& renderer {Engine::getRenderer()};
    GLuint shader {renderer.getShaderID()};

    TaskMaster tm;
    std::queue<std::tuple<std::vector<Vertex>, std::vector<GLuint>, GLenum, glm::mat4>> newMeshesQueue;
    std::vector<std::shared_ptr<MeshBase>> activeMeshes;
    std::mutex meshesMutex;

    std::function<void()> createScene = [&]() {
        noiseConfig.seed = static_cast<unsigned int>(time(NULL));
        auto data = generateNoiseMap(noiseConfig);
        
        auto width = noiseConfig.width;
        auto height = noiseConfig.height;
        
        auto graph = createlwGraphFromNoise(data, width, height, heightLimit, intensity);

        fs::path savePath = fs::path(saveDir) / "noise_temp.png";
        saveNoiseAsPNG(savePath, data, width, height);

        int startId = 0;
        int endId = width * height - 1;

        auto [floorVertices, floorIndices] = createMeshDataFromNoise(data, width, height, intensity, {0.6f, 0.6f, 0.6f, 1.0f});
        auto floorModel = glm::mat4(1.0f);

        auto [outlineVertices, outlineIndices] = createMeshDataFromLwGraph(*graph, (float)intensity, {1.0f, 1.0f, 1.0f, 1.0f});
        auto outlineModel = glm::mat4(1.0f);
        outlineModel = glm::translate(outlineModel, glm::vec3(0.0f, 0.6f, 0.0f));

        {
            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(floorVertices, floorIndices, GL_TRIANGLES, floorModel));
            newMeshesQueue.push(std::make_tuple(outlineVertices, outlineIndices, GL_LINES, outlineModel));
        }

        auto stats = std::make_shared<Statistics>(1);
        auto pathCounter = std::make_shared<int>(1);

        auto reconstructPath = [width](const std::vector<int>& path) {
            std::vector<int> fullPath;
            if (path.empty()) return fullPath;
            
            for (size_t i = 0; i < path.size() - 1; ++i) {
                int curr = path[i];
                int next = path[i + 1];
                
                int x1 = curr % width, y1 = curr / width;
                int x2 = next % width, y2 = next / width;
                
                int dx = (x2 > x1) ? 1 : (x2 < x1 ? -1 : 0);
                int dy = (y2 > y1) ? 1 : (y2 < y1 ? -1 : 0);
                
                int x = x1, y = y1;
                while (x != x2 || y != y2) {
                    fullPath.push_back(y * width + x);
                    if (x != x2) x += dx;
                    if (y != y2) y += dy;
                }
            }
            fullPath.push_back(path.back());
            return fullPath;
        };

        auto aStarFunc = [graph, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter, reconstructPath]() {
            int visitedNodes = 0;

            auto chebyshevHeuristic = [&](const auto& a, const auto& b) -> float {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            };
            
            auto startTime = std::chrono::high_resolution_clock::now();
            auto rawPath = util::lwAStar<Vertex3D>(*graph, startId, endId, chebyshevHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;
            
            auto path = reconstructPath(rawPath);
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

            auto [pathVertices, pathIndices] = createMeshDataFromLwPath(*graph, path, {1.0f, 0.0f, 0.0f, 1.0f});
            auto model = glm::mat4(1.0f);
            model = glm::translate(model, glm::vec3(0.0f, 0.5f * currentPathIdx, 0.0f));

            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model)); 
        };

        auto aStarModFunc = [graph, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter, reconstructPath]() {
            int visitedNodes = 0;

            auto chebyshevHeuristic = [&](const auto& a, const auto& b) -> float {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            };

            auto startTime = std::chrono::high_resolution_clock::now();
            auto rawPath = util::lwAStarMod<Vertex3D>(*graph, startId, endId, chebyshevHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;
            
            auto path = reconstructPath(rawPath);
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

            auto [pathVertices, pathIndices] = createMeshDataFromLwPath(*graph, path, {0.0f, 1.0f, 0.0f, 1.0f});
            auto model = glm::mat4(1.0f);
            model = glm::translate(model, glm::vec3(0.0f, 0.5f * currentPathIdx, 0.0f));

            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model));
        };

        auto dijkstraFunc = [graph, data, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter, reconstructPath]() {
            int visitedNodes = 0;

            auto zeroHeuristic = [&](const auto& a, const auto& b) -> float {
                visitedNodes++;
                return 0.0f;
            };

            auto startTime = std::chrono::high_resolution_clock::now();
            auto rawPath = util::lwAStar<Vertex3D>(*graph, startId, endId, zeroHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;
            
            auto path = reconstructPath(rawPath);
            if (path.empty()) {
                std::cout << "Dijkstra: Nenhum caminho encontrado de " << startId << " para " << endId << std::endl;
                return;
            }

            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                (*pathCounter)++;
                currentPathIdx = *pathCounter;
            }

            stats->addEntry("Dijkstra", "Tempo de Execução", elapsed.count());
            stats->addEntry("Dijkstra", "Custo do Caminho", calculatePathCostLW(path, *graph));
            stats->addEntry("Dijkstra", "Número de Nós Expandidos", visitedNodes);

            stats->makeCSV("../results/statistics");

            auto [pathVertices, pathIndices] = createMeshDataFromLwPath(*graph, path, {0.0f, 0.0f, 1.0f, 1.0f});
            auto model = glm::mat4(1.0f);
            model = glm::translate(model, glm::vec3(0.0f, 0.5f * currentPathIdx, 0.0f));

            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model)); 
        };

        auto thetaStarFunc = [graph, width, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter, heightLimit]() {
            int visitedNodes = 0;
            auto chebyshevHeuristic = [&](const auto& a, const auto& b) -> float {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            };
            std::function<bool(int, int)> los = [&](int start, int end) -> bool {
                int w = width;
                int x0 = start % w;
                int y0 = start / w;
                int x1 = end % w;
                int y1 = end / w;
                int dx = std::abs(x1 - x0);
                int dy = std::abs(y1 - y0);
                int sx = (x0 < x1) ? 1 : -1;
                int sy = (y0 < y1) ? 1 : -1;
                int err = dx - dy;
                int x = x0;
                int y = y0;
                float lastZ = graph->getVertexData(start).z;
                while (true) {
                    int currentId = y * w + x;
                    float currentZ = graph->getVertexData(currentId).z;
                    if (std::abs(currentZ - lastZ) > heightLimit) {
                        return false;
                    }
                    lastZ = currentZ;
                    if (x == x1 && y == y1) {
                        break;
                    }
                    int e2 = 2 * err;
                    if (e2 > -dy) {
                        err -= dy;
                        x += sx;
                    }
                    if (e2 < dx) {
                        err += dx;
                        y += sy;
                    }
                }
                return true;
            };
            auto startTime = std::chrono::high_resolution_clock::now();
            auto rawPath = util::lwThetaStar<Vertex3D>(*graph, startId, endId, chebyshevHeuristic, los);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;
            
            auto path = reconstructPathLW(rawPath, width);
            if (path.empty()) {
                std::cout << "Theta Star: Nenhum caminho encontrado de " << startId << " para " << endId << std::endl;
                return;
            }
            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                (*pathCounter)++;
                currentPathIdx = *pathCounter;
            }
            stats->addEntry("Theta Star", "Tempo de Execução", elapsed.count());
            stats->addEntry("Theta Star", "Custo do Caminho", calculatePathCostLW(path, *graph));
            stats->addEntry("Theta Star", "Número de Nós Expandidos", visitedNodes);
            stats->makeCSV("../results/statistics");
            
            auto [pathVertices, pathIndices] = createMeshDataFromLwPath(*graph, path, {1.0f, 0.5f, 0.0f, 1.0f});
            auto model = glm::mat4(1.0f);
            model = glm::translate(model, glm::vec3(0.0f, 0.5f * currentPathIdx, 0.0f));
            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model));
        };

        auto jpsFunc = [graph, width, height, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter, heightLimit]() {
            std::vector<unsigned int> gridData(width * height, 1);
            common::lwGrid grid(width, height, gridData);
            auto validator = [&](int fromId, int toId) {
                const auto& fromData = graph->getVertexData(fromId);
                const auto& toData = graph->getVertexData(toId);
                return std::abs(fromData.z - toData.z) <= heightLimit;
            };
            util::JumpPointSearchLw jps(grid, validator);
            auto jpsHeuristic = [](const util::Vertex2D& a, const util::Vertex2D& b) -> double {
                return std::sqrt(std::pow(a.x - b.x, 2) + std::pow(a.y - b.y, 2));
            };
            auto startTime = std::chrono::high_resolution_clock::now();
            auto rawPath = jps.find(startId, endId, jpsHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;
            
            auto path = reconstructPathLW(rawPath, width);
            if (path.empty()) {
                std::cout << "JPS: Nenhum caminho encontrado de " << startId << " para " << endId << std::endl;
                return;
            }
            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                (*pathCounter)++;
                currentPathIdx = *pathCounter;
            }
            stats->addEntry("JPS", "Tempo de Execução", elapsed.count());
            stats->addEntry("JPS", "Custo do Caminho", calculatePathCostLW(path, *graph));
            stats->addEntry("JPS", "Número de Nós Expandidos", 0);
            stats->makeCSV("../results/statistics");
            
            auto [pathVertices, pathIndices] = createMeshDataFromLwPath(*graph, path, {1.0f, 0.0f, 1.0f, 1.0f});
            auto model = glm::mat4(1.0f);
            model = glm::translate(model, glm::vec3(0.0f, 0.5f * currentPathIdx, 0.0f));
            std::lock_guard<std::mutex> lock(meshesMutex);
            newMeshesQueue.push(std::make_tuple(pathVertices, pathIndices, GL_LINES, model));
        };

        tm.addTask(aStarFunc, Priority::Medium);
        tm.addTask(aStarModFunc, Priority::Medium);
        tm.addTask(dijkstraFunc, Priority::Medium);
        tm.addTask(thetaStarFunc, Priority::Medium);
        tm.addTask(jpsFunc, Priority::Medium);
    };
    
    auto& camera {renderer.getCamera()};
    camera.setPosition(glm::vec3(-25.0f, (float)intensity * 0.9f, -25.0f));
    camera.setOrientation(glm::vec3(0.6, -0.5, 0.6));
    renderer.setFarPlane(1000.0f);

    input.addKeyCallback(Key::K, KeyAction::PRESS, [&]() {
        for (auto& mesh : activeMeshes) {
            renderer.removeMesh(mesh);
        }
        activeMeshes.clear();

        {
            std::lock_guard<std::mutex> lock(meshesMutex);
            while(!newMeshesQueue.empty()) newMeshesQueue.pop();
        }

        tm.addTask(createScene, Priority::High);
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
};

void map(const char* imagePath, uint intensity, float heightLimit) {
    Engine::init(1200, 800, "TCC");
    Engine::setup3D();

    auto& input {Engine::getInputHandler()};
    auto& renderer {Engine::getRenderer()};
    GLuint shader {renderer.getShaderID()};

    TaskMaster tm;
    std::queue<std::tuple<std::vector<Vertex>, std::vector<GLuint>, GLenum, glm::mat4>> newMeshesQueue;
    std::vector<std::shared_ptr<MeshBase>> activeMeshes;
    std::mutex meshesMutex;

    std::function<void()> createScene = [imagePath, intensity, heightLimit, shader, &meshesMutex, &newMeshesQueue, &tm]() {
        auto [graph, startId, endId] = createLwGraphFromHeightmap(imagePath, intensity, heightLimit);
        
        if (!graph) return;

        int width = graph->getOrder();
        for (int i = 0; i < graph->getOrder(); ++i) {
            if (graph->getVertexData(i).y > 0.0f) {
                width = i;
                break;
            }
        }
        int height = graph->getOrder() / width;

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

        auto thetaStarFunc = [graph, width, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter, heightLimit]() {
            int visitedNodes = 0;
            auto chebyshevHeuristic = [&](const auto& a, const auto& b) -> float {
                visitedNodes++;
                return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
            };
            std::function<bool(int, int)> los = [&](int start, int end) -> bool {
                int w = width;
                int x0 = start % w;
                int y0 = start / w;
                int x1 = end % w;
                int y1 = end / w;
                int dx = std::abs(x1 - x0);
                int dy = std::abs(y1 - y0);
                int sx = (x0 < x1) ? 1 : -1;
                int sy = (y0 < y1) ? 1 : -1;
                int err = dx - dy;
                int x = x0;
                int y = y0;
                float lastZ = graph->getVertexData(start).z;
                while (true) {
                    int currentId = y * w + x;
                    float currentZ = graph->getVertexData(currentId).z;
                    if (std::abs(currentZ - lastZ) > heightLimit) {
                        return false;
                    }
                    lastZ = currentZ;
                    if (x == x1 && y == y1) {
                        break;
                    }
                    int e2 = 2 * err;
                    if (e2 > -dy) {
                        err -= dy;
                        x += sx;
                    }
                    if (e2 < dx) {
                        err += dx;
                        y += sy;
                    }
                }
                return true;
            };
            auto startTime = std::chrono::high_resolution_clock::now();
            auto rawPath = util::lwThetaStar<Vertex3D>(*graph, startId, endId, chebyshevHeuristic, los);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;
            
            auto path = reconstructPathLW(rawPath, width);
            if (path.empty()) {
                std::cout << "Theta Star: Nenhum caminho encontrado de " << startId << " para " << endId << std::endl;
                return;
            }
            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                (*pathCounter)++;
                currentPathIdx = *pathCounter;
            }
            stats->addEntry("Theta Star", "Tempo de Execução", elapsed.count());
            stats->addEntry("Theta Star", "Custo do Caminho", calculatePathCostLW(path, *graph));
            stats->addEntry("Theta Star", "Número de Nós Expandidos", visitedNodes);
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

        auto jpsFunc = [graph, width, height, startId, endId, stats, &meshesMutex, &newMeshesQueue, pathCounter, heightLimit]() {
            std::vector<unsigned int> gridData(width * height, 1);
            common::lwGrid grid(width, height, gridData);
            auto validator = [&](int fromId, int toId) {
                const auto& fromData = graph->getVertexData(fromId);
                const auto& toData = graph->getVertexData(toId);
                return std::abs(fromData.z - toData.z) <= heightLimit;
            };
            util::JumpPointSearchLw jps(grid, validator);
            auto jpsHeuristic = [](const util::Vertex2D& a, const util::Vertex2D& b) -> double {
                return std::sqrt(std::pow(a.x - b.x, 2) + std::pow(a.y - b.y, 2));
            };
            auto startTime = std::chrono::high_resolution_clock::now();
            auto rawPath = jps.find(startId, endId, jpsHeuristic);
            auto endTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<float> elapsed = endTime - startTime;
            
            auto path = reconstructPathLW(rawPath, width);
            if (path.empty()) {
                std::cout << "JPS: Nenhum caminho encontrado de " << startId << " para " << endId << std::endl;
                return;
            }
            int currentPathIdx;
            {
                std::lock_guard<std::mutex> lock(meshesMutex);
                (*pathCounter)++;
                currentPathIdx = *pathCounter;
            }
            stats->addEntry("JPS", "Tempo de Execução", elapsed.count());
            stats->addEntry("JPS", "Custo do Caminho", calculatePathCostLW(path, *graph));
            stats->addEntry("JPS", "Número de Nós Expandidos", 0);
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

        tm.addTask(aStarFunc, Priority::Medium);
        tm.addTask(aStarModFunc, Priority::Medium);
        tm.addTask(thetaStarFunc, Priority::Medium);
        tm.addTask(jpsFunc, Priority::Medium);
    };

    auto& camera {renderer.getCamera()};
    camera.setPosition(glm::vec3(-25.0f, (float)intensity * 0.9f, -25.0f));
    camera.setOrientation(glm::vec3(0.6, -0.5, 0.6));
    renderer.setFarPlane(1000.0f);

    tm.addTask(createScene, Priority::High);

    input.addKeyCallback(Key::K, KeyAction::PRESS, [&]() {
        for (auto& mesh : activeMeshes) {
            renderer.removeMesh(mesh);
        }
        activeMeshes.clear();
        
        {
            std::lock_guard<std::mutex> lock(meshesMutex);
            while(!newMeshesQueue.empty()) newMeshesQueue.pop();
        }
        
        tm.addTask(createScene, Priority::High);

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
};

void stats(uint repetitions, uint steps, uint intensity, float heightLimit) {
    struct TestConfig {
        std::string name;
        Param paramSetter;
        Stats statsSetter;
    };

    std::unordered_map<std::string, AlgFunc> algorithms = {
        {"A Star", util::lwAStar<Vertex3D>},
        {"A Star Mod", util::lwAStarMod<Vertex3D>},
        {"Theta Star", [heightLimit](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW heuristic) {
            int width = graph.getOrder();
            for (int i = 0; i < graph.getOrder(); ++i) {
                if (graph.getVertexData(i).y > 0.0f) {
                    width = i;
                    break;
                }
            }
            std::function<bool(int, int)> los = [&](int start, int end) -> bool {
                int w = width;
                int x0 = start % w;
                int y0 = start / w;
                int x1 = end % w;
                int y1 = end / w;
                int dx = std::abs(x1 - x0);
                int dy = std::abs(y1 - y0);
                int sx = (x0 < x1) ? 1 : -1;
                int sy = (y0 < y1) ? 1 : -1;
                int err = dx - dy;
                int x = x0;
                int y = y0;
                float lastZ = graph.getVertexData(start).z;
                while (true) {
                    int currentId = y * w + x;
                    float currentZ = graph.getVertexData(currentId).z;
                    if (std::abs(currentZ - lastZ) > heightLimit) {
                        return false;
                    }
                    lastZ = currentZ;
                    if (x == x1 && y == y1) {
                        break;
                    }
                    int e2 = 2 * err;
                    if (e2 > -dy) {
                        err -= dy;
                        x += sx;
                    }
                    if (e2 < dx) {
                        err += dx;
                        y += sy;
                    }
                }
                return true;
            };
            auto path = util::lwThetaStar<Vertex3D>(graph, startId, endId, heuristic, los);
            return reconstructPathLW(path, width);
        }},
        {"JPS", [heightLimit](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW heuristic) {
            int width = graph.getOrder();
            for (int i = 0; i < graph.getOrder(); ++i) {
                if (graph.getVertexData(i).y > 0.0f) {
                    width = i;
                    break;
                }
            }
            int height = graph.getOrder() / width;
            std::vector<unsigned int> gridData(width * height, 1);
            common::lwGrid grid(width, height, gridData);
            auto validator = [&](int fromId, int toId) {
                const auto& fromData = graph.getVertexData(fromId);
                const auto& toData = graph.getVertexData(toId);
                return std::abs(fromData.z - toData.z) <= heightLimit;
            };
            util::JumpPointSearchLw jps(grid, validator);
            auto jpsHeuristic = [](const util::Vertex2D& a, const util::Vertex2D& b) -> double {
                return std::sqrt(std::pow(a.x - b.x, 2) + std::pow(a.y - b.y, 2));
            };
            auto path = jps.find(startId, endId, jpsHeuristic);
            return reconstructPathLW(path, width);
        }}
    };

    std::vector<TestConfig> testConfigs = {
        {
            "Escala",
            [](int step) {
                std::random_device rd;
                std::mt19937 gen(rd());
                std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

                NoiseConfig config = {
                    .width = (step + 1) * 200,
                    .height = (step + 1) * 200,
                    .wave = (step + 1) * 50,
                    .freq = 4.0f,
                    .amp = 1.0f,
                    .exp = 1.0f,
                    .seed = distSeed(gen),
                    .octaves = 6
                };
                
                return config;
            },
            [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
                stats.addEntry(algName, "Tamanho do Mapa", (double)config.width);
            }
        }, {
            "Lacunaridade",
            [](int step) {
                std::random_device rd;
                std::mt19937 gen(rd());
                std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

                NoiseConfig config = {
                    .width = 500,
                    .height = 500,
                    .wave = 50,
                    .freq = 1.0f + (step * 0.5f),
                    .amp = 1.0f,
                    .exp = 1.0f,
                    .seed = distSeed(gen),
                    .octaves = 6
                };
                
                return config;
            },
            [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
                stats.addEntry(algName, "Frequência", (double)config.freq);
            }
        }, {
            "Persistência",
            [](int step) {
                std::random_device rd;
                std::mt19937 gen(rd());
                std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

                NoiseConfig config = {
                    .width = 500,
                    .height = 500,
                    .wave = 50,
                    .freq = 4.0f,
                    .amp = 1.0f - (step * 0.15f),
                    .exp = 1.0f,
                    .seed = distSeed(gen),
                    .octaves = 6
                };

                return config;
            },
            [](Statistics& stats, const std::string& algName, const NoiseConfig& config) {
                stats.addEntry(algName, "Amplitude", (double)config.amp);
            }
        }
    };

    for (const auto& config : testConfigs) {
        auto testName = config.name;
        auto paramSetter = config.paramSetter;
        auto statsSetter = config.statsSetter;

        runTestsParClean(
            testName,
            algorithms,
            paramSetter,
            statsSetter,
            repetitions, steps,
            intensity, heightLimit
        );

        std::cout << std::endl;
    }
};