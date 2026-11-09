#pragma once

// Métricas auxiliares da coleta (`tcc stats`), todas calculadas fora dos cronômetros de
// construção do grafo e de busca:
// - métricas do terreno, uma vez por semente, sobre o heightmap contínuo;
// - métricas do caminho encontrado;
// - medição isolada da inicialização do estado das buscas;
// - estado da máquina e do processo (frequência, carga, pico de memória);
// - repetições internas para buscas curtas.

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <fstream>
#include <limits>
#include <optional>
#include <string>
#include <vector>
#include <sys/resource.h>

#include "core/search.hpp"
#include "core/util.hpp"

// ---------------------------------------------------------------------------------------
// Terreno
// ---------------------------------------------------------------------------------------

struct TerrainMetrics {
    std::size_t localMaxima = 0;   // máximos locais (vizinhança de 8) com altura ≥ média + 1σ
    double obstacleFraction = 0.0; // fração das células com altura ≥ média + 1σ
    double heightStdDev = 0.0;     // desvio padrão (populacional) da altura
    double meanSlope = 0.0;        // média de |∇h| por diferenças centrais
};

// Alturas na unidade do mapa (mesma conversão do grafo 2.5D: y = 1 + ruído·(heightScale − 1)),
// com espaçamento horizontal de 1 entre células. A declividade é adimensional (subida/avanço).
// Máximos locais e gradiente só no interior: as bordas não têm a vizinhança completa.
inline TerrainMetrics computeTerrainMetrics(
    const std::vector<float>& noise,
    int width,
    int depth,
    int heightScale
) {
    TerrainMetrics metrics;
    const std::size_t cellCount = static_cast<std::size_t>(width) * static_cast<std::size_t>(depth);
    if (cellCount == 0 || noise.size() < cellCount) {
        return metrics;
    }

    std::vector<double> heights(cellCount);
    double sum = 0.0;
    for (std::size_t i = 0; i < cellCount; ++i) {
        heights[i] = 1.0 + static_cast<double>(noise[i]) * (static_cast<double>(heightScale) - 1.0);
        sum += heights[i];
    }

    const double mean = sum / static_cast<double>(cellCount);
    double squaredDeviation = 0.0;
    for (const double h : heights) {
        squaredDeviation += (h - mean) * (h - mean);
    }
    metrics.heightStdDev = std::sqrt(squaredDeviation / static_cast<double>(cellCount));

    const double threshold = mean + metrics.heightStdDev;
    std::size_t obstacleCells = 0;
    for (const double h : heights) {
        if (h >= threshold) {
            ++obstacleCells;
        }
    }
    metrics.obstacleFraction = static_cast<double>(obstacleCells) / static_cast<double>(cellCount);

    auto at = [&](int x, int z) {
        return heights[(static_cast<std::size_t>(z) * static_cast<std::size_t>(width)) + static_cast<std::size_t>(x)];
    };

    double slopeSum = 0.0;
    std::size_t slopeCells = 0;
    for (int z = 1; z + 1 < depth; ++z) {
        for (int x = 1; x + 1 < width; ++x) {
            const double h = at(x, z);

            const double gx = (at(x + 1, z) - at(x - 1, z)) * 0.5;
            const double gz = (at(x, z + 1) - at(x, z - 1)) * 0.5;
            slopeSum += std::sqrt((gx * gx) + (gz * gz));
            ++slopeCells;

            if (h < threshold) {
                continue;
            }

            bool isMaximum = true;
            for (int dz = -1; dz <= 1 && isMaximum; ++dz) {
                for (int dx = -1; dx <= 1; ++dx) {
                    if ((dx != 0 || dz != 0) && at(x + dx, z + dz) >= h) {
                        isMaximum = false;
                        break;
                    }
                }
            }
            if (isMaximum) {
                ++metrics.localMaxima;
            }
        }
    }
    metrics.meanSlope = slopeCells > 0 ? slopeSum / static_cast<double>(slopeCells) : 0.0;

    return metrics;
}

// ---------------------------------------------------------------------------------------
// Caminho
// ---------------------------------------------------------------------------------------

struct PathMetrics {
    double totalAscent = 0.0;     // soma das subidas (Δy > 0) entre nós consecutivos
    double maxSlopeDegrees = 0.0; // maior inclinação de um segmento, em graus
};

// A declividade máxima vai em graus (atan2(|Δy|, avanço horizontal)) porque as malhas do
// Marching Cubes têm paredes verticais: nelas o avanço horizontal é 0 e a razão subida/avanço
// seria infinita. Uma parede vertical vale 90°.
inline PathMetrics computePathMetrics(
    const std::vector<std::size_t>& path,
    const common::lwGraph<Vertex3D>& graph
) {
    PathMetrics metrics;
    constexpr double radiansToDegrees = 180.0 / 3.14159265358979323846;

    for (std::size_t i = 0; i + 1 < path.size(); ++i) {
        const Vertex3D& a = graph.getVertexData(path[i]);
        const Vertex3D& b = graph.getVertexData(path[i + 1]);
        const double dy = static_cast<double>(b.y) - static_cast<double>(a.y);
        const double horizontal = std::hypot(
            static_cast<double>(b.x) - static_cast<double>(a.x),
            static_cast<double>(b.z) - static_cast<double>(a.z)
        );

        if (dy > 0.0) {
            metrics.totalAscent += dy;
        }
        if (horizontal > 0.0 || dy != 0.0) {
            metrics.maxSlopeDegrees = std::max(
                metrics.maxSlopeDegrees, std::atan2(std::abs(dy), horizontal) * radiansToDegrees
            );
        }
    }

    return metrics;
}

inline double euclideanDistance3D(const Vertex3D& a, const Vertex3D& b) {
    const double dx = static_cast<double>(a.x) - static_cast<double>(b.x);
    const double dy = static_cast<double>(a.y) - static_cast<double>(b.y);
    const double dz = static_cast<double>(a.z) - static_cast<double>(b.z);
    return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
}

// ---------------------------------------------------------------------------------------
// Inicialização do estado das buscas
// ---------------------------------------------------------------------------------------

// Aloca e inicializa gScore, cameFrom e closed exatamente como as buscas de search.hpp e mede
// só esse trecho (a liberação fica fora do cronômetro). A barreira impede que o compilador
// elimine as alocações, já que os vetores não são usados depois.
inline double measureSearchStateInit(std::size_t numVertices) {
    double elapsed = 0.0;
    {
        const auto start = std::chrono::steady_clock::now();
        std::vector<double> gScore(numVertices, search::INF);
        std::vector<std::size_t> cameFrom(numVertices);
        std::vector<char> closed(numVertices, 0);
        asm volatile("" : : "r"(gScore.data()), "r"(cameFrom.data()), "r"(closed.data()) : "memory");
        const auto end = std::chrono::steady_clock::now();
        elapsed = std::chrono::duration<double>(end - start).count();
    }
    return elapsed;
}

// ---------------------------------------------------------------------------------------
// Repetições internas para buscas curtas
// ---------------------------------------------------------------------------------------

// Antes de cada cronometragem de busca, a mesma busca roda uma vez sem cronômetro.
inline constexpr bool SEARCH_WARMUP = true;

inline constexpr double SHORT_SEARCH_THRESHOLD_S = 0.005;
inline constexpr std::size_t SHORT_SEARCH_MAX_REPETITIONS = 100000;

struct RepeatedTiming {
    double median = 0.0;
    std::size_t repetitions = 0;
};

// Repete a busca, cronometrando cada repetição isoladamente, até o tempo acumulado passar de
// SHORT_SEARCH_THRESHOLD_S; k é o número de repetições feitas. Cada chamada de runOnce cria seu
// próprio estado (como run() já faz) e o resultado é destruído fora do cronômetro.
template <typename RunOnce>
RepeatedTiming repeatShortSearch(RunOnce&& runOnce) {
    std::vector<double> times;
    double total = 0.0;

    while (total <= SHORT_SEARCH_THRESHOLD_S && times.size() < SHORT_SEARCH_MAX_REPETITIONS) {
        const auto start = std::chrono::steady_clock::now();
        const auto result = runOnce();
        const auto end = std::chrono::steady_clock::now();

        const double elapsed = std::chrono::duration<double>(end - start).count();
        times.push_back(elapsed);
        total += elapsed;
    }

    std::sort(times.begin(), times.end());
    const std::size_t middle = times.size() / 2;
    const double median = times.size() % 2 == 1
        ? times[middle]
        : (times[middle - 1] + times[middle]) * 0.5;

    return {median, times.size()};
}

// ---------------------------------------------------------------------------------------
// Estado da máquina e do processo
// ---------------------------------------------------------------------------------------

inline constexpr const char* CPU_FREQ_PATH = "/sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq";

struct MachineState {
    std::optional<long> cpuFreqKHz = std::nullopt;
    std::optional<double> load1 = std::nullopt;   // primeiro campo de /proc/loadavg
};

inline MachineState readMachineState() {
    MachineState state;

    std::ifstream freq(CPU_FREQ_PATH);
    long kHz = 0;
    if (freq >> kHz) {
        state.cpuFreqKHz = kHz;
    }

    std::ifstream loadavg("/proc/loadavg");
    double load = 0.0;
    if (loadavg >> load) {
        state.load1 = load;
    }

    return state;
}

// Pico de memória residente do processo até agora (no Linux, ru_maxrss já vem em KiB).
inline std::optional<long> peakMemoryKB() {
    rusage usage {};
    if (getrusage(RUSAGE_SELF, &usage) != 0) {
        return std::nullopt;
    }
    return usage.ru_maxrss;
}

// Estado do processo gravado em todas as linhas do CSV de uma execução.
struct ProcessState {
    MachineState start;
    MachineState end;
    std::optional<long> peakMemoryKB = std::nullopt;
};
