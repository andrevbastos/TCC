#pragma once

#include <iostream>
#include <filesystem>
#include <pthread.h>
#include <iomanip>
#include <fstream>
#include <thread>
#include <chrono>
#include <random>
#include <vector>
#include <map>
#include <graph/common/lw_grid.hpp>
#include <graph/common/lw_graph.hpp>
#include <graph/util/dijkstra.hpp>
#include <graph/util/a_star.hpp>
#include <graph/util/jps.hpp>
#include <graph/util/theta_star.hpp>
#include <graph/util/node_data.hpp>

#include "core/util.hpp"
#include "core/task.hpp"

class Statistics {
public:
    Statistics(int max_entries = 1)  
        : max_entries(max_entries) {};

    ~Statistics() = default;

    void addEntry(const std::string& group, const std::string& metric, double value) {
        std::lock_guard<std::mutex> lock(mtx);
        if (data[group][metric].size() < max_entries) {
            data[group][metric].push_back(value);
        }
    }

    void printStatistics() const {
        std::lock_guard<std::mutex> lock(mtx);
        const int columnWidth = 20;

        for (const auto& group : data) {
            std::cout << group.first << ":" << std::endl;

            const auto& metrics = group.second;
            if (metrics.empty()) continue;

            bool first = true;
            for (const auto& m : metrics) {
                if (!first) std::cout << ", ";
                std::cout << std::left << std::setw(columnWidth) << m.first;
                first = false;
            }
            std::cout << std::endl;

            size_t numRows = metrics.begin()->second.size();
            for (size_t i = 0; i < numRows; ++i) {
                first = true;
                for (const auto& m : metrics) {
                    if (!first) std::cout << ", ";
                    std::cout << std::left << std::setw(columnWidth) << m.second[i];
                    first = false;
                }
                std::cout << std::endl;
            }
            std::cout << std::string(columnWidth * metrics.size(), '-') << std::endl;
        }
    }

    void clear() {
        std::lock_guard<std::mutex> lock(mtx);
        data.clear();
    }

    void saveToCSV(const std::string& fullPath) const {
        std::lock_guard<std::mutex> lock(mtx);
        std::ofstream file(fullPath);
        
        if (!file.is_open()) {
            return;
        }

        if (data.empty()) return;

        file << "Grupo";
        const auto& firstGroupMetrics = data.begin()->second;
        for (const auto& m : firstGroupMetrics) {
            file << "," << m.first;
        }
        file << std::endl;

        auto formatValue = [](double v) {
            std::ostringstream oss;
            oss << std::fixed << std::setprecision(6) << v;
            std::string s = oss.str();
            s.erase(s.find_last_not_of('0') + 1, std::string::npos);
            if (s.back() == '.') s.pop_back();
            return s;
        };

        for (const auto& group : data) {
            const std::string& groupName = group.first;
            const auto& metrics = group.second;
            
            size_t numRows = metrics.begin()->second.size();
            for (size_t i = 0; i < numRows; ++i) {
                file << groupName;
                for (const auto& m : metrics) {
                    file << "," << formatValue(m.second[i]);
                }
                file << std::endl;
            }
        }

        file.close();
    }

    void makeCSV(const std::string& filepath) const {
        std::lock_guard<std::mutex> lock(mtx);
        for (const auto& group : data) {
            std::ofstream file(filepath + "/" + group.first + ".csv");
            
            if (!file.is_open()) {
                return;
            }
            
            const auto& metrics = group.second;
            if (metrics.empty()) continue;
            
            bool first = true;
            for (const auto& m : metrics) {
                if (!first) file << ",";
                file << m.first;
                first = false;
            }

            auto formatValue = [](double v) {
                std::ostringstream oss;
                oss << std::fixed << std::setprecision(6) << v;
                std::string s = oss.str();
                s.erase(s.find_last_not_of('0') + 1, std::string::npos);
                if (s.back() == '.') s.pop_back();
                return s;
            };
            
            file << std::endl;
            size_t numRows = metrics.begin()->second.size();
            for (size_t i = 0; i < numRows; ++i) {
                first = true;
                for (const auto& m : metrics) {
                    if (!first) file << ",";
                    file << formatValue(m.second[i]);
                    first = false;
                }
                file << std::endl;
            }

            file.close();
        }
    }

private:
    std::map<std::string, std::map<std::string, std::vector<double>>> data;
    int max_entries;

    mutable std::mutex mtx;
};

void warmUp() {
    undirected::Graph warmUpGraph;
    for (int i = 0; i < 10; ++i) {
        warmUpGraph.newVertex(std::make_tuple(i, 0, 0));
    }
    for (int i = 0; i < 9; ++i) {
        warmUpGraph.newEdge(warmUpGraph.getVertex(i), warmUpGraph.getVertex(i + 1));
    }

    for (int i = 0; i < 5; ++i) {
        util::AStar(&warmUpGraph, 0, 9, util::heuristics::euclideanHeuristic3D);
        util::AStarMod(&warmUpGraph, 0, 9, util::heuristics::chebyshevHeuristic3D);
    }
};

using HeuristicFuncLW = std::function<float(const Vertex3D&, const Vertex3D&)>;
using AlgFunc = std::function<std::vector<int>(const common::lwGraph<Vertex3D>&, int, int, HeuristicFuncLW)>;

using Param = std::function<NoiseConfig(int)>;
using Stats = std::function<void(Statistics&, const std::string&, const NoiseConfig&)>;

void pinThreadToCore(int core_id) {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(core_id, &cpuset);
    pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
}

void runTestsPar(
    std::string testName,
    std::unordered_map<std::string, AlgFunc> algorithms, 
    Param paramSetter, 
    Stats statsSetter,
    unsigned int repetitions,
    unsigned int numSteps,
    unsigned int intensity,
    float heightLimit
) {
    warmUp();
    TaskMaster tm(true);
    
    int tarefasPorPasso = repetitions * 3; 
    
    std::mutex mainMtx;
    std::condition_variable mainCv;

    Statistics stats(numSteps * repetitions);

    std::string folderPath = "../results/parallel/" + testName;
    fs::create_directories(folderPath);

    for (int step = 0; step < numSteps; ++step) {
        std::cout << "\r                                                   " << std::flush;

        std::vector<std::shared_ptr<common::lwGraph<Vertex3D>>> graphs(repetitions);
        std::vector<NoiseConfig> configs(repetitions);
        
        int tarefasConcluidas = 0;

        for (int rep = 0; rep < repetitions; ++rep) {
            tm.addTask([step, rep, tarefasPorPasso, algorithms, paramSetter, heightLimit, intensity, folderPath, &graphs, &configs, &mainMtx, &mainCv, &tarefasConcluidas, &tm]() {
                std::random_device rd;
                std::mt19937 gen(rd());
                std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);
                
                int currentSize = (step + 1) * 125;
                NoiseConfig config = paramSetter(step);
                
                configs[rep] = config;
                auto noise = generateNoiseMap(config);

                tm.addTask([config, noise, step, rep, tarefasPorPasso, folderPath, &mainMtx, &mainCv, &tarefasConcluidas]() {
                    std::string fileName = "step" + std::to_string(step + 1) + "_rep" + std::to_string(rep + 1) + ".png";
                    saveNoiseAsPNG(folderPath + "/" + fileName, noise, config.width, config.height);
                    
                    std::lock_guard<std::mutex> lock(mainMtx);
                    tarefasConcluidas++;
                    if (tarefasConcluidas == tarefasPorPasso) mainCv.notify_one();
                }, Priority::Low);

                tm.addTask([config, noise = std::move(noise), rep, tarefasPorPasso, heightLimit, intensity, &graphs, &mainMtx, &mainCv, &tarefasConcluidas]() mutable {
                    auto graph = createlwGraphFromNoise(noise, config.width, config.height, heightLimit, intensity);
                    
                    if (graph) {
                        graphs[rep] = std::move(graph);
                    }

                    std::lock_guard<std::mutex> lock(mainMtx);
                    tarefasConcluidas++;
                    if (tarefasConcluidas == tarefasPorPasso) mainCv.notify_one();
                }, Priority::Medium);

                {
                    std::lock_guard<std::mutex> lock(mainMtx);
                    tarefasConcluidas++;
                    if (tarefasConcluidas == tarefasPorPasso) mainCv.notify_one();
                }
            }, Priority::High); 
        }

        {
            std::unique_lock<std::mutex> mainLock(mainMtx);
            mainCv.wait(mainLock, [&]() { return tarefasConcluidas == tarefasPorPasso; });
        }

        pinThreadToCore(2);

        for (int rep = 0; rep < repetitions; ++rep) {
            if (!graphs[rep]) continue;
            
            const NoiseConfig& config = configs[rep];
            auto& graph = *graphs[rep];
            
            int startId = 0;
            int endId = config.width * config.height - 1;
            
            std::cout << "\r" << testName << ": Step " << step + 1 << "/" << numSteps << " (Rep " << rep + 1 << "/" << repetitions << ")" << std::flush;

            for (const auto& algPair : algorithms) {
                const std::string& algName = algPair.first;
                const AlgFunc& algFunc = algPair.second;
                
                int nosAvaliados = 0;
                auto trackingHeuristic = [&nosAvaliados](const auto& a, const auto& b) -> float {
                    nosAvaliados++;
                    return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
                };

                auto startTime = std::chrono::steady_clock::now();
                auto path = algFunc(graph, startId, endId, trackingHeuristic);
                auto endTime = std::chrono::steady_clock::now();
                
                double execTime = std::chrono::duration<double, std::milli>(endTime - startTime).count();
                double pathCost = (double)calculatePathCostLW(path, graph);
            
                stats.addEntry(algName, "Tempo de Execução", execTime);
                stats.addEntry(algName, "Custo do Caminho", pathCost);
                stats.addEntry(algName, "Número de Nós Expandidos", (double)nosAvaliados);

                statsSetter(stats, algName, config);
            }
            
            graphs[rep].reset();
        }
    }

    stats.saveToCSV(folderPath + "/stats.csv");
};

void runTestsSeq(
    std::string testName,
    std::unordered_map<std::string, AlgFunc> algorithms,
    Param paramSetter,
    Stats statsSetter,
    unsigned int repetitions,
    unsigned int numSteps,
    unsigned int intensity,
    float heightLimit
) {

    Statistics stats(numSteps * repetitions);

    using HeuristicFuncLW = std::function<float(const Vertex3D&, const Vertex3D&)>;
    using AlgFunc = std::function<std::vector<int>(const common::lwGraph<Vertex3D>&, int, int, HeuristicFuncLW)>;

    AlgFunc dijkstra = [](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW) {
        return util::lwAStar<Vertex3D>(graph, startId, endId, [](const Vertex3D&, const Vertex3D&) { return 0.0f; });
    };

    int nosAvaliados {0};
    auto trackingHeuristic = [&](const auto& a, const auto& b) -> float {
        nosAvaliados++;
        return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
    };

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

    std::string folderPath = "../results/sequential/" + testName;
    fs::create_directories(folderPath);

    for (int step = 0; step < numSteps; ++step) {
        for (int rep = 0; rep < repetitions; ++rep) {
            NoiseConfig noiseConfig = paramSetter(step);

            auto noise = generateNoiseMap(noiseConfig);
            
            std::string fileName = "step" + std::to_string(step + 1) + "_rep" + std::to_string(rep + 1) + ".png";
            saveNoiseAsPNG(folderPath + "/" + fileName, noise, noiseConfig.width, noiseConfig.height);

            auto graph = createlwGraphFromNoise(noise, noiseConfig.width, noiseConfig.height, heightLimit, intensity);

            if (!graph) {
                std::cout << " Erro: Não foi possível carregar o mapa!" << std::endl;
                continue;
            }

            int startId = 0;
            int endId = noiseConfig.width * noiseConfig.height - 1;

            std::cout << "\r" << testName << ": Step " << step + 1 << "/" << numSteps << " (Rep " << rep + 1 << "/" << repetitions << ")" << std::flush;

            for (const auto& alg : algorithms) {
                nosAvaliados = 0;

                auto startTime = std::chrono::steady_clock::now();
                auto path = alg.second(*graph, startId, endId, trackingHeuristic);
                auto endTime = std::chrono::steady_clock::now();
                
                std::chrono::duration<double, std::milli> elapsed = endTime - startTime;
                double execTime = elapsed.count();
                double pathCost = (double)calculatePathCostLW(path, *graph);

                stats.addEntry(alg.first, "Tempo de Execução", execTime);
                stats.addEntry(alg.first, "Custo do Caminho", pathCost);
                stats.addEntry(alg.first, "Número de Nós Expandidos", (double)nosAvaliados);
                
                statsSetter(stats, alg.first, noiseConfig);
            }

            graph.reset();
        }
    }

    stats.saveToCSV(folderPath + "/stats.csv");
};

void runTestsParClean(
    std::string testName,
    std::unordered_map<std::string, AlgFunc> algorithms, 
    Param paramSetter, 
    Stats statsSetter,
    unsigned int repetitions,
    unsigned int numSteps,
    unsigned int intensity,
    float heightLimit
) {
    warmUp();
    TaskMaster tm(false);
    
    int tarefasPorPasso = repetitions * 3; 
    
    std::mutex mainMtx;
    std::condition_variable mainCv;

    Statistics stats(numSteps * repetitions);

    std::string folderPath = "../results/parallel/" + testName;
    fs::create_directories(folderPath);

    for (int step = 0; step < numSteps; ++step) {
        std::vector<std::shared_ptr<common::lwGraph<Vertex3D>>> graphs(repetitions);
        std::vector<NoiseConfig> configs(repetitions);
        
        int tarefasConcluidas = 0;

        for (int rep = 0; rep < repetitions; ++rep) {
            tm.addTask([step, rep, tarefasPorPasso, algorithms, paramSetter, heightLimit, intensity, folderPath, &graphs, &configs, &mainMtx, &mainCv, &tarefasConcluidas, &tm]() {
                std::random_device rd;
                std::mt19937 gen(rd());
                std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);
                
                int currentSize = (step + 1) * 125;
                NoiseConfig config = paramSetter(step);
                
                configs[rep] = config;
                auto noise = generateNoiseMap(config);

                tm.addTask([config, noise, step, rep, tarefasPorPasso, folderPath, &mainMtx, &mainCv, &tarefasConcluidas]() {
                    std::string fileName = "step" + std::to_string(step + 1) + "_rep" + std::to_string(rep + 1) + ".png";
                    saveNoiseAsPNG(folderPath + "/" + fileName, noise, config.width, config.height);
                    
                    std::lock_guard<std::mutex> lock(mainMtx);
                    tarefasConcluidas++;
                    if (tarefasConcluidas == tarefasPorPasso) mainCv.notify_one();
                }, Priority::Low);

                tm.addTask([config, noise = std::move(noise), rep, tarefasPorPasso, heightLimit, intensity, &graphs, &mainMtx, &mainCv, &tarefasConcluidas]() mutable {
                    auto graph = createlwGraphFromNoise(noise, config.width, config.height, heightLimit, intensity);
                    
                    if (graph) {
                        graphs[rep] = std::move(graph);
                    }

                    std::lock_guard<std::mutex> lock(mainMtx);
                    tarefasConcluidas++;
                    if (tarefasConcluidas == tarefasPorPasso) mainCv.notify_one();
                }, Priority::Medium);

                {
                    std::lock_guard<std::mutex> lock(mainMtx);
                    tarefasConcluidas++;
                    if (tarefasConcluidas == tarefasPorPasso) mainCv.notify_one();
                }
            }, Priority::High); 
        }

        {
            std::unique_lock<std::mutex> mainLock(mainMtx);
            mainCv.wait(mainLock, [&]() { return tarefasConcluidas == tarefasPorPasso; });
        }

        pinThreadToCore(2);

        for (int rep = 0; rep < repetitions; ++rep) {
            if (!graphs[rep]) continue;
            
            const NoiseConfig& config = configs[rep];
            auto& graph = *graphs[rep];
            
            int startId = 0;
            int endId = config.width * config.height - 1;
            
            for (const auto& algPair : algorithms) {
                const std::string& algName = algPair.first;
                const AlgFunc& algFunc = algPair.second;
                
                int nosAvaliados = 0;
                auto trackingHeuristic = [&nosAvaliados](const auto& a, const auto& b) -> float {
                    nosAvaliados++;
                    return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
                };

                auto startTime = std::chrono::steady_clock::now();
                auto path = algFunc(graph, startId, endId, trackingHeuristic);
                auto endTime = std::chrono::steady_clock::now();
                
                double execTime = std::chrono::duration<double, std::milli>(endTime - startTime).count();
                double pathCost = (double)calculatePathCostLW(path, graph);
            
                stats.addEntry(algName, "Tempo de Execução", execTime);
                stats.addEntry(algName, "Custo do Caminho", pathCost);
                stats.addEntry(algName, "Número de Nós Expandidos", (double)nosAvaliados);

                statsSetter(stats, algName, config);
            }
            
            graphs[rep].reset();
        }
    }

    stats.saveToCSV(folderPath + "/stats.csv");
};

void runTestsSeqClean(
    std::string testName,
    std::unordered_map<std::string, AlgFunc> algorithms,
    Param paramSetter,
    Stats statsSetter,
    unsigned int repetitions,
    unsigned int numSteps,
    unsigned int intensity,
    float heightLimit
) {

    Statistics stats(numSteps * repetitions);

    using HeuristicFuncLW = std::function<float(const Vertex3D&, const Vertex3D&)>;
    using AlgFunc = std::function<std::vector<int>(const common::lwGraph<Vertex3D>&, int, int, HeuristicFuncLW)>;

    AlgFunc dijkstra = [](const common::lwGraph<Vertex3D>& graph, int startId, int endId, HeuristicFuncLW) {
        return util::lwAStar<Vertex3D>(graph, startId, endId, [](const Vertex3D&, const Vertex3D&) { return 0.0f; });
    };

    int nosAvaliados {0};
    auto trackingHeuristic = [&](const auto& a, const auto& b) -> float {
        nosAvaliados++;
        return std::max({std::abs(a.x - b.x), std::abs(a.y - b.y), std::abs(a.z - b.z)});
    };

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<unsigned int> distSeed(0, UINT32_MAX);

    std::string folderPath = "../results/sequential/" + testName;
    fs::create_directories(folderPath);

    for (int step = 0; step < numSteps; ++step) {
        for (int rep = 0; rep < repetitions; ++rep) {
            NoiseConfig noiseConfig = paramSetter(step);

            auto noise = generateNoiseMap(noiseConfig);
            
            std::string fileName = "step" + std::to_string(step + 1) + "_rep" + std::to_string(rep + 1) + ".png";
            saveNoiseAsPNG(folderPath + "/" + fileName, noise, noiseConfig.width, noiseConfig.height);

            auto graph = createlwGraphFromNoise(noise, noiseConfig.width, noiseConfig.height, heightLimit, intensity);

            int startId = 0;
            int endId = noiseConfig.width * noiseConfig.height - 1;

            for (const auto& alg : algorithms) {
                nosAvaliados = 0;

                auto startTime = std::chrono::steady_clock::now();
                auto path = alg.second(*graph, startId, endId, trackingHeuristic);
                auto endTime = std::chrono::steady_clock::now();
                
                std::chrono::duration<double, std::milli> elapsed = endTime - startTime;
                double execTime = elapsed.count();
                double pathCost = (double)calculatePathCostLW(path, *graph);

                stats.addEntry(alg.first, "Tempo de Execução", execTime);
                stats.addEntry(alg.first, "Custo do Caminho", pathCost);
                stats.addEntry(alg.first, "Número de Nós Expandidos", (double)nosAvaliados);
                
                statsSetter(stats, alg.first, noiseConfig);
            }

            graph.reset();
        }
    }

    stats.saveToCSV(folderPath + "/stats.csv");
};