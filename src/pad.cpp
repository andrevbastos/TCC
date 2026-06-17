// rodar com `~/facul/programacao-de-alto-desempenho/benchmark.sh`

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <iostream>
#include <filesystem>
#include <thread>
#include <chrono>
#include <random>
#include <vector>
#include <mutex>
#include <queue>
#include <condition_variable>

#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>

#include "statistics.hpp"
#include "util.hpp"
#include "task.hpp"

namespace fs = std::filesystem;

using Param = std::function<NoiseConfig(int)>;
using Stats = std::function<void(Statistics&, const std::string&, const NoiseConfig&)>;

void runBenchSeq(std::string testName, Param paramSetter, Stats statsSetter, uint repetitions, uint numSteps, uint intensity);
void runBenchPar(std::string testName, Param paramSetter, Stats statsSetter, uint repetitions, uint numSteps, uint intensity);
void runEngineSeq(std::string testName, Param paramSetter, Stats statsSetter, uint repetitions, uint numSteps, uint intensity);
void runEnginePar(std::string testName, Param paramSetter, Stats statsSetter, uint repetitions, uint numSteps, uint intensity);

struct MeshData {
    std::vector<Vertex> v;
    std::vector<GLuint> i;
    double time;
    NoiseConfig config;
};

struct TestConfig {
    std::string name;
    Param paramSetter;
    Stats statsSetter;
};

int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cerr << "Uso: " << argv[0] << " <bench|engine> <paralelo|sequencial>" << std::endl;
        return 1;
    }

    std::string type = argv[1];
    std::string mode = argv[2];

    const uint repetitions = 20;
    const uint numSteps = 10;
    const uint intensity = 100;

    std::vector<TestConfig> testConfigs = {
        {
            "Escala",
            [](int step) {
                NoiseConfig config = {
                    .width = (step + 1) * 100,
                    .height = (step + 1) * 100,
                    .wave = (step + 1) * 50,
                    .freq = 4.0f,
                    .amp = 1.0f,
                    .exp = 1.0f,
                    .seed = (uint)time(NULL),
                    .octaves = 6
                };
                return config;
            },
            [](Statistics& stats, const std::string& group, const NoiseConfig& config) {
                stats.addEntry(group, "Tamanho", (double)config.width);
            }
        },
        {
            "Octaves",
            [](int step) {
                NoiseConfig config = {
                    .width = 400,
                    .height = 400,
                    .wave = 200,
                    .freq = 4.0f,
                    .amp = 1.0f,
                    .exp = 1.0f,
                    .seed = (uint)time(NULL),
                    .octaves = (uint) step + 1
                };
                return config;
            },
            [](Statistics& stats, const std::string& group, const NoiseConfig& config) {
                stats.addEntry(group, "Octaves", (double)config.octaves);
            }
        }
    };

    for (const auto& config : testConfigs) {
        if (type == "bench") {
            if (mode == "paralelo") {
                runBenchPar(config.name, config.paramSetter, config.statsSetter, repetitions, numSteps, intensity);
            } else {
                runBenchSeq(config.name, config.paramSetter, config.statsSetter, repetitions, numSteps, intensity);
            }
        } else {
            if (mode == "paralelo") {
                runEnginePar(config.name, config.paramSetter, config.statsSetter, repetitions, numSteps, intensity);
            } else {
                runEngineSeq(config.name, config.paramSetter, config.statsSetter, repetitions, numSteps, intensity);
            }
        }
    }
    
    return 0;
}


void runBenchSeq(std::string testName, Param paramSetter, Stats statsSetter, uint repetitions, uint numSteps, uint intensity) {
    Statistics stats(numSteps * repetitions);
    std::string folderPath = "../results/bench_seq/" + testName;
    fs::create_directories(folderPath);

    for (int step = 0; step < (int)numSteps; ++step) {
        NoiseConfig config = paramSetter(step);
        for (uint rep = 0; rep < repetitions; ++rep) {
            std::cout << "\rBench Seq: Step " << step + 1 << "/" << numSteps << " (Rep " << rep + 1 << "/" << repetitions << ")" << std::flush;
            
            auto start = std::chrono::steady_clock::now();
            auto noise = generateNoiseMap(config);
            auto [v, i] = createMeshDataFromNoise(noise, config.width, config.height, (float)intensity);
            auto end = std::chrono::steady_clock::now();

            double totalTime = std::chrono::duration<double, std::milli>(end - start).count();
            stats.addEntry("Sequencial", "Tempo Geração", totalTime);
            statsSetter(stats, "Sequencial", config);
        }
    }
    std::cout << std::endl;
    stats.saveToCSV(folderPath + "/stats.csv");
}

void runBenchPar(std::string testName, Param paramSetter, Stats statsSetter, uint repetitions, uint numSteps, uint intensity) {
    TaskMaster tm(true);
    Statistics stats(numSteps * repetitions);
    std::string folderPath = "../results/bench_par/" + testName;
    fs::create_directories(folderPath);

    std::mutex mtx;
    std::condition_variable_any cv;
    uint totalTasks = repetitions * numSteps;
    uint completedTasks = 0;

    for (int step = 0; step < (int)numSteps; ++step) {
        NoiseConfig config = paramSetter(step);
        for (uint rep = 0; rep < repetitions; ++rep) {
            tm.addTask([&stats, &statsSetter, &mtx, &cv, &completedTasks, config, intensity]() {
                auto start = std::chrono::steady_clock::now();
                auto noise = generateNoiseMap(config);
                auto [v, i] = createMeshDataFromNoise(noise, config.width, config.height, (float)intensity);
                auto end = std::chrono::steady_clock::now();

                double totalTime = std::chrono::duration<double, std::milli>(end - start).count();
                stats.addEntry("Paralelo", "Tempo Geração", totalTime);
                statsSetter(stats, "Paralelo", config);

                {
                    std::lock_guard<std::mutex> lock(mtx);
                    completedTasks++;
                }
                cv.notify_all();
            }, Priority::High);
        }
    }

    {
        std::unique_lock<std::mutex> lock(mtx);
        cv.wait(lock, [&]() { return completedTasks == totalTasks; });
    }
    std::cout << std::endl;
    stats.saveToCSV(folderPath + "/stats.csv");
}

void runEngineSeq(std::string testName, Param paramSetter, Stats statsSetter, uint repetitions, uint numSteps, uint intensity) {
    Engine::init(1200, 800, "Engine Sequential - Blocking Main Thread");
    Engine::setup3D();
    auto& renderer = Engine::getRenderer();
    GLuint shader = renderer.getShaderID();

    Statistics stats(numSteps * repetitions);
    std::string folderPath = "../results/engine_seq/" + testName;
    fs::create_directories(folderPath);

    uint currentStep = 0;
    uint currentRep = 0;
    std::vector<std::shared_ptr<MeshBase>> activeMeshes;

    LoopConfig config {
        .loopBody = [&]() {
            if (currentStep >= numSteps) return;

            NoiseConfig nConfig = paramSetter(currentStep);
            
            auto start = std::chrono::steady_clock::now();
            auto noise = generateNoiseMap(nConfig);
            auto [v, i] = createMeshDataFromNoise(noise, nConfig.width, nConfig.height, (float)intensity);
            auto end = std::chrono::steady_clock::now();

            double totalTime = std::chrono::duration<double, std::milli>(end - start).count();
            stats.addEntry("Engine Seq", "Tempo Geração", totalTime);
            statsSetter(stats, "Engine Seq", nConfig);

            // Substitui a malha antiga para manter performance de renderização mas mostrar o custo de CPU
            for (auto& mesh : activeMeshes) renderer.removeMesh(mesh);
            activeMeshes.clear();

            auto mesh = std::make_shared<Mesh>(v, i, shader, GL_TRIANGLES);
            renderer.addMesh(mesh);
            activeMeshes.push_back(mesh);

            currentRep++;
            if (currentRep >= repetitions) {
                currentRep = 0;
                currentStep++;
            }
        }
    };

    Engine::loop(config);
    Engine::terminate();
    stats.saveToCSV(folderPath + "/stats.csv");
}

void runEnginePar(std::string testName, Param paramSetter, Stats statsSetter, uint repetitions, uint numSteps, uint intensity) {
    Engine::init(1200, 800, "Engine Parallel - Async Generation");
    Engine::setup3D();
    auto& renderer = Engine::getRenderer();
    GLuint shader = renderer.getShaderID();

    Statistics stats(numSteps * repetitions);
    std::string folderPath = "../results/engine_par/" + testName;
    fs::create_directories(folderPath);

    std::queue<MeshData> queue;
    std::mutex queueMtx;
    bool running = true;

    std::thread generator([&]() {
        for (uint step = 0; step < numSteps; ++step) {
            NoiseConfig nConfig = paramSetter(step);
            for (uint rep = 0; rep < repetitions; ++rep) {
                if (!running) return;

                auto start = std::chrono::steady_clock::now();
                auto noise = generateNoiseMap(nConfig);
                auto [v, i] = createMeshDataFromNoise(noise, nConfig.width, nConfig.height, (float)intensity);
                auto end = std::chrono::steady_clock::now();

                double totalTime = std::chrono::duration<double, std::milli>(end - start).count();
                
                {
                    std::lock_guard<std::mutex> lock(queueMtx);
                    queue.push({v, i, totalTime, nConfig});
                }
                
                std::this_thread::sleep_for(std::chrono::milliseconds(50));
            }
        }
    });

    std::vector<std::shared_ptr<MeshBase>> activeMeshes;

    LoopConfig config {
        .loopBody = [&]() {
            MeshData data;
            bool hasData = false;

            {
                std::lock_guard<std::mutex> lock(queueMtx);
                if (!queue.empty()) {
                    data = std::move(queue.front());
                    queue.pop();
                    hasData = true;
                }
            }

            if (hasData) {
                stats.addEntry("Engine Par", "Tempo Geração", data.time);
                statsSetter(stats, "Engine Par", data.config);

                for (auto& mesh : activeMeshes) renderer.removeMesh(mesh);
                activeMeshes.clear();

                auto mesh = std::make_shared<Mesh>(data.v, data.i, shader, GL_TRIANGLES);
                renderer.addMesh(mesh);
                activeMeshes.push_back(mesh);
            }
        }
    };

    Engine::loop(config);

    running = false;
    if (generator.joinable()) generator.join();
    Engine::terminate();

    stats.saveToCSV(folderPath + "/stats.csv");
}