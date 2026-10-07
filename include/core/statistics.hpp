#pragma once

#include <fstream>
#include <functional>
#include <iomanip>
#include <map>
#include <mutex>
#include <sstream>
#include <string>
#include <vector>

#include "core/util.hpp"

class Statistics {
public:
    explicit Statistics(int maxEntries = 1)
        : maxEntries(maxEntries) {}

    void addEntry(const std::string& group, const std::string& metric, double value) {
        std::lock_guard<std::mutex> lock(mutex);
        if (data[group][metric].size() < static_cast<std::size_t>(maxEntries)) {
            data[group][metric].push_back(value);
        }
    }

    void printStatistics() const {
        std::lock_guard<std::mutex> lock(mutex);
        constexpr int columnWidth = 20;

        for (const auto& [group, metrics] : data) {
            std::cout << group << ":\n";
            if (metrics.empty()) {
                continue;
            }

            bool first = true;
            for (const auto& [metric, values] : metrics) {
                if (!first) {
                    std::cout << ", ";
                }
                std::cout << std::left << std::setw(columnWidth) << metric;
                first = false;
            }
            std::cout << '\n';

            const std::size_t rowCount = metrics.begin()->second.size();
            for (std::size_t row = 0; row < rowCount; ++row) {
                first = true;
                for (const auto& [metric, values] : metrics) {
                    if (!first) {
                        std::cout << ", ";
                    }
                    std::cout << std::left << std::setw(columnWidth) << values[row];
                    first = false;
                }
                std::cout << '\n';
            }
        }
    }

    void clear() {
        std::lock_guard<std::mutex> lock(mutex);
        data.clear();
    }

    void saveToCSV(const std::string& fullPath) const {
        std::lock_guard<std::mutex> lock(mutex);
        std::ofstream file(fullPath);
        if (!file || data.empty()) {
            return;
        }

        file << "Grupo";
        for (const auto& [metric, values] : data.begin()->second) {
            file << ',' << metric;
        }
        file << '\n';

        for (const auto& [group, metrics] : data) {
            if (metrics.empty()) {
                continue;
            }

            const std::size_t rowCount = metrics.begin()->second.size();
            for (std::size_t row = 0; row < rowCount; ++row) {
                file << group;
                for (const auto& [metric, values] : metrics) {
                    file << ',' << formatValue(values[row]);
                }
                file << '\n';
            }
        }
    }

    void makeCSV(const std::string& directory) const {
        std::lock_guard<std::mutex> lock(mutex);
        for (const auto& [group, metrics] : data) {
            if (metrics.empty()) {
                continue;
            }

            std::ofstream file(directory + "/" + group + ".csv");
            if (!file) {
                continue;
            }

            bool first = true;
            for (const auto& [metric, values] : metrics) {
                if (!first) {
                    file << ',';
                }
                file << metric;
                first = false;
            }
            file << '\n';

            const std::size_t rowCount = metrics.begin()->second.size();
            for (std::size_t row = 0; row < rowCount; ++row) {
                first = true;
                for (const auto& [metric, values] : metrics) {
                    if (!first) {
                        file << ',';
                    }
                    file << formatValue(values[row]);
                    first = false;
                }
                file << '\n';
            }
        }
    }

private:
    static std::string formatValue(double value) {
        std::ostringstream output;
        output << std::fixed << std::setprecision(6) << value;
        std::string formatted = output.str();
        formatted.erase(formatted.find_last_not_of('0') + 1);
        if (!formatted.empty() && formatted.back() == '.') {
            formatted.pop_back();
        }
        return formatted;
    }

    std::map<std::string, std::map<std::string, std::vector<double>>> data;
    int maxEntries;
    mutable std::mutex mutex;
};

using HeuristicFuncLW = std::function<double(const Vertex3D&, const Vertex3D&)>;
using AlgFunc = std::function<std::vector<std::size_t>(
    const common::lwGraph<Vertex3D>&,
    std::size_t,
    std::size_t,
    HeuristicFuncLW
)>;

// #pragma once

// #include <iostream>
// #include <filesystem>
// #include <pthread.h>
// #include <iomanip>
// #include <fstream>
// #include <thread>
// #include <chrono>
// #include <random>
// #include <vector>
// #include <array>
// #include <map>
// #include <ifcg/components/task.hpp>
// #include <graph/common/lw_graph.hpp>
// #include <graph/util/dijkstra.hpp>
// #include <graph/util/a_star.hpp>
// #include <graph/util/jps.hpp>
// #include <graph/util/theta_star.hpp>
// #include <graph/util/node_data.hpp>

// #include "core/util.hpp"

// class Statistics {
// public:
//     Statistics(int max_entries = 1)  
//         : max_entries(max_entries) {};

//     ~Statistics() = default;

//     void addEntry(const std::string& group, const std::string& metric, double value) {
//         std::lock_guard<std::mutex> lock(mtx);
//         if (data[group][metric].size() < max_entries) {
//             data[group][metric].push_back(value);
//         }
//     }

//     void printStatistics() const {
//         std::lock_guard<std::mutex> lock(mtx);
//         const int columnWidth = 20;

//         for (const auto& group : data) {
//             std::cout << group.first << ":" << std::endl;

//             const auto& metrics = group.second;
//             if (metrics.empty()) continue;

//             bool first = true;
//             for (const auto& m : metrics) {
//                 if (!first) std::cout << ", ";
//                 std::cout << std::left << std::setw(columnWidth) << m.first;
//                 first = false;
//             }
//             std::cout << std::endl;

//             size_t numRows = metrics.begin()->second.size();
//             for (size_t i = 0; i < numRows; ++i) {
//                 first = true;
//                 for (const auto& m : metrics) {
//                     if (!first) std::cout << ", ";
//                     std::cout << std::left << std::setw(columnWidth) << m.second[i];
//                     first = false;
//                 }
//                 std::cout << std::endl;
//             }
//             std::cout << std::string(columnWidth * metrics.size(), '-') << std::endl;
//         }
//     }

//     void clear() {
//         std::lock_guard<std::mutex> lock(mtx);
//         data.clear();
//     }

//     void saveToCSV(const std::string& fullPath) const {
//         std::lock_guard<std::mutex> lock(mtx);
//         std::ofstream file(fullPath);
        
//         if (!file.is_open()) {
//             return;
//         }

//         if (data.empty()) return;

//         file << "Grupo";
//         const auto& firstGroupMetrics = data.begin()->second;
//         for (const auto& m : firstGroupMetrics) {
//             file << "," << m.first;
//         }
//         file << std::endl;

//         auto formatValue = [](double v) {
//             std::ostringstream oss;
//             oss << std::fixed << std::setprecision(6) << v;
//             std::string s = oss.str();
//             s.erase(s.find_last_not_of('0') + 1, std::string::npos);
//             if (s.back() == '.') s.pop_back();
//             return s;
//         };

//         for (const auto& group : data) {
//             const std::string& groupName = group.first;
//             const auto& metrics = group.second;
            
//             size_t numRows = metrics.begin()->second.size();
//             for (size_t i = 0; i < numRows; ++i) {
//                 file << groupName;
//                 for (const auto& m : metrics) {
//                     file << "," << formatValue(m.second[i]);
//                 }
//                 file << std::endl;
//             }
//         }

//         file.close();
//     }

//     void makeCSV(const std::string& filepath) const {
//         std::lock_guard<std::mutex> lock(mtx);
//         for (const auto& group : data) {
//             std::ofstream file(filepath + "/" + group.first + ".csv");
            
//             if (!file.is_open()) {
//                 return;
//             }
            
//             const auto& metrics = group.second;
//             if (metrics.empty()) continue;
            
//             bool first = true;
//             for (const auto& m : metrics) {
//                 if (!first) file << ",";
//                 file << m.first;
//                 first = false;
//             }

//             auto formatValue = [](double v) {
//                 std::ostringstream oss;
//                 oss << std::fixed << std::setprecision(6) << v;
//                 std::string s = oss.str();
//                 s.erase(s.find_last_not_of('0') + 1, std::string::npos);
//                 if (s.back() == '.') s.pop_back();
//                 return s;
//             };
            
//             file << std::endl;
//             size_t numRows = metrics.begin()->second.size();
//             for (size_t i = 0; i < numRows; ++i) {
//                 first = true;
//                 for (const auto& m : metrics) {
//                     if (!first) file << ",";
//                     file << formatValue(m.second[i]);
//                     first = false;
//                 }
//                 file << std::endl;
//             }

//             file.close();
//         }
//     }

// private:
//     std::map<std::string, std::map<std::string, std::vector<double>>> data;
//     int max_entries;

//     mutable std::mutex mtx;
// };

// void warmUp() {
//     undirected::Graph warmUpGraph;
//     for (int i = 0; i < 10; ++i) {
//         warmUpGraph.newVertex(std::make_tuple(i, 0, 0));
//     }
//     for (int i = 0; i < 9; ++i) {
//         warmUpGraph.newEdge(warmUpGraph.getVertex(i), warmUpGraph.getVertex(i + 1));
//     }

//     for (int i = 0; i < 5; ++i) {
//         util::AStar(&warmUpGraph, 0, 9, util::heuristics::euclideanHeuristic3D);
//         util::AStarMod(&warmUpGraph, 0, 9, util::heuristics::chebyshevHeuristic3D);
//     }
// };

// using HeuristicFuncLW = std::function<double(const Vertex3D&, const Vertex3D&)>;
// using AlgFunc = std::function<std::vector<std::size_t>(
//     const common::lwGraph<Vertex3D>&,
//     std::size_t,
//     std::size_t,
//     HeuristicFuncLW
// )>;

// using Param = std::function<NoiseConfig(int)>;
// using Stats = std::function<void(Statistics&, const std::string&, const NoiseConfig&)>;

// void pinThreadToCore(int core_id) {
//     cpu_set_t cpuset;
//     CPU_ZERO(&cpuset);
//     CPU_SET(core_id, &cpuset);
//     pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
// }

// void runTests(
//     std::vector<AlgFunc> algorithms, 
//     Param paramSetter, 
//     Stats statsSetter,
//     unsigned int repetitions,
//     unsigned int steps,
//     unsigned int intensity,
//     float heightLimit
// ) {
//     Statistics stats;
//     TaskMaster tm;

//     while (steps--) {
//         auto reps = repetitions;
//         while (reps--) {
//             auto noiseConfig = paramSetter(steps);
//             auto noise = generateNoiseMap(noiseConfig);
            
//             auto terrain = getMarchingCubeData(
//                 noise,
//                 noiseConfig.width,
//                 intensity,
//                 noiseConfig.height
//             );

//             std::array<std::unique_ptr<graph::lwGraph<Vertex3D>>, 4> graphs;
//             std::

//             // auto graph = createVoxelGraph(noise, currentConfig.width, intensity, currentConfig.height);
//             // auto graph = createGrid2_5D(noise, currentConfig.width, intensity, currentConfig.height);
//             // auto graph = createVertexToVertex(*geometryPtr);
//             // auto graph = createPolygonToPolygon(*geometryPtr);

//             tm.addTask([]{
                
//             });
//         }
//     }

// };