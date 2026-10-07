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
#include <map>
#include <unordered_map>
#include <graph/undirected/graph.hpp>
#include <graph/undirected/lw_graph.hpp>
#include <graph/util/a_star.hpp>
#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include <ifcg/graphics/meshTree.hpp>
#include <fstream>
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

                        auto dim = (float)(y) / (float)(height);

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
        const int heightDifference = std::abs(columnHeights[from] - columnHeights[to]);

        if (heightDifference > 5) {
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

undirected::lwGraph<Vertex3D> createVertexToVertex(const Mesh& mesh) {
    const auto& vertices = mesh.getVertices();
    const auto& indices = mesh.getIndices();

    undirected::lwGraph<Vertex3D> graph(vertices.size());

    for (size_t i = 0; i < vertices.size(); ++i) {
        auto x = vertices[i].x;
        auto y = vertices[i].y;
        auto z = vertices[i].z;
        graph.setVertex(i, Vertex3D{x, y, z});
    }

    auto addUniqueEdge = [&](int from, int to) {
        if (from == to) {
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

undirected::lwGraph<Vertex3D> createPolygonToPolygon(const Mesh& mesh) {
    const auto& vertices = mesh.getVertices();
    const auto& indices = mesh.getIndices();

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
            const float weight = distance(centroids[triangle], centroids[neighbor]);
            graph.addEdge(triangle, neighbor, weight);
        }
    }

    return graph;
};