#pragma once

#include <algorithm>
#include <array>
#include <chrono>
#include <fstream>
#include <functional>
#include <iomanip>
#include <mutex>
#include <optional>
#include <random>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include "core/search.hpp"
#include "core/terrain_metrics.hpp"
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

    // Terreno (uma vez por semente, fora dos cronômetros)
    std::optional<std::size_t> localMaxima = std::nullopt;
    std::optional<double> obstacleFraction = std::nullopt;
    std::optional<double> heightStdDev = std::nullopt;
    std::optional<double> meanSlope = std::nullopt;
    // Consulta (depois de cada busca, fora dos cronômetros)
    std::optional<std::size_t> heuristicCalls = std::nullopt;
    std::optional<double> startHeuristicRatio = std::nullopt;
    std::optional<double> straightLineDistance = std::nullopt;
    std::optional<double> totalAscent = std::nullopt;
    std::optional<double> maxPathSlope = std::nullopt;
    // Inicialização isolada do estado das buscas (uma vez por grafo)
    std::optional<double> initTime = std::nullopt;
    // Busca com repetições internas: mediana e número de repetições (k)
    std::optional<double> searchTime = std::nullopt;
    std::optional<std::size_t> searchRepetitions = std::nullopt;
    // Extração do Marching Cubes (só vértice e dual)
    std::optional<double> mcExtractionTime = std::nullopt;
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
        const std::string& testedColumnName,
        const ProcessState& process
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
            << ",Nós Expandidos,Nós Gerados,Pico da Open List"
            << ",n_maximos_locais,fracao_obstaculos,desvio_altura,declividade_media"
            << ",chamadas_heuristica,razao_heuristica_inicio,distancia_linha_reta"
            << ",subida_acumulada,declividade_maxima_caminho"
            << ",tempo_inicializacao"
            << ",pico_memoria_kb,freq_cpu_inicio_khz,freq_cpu_fim_khz,carga_inicio,carga_fim"
            << ",tempo_busca,k"
            << ",tempo_extracao_mc_s\n";

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
            writeOptional(file, result.localMaxima);
            file << ',';
            writeOptional(file, result.obstacleFraction);
            file << ',';
            writeOptional(file, result.heightStdDev);
            file << ',';
            writeOptional(file, result.meanSlope);
            file << ',';
            writeOptional(file, result.heuristicCalls);
            file << ',';
            writeOptional(file, result.startHeuristicRatio);
            file << ',';
            writeOptional(file, result.straightLineDistance);
            file << ',';
            writeOptional(file, result.totalAscent);
            file << ',';
            writeOptional(file, result.maxPathSlope);
            file << ',';
            writeOptional(file, result.initTime);
            file << ',';
            writeOptional(file, process.peakMemoryKB);
            file << ',';
            writeOptional(file, process.start.cpuFreqKHz);
            file << ',';
            writeOptional(file, process.end.cpuFreqKHz);
            file << ',';
            writeOptional(file, process.start.load1);
            file << ',';
            writeOptional(file, process.end.load1);
            file << ',';
            writeOptional(file, result.searchTime);
            file << ',';
            writeOptional(file, result.searchRepetitions);
            file << ',';
            writeOptional(file, result.mcExtractionTime);
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
    // false só no Dijkstra: chamadas_heuristica = 0 e o custo dele é a referência ótima.
    bool usesHeuristic = true;
};

struct QueryPair {
    Vertex3D start;
    Vertex3D goal;
};

// As duas diagonais do terreno, de canto a canto.
inline std::vector<QueryPair> generateQueryPairs(
    const std::vector<float>& noise,
    int width,
    int depth,
    int heightScale
) {
    auto surfacePoint = [&](int x, int z) {
        const float y = 1.0f + noise[(z * width) + x] * (static_cast<float>(heightScale) - 1.0f);
        return Vertex3D{static_cast<float>(x), y, static_cast<float>(z)};
    };

    return {
        {surfacePoint(0, 0), surfacePoint(width - 1, depth - 1)},
        {surfacePoint(width - 1, 0), surfacePoint(0, depth - 1)}
    };
}

// Configuração de ruído do teste de escala, compartilhada com o mcbench (mc_bench.hpp)
// para que as duas medições usem exatamente o mesmo terreno. lac e pers ficam no padrão
// do NoiseConfig.
inline perlin2D::NoiseConfig scaleNoiseConfig(int dimension, unsigned int terrainSeed) {
    return {
        .width = dimension,
        .height = dimension,
        .wave = dimension / 2,
        .freq = 1.0f,
        .amp = 1.0f,
        .exp = 1.0f,
        .seed = terrainSeed,
        .octaves = 6
    };
}

// Volume cúbico: a altura acompanha a dimensão no teste de escala.
inline int scaleHeightScale(int dimension) {
    return dimension;
}

// Comprimentos de onda base do teste de frequência.
inline constexpr std::array<int, 4> FREQUENCY_WAVES {200, 275, 350, 500};

// Passos selecionados por --level (vazio: todos). Usado no piloto para rodar só os extremos.
inline bool levelSelected(const std::vector<uint>& levels, std::size_t step) {
    return levels.empty()
        || std::find(levels.begin(), levels.end(), static_cast<uint>(step)) != levels.end();
}

void testScale(
    uint steps,
    uint repetitions,
    unsigned int baseSeed,
    const std::string& outputDir,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms,
    const std::vector<uint>& levels
) {
    const MachineState machineStart = readMachineState();
    Statistics stats;
    std::mt19937 seedGenerator(baseSeed);
    std::uniform_int_distribution<unsigned int> seedDistribution;

    const HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) {
        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    for (std::size_t step = 0; step < steps; ++step) {
        if (!levelSelected(levels, step)) {
            continue;
        }
        const int dimension = 500 + (static_cast<int>(step) * 100);
        // Volume cúbico e terreno esticado: altura e comprimento de onda acompanham a dimensão
        // (heightScale / wave = 2, como em lac/pers), então só a resolução muda entre os passos.
        const int heightScale = scaleHeightScale(dimension);

        for (std::size_t repetition = 0; repetition < repetitions; ++repetition) {
            // Refaz a repetição apenas se o grafo sair vazio.
            while (true) {
                const unsigned int terrainSeed = seedDistribution(seedGenerator);

                perlin2D::NoiseConfig config = scaleNoiseConfig(dimension, terrainSeed);

                auto noise = perlin2D::generateNoiseMap(config);
                std::vector<Vertex> geometryVertices;
                std::vector<GLuint> geometryIndices;
                std::optional<double> mcExtractionTime;

                if (graphModel.requiresGeometry) {
                    // Uma extração por terreno; a malha alimenta o grafo (vértice ou dual).
                    const auto mcStart = std::chrono::steady_clock::now();
                    auto [vertices, indices] = getMarchingCubeData(
                        noise,
                        config.width,
                        heightScale,
                        config.height
                    );
                    const auto mcEnd = std::chrono::steady_clock::now();
                    mcExtractionTime = std::chrono::duration<double>(mcEnd - mcStart).count();
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

                std::vector<Results> attemptResults;

                const auto pairs = generateQueryPairs(
                    noise, config.width, config.height, heightScale
                );

                for (std::size_t pairIndex = 0; pairIndex < pairs.size(); ++pairIndex) {
                    const SnapResult start = nearestVertex(graph, pairs[pairIndex].start);
                    const SnapResult goal = nearestVertex(graph, pairs[pairIndex].goal);
                    std::cerr << "[snap] " << graphModel.name << " seed=" << terrainSeed
                        << " par=" << pairIndex << ": início=" << start.distance
                        << " fim=" << goal.distance << std::endl;

                    const std::size_t pairBegin = attemptResults.size();
                    const Vertex3D& startData = graph.getVertexData(start.id);
                    const Vertex3D& goalData = graph.getVertexData(goal.id);
                    const double straightLineDistance = euclideanDistance3D(startData, goalData);
                    const double startHeuristic = heuristic(startData, goalData);
                    std::optional<double> optimalCost;

                    for (const Algorithm& algorithm : algorithms) {
                        Results result {
                            .algorithmName = algorithm.name,
                            .testedValue = static_cast<double>(dimension),
                            .terrainSeed = terrainSeed,
                            .pairIndex = pairIndex,
                            .graphGenerationTime = graphGenerationTime,
                            .graphNodes = graph.getOrder(),
                            .graphEdges = graphEdges,
                            .graphMemory = graphMemory,
                            .mcExtractionTime = mcExtractionTime
                        };

                        // Warm-up: a mesma busca, no mesmo grafo e par, uma vez sem cronômetro.
                        if (SEARCH_WARMUP) {
                            (void)algorithm.run(graph, start.id, goal.id, heuristic);
                        }

                        const auto executionStart = std::chrono::steady_clock::now();
                        const auto search = algorithm.run(graph, start.id, goal.id, heuristic);
                        const auto executionEnd = std::chrono::steady_clock::now();

                        result.executionTime =
                            std::chrono::duration<double>(executionEnd - executionStart).count();
                        const bool pathFound = !search.path.empty();
                        result.expandedNodes = search.expanded;
                        result.generatedNodes = search.generated;
                        result.peakOpen = search.peakOpen;

                        // Sem filtro de arestas a superfície é conexa; sem caminho, a aquisição é inválida.
                        if (!pathFound) {
                            throw std::runtime_error(
                                graphModel.name + " seed=" + std::to_string(terrainSeed)
                                + " par=" + std::to_string(pairIndex) + ": "
                                + algorithm.name + " não encontrou caminho."
                            );
                        }

                        // Buscas curtas: repete até passar de 5 ms e guarda a mediana; as longas
                        // ficam com a medição acima (k = 1).
                        if (*result.executionTime < SHORT_SEARCH_THRESHOLD_S) {
                            const RepeatedTiming repeated = repeatShortSearch([&]() {
                                return algorithm.run(graph, start.id, goal.id, heuristic);
                            });
                            result.searchTime = repeated.median;
                            result.searchRepetitions = repeated.repetitions;
                        } else {
                            result.searchTime = result.executionTime;
                            result.searchRepetitions = 1;
                        }

                        result.pathCost = search.cost;
                        result.pathNodeCount = search.path.size();
                        result.geometricLength = surfacePathLength(
                            search.path, graph, noise, config.width, config.height, heightScale
                        );

                        // generated conta o início e cada push, e cada um deles chama h uma vez.
                        result.heuristicCalls = algorithm.usesHeuristic ? search.generated : 0;
                        result.straightLineDistance = straightLineDistance;
                        const PathMetrics pathMetrics = computePathMetrics(search.path, graph);
                        result.totalAscent = pathMetrics.totalAscent;
                        result.maxPathSlope = pathMetrics.maxSlopeDegrees;
                        if (!algorithm.usesHeuristic) {
                            optimalCost = search.cost;
                        }

                        attemptResults.push_back(std::move(result));
                    }

                    // Custo ótimo do Dijkstra da mesma semente, par e representação; sem Dijkstra
                    // na lista, ele roda aqui, sem cronômetro.
                    if (!optimalCost.has_value()) {
                        optimalCost = search::dijkstra(graph, start.id, goal.id).cost;
                    }
                    for (std::size_t i = pairBegin; i < attemptResults.size(); ++i) {
                        attemptResults[i].startHeuristicRatio = startHeuristic / *optimalCost;
                    }
                }

                // Depois de todas as buscas, para não aquecer a cache antes dos cronômetros.
                const TerrainMetrics terrain = computeTerrainMetrics(
                    noise, config.width, config.height, heightScale
                );
                const double initTime = measureSearchStateInit(graph.getOrder());

                for (Results& result : attemptResults) {
                    result.localMaxima = terrain.localMaxima;
                    result.obstacleFraction = terrain.obstacleFraction;
                    result.heightStdDev = terrain.heightStdDev;
                    result.meanSlope = terrain.meanSlope;
                    result.initTime = initTime;
                    stats.addResult(std::move(result));
                }
                break;
            }
        }
    }

    const std::string separator =
        !outputDir.empty() && outputDir.back() == '/' ? "" : "/";
    const std::string savePath =
        outputDir + separator + "scale_" + graphModel.name + ".csv";
    stats.saveToCSV(savePath, "Escala", {machineStart, readMachineState(), peakMemoryKB()});
}

void testLacunarity(
    uint steps,
    uint repetitions,
    unsigned int baseSeed,
    const std::string& outputDir,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms,
    const std::vector<uint>& levels
) {
    const MachineState machineStart = readMachineState();
    Statistics stats;
    std::mt19937 seedGenerator(baseSeed);
    std::uniform_int_distribution<unsigned int> seedDistribution;

    const HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) {
        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    for (std::size_t step = 0; step < steps; ++step) {
        if (!levelSelected(levels, step)) {
            continue;
        }
        const int dimension = 500;
        const int heightScale = dimension;
        // lac⁵ / wave ≤ 0,25 ciclo por unidade: a última oitava fica abaixo do limite de Nyquist com margem.
        const float lacunarity = 1.5f + (static_cast<float>(step) * (2.25f - 1.5f) / static_cast<float>(std::max(steps - 1, 1u)));

        for (std::size_t repetition = 0; repetition < repetitions; ++repetition) {
            // Refaz a repetição apenas se o grafo sair vazio.
            while (true) {
                const unsigned int terrainSeed = seedDistribution(seedGenerator);

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
                std::optional<double> mcExtractionTime;

                if (graphModel.requiresGeometry) {
                    // Uma extração por terreno; a malha alimenta o grafo (vértice ou dual).
                    const auto mcStart = std::chrono::steady_clock::now();
                    auto [vertices, indices] = getMarchingCubeData(
                        noise,
                        config.width,
                        heightScale,
                        config.height
                    );
                    const auto mcEnd = std::chrono::steady_clock::now();
                    mcExtractionTime = std::chrono::duration<double>(mcEnd - mcStart).count();
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

                std::vector<Results> attemptResults;

                const auto pairs = generateQueryPairs(
                    noise, config.width, config.height, heightScale
                );

                for (std::size_t pairIndex = 0; pairIndex < pairs.size(); ++pairIndex) {
                    const SnapResult start = nearestVertex(graph, pairs[pairIndex].start);
                    const SnapResult goal = nearestVertex(graph, pairs[pairIndex].goal);
                    std::cerr << "[snap] " << graphModel.name << " seed=" << terrainSeed
                        << " par=" << pairIndex << ": início=" << start.distance
                        << " fim=" << goal.distance << std::endl;

                    const std::size_t pairBegin = attemptResults.size();
                    const Vertex3D& startData = graph.getVertexData(start.id);
                    const Vertex3D& goalData = graph.getVertexData(goal.id);
                    const double straightLineDistance = euclideanDistance3D(startData, goalData);
                    const double startHeuristic = heuristic(startData, goalData);
                    std::optional<double> optimalCost;

                    for (const Algorithm& algorithm : algorithms) {
                        Results result {
                            .algorithmName = algorithm.name,
                            .testedValue = static_cast<double>(lacunarity),
                            .terrainSeed = terrainSeed,
                            .pairIndex = pairIndex,
                            .graphGenerationTime = graphGenerationTime,
                            .graphNodes = graph.getOrder(),
                            .graphEdges = graphEdges,
                            .graphMemory = graphMemory,
                            .mcExtractionTime = mcExtractionTime
                        };

                        // Warm-up: a mesma busca, no mesmo grafo e par, uma vez sem cronômetro.
                        if (SEARCH_WARMUP) {
                            (void)algorithm.run(graph, start.id, goal.id, heuristic);
                        }

                        const auto executionStart = std::chrono::steady_clock::now();
                        const auto search = algorithm.run(graph, start.id, goal.id, heuristic);
                        const auto executionEnd = std::chrono::steady_clock::now();

                        result.executionTime =
                            std::chrono::duration<double>(executionEnd - executionStart).count();
                        const bool pathFound = !search.path.empty();
                        result.expandedNodes = search.expanded;
                        result.generatedNodes = search.generated;
                        result.peakOpen = search.peakOpen;

                        // Sem filtro de arestas a superfície é conexa; sem caminho, a aquisição é inválida.
                        if (!pathFound) {
                            throw std::runtime_error(
                                graphModel.name + " seed=" + std::to_string(terrainSeed)
                                + " par=" + std::to_string(pairIndex) + ": "
                                + algorithm.name + " não encontrou caminho."
                            );
                        }

                        // Buscas curtas: repete até passar de 5 ms e guarda a mediana; as longas
                        // ficam com a medição acima (k = 1).
                        if (*result.executionTime < SHORT_SEARCH_THRESHOLD_S) {
                            const RepeatedTiming repeated = repeatShortSearch([&]() {
                                return algorithm.run(graph, start.id, goal.id, heuristic);
                            });
                            result.searchTime = repeated.median;
                            result.searchRepetitions = repeated.repetitions;
                        } else {
                            result.searchTime = result.executionTime;
                            result.searchRepetitions = 1;
                        }

                        result.pathCost = search.cost;
                        result.pathNodeCount = search.path.size();
                        result.geometricLength = surfacePathLength(
                            search.path, graph, noise, config.width, config.height, heightScale
                        );

                        // generated conta o início e cada push, e cada um deles chama h uma vez.
                        result.heuristicCalls = algorithm.usesHeuristic ? search.generated : 0;
                        result.straightLineDistance = straightLineDistance;
                        const PathMetrics pathMetrics = computePathMetrics(search.path, graph);
                        result.totalAscent = pathMetrics.totalAscent;
                        result.maxPathSlope = pathMetrics.maxSlopeDegrees;
                        if (!algorithm.usesHeuristic) {
                            optimalCost = search.cost;
                        }

                        attemptResults.push_back(std::move(result));
                    }

                    // Custo ótimo do Dijkstra da mesma semente, par e representação; sem Dijkstra
                    // na lista, ele roda aqui, sem cronômetro.
                    if (!optimalCost.has_value()) {
                        optimalCost = search::dijkstra(graph, start.id, goal.id).cost;
                    }
                    for (std::size_t i = pairBegin; i < attemptResults.size(); ++i) {
                        attemptResults[i].startHeuristicRatio = startHeuristic / *optimalCost;
                    }
                }

                // Depois de todas as buscas, para não aquecer a cache antes dos cronômetros.
                const TerrainMetrics terrain = computeTerrainMetrics(
                    noise, config.width, config.height, heightScale
                );
                const double initTime = measureSearchStateInit(graph.getOrder());

                for (Results& result : attemptResults) {
                    result.localMaxima = terrain.localMaxima;
                    result.obstacleFraction = terrain.obstacleFraction;
                    result.heightStdDev = terrain.heightStdDev;
                    result.meanSlope = terrain.meanSlope;
                    result.initTime = initTime;
                    stats.addResult(std::move(result));
                }
                break;
            }
        }
    }

    const std::string separator =
        !outputDir.empty() && outputDir.back() == '/' ? "" : "/";
    const std::string savePath =
        outputDir + separator + "lac_" + graphModel.name + ".csv";
    stats.saveToCSV(savePath, "Lacunaridade", {machineStart, readMachineState(), peakMemoryKB()});
}

void testPersistence(
    uint steps,
    uint repetitions,
    unsigned int baseSeed,
    const std::string& outputDir,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms,
    const std::vector<uint>& levels
) {
    const MachineState machineStart = readMachineState();
    Statistics stats;
    std::mt19937 seedGenerator(baseSeed);
    std::uniform_int_distribution<unsigned int> seedDistribution;

    const HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) {
        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    for (std::size_t step = 0; step < steps; ++step) {
        if (!levelSelected(levels, step)) {
            continue;
        }
        const int dimension = 500;
        const int heightScale = dimension;
        const float persistence = 0.3f + (static_cast<float>(step) * (0.7f - 0.3f) / static_cast<float>(std::max(steps - 1, 1u)));

        for (std::size_t repetition = 0; repetition < repetitions; ++repetition) {
            // Refaz a repetição apenas se o grafo sair vazio.
            while (true) {
                const unsigned int terrainSeed = seedDistribution(seedGenerator);

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
                std::optional<double> mcExtractionTime;

                if (graphModel.requiresGeometry) {
                    // Uma extração por terreno; a malha alimenta o grafo (vértice ou dual).
                    const auto mcStart = std::chrono::steady_clock::now();
                    auto [vertices, indices] = getMarchingCubeData(
                        noise,
                        config.width,
                        heightScale,
                        config.height
                    );
                    const auto mcEnd = std::chrono::steady_clock::now();
                    mcExtractionTime = std::chrono::duration<double>(mcEnd - mcStart).count();
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

                std::vector<Results> attemptResults;

                const auto pairs = generateQueryPairs(
                    noise, config.width, config.height, heightScale
                );

                for (std::size_t pairIndex = 0; pairIndex < pairs.size(); ++pairIndex) {
                    const SnapResult start = nearestVertex(graph, pairs[pairIndex].start);
                    const SnapResult goal = nearestVertex(graph, pairs[pairIndex].goal);
                    std::cerr << "[snap] " << graphModel.name << " seed=" << terrainSeed
                        << " par=" << pairIndex << ": início=" << start.distance
                        << " fim=" << goal.distance << std::endl;

                    const std::size_t pairBegin = attemptResults.size();
                    const Vertex3D& startData = graph.getVertexData(start.id);
                    const Vertex3D& goalData = graph.getVertexData(goal.id);
                    const double straightLineDistance = euclideanDistance3D(startData, goalData);
                    const double startHeuristic = heuristic(startData, goalData);
                    std::optional<double> optimalCost;

                    for (const Algorithm& algorithm : algorithms) {
                        Results result {
                            .algorithmName = algorithm.name,
                            .testedValue = static_cast<double>(persistence),
                            .terrainSeed = terrainSeed,
                            .pairIndex = pairIndex,
                            .graphGenerationTime = graphGenerationTime,
                            .graphNodes = graph.getOrder(),
                            .graphEdges = graphEdges,
                            .graphMemory = graphMemory,
                            .mcExtractionTime = mcExtractionTime
                        };

                        // Warm-up: a mesma busca, no mesmo grafo e par, uma vez sem cronômetro.
                        if (SEARCH_WARMUP) {
                            (void)algorithm.run(graph, start.id, goal.id, heuristic);
                        }

                        const auto executionStart = std::chrono::steady_clock::now();
                        const auto search = algorithm.run(graph, start.id, goal.id, heuristic);
                        const auto executionEnd = std::chrono::steady_clock::now();

                        result.executionTime =
                            std::chrono::duration<double>(executionEnd - executionStart).count();
                        const bool pathFound = !search.path.empty();
                        result.expandedNodes = search.expanded;
                        result.generatedNodes = search.generated;
                        result.peakOpen = search.peakOpen;

                        // Sem filtro de arestas a superfície é conexa; sem caminho, a aquisição é inválida.
                        if (!pathFound) {
                            throw std::runtime_error(
                                graphModel.name + " seed=" + std::to_string(terrainSeed)
                                + " par=" + std::to_string(pairIndex) + ": "
                                + algorithm.name + " não encontrou caminho."
                            );
                        }

                        // Buscas curtas: repete até passar de 5 ms e guarda a mediana; as longas
                        // ficam com a medição acima (k = 1).
                        if (*result.executionTime < SHORT_SEARCH_THRESHOLD_S) {
                            const RepeatedTiming repeated = repeatShortSearch([&]() {
                                return algorithm.run(graph, start.id, goal.id, heuristic);
                            });
                            result.searchTime = repeated.median;
                            result.searchRepetitions = repeated.repetitions;
                        } else {
                            result.searchTime = result.executionTime;
                            result.searchRepetitions = 1;
                        }

                        result.pathCost = search.cost;
                        result.pathNodeCount = search.path.size();
                        result.geometricLength = surfacePathLength(
                            search.path, graph, noise, config.width, config.height, heightScale
                        );

                        // generated conta o início e cada push, e cada um deles chama h uma vez.
                        result.heuristicCalls = algorithm.usesHeuristic ? search.generated : 0;
                        result.straightLineDistance = straightLineDistance;
                        const PathMetrics pathMetrics = computePathMetrics(search.path, graph);
                        result.totalAscent = pathMetrics.totalAscent;
                        result.maxPathSlope = pathMetrics.maxSlopeDegrees;
                        if (!algorithm.usesHeuristic) {
                            optimalCost = search.cost;
                        }

                        attemptResults.push_back(std::move(result));
                    }

                    // Custo ótimo do Dijkstra da mesma semente, par e representação; sem Dijkstra
                    // na lista, ele roda aqui, sem cronômetro.
                    if (!optimalCost.has_value()) {
                        optimalCost = search::dijkstra(graph, start.id, goal.id).cost;
                    }
                    for (std::size_t i = pairBegin; i < attemptResults.size(); ++i) {
                        attemptResults[i].startHeuristicRatio = startHeuristic / *optimalCost;
                    }
                }

                // Depois de todas as buscas, para não aquecer a cache antes dos cronômetros.
                const TerrainMetrics terrain = computeTerrainMetrics(
                    noise, config.width, config.height, heightScale
                );
                const double initTime = measureSearchStateInit(graph.getOrder());

                for (Results& result : attemptResults) {
                    result.localMaxima = terrain.localMaxima;
                    result.obstacleFraction = terrain.obstacleFraction;
                    result.heightStdDev = terrain.heightStdDev;
                    result.meanSlope = terrain.meanSlope;
                    result.initTime = initTime;
                    stats.addResult(std::move(result));
                }
                break;
            }
        }
    }

    const std::string separator =
        !outputDir.empty() && outputDir.back() == '/' ? "" : "/";
    const std::string savePath =
        outputDir + separator + "pers_" + graphModel.name + ".csv";
    stats.saveToCSV(savePath, "Persistência", {machineStart, readMachineState(), peakMemoryKB()});
}

// Um fator por vez: só o comprimento de onda base varia (FREQUENCY_WAVES); dimensão,
// lacunaridade, persistência e oitavas ficam nos valores fixos de lac/pers.
// Com lac = 2, a última oitava de wave = 200 fica em 2⁵ / 200 = 0,16 ciclo por unidade.
void testFrequency(
    uint steps,
    uint repetitions,
    unsigned int baseSeed,
    const std::string& outputDir,
    const GraphModel& graphModel,
    const std::vector<Algorithm>& algorithms,
    const std::vector<uint>& levels
) {
    if (steps != FREQUENCY_WAVES.size()) {
        throw std::invalid_argument(
            "frequency tem exatamente " + std::to_string(FREQUENCY_WAVES.size())
            + " passos (wave 200, 275, 350, 500); recebido " + std::to_string(steps) + "."
        );
    }

    const MachineState machineStart = readMachineState();
    Statistics stats;
    std::mt19937 seedGenerator(baseSeed);
    std::uniform_int_distribution<unsigned int> seedDistribution;

    const HeuristicFuncLW heuristic = [](const Vertex3D& a, const Vertex3D& b) {
        const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
        const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
        const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    for (std::size_t step = 0; step < steps; ++step) {
        if (!levelSelected(levels, step)) {
            continue;
        }
        const int dimension = 500;
        const int heightScale = dimension;
        const int wave = FREQUENCY_WAVES[step];

        for (std::size_t repetition = 0; repetition < repetitions; ++repetition) {
            // Refaz a repetição apenas se o grafo sair vazio.
            while (true) {
                const unsigned int terrainSeed = seedDistribution(seedGenerator);

                perlin2D::NoiseConfig config = {
                    .width = dimension,
                    .height = dimension,
                    .wave = wave,
                    .freq = 1.0f,
                    .lac = 2.0f,
                    .amp = 1.0f,
                    .pers = 0.5f,
                    .exp = 1.0f,
                    .seed = terrainSeed,
                    .octaves = 6
                };

                auto noise = perlin2D::generateNoiseMap(config);
                std::vector<Vertex> geometryVertices;
                std::vector<GLuint> geometryIndices;
                std::optional<double> mcExtractionTime;

                if (graphModel.requiresGeometry) {
                    // Uma extração por terreno; a malha alimenta o grafo (vértice ou dual).
                    const auto mcStart = std::chrono::steady_clock::now();
                    auto [vertices, indices] = getMarchingCubeData(
                        noise,
                        config.width,
                        heightScale,
                        config.height
                    );
                    const auto mcEnd = std::chrono::steady_clock::now();
                    mcExtractionTime = std::chrono::duration<double>(mcEnd - mcStart).count();
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

                std::vector<Results> attemptResults;

                const auto pairs = generateQueryPairs(
                    noise, config.width, config.height, heightScale
                );

                for (std::size_t pairIndex = 0; pairIndex < pairs.size(); ++pairIndex) {
                    const SnapResult start = nearestVertex(graph, pairs[pairIndex].start);
                    const SnapResult goal = nearestVertex(graph, pairs[pairIndex].goal);
                    std::cerr << "[snap] " << graphModel.name << " seed=" << terrainSeed
                        << " par=" << pairIndex << ": início=" << start.distance
                        << " fim=" << goal.distance << std::endl;

                    const std::size_t pairBegin = attemptResults.size();
                    const Vertex3D& startData = graph.getVertexData(start.id);
                    const Vertex3D& goalData = graph.getVertexData(goal.id);
                    const double straightLineDistance = euclideanDistance3D(startData, goalData);
                    const double startHeuristic = heuristic(startData, goalData);
                    std::optional<double> optimalCost;

                    for (const Algorithm& algorithm : algorithms) {
                        Results result {
                            .algorithmName = algorithm.name,
                            .testedValue = static_cast<double>(wave),
                            .terrainSeed = terrainSeed,
                            .pairIndex = pairIndex,
                            .graphGenerationTime = graphGenerationTime,
                            .graphNodes = graph.getOrder(),
                            .graphEdges = graphEdges,
                            .graphMemory = graphMemory,
                            .mcExtractionTime = mcExtractionTime
                        };

                        // Warm-up: a mesma busca, no mesmo grafo e par, uma vez sem cronômetro.
                        if (SEARCH_WARMUP) {
                            (void)algorithm.run(graph, start.id, goal.id, heuristic);
                        }

                        const auto executionStart = std::chrono::steady_clock::now();
                        const auto search = algorithm.run(graph, start.id, goal.id, heuristic);
                        const auto executionEnd = std::chrono::steady_clock::now();

                        result.executionTime =
                            std::chrono::duration<double>(executionEnd - executionStart).count();
                        const bool pathFound = !search.path.empty();
                        result.expandedNodes = search.expanded;
                        result.generatedNodes = search.generated;
                        result.peakOpen = search.peakOpen;

                        // Sem filtro de arestas a superfície é conexa; sem caminho, a aquisição é inválida.
                        if (!pathFound) {
                            throw std::runtime_error(
                                graphModel.name + " seed=" + std::to_string(terrainSeed)
                                + " par=" + std::to_string(pairIndex) + ": "
                                + algorithm.name + " não encontrou caminho."
                            );
                        }

                        // Buscas curtas: repete até passar de 5 ms e guarda a mediana; as longas
                        // ficam com a medição acima (k = 1).
                        if (*result.executionTime < SHORT_SEARCH_THRESHOLD_S) {
                            const RepeatedTiming repeated = repeatShortSearch([&]() {
                                return algorithm.run(graph, start.id, goal.id, heuristic);
                            });
                            result.searchTime = repeated.median;
                            result.searchRepetitions = repeated.repetitions;
                        } else {
                            result.searchTime = result.executionTime;
                            result.searchRepetitions = 1;
                        }

                        result.pathCost = search.cost;
                        result.pathNodeCount = search.path.size();
                        result.geometricLength = surfacePathLength(
                            search.path, graph, noise, config.width, config.height, heightScale
                        );

                        // generated conta o início e cada push, e cada um deles chama h uma vez.
                        result.heuristicCalls = algorithm.usesHeuristic ? search.generated : 0;
                        result.straightLineDistance = straightLineDistance;
                        const PathMetrics pathMetrics = computePathMetrics(search.path, graph);
                        result.totalAscent = pathMetrics.totalAscent;
                        result.maxPathSlope = pathMetrics.maxSlopeDegrees;
                        if (!algorithm.usesHeuristic) {
                            optimalCost = search.cost;
                        }

                        attemptResults.push_back(std::move(result));
                    }

                    // Custo ótimo do Dijkstra da mesma semente, par e representação; sem Dijkstra
                    // na lista, ele roda aqui, sem cronômetro.
                    if (!optimalCost.has_value()) {
                        optimalCost = search::dijkstra(graph, start.id, goal.id).cost;
                    }
                    for (std::size_t i = pairBegin; i < attemptResults.size(); ++i) {
                        attemptResults[i].startHeuristicRatio = startHeuristic / *optimalCost;
                    }
                }

                // Depois de todas as buscas, para não aquecer a cache antes dos cronômetros.
                const TerrainMetrics terrain = computeTerrainMetrics(
                    noise, config.width, config.height, heightScale
                );
                const double initTime = measureSearchStateInit(graph.getOrder());

                for (Results& result : attemptResults) {
                    result.localMaxima = terrain.localMaxima;
                    result.obstacleFraction = terrain.obstacleFraction;
                    result.heightStdDev = terrain.heightStdDev;
                    result.meanSlope = terrain.meanSlope;
                    result.initTime = initTime;
                    stats.addResult(std::move(result));
                }
                break;
            }
        }
    }

    const std::string separator =
        !outputDir.empty() && outputDir.back() == '/' ? "" : "/";
    const std::string savePath =
        outputDir + separator + "freq_" + graphModel.name + ".csv";
    stats.saveToCSV(savePath, "Comprimento de Onda", {machineStart, readMachineState(), peakMemoryKB()});
}
