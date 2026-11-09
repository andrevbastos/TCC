#pragma once

// Benchmark do Marching Cubes (subcomando `mcbench`).
//
// Na coleta de stats, o cronômetro de "Tempo de Construção do Grafo" começa depois de
// getMarchingCubeData, então o custo da extração da malha não aparece em nenhum CSV.
// Este modo mede só esse custo, sem alterar a coleta de stats.
//
// - Terreno: mesma configuração do passo de dimensão 500 de testScale
//   (scaleNoiseConfig/scaleHeightScale, compartilhadas com statistics.hpp).
// - A extração é idêntica para as representações vértice e dual (as duas recebem a mesma
//   malha de getMarchingCubeData), então ela é medida uma vez por semente e o tempo vale
//   para ambas.
// - Cada semente é medida MC_BENCH_REPETITIONS vezes; o CSV guarda todas as repetições e o
//   resultado da semente é a mediana delas (calculada na análise). A geração do ruído fica
//   fora do cronômetro; a liberação da malha também.

#include <algorithm>
#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include "core/statistics.hpp"

inline constexpr int MC_BENCH_DIMENSION = 500;
inline constexpr unsigned int MC_BENCH_REPETITIONS = 5;

inline void benchMarchingCubes(
    const std::vector<unsigned int>& seeds,
    const std::string& outputFile
) {
    std::ofstream file(outputFile);
    if (!file) {
        throw std::runtime_error("Não foi possível abrir " + outputFile);
    }
    file << "seed,repeticao,tempo_mc_s,vertices,indices\n";

    const int heightScale = scaleHeightScale(MC_BENCH_DIMENSION);

    for (const unsigned int seed : seeds) {
        const perlin2D::NoiseConfig config = scaleNoiseConfig(MC_BENCH_DIMENSION, seed);
        const std::vector<float> noise = perlin2D::generateNoiseMap(config);

        std::vector<double> times;
        for (unsigned int repetition = 1; repetition <= MC_BENCH_REPETITIONS; ++repetition) {
            std::size_t vertexCount = 0;
            std::size_t indexCount = 0;
            double elapsed = 0.0;
            {
                const auto start = std::chrono::steady_clock::now();
                auto [vertices, indices] = getMarchingCubeData(
                    noise, config.width, heightScale, config.height
                );
                const auto end = std::chrono::steady_clock::now();
                elapsed = std::chrono::duration<double>(end - start).count();
                vertexCount = vertices.size();
                indexCount = indices.size();
            }

            times.push_back(elapsed);
            file << seed << ',' << repetition << ','
                 << std::setprecision(9) << elapsed << ','
                 << vertexCount << ',' << indexCount << '\n';
        }

        std::sort(times.begin(), times.end());
        std::cout << "seed=" << seed << " mediana=" << times[times.size() / 2] << " s" << std::endl;
    }
}
