#pragma once

#include <iostream>
#include <set>
#include <tuple>
#include <algorithm>
#include <array>
#include <vector>
#include <memory>
#include <cmath>
#include <cstdint>
#include <limits>
#include <map>
#include <queue>
#include <unordered_map>
#include <graph/undirected/graph.hpp>
#include <graph/undirected/lw_graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>
#include <fstream>
#include <functional>
#include <string>
#include <unistd.h>

#include "core/noise_gen.hpp"
#include "transvoxel/transvoxel.hpp"
#include "stb_image.h"

using namespace ifcg;

struct Vertex3D {
    float x, y, z;
};

struct Color {
    float r, g, b, a;

    Color operator*(float f) const {
        return {r * f, g * f, b * f, a};
    };
};

using NavigationGraph = undirected::lwGraph<Vertex3D>;

struct GraphBuildInput {
    const std::vector<float>& noise;
    const std::vector<Vertex>& vertices;
    const std::vector<GLuint>& indices;
    int width;
    int heightScale;
    int depth;
};

using GraphFactory = std::function<NavigationGraph(const GraphBuildInput&)>;

struct GraphModel {
    std::string name;
    bool requiresGeometry;
    GraphFactory create;
};

// Inclinação máxima transitável (|dy| / distância horizontal), comum a todas as representações.
// 1.0 corresponde a 45°: o desnível não pode exceder a distância horizontal.
inline constexpr float MAX_SLOPE = 1.0f;

inline bool isTraversable(const Vertex3D& a, const Vertex3D& b) {
    const float horizontal = std::hypot(b.x - a.x, b.z - a.z);
    if (horizontal == 0.0f) return false;
    return std::abs(b.y - a.y) / horizontal <= MAX_SLOPE;
}

struct SnapResult {
    std::size_t id = 0;
    double distance = 0.0;
};

// Marca os vértices do maior componente conexo (BFS). Evita que o snap caia em ilhas
// isoladas pelo critério de transitabilidade, como triângulos de parede do marching cubes.
inline std::vector<char> largestComponentMask(const common::lwGraph<Vertex3D>& graph) {
    const std::size_t numVertices = graph.getOrder();
    std::vector<std::size_t> component(numVertices, std::numeric_limits<std::size_t>::max());
    std::size_t bestComponent = 0;
    std::size_t bestSize = 0;
    std::size_t componentCount = 0;

    for (std::size_t source = 0; source < numVertices; ++source) {
        if (component[source] != std::numeric_limits<std::size_t>::max()) continue;

        std::size_t size = 0;
        std::queue<std::size_t> frontier;
        frontier.push(source);
        component[source] = componentCount;

        while (!frontier.empty()) {
            const std::size_t current = frontier.front();
            frontier.pop();
            ++size;

            for (const auto& edge : graph.adj(current)) {
                if (component[edge.target] != std::numeric_limits<std::size_t>::max()) continue;
                component[edge.target] = componentCount;
                frontier.push(edge.target);
            }
        }

        if (size > bestSize) {
            bestSize = size;
            bestComponent = componentCount;
        }
        ++componentCount;
    }

    std::vector<char> mask(numVertices, 0);
    for (std::size_t v = 0; v < numVertices; ++v) {
        mask[v] = component[v] == bestComponent;
    }
    return mask;
}

// Busca linear pelo vértice mais próximo (distância 3D) dentre os permitidos pela máscara;
// usada apenas no setup do experimento.
inline SnapResult nearestVertex(
    const common::lwGraph<Vertex3D>& graph,
    const Vertex3D& point,
    const std::vector<char>& allowed
) {
    SnapResult result;
    double bestSq = std::numeric_limits<double>::infinity();

    for (std::size_t v = 0; v < graph.getOrder(); ++v) {
        if (!allowed[v]) continue;

        const auto& data = graph.getVertexData(v);
        const double dx = static_cast<double>(data.x) - point.x;
        const double dy = static_cast<double>(data.y) - point.y;
        const double dz = static_cast<double>(data.z) - point.z;
        const double distSq = (dx * dx) + (dy * dy) + (dz * dz);

        if (distSq < bestSq) {
            bestSq = distSq;
            result.id = v;
        }
    }

    result.distance = std::sqrt(bestSq);
    return result;
}

// Altura contínua da superfície de referência (heightmap), com interpolação bilinear.
inline float terrainHeightAt(
    const std::vector<float>& noise,
    int width,
    int depth,
    int heightScale,
    float x,
    float z
) {
    x = std::clamp(x, 0.0f, static_cast<float>(width - 1));
    z = std::clamp(z, 0.0f, static_cast<float>(depth - 1));

    const int x0 = static_cast<int>(std::floor(x));
    const int z0 = static_cast<int>(std::floor(z));
    const int x1 = std::min(x0 + 1, width - 1);
    const int z1 = std::min(z0 + 1, depth - 1);
    const float tx = x - static_cast<float>(x0);
    const float tz = z - static_cast<float>(z0);

    const float top = (noise[(z0 * width) + x0] * (1.0f - tx)) + (noise[(z0 * width) + x1] * tx);
    const float bottom = (noise[(z1 * width) + x0] * (1.0f - tx)) + (noise[(z1 * width) + x1] * tx);
    const float value = (top * (1.0f - tz)) + (bottom * tz);

    return 1.0f + value * (static_cast<float>(heightScale) - 1.0f);
}

// Comprimento do caminho projetado em (x, z) sobre a superfície de referência,
// amostrando cada segmento em subpassos de no máximo 0.25 unidade horizontal.
inline double surfacePathLength(
    const std::vector<std::size_t>& path,
    const common::lwGraph<Vertex3D>& graph,
    const std::vector<float>& noise,
    int width,
    int depth,
    int heightScale
) {
    constexpr double sampleStep = 0.25;
    double length = 0.0;

    for (std::size_t i = 0; i + 1 < path.size(); ++i) {
        const Vertex3D& a = graph.getVertexData(path[i]);
        const Vertex3D& b = graph.getVertexData(path[i + 1]);
        const double horizontal = std::hypot(
            static_cast<double>(b.x) - a.x,
            static_cast<double>(b.z) - a.z
        );
        const int samples = std::max(1, static_cast<int>(std::ceil(horizontal / sampleStep)));

        double prevX = a.x;
        double prevZ = a.z;
        double prevY = terrainHeightAt(noise, width, depth, heightScale, a.x, a.z);

        for (int s = 1; s <= samples; ++s) {
            const double t = static_cast<double>(s) / samples;
            const double x = a.x + (b.x - a.x) * t;
            const double z = a.z + (b.z - a.z) * t;
            const double y = terrainHeightAt(
                noise, width, depth, heightScale, static_cast<float>(x), static_cast<float>(z)
            );

            const double dx = x - prevX;
            const double dy = y - prevY;
            const double dz = z - prevZ;
            length += std::sqrt((dx * dx) + (dy * dy) + (dz * dz));

            prevX = x;
            prevY = y;
            prevZ = z;
        }
    }

    return length;
}

// Memória estrutural da representação pronta: objeto do grafo, dados dos vértices,
// vetores de adjacência e arestas alocadas (capacity, inclui a folga de crescimento).
inline std::size_t graphMemoryBytes(const NavigationGraph& graph) {
    const std::size_t numVertices = graph.getOrder();
    std::size_t edgeBytes = 0;
    for (std::size_t v = 0; v < numVertices; ++v) {
        edgeBytes += graph.adj(v).capacity() * sizeof(common::lwEdge);
    }

    return sizeof(NavigationGraph)
        + (numVertices * sizeof(Vertex3D))
        + (numVertices * sizeof(std::vector<common::lwEdge>))
        + edgeBytes;
}

inline std::size_t countEdges(const common::lwGraph<Vertex3D>& graph) {
    std::size_t total = 0;
    for (std::size_t v = 0; v < graph.getOrder(); ++v) {
        total += graph.adj(v).size();
    }
    return total / 2;
}

inline double getMemoryUsageMB() {
    std::ifstream statm("/proc/self/statm");
    if (!statm.is_open()) return 0.0;

    unsigned long size, resident, share, text, lib, data, dt;
    statm >> size >> resident >> share >> text >> lib >> data >> dt;

    long pageSize = sysconf(_SC_PAGESIZE);
    return (double)(resident * pageSize) / (1024.0 * 1024.0);
}

inline double getMeshDataSizeMB(const std::vector<Vertex>& vertices, const std::vector<GLuint>& indices) {
    size_t totalBytes = (vertices.capacity() * sizeof(Vertex)) + (indices.capacity() * sizeof(GLuint));
    return (double)totalBytes / (1024.0 * 1024.0);
}

inline double calculatePathCostLW(const std::vector<std::size_t>& path, const common::lwGraph<Vertex3D>& graph) {
    if (path.size() < 2) return 0.0;

    double totalCost = 0.0;
    for (std::size_t i = 0; i < path.size() - 1; ++i) {
        const std::size_t currentId = path[i];
        const std::size_t nextId = path[i + 1];
        
        for (const auto& edge : graph.adj(currentId)) {
            if (edge.target == nextId) {
                totalCost += edge.weight;
                break;
            }
        }
    }
    return totalCost;
};

inline std::vector<int> reconstructPathLW(const std::vector<int>& path, int width) {
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

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> getMeshFromPath(const common::lwGraph<Vertex3D>& graph, const std::vector<std::size_t>& path, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (std::size_t i = 0; i < path.size(); ++i) {
        const std::size_t nodeId = path[i];
        
        const auto& data = graph.getVertexData(nodeId);
        
        vertices.emplace_back(data.x, data.y, data.z, color.r, color.g, color.b, color.a);
        
        if (i < path.size() - 1) {
            indices.push_back(static_cast<GLuint>(i));
            indices.push_back(static_cast<GLuint>(i + 1));
        }
    }

    return {vertices, indices};
};

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> getMeshFromGraph(const common::lwGraph<Vertex3D>& graph, float intensity, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    const std::size_t numVertices {graph.getOrder()};

    for (std::size_t i = 0; i < numVertices; ++i) {
        const auto& data {graph.getVertexData(i)};
        Vertex vertex {data.x, data.y, data.z, color.r, color.g, color.b, color.a};
        
        auto dim = (float)(data.y) / (float)(intensity);
        vertex = vertex * Vertex{1.0f, 1.0f, 1.0f, dim, dim, dim, 1.0f};

        vertices.emplace_back(vertex);
    }

    for (std::size_t i = 0; i < numVertices; ++i) {
        const auto& adjNodes = graph.adj(i);

        for (const common::lwEdge& neighbor : adjNodes) {
            if (i < neighbor.target) {
                indices.push_back(static_cast<GLuint>(i));
                indices.push_back(static_cast<GLuint>(neighbor.target));
            }
        }
    }

    return {vertices, indices};
};

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> getMarchingCubeData(
    const std::vector<float>& noise,
    int width,
    int height,
    int depth,
    Color color = {1.0f, 1.0f, 1.0f, 1.0f}
) {
    if (width < 2 || height < 2 || depth < 2 || noise.size() < static_cast<size_t>(width) * static_cast<size_t>(depth)) {
        return {{}, {}};
    }

    const std::array<Vertex, 8> corners {
        Vertex{0.0f, 0.0f, 0.0f, color.r, color.g, color.b, color.a},
        Vertex{1.0f, 0.0f, 0.0f, color.r, color.g, color.b, color.a},
        Vertex{0.0f, 1.0f, 0.0f, color.r, color.g, color.b, color.a},
        Vertex{1.0f, 1.0f, 0.0f, color.r, color.g, color.b, color.a},
        Vertex{0.0f, 0.0f, 1.0f, color.r, color.g, color.b, color.a},
        Vertex{1.0f, 0.0f, 1.0f, color.r, color.g, color.b, color.a},
        Vertex{0.0f, 1.0f, 1.0f, color.r, color.g, color.b, color.a},
        Vertex{1.0f, 1.0f, 1.0f, color.r, color.g, color.b, color.a}
    };

    const std::array<uint, 8> cornerDx {0, 1, 0, 1, 0, 1, 0, 1};
    const std::array<uint, 8> cornerDy {0, 0, 1, 1, 0, 0, 1, 1};
    const std::array<uint, 8> cornerDz {0, 0, 0, 0, 1, 1, 1, 1};

    std::vector<uint> columnHeights(static_cast<size_t>(width) * static_cast<size_t>(depth));
    for (uint z = 0; z < static_cast<uint>(depth); ++z) {
        for (uint x = 0; x < static_cast<uint>(width); ++x) {
            const uint noiseIndex = (z * width) + x;
            columnHeights[noiseIndex] = static_cast<uint>(std::round(1.0f + noise[noiseIndex] * ((float)height - 1.0f)));
        }
    }

    auto isVoxelFilled = [&](uint x, uint y, uint z) {
        return y < columnHeights[(z * width) + x];
    };

	std::vector<Vertex> vertices;
	std::vector<GLuint> indices;

    const std::uint64_t keyWidth = (2ULL * static_cast<std::uint64_t>(width)) - 1ULL;
    const std::uint64_t keyDepth = (2ULL * static_cast<std::uint64_t>(depth)) - 1ULL;
    std::unordered_map<std::uint64_t, GLuint> vertexLookup;
    vertexLookup.reserve(static_cast<size_t>(width) * static_cast<size_t>(depth));

	for (uint z = 0; z < static_cast<uint>(depth - 1); ++z) {
		for (uint y = 0; y < static_cast<uint>(height); ++y) {
			for (uint x = 0; x < static_cast<uint>(width - 1); ++x) {
				uint caseIndex = 0;

				for (int i = 0; i < 8; ++i) {
					if (isVoxelFilled(x + cornerDx[i], y + cornerDy[i], z + cornerDz[i])) {
						caseIndex |= (1 << i);
					}
				}

				if (caseIndex != 0 && caseIndex != 255) {
					auto classIndex = regularCellClass[caseIndex];
					auto cellData = regularCellData[classIndex];
					auto vertexCount = cellData.GetVertexCount();
					auto triangleCount = cellData.GetTriangleCount();

                    std::array<GLuint, 12> cellVertexIndices {};

					for (int i = 0; i < vertexCount; i++) {
						auto edgeInfo = regularVertexData[caseIndex][i];
						auto lowByte = edgeInfo & 0xFF;
						auto a = lowByte >> 4;
						auto b = lowByte & 0x0F;

                        const std::uint64_t keyX = (2ULL * x) + cornerDx[a] + cornerDx[b];
                        const std::uint64_t keyY = (2ULL * y) + cornerDy[a] + cornerDy[b];
                        const std::uint64_t keyZ = (2ULL * z) + cornerDz[a] + cornerDz[b];
                        const std::uint64_t key = ((keyY * keyDepth) + keyZ) * keyWidth + keyX;

                        auto existingVertex = vertexLookup.find(key);
                        if (existingVertex != vertexLookup.end()) {
                            cellVertexIndices[i] = existingVertex->second;
                            continue;
                        }

                        const auto [minIt, maxIt] = std::minmax_element(columnHeights.begin(), columnHeights.end());
                        const float yMin = static_cast<float>(*minIt);
                        const float yRange = std::max(1.0f, static_cast<float>(*maxIt) - yMin);

                        const float t = std::clamp((static_cast<float>(y) - yMin) / yRange, 0.0f, 1.0f);
                        const float dim = 0.35f + 0.65f * t;

						auto pos = corners[a] % corners[b];
						pos = (pos + Vertex{(float)x, (float)y, (float)z, 0.0f, 0.0f, 0.0f, 0.0f}) * Vertex{1.0f, 1.0f, 1.0f, dim, dim, dim, 1.0f};

                        const GLuint vertexIndex = static_cast<GLuint>(vertices.size());
						vertices.push_back(pos);
                        vertexLookup.emplace(key, vertexIndex);
                        cellVertexIndices[i] = vertexIndex;
					}
					for (int i = 0; i < (triangleCount * 3); i++) {
						indices.push_back(cellVertexIndices[cellData.vertexIndex[i]]);
					}
				}
			}
		}
	}

	if (!vertices.empty() && !indices.empty()) {
        return {vertices, indices};
    }
    return {{}, {}};
};

undirected::lwGraph<Vertex3D> createGrid2_5D(const std::vector<float>& noise, int width, int heightScale, int depth) {
    undirected::lwGraph<Vertex3D> graph(width * depth);

    for (int z = 0; z < depth; ++z) {
        for (int x = 0; x < width; ++x) {
            int index = z * width + x;
            float y = 1.0f + noise[index] * ((float)heightScale - 1.0f);
            graph.setVertex(index, Vertex3D{static_cast<float>(x), y, static_cast<float>(z)});
        }
    }

    auto addEdge = [&](int from, int to) {
        const auto& a = graph.getVertexData(from);
        const auto& b = graph.getVertexData(to);
        if (!isTraversable(a, b)) {
            return;
        }

        const float dx = a.x - b.x;
        const float dy = a.y - b.y;
        const float dz = a.z - b.z;
        const float weight = std::sqrt((dx * dx) + (dy * dy) + (dz * dz));

        graph.addEdge(from, to, weight);
    };

    for (int z = 0; z < depth; ++z) {
        for (int x = 0; x < width; ++x) {
            int index = z * width + x;

            if (x < width - 1) {
                addEdge(index, index + 1);
            }
            if (z < depth - 1) {
                addEdge(index, index + width);
            }
            if (x < width - 1 && z < depth - 1) {
                addEdge(index, index + width + 1);
            }
            if (x > 0 && z < depth - 1) {
                addEdge(index, index + width - 1);
            }
        }
    }

    return graph;
}

undirected::lwGraph<Vertex3D> createVoxelGraph(const std::vector<float>& noise, int width, int height, int depth) {
    if (width <= 0 || height <= 0 || depth <= 0 || noise.size() < static_cast<size_t>(width) * static_cast<size_t>(depth)) {
        return undirected::lwGraph<Vertex3D>(0);
    }

    const int vertexCount = width * depth;
    undirected::lwGraph<Vertex3D> graph(vertexCount);
    std::vector<int> columnHeights(static_cast<size_t>(vertexCount));

    auto vertexIndex = [width](int x, int z) {
        return (z * width) + x;
    };

    for (int z = 0; z < depth; ++z) {
        for (int x = 0; x < width; ++x) {
            const int index = vertexIndex(x, z);
            const int y = static_cast<int>(std::round(
                1.0f + noise[index] * (static_cast<float>(height) - 1.0f)
            ));

            columnHeights[index] = y;
            graph.setVertex(index, Vertex3D {
                static_cast<float>(x),
                static_cast<float>(y),
                static_cast<float>(z)
            });
        }
    }

    auto addSurfaceEdge = [&](int x1, int z1, int x2, int z2) {
        const int from = vertexIndex(x1, z1);
        const int to = vertexIndex(x2, z2);
        if (!isTraversable(graph.getVertexData(from), graph.getVertexData(to))) {
            return;
        }

        const float dx = static_cast<float>(x2 - x1);
        const float dy = static_cast<float>(columnHeights[to] - columnHeights[from]);
        const float dz = static_cast<float>(z2 - z1);
        const float weight = std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
        graph.addEdge(from, to, weight);
    };

    for (int z = 0; z < depth; ++z) {
        for (int x = 0; x < width; ++x) {
            if (x + 1 < width) {
                addSurfaceEdge(x, z, x + 1, z);
            }
            if (z + 1 < depth) {
                addSurfaceEdge(x, z, x, z + 1);
            }
        }
    }

    return graph;
}

undirected::lwGraph<Vertex3D> createVertexToVertex(
    const std::vector<Vertex>& vertices,
    const std::vector<GLuint>& indices
) {
    undirected::lwGraph<Vertex3D> graph(vertices.size());

    for (size_t i = 0; i < vertices.size(); ++i) {
        auto x = vertices[i].x;
        auto y = vertices[i].y;
        auto z = vertices[i].z;
        graph.setVertex(i, Vertex3D{x, y, z});
    }

    auto addUniqueEdge = [&](int from, int to) {
        if (from == to || !isTraversable(graph.getVertexData(from), graph.getVertexData(to))) {
            return;
        }

        const auto& neighbors = graph.adj(from);
        const bool alreadyExists = std::any_of(
            neighbors.begin(),
            neighbors.end(),
            [to](const common::lwEdge& edge) {
                return edge.target == to;
            }
        );

        if (alreadyExists) {
            return;
        }

        const Vertex& a = vertices[from];
        const Vertex& b = vertices[to];
        const float dx = a.x - b.x;
        const float dy = a.y - b.y;
        const float dz = a.z - b.z;
        const float weight = std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
        graph.addEdge(from, to, weight);
    };

    for (size_t i = 0; i + 2 < indices.size(); i += 3) {
        const int v1 = static_cast<int>(indices[i]);
        const int v2 = static_cast<int>(indices[i + 1]);
        const int v3 = static_cast<int>(indices[i + 2]);

        addUniqueEdge(v1, v2);
        addUniqueEdge(v2, v3);
        addUniqueEdge(v3, v1);
    }

    return graph;
}

undirected::lwGraph<Vertex3D> createVertexToVertex(const Mesh& mesh) {
    return createVertexToVertex(mesh.getVertices(), mesh.getIndices());
}

undirected::lwGraph<Vertex3D> createPolygonToPolygon(
    const std::vector<Vertex>& vertices,
    const std::vector<GLuint>& indices
) {
    const size_t triangleCount = indices.size() / 3;
    undirected::lwGraph<Vertex3D> graph(triangleCount);

    auto distance = [](const Vertex3D& a, const Vertex3D& b) {
        const float dx = a.x - b.x;
        const float dy = a.y - b.y;
        const float dz = a.z - b.z;
        return std::sqrt((dx * dx) + (dy * dy) + (dz * dz));
    };

    using PointKey = std::tuple<float, float, float>;
    using EdgeKey = std::pair<PointKey, PointKey>;

    auto pointKey = [](const Vertex& vertex) {
        return PointKey{vertex.x, vertex.y, vertex.z};
    };

    auto edgeKey = [&](const Vertex& a, const Vertex& b) {
        PointKey p1 = pointKey(a);
        PointKey p2 = pointKey(b);

        if (p2 < p1) {
            std::swap(p1, p2);
        }

        return EdgeKey{p1, p2};
    };

    std::vector<Vertex3D> centroids(triangleCount);

    for (size_t triangle = 0; triangle < triangleCount; ++triangle) {
        const Vertex& v1 = vertices[indices[(triangle * 3)]];
        const Vertex& v2 = vertices[indices[(triangle * 3) + 1]];
        const Vertex& v3 = vertices[indices[(triangle * 3) + 2]];

        Vertex3D centroid {
            (v1.x + v2.x + v3.x) / 3.0f,
            (v1.y + v2.y + v3.y) / 3.0f,
            (v1.z + v2.z + v3.z) / 3.0f
        };

        centroids[triangle] = centroid;
        graph.setVertex(triangle, centroid);
    }

    std::map<EdgeKey, size_t> edgeToTriangle;

    for (size_t triangle = 0; triangle < triangleCount; ++triangle) {
        const Vertex& v1 = vertices[indices[(triangle * 3)]];
        const Vertex& v2 = vertices[indices[(triangle * 3) + 1]];
        const Vertex& v3 = vertices[indices[(triangle * 3) + 2]];

        const std::array<EdgeKey, 3> triangleEdges {
            edgeKey(v1, v2),
            edgeKey(v2, v3),
            edgeKey(v3, v1)
        };

        for (const EdgeKey& edge : triangleEdges) {
            auto found = edgeToTriangle.find(edge);

            if (found == edgeToTriangle.end()) {
                edgeToTriangle[edge] = triangle;
                continue;
            }

            const size_t neighbor = found->second;
            if (!isTraversable(centroids[triangle], centroids[neighbor])) {
                continue;
            }

            const float weight = distance(centroids[triangle], centroids[neighbor]);
            graph.addEdge(triangle, neighbor, weight);
        }
    }

    return graph;
};

undirected::lwGraph<Vertex3D> createPolygonToPolygon(const Mesh& mesh) {
    return createPolygonToPolygon(mesh.getVertices(), mesh.getIndices());
}