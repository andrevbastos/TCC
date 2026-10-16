#pragma once

#include <chrono>
#include <fstream>
#include <functional>
#include <iomanip>
#include <mutex>
#include <optional>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

#include "core/util.hpp"

struct Results {
    std::string algorithmName;
    double testedValue = 0.0;

    double graphGenerationTime = 0.0;
    std::size_t graphNodes = 0;
    bool success = false;
    std::optional<double> pathCost = std::nullopt;
    std::optional<double> executionTime = std::nullopt;
    std::optional<std::size_t> pathNodeCount = std::nullopt;
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
                << ", success=" << result.success
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
            << ",Tempo de Construção do Grafo,Nós do Grafo,Sucesso"
            << ",Custo do Caminho,Tempo de Execução,Nós no Caminho\n";

        for (const Results& result : data) {
            file
                << result.algorithmName << ','
                << formatValue(result.testedValue) << ','
                << formatValue(result.graphGenerationTime) << ','
                << result.graphNodes << ','
                << (result.success ? 1 : 0) << ',';
            writeOptional(file, result.pathCost);
            file << ',';
            writeOptional(file, result.executionTime);
            file << ',';
            writeOptional(file, result.pathNodeCount);
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
using AlgFunc = std::function<std::vector<std::size_t>(
    const common::lwGraph<Vertex3D>&,
    std::size_t,
    std::size_t,
    HeuristicFuncLW
)>;

struct Algorithm {
    std::string name;
    AlgFunc run;
};

void testScale(
    uint steps,
    uint repetitions,
    const std::string& outputDir,
    int heightScale,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms
) {
    Statistics stats;
    std::random_device randomDevice;
    std::mt19937 generator(randomDevice());
    std::uniform_int_distribution<unsigned int> seedDistribution;

    const HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) {
        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    for (std::size_t step = 0; step < steps; ++step) {
        const int dimension = 500 + (static_cast<int>(step) * 100);

        for (std::size_t repetition = 0; repetition < repetitions; ++repetition) {
            perlin2D::NoiseConfig config = {
                .width = dimension,
                .height = dimension,
                .freq = 1.0f,
                .amp = 1.0f,
                .exp = 1.0f,
                .seed = seedDistribution(generator),
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

            for (const Algorithm& algorithm : algorithms) {
                Results result {
                    .algorithmName = algorithm.name,
                    .testedValue = static_cast<double>(dimension),
                    .graphGenerationTime = graphGenerationTime,
                    .graphNodes = graph.getOrder()
                };

                if (graph.getOrder() > 0) {
                    const std::size_t startId = 0;
                    const std::size_t endId = graph.getOrder() - 1;

                    const auto executionStart = std::chrono::steady_clock::now();
                    const auto path = algorithm.run(graph, startId, endId, heuristic);
                    const auto executionEnd = std::chrono::steady_clock::now();

                    result.executionTime =
                        std::chrono::duration<double>(executionEnd - executionStart).count();
                    result.success = !path.empty();

                    // TODO: coletar nós expandidos quando os algoritmos fornecerem essa métrica.
                    if (result.success) {
                        result.pathCost = calculatePathCostLW(path, graph);
                        result.pathNodeCount = path.size();
                    }
                }

                stats.addResult(std::move(result));
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
    const std::string& outputDir,
    int heightScale,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms
) {
}

void testPersistence(
    uint steps,
    uint repetitions,
    const std::string& outputDir,
    int heightScale,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms
) {
}
