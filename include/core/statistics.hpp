#pragma once

#include <chrono>
#include <fstream>
#include <functional>
#include <iomanip>
#include <mutex>
#include <optional>
#include <random>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

#include "core/search.hpp"
#include "core/util.hpp"

struct Results {
    std::string algorithmName;
    double testedValue = 0.0;
    unsigned int terrainSeed = 0;
    std::size_t pairIndex = 0;

    double graphGenerationTime = 0.0;
    std::size_t graphNodes = 0;
    std::size_t graphEdges = 0;
    std::size_t graphMemory = 0;
    std::optional<double> pathCost = std::nullopt;
    std::optional<double> executionTime = std::nullopt;
    std::optional<std::size_t> pathNodeCount = std::nullopt;
    std::optional<double> geometricLength = std::nullopt;
    std::optional<std::size_t> expandedNodes = std::nullopt;
    std::optional<std::size_t> generatedNodes = std::nullopt;
    std::optional<std::size_t> peakOpen = std::nullopt;
    std::optional<std::size_t> searchBytes = std::nullopt;
};

class Statistics {
public:
    void addResult(Results result) {
        std::lock_guard<std::mutex> lock(mutex);
        data.push_back(std::move(result));
    }

    void printStatistics() const {
        std::lock_guard<std::mutex> lock(mutex);

        for (const Results& result : data) {
            std::cout
                << result.algorithmName
                << ": testedValue=" << result.testedValue
                << ", executionTime=";
            printOptional(std::cout, result.executionTime);
            std::cout << '\n';
        }
    }

    void clear() {
        std::lock_guard<std::mutex> lock(mutex);
        data.clear();
    }

    void saveToCSV(
        const std::string& fullPath,
        const std::string& testedColumnName
    ) const {
        std::lock_guard<std::mutex> lock(mutex);
        std::ofstream file(fullPath);
        if (!file || data.empty()) {
            return;
        }

        file
            << "Algoritmo," << testedColumnName
            << ",Seed do Terreno,Par"
            << ",Tempo de Construção do Grafo,Nós do Grafo,Arestas do Grafo,Memória do Grafo (B)"
            << ",Custo do Caminho,Tempo de Execução,Nós no Caminho,Comprimento Geométrico"
            << ",Nós Expandidos,Nós Gerados,Pico da Open List,Memória da Busca (B)\n";

        for (const Results& result : data) {
            file
                << result.algorithmName << ','
                << formatValue(result.testedValue) << ','
                << result.terrainSeed << ','
                << result.pairIndex << ','
                << formatValue(result.graphGenerationTime) << ','
                << result.graphNodes << ','
                << result.graphEdges << ','
                << result.graphMemory << ',';
            writeOptional(file, result.pathCost);
            file << ',';
            writeOptional(file, result.executionTime);
            file << ',';
            writeOptional(file, result.pathNodeCount);
            file << ',';
            writeOptional(file, result.geometricLength);
            file << ',';
            writeOptional(file, result.expandedNodes);
            file << ',';
            writeOptional(file, result.generatedNodes);
            file << ',';
            writeOptional(file, result.peakOpen);
            file << ',';
            writeOptional(file, result.searchBytes);
            file << '\n';
        }
    }

private:
    template <typename T>
    static void printOptional(std::ostream& output, const std::optional<T>& value) {
        if (value.has_value()) {
            output << *value;
        }
    }

    template <typename T>
    static void writeOptional(std::ostream& output, const std::optional<T>& value) {
        if (value.has_value()) {
            output << *value;
        }
    }

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

    std::vector<Results> data;
    mutable std::mutex mutex;
};

using HeuristicFuncLW = std::function<double(const Vertex3D&, const Vertex3D&)>;
using AlgFunc = std::function<search::SearchResult(
    const common::lwGraph<Vertex3D>&,
    std::size_t,
    std::size_t,
    HeuristicFuncLW
)>;

struct Algorithm {
    std::string name;
    AlgFunc run;
};

struct QueryPair {
    Vertex3D start;
    Vertex3D goal;
};

// Pares em margens opostas: início em z = 0 e fim em z = depth - 1, com x sorteado.
inline std::vector<QueryPair> generateQueryPairs(
    const std::vector<float>& noise,
    int width,
    int depth,
    int heightScale,
    unsigned int terrainSeed,
    uint pairCount
) {
    std::mt19937 generator(terrainSeed ^ 0x9E3779B9u);
    std::uniform_int_distribution<int> xDistribution(0, width - 1);

    auto surfacePoint = [&](int x, int z) {
        const float y = 1.0f + noise[(z * width) + x] * (static_cast<float>(heightScale) - 1.0f);
        return Vertex3D{static_cast<float>(x), y, static_cast<float>(z)};
    };

    std::vector<QueryPair> pairs;
    pairs.reserve(pairCount);
    for (uint i = 0; i < pairCount; ++i) {
        const int startX = xDistribution(generator);
        const int goalX = xDistribution(generator);
        pairs.push_back({surfacePoint(startX, 0), surfacePoint(goalX, depth - 1)});
    }
    return pairs;
}

void testScale(
    uint steps,
    uint repetitions,
    uint pairCount,
    unsigned int baseSeed,
    const std::string& outputDir,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms
) {
    Statistics stats;

    const HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) {
        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    for (std::size_t step = 0; step < steps; ++step) {
        const int dimension = 500 + (static_cast<int>(step) * 100);
        // Volume cúbico e terreno esticado: altura e comprimento de onda acompanham a dimensão
        // (heightScale / wave = 2, como em lac/pers), então só a resolução muda entre os passos.
        const int heightScale = dimension;

        for (std::size_t repetition = 0; repetition < repetitions; ++repetition) {
            const unsigned int terrainSeed =
                baseSeed + static_cast<unsigned int>((step * repetitions) + repetition);

            perlin2D::NoiseConfig config = {
                .width = dimension,
                .height = dimension,
                .wave = dimension / 2,
                .freq = 1.0f,
                .amp = 1.0f,
                .exp = 1.0f,
                .seed = terrainSeed,
                .octaves = 6
            };

            auto noise = perlin2D::generateNoiseMap(config);
            std::vector<Vertex> geometryVertices;
            std::vector<GLuint> geometryIndices;

            if (graphModel.requiresGeometry) {
                auto [vertices, indices] = getMarchingCubeData(
                    noise,
                    config.width,
                    heightScale,
                    config.height
                );
                geometryVertices = std::move(vertices);
                geometryIndices = std::move(indices);
            }

            const GraphBuildInput graphInput {
                .noise = noise,
                .vertices = geometryVertices,
                .indices = geometryIndices,
                .width = config.width,
                .heightScale = heightScale,
                .depth = config.height
            };

            const auto graphStart = std::chrono::steady_clock::now();
            auto graph = graphModel.create(graphInput);
            const auto graphEnd = std::chrono::steady_clock::now();
            const double graphGenerationTime =
                std::chrono::duration<double>(graphEnd - graphStart).count();
            const std::size_t graphEdges = countEdges(graph);
            const std::size_t graphMemory = graphMemoryBytes(graph);

            if (graph.getOrder() == 0) {
                continue;
            }

            const std::vector<char> snapMask = largestComponentMask(graph);

            const auto pairs = generateQueryPairs(
                noise, config.width, config.height, heightScale, terrainSeed, pairCount
            );

            for (std::size_t pairIndex = 0; pairIndex < pairs.size(); ++pairIndex) {
                const SnapResult start = nearestVertex(graph, pairs[pairIndex].start, snapMask);
                const SnapResult goal = nearestVertex(graph, pairs[pairIndex].goal, snapMask);

                // Diagnóstico interno (fora do CSV): ponto realocado para longe do pedido.
                if (start.distance > 2.0 || goal.distance > 2.0) {
                    std::cerr << "[aviso] " << graphModel.name << " seed=" << terrainSeed
                        << " par=" << pairIndex << ": snap início=" << start.distance
                        << ", fim=" << goal.distance << std::endl;
                }

                for (const Algorithm& algorithm : algorithms) {
                    Results result {
                        .algorithmName = algorithm.name,
                        .testedValue = static_cast<double>(dimension),
                        .terrainSeed = terrainSeed,
                        .pairIndex = pairIndex,
                        .graphGenerationTime = graphGenerationTime,
                        .graphNodes = graph.getOrder(),
                        .graphEdges = graphEdges,
                        .graphMemory = graphMemory
                    };

                    const auto executionStart = std::chrono::steady_clock::now();
                    const auto search = algorithm.run(graph, start.id, goal.id, heuristic);
                    const auto executionEnd = std::chrono::steady_clock::now();

                    result.executionTime =
                        std::chrono::duration<double>(executionEnd - executionStart).count();
                    const bool pathFound = !search.path.empty();
                    result.expandedNodes = search.expanded;
                    result.generatedNodes = search.generated;
                    result.peakOpen = search.peakOpen;
                    result.searchBytes = search.peakBytes;

                    if (!pathFound) {
                        // Não deveria ocorrer: início e fim estão no mesmo componente.
                        std::cerr << "[aviso] " << graphModel.name << " seed=" << terrainSeed
                            << " par=" << pairIndex << ": " << algorithm.name
                            << " não encontrou caminho." << std::endl;
                    }

                    if (pathFound) {
                        result.pathCost = search.cost;
                        result.pathNodeCount = search.path.size();
                        result.geometricLength = surfacePathLength(
                            search.path, graph, noise, config.width, config.height, heightScale
                        );
                    }

                    stats.addResult(std::move(result));
                }
            }
        }
    }

    const std::string separator =
        !outputDir.empty() && outputDir.back() == '/' ? "" : "/";
    const std::string savePath =
        outputDir + separator + "scale_" + graphModel.name + ".csv";
    stats.saveToCSV(savePath, "Escala");
}

void testLacunarity(
    uint steps,
    uint repetitions,
    uint pairCount,
    unsigned int baseSeed,
    const std::string& outputDir,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms
) {
    Statistics stats;

    const HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) {
        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    for (std::size_t step = 0; step < steps; ++step) {
        const int dimension = 500;
        const int heightScale = dimension;
        const float lacunarity = 1.5f + (static_cast<float>(step) * (3.0f - 1.5f) / static_cast<float>(std::max(steps - 1, 1u)));

        for (std::size_t repetition = 0; repetition < repetitions; ++repetition) {
            const unsigned int terrainSeed =
                baseSeed + static_cast<unsigned int>(repetition);

            perlin2D::NoiseConfig config = {
                .width = dimension,
                .height = dimension,
                .wave = 250,
                .freq = 1.0f,
                .lac = lacunarity,
                .amp = 1.0f,
                .pers = 0.5f,
                .exp = 1.0f,
                .seed = terrainSeed,
                .octaves = 6
            };

            auto noise = perlin2D::generateNoiseMap(config);
            std::vector<Vertex> geometryVertices;
            std::vector<GLuint> geometryIndices;

            if (graphModel.requiresGeometry) {
                auto [vertices, indices] = getMarchingCubeData(
                    noise,
                    config.width,
                    heightScale,
                    config.height
                );
                geometryVertices = std::move(vertices);
                geometryIndices = std::move(indices);
            }

            const GraphBuildInput graphInput {
                .noise = noise,
                .vertices = geometryVertices,
                .indices = geometryIndices,
                .width = config.width,
                .heightScale = heightScale,
                .depth = config.height
            };

            const auto graphStart = std::chrono::steady_clock::now();
            auto graph = graphModel.create(graphInput);
            const auto graphEnd = std::chrono::steady_clock::now();
            const double graphGenerationTime =
                std::chrono::duration<double>(graphEnd - graphStart).count();
            const std::size_t graphEdges = countEdges(graph);
            const std::size_t graphMemory = graphMemoryBytes(graph);

            if (graph.getOrder() == 0) {
                continue;
            }

            const std::vector<char> snapMask = largestComponentMask(graph);

            const auto pairs = generateQueryPairs(
                noise, config.width, config.height, heightScale, terrainSeed, pairCount
            );

            for (std::size_t pairIndex = 0; pairIndex < pairs.size(); ++pairIndex) {
                const SnapResult start = nearestVertex(graph, pairs[pairIndex].start, snapMask);
                const SnapResult goal = nearestVertex(graph, pairs[pairIndex].goal, snapMask);

                // Diagnóstico interno (fora do CSV): ponto realocado para longe do pedido.
                if (start.distance > 2.0 || goal.distance > 2.0) {
                    std::cerr << "[aviso] " << graphModel.name << " seed=" << terrainSeed
                        << " par=" << pairIndex << ": snap início=" << start.distance
                        << ", fim=" << goal.distance << std::endl;
                }

                for (const Algorithm& algorithm : algorithms) {
                    Results result {
                        .algorithmName = algorithm.name,
                        .testedValue = static_cast<double>(lacunarity),
                        .terrainSeed = terrainSeed,
                        .pairIndex = pairIndex,
                        .graphGenerationTime = graphGenerationTime,
                        .graphNodes = graph.getOrder(),
                        .graphEdges = graphEdges,
                        .graphMemory = graphMemory
                    };

                    const auto executionStart = std::chrono::steady_clock::now();
                    const auto search = algorithm.run(graph, start.id, goal.id, heuristic);
                    const auto executionEnd = std::chrono::steady_clock::now();

                    result.executionTime =
                        std::chrono::duration<double>(executionEnd - executionStart).count();
                    const bool pathFound = !search.path.empty();
                    result.expandedNodes = search.expanded;
                    result.generatedNodes = search.generated;
                    result.peakOpen = search.peakOpen;
                    result.searchBytes = search.peakBytes;

                    if (!pathFound) {
                        // Não deveria ocorrer: início e fim estão no mesmo componente.
                        std::cerr << "[aviso] " << graphModel.name << " seed=" << terrainSeed
                            << " par=" << pairIndex << ": " << algorithm.name
                            << " não encontrou caminho." << std::endl;
                    }

                    if (pathFound) {
                        result.pathCost = search.cost;
                        result.pathNodeCount = search.path.size();
                        result.geometricLength = surfacePathLength(
                            search.path, graph, noise, config.width, config.height, heightScale
                        );
                    }

                    stats.addResult(std::move(result));
                }
            }
        }
    }

    const std::string separator =
        !outputDir.empty() && outputDir.back() == '/' ? "" : "/";
    const std::string savePath =
        outputDir + separator + "lac_" + graphModel.name + ".csv";
    stats.saveToCSV(savePath, "Lacunaridade");
}

void testPersistence(
    uint steps,
    uint repetitions,
    uint pairCount,
    unsigned int baseSeed,
    const std::string& outputDir,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms
) {
    Statistics stats;

    const HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) {
        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    for (std::size_t step = 0; step < steps; ++step) {
        const int dimension = 500;
        const int heightScale = dimension;
        const float persistence = 0.3f + (static_cast<float>(step) * (0.7f - 0.3f) / static_cast<float>(std::max(steps - 1, 1u)));

        for (std::size_t repetition = 0; repetition < repetitions; ++repetition) {
            const unsigned int terrainSeed =
                baseSeed + static_cast<unsigned int>(repetition);

            perlin2D::NoiseConfig config = {
                .width = dimension,
                .height = dimension,
                .wave = 250,
                .freq = 1.0f,
                .lac = 2.0f,
                .amp = 1.0f,
                .pers = persistence,
                .exp = 1.0f,
                .seed = terrainSeed,
                .octaves = 6
            };

            auto noise = perlin2D::generateNoiseMap(config);
            std::vector<Vertex> geometryVertices;
            std::vector<GLuint> geometryIndices;

            if (graphModel.requiresGeometry) {
                auto [vertices, indices] = getMarchingCubeData(
                    noise,
                    config.width,
                    heightScale,
                    config.height
                );
                geometryVertices = std::move(vertices);
                geometryIndices = std::move(indices);
            }

            const GraphBuildInput graphInput {
                .noise = noise,
                .vertices = geometryVertices,
                .indices = geometryIndices,
                .width = config.width,
                .heightScale = heightScale,
                .depth = config.height
            };

            const auto graphStart = std::chrono::steady_clock::now();
            auto graph = graphModel.create(graphInput);
            const auto graphEnd = std::chrono::steady_clock::now();
            const double graphGenerationTime =
                std::chrono::duration<double>(graphEnd - graphStart).count();
            const std::size_t graphEdges = countEdges(graph);
            const std::size_t graphMemory = graphMemoryBytes(graph);

            if (graph.getOrder() == 0) {
                continue;
            }

            const std::vector<char> snapMask = largestComponentMask(graph);

            const auto pairs = generateQueryPairs(
                noise, config.width, config.height, heightScale, terrainSeed, pairCount
            );

            for (std::size_t pairIndex = 0; pairIndex < pairs.size(); ++pairIndex) {
                const SnapResult start = nearestVertex(graph, pairs[pairIndex].start, snapMask);
                const SnapResult goal = nearestVertex(graph, pairs[pairIndex].goal, snapMask);

                // Diagnóstico interno (fora do CSV): ponto realocado para longe do pedido.
                if (start.distance > 2.0 || goal.distance > 2.0) {
                    std::cerr << "[aviso] " << graphModel.name << " seed=" << terrainSeed
                        << " par=" << pairIndex << ": snap início=" << start.distance
                        << ", fim=" << goal.distance << std::endl;
                }

                for (const Algorithm& algorithm : algorithms) {
                    Results result {
                        .algorithmName = algorithm.name,
                        .testedValue = static_cast<double>(persistence),
                        .terrainSeed = terrainSeed,
                        .pairIndex = pairIndex,
                        .graphGenerationTime = graphGenerationTime,
                        .graphNodes = graph.getOrder(),
                        .graphEdges = graphEdges,
                        .graphMemory = graphMemory
                    };

                    const auto executionStart = std::chrono::steady_clock::now();
                    const auto search = algorithm.run(graph, start.id, goal.id, heuristic);
                    const auto executionEnd = std::chrono::steady_clock::now();

                    result.executionTime =
                        std::chrono::duration<double>(executionEnd - executionStart).count();
                    const bool pathFound = !search.path.empty();
                    result.expandedNodes = search.expanded;
                    result.generatedNodes = search.generated;
                    result.peakOpen = search.peakOpen;
                    result.searchBytes = search.peakBytes;

                    if (!pathFound) {
                        // Não deveria ocorrer: início e fim estão no mesmo componente.
                        std::cerr << "[aviso] " << graphModel.name << " seed=" << terrainSeed
                            << " par=" << pairIndex << ": " << algorithm.name
                            << " não encontrou caminho." << std::endl;
                    }

                    if (pathFound) {
                        result.pathCost = search.cost;
                        result.pathNodeCount = search.path.size();
                        result.geometricLength = surfacePathLength(
                            search.path, graph, noise, config.width, config.height, heightScale
                        );
                    }

                    stats.addResult(std::move(result));
                }
            }
        }
    }

    const std::string separator =
        !outputDir.empty() && outputDir.back() == '/' ? "" : "/";
    const std::string savePath =
        outputDir + separator + "pers_" + graphModel.name + ".csv";
    stats.saveToCSV(savePath, "Persistência");
}
