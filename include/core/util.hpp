#pragma once

#include <iostream>
#include <set>
#include <tuple>
#include <algorithm>
#include <array>
#include <vector>
#include <memory>
#include <cmath>
#include <map>
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

inline float calculatePathCostLW(const std::vector<int>& path, const common::lwGraph<Vertex3D>& graph) {
    if (path.size() < 2) return 0.0; 
    
    float totalCost = 0.0;
    for (size_t i = 0; i < path.size() - 1; ++i) {
        int currentId = path[i];
        int nextId = path[i + 1];
        
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

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> getMeshFromPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (size_t i = 0; i < path.size(); ++i) {
        int nodeId = path[i];
        
        const auto& data = graph.getVertexData(nodeId);
        
        vertices.emplace_back(data.x, data.y, data.z, color.r, color.g, color.b, color.a);
        
        if (i < path.size() - 1) {
            indices.push_back(i);
            indices.push_back(i + 1);
        }
    }

    return {vertices, indices};
};

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> getMeshFromGraph(const common::lwGraph<Vertex3D>& graph, float intensity, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    int numVertices {graph.getOrder()}; 

    for (int i = 0; i < numVertices; ++i) {
        const auto& data {graph.getVertexData(i)};
        Vertex vertex {data.x, data.y, data.z, color.r, color.g, color.b, color.a};
        
        auto dim = (float)(data.y) / (float)(intensity);
        vertex = vertex * Vertex{1.0f, 1.0f, 1.0f, dim, dim, dim, 1.0f};

        vertices.emplace_back(vertex);
    }

    for (int i = 0; i < numVertices; ++i) {
        auto adjNodes = graph.adj(i);
        
        for (common::lwEdge neighbor : adjNodes) {
            if (i < neighbor.target) {
                indices.push_back(i);
                indices.push_back(neighbor.target);
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

					uint vertexOffset = vertices.size();

					for (int i = 0; i < vertexCount; i++) {
						auto edgeInfo = regularVertexData[caseIndex][i];
						auto lowByte = edgeInfo & 0xFF;
						auto a = lowByte >> 4;
						auto b = lowByte & 0x0F;

                        auto dim = (float)(y) / (float)(height);

						auto pos = corners[a] % corners[b];
						pos = (pos + Vertex{(float)x, (float)y, (float)z, 0.0f, 0.0f, 0.0f, 0.0f}) * Vertex{1.0f, 1.0f, 1.0f, dim, dim, dim, 1.0f};
						vertices.push_back(pos);
					}
					for (int i = 0; i < (triangleCount * 3); i++) {
						indices.push_back(vertexOffset + cellData.vertexIndex[i]);
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

undirected::lwGraph<Vertex3D> createGrid3D(const std::vector<float>& noise, int width, int heightScale, int depth) {
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

    const int layerSize = width * depth;
    undirected::lwGraph<Vertex3D> graph(layerSize * height);

    auto voxelIndex = [&](int x, int y, int z) {
        return (y * layerSize) + (z * width) + x;
    };

    for (int y = 0; y < height; ++y) {
        for (int z = 0; z < depth; ++z) {
            for (int x = 0; x < width; ++x) {
                graph.setVertex(voxelIndex(x, y, z), Vertex3D{static_cast<float>(x), static_cast<float>(y), static_cast<float>(z)});
            }
        }
    }

    std::vector<int> columnHeights(static_cast<size_t>(width) * static_cast<size_t>(depth));
    for (int z = 0; z < depth; ++z) {
        for (int x = 0; x < width; ++x) {
            const int noiseIndex = (z * width) + x;
            columnHeights[noiseIndex] = static_cast<int>(std::round(1.0f + noise[noiseIndex] * (static_cast<float>(height) - 1.0f)));
        }
    }

    auto navigableY = [&](int x, int z) {
        const int y = columnHeights[(z * width) + x];
        return y < height ? y : -1;
    };

    std::set<std::pair<int, int>> addedEdges;
    auto addGraphEdge = [&](int from, int to) {
        if (from == to) {
            return;
        }

        auto edge = std::minmax(from, to);
        if (addedEdges.insert(edge).second) {
            graph.addEdge(from, to, 1.0f);
        }
    };

    auto addEdge = [&](int x1, int z1, int x2, int z2) {
        const int y1 = navigableY(x1, z1);
        const int y2 = navigableY(x2, z2);

        if (y1 < 0 || y2 < 0 || std::abs(y1 - y2) > 1) {
            return;
        }

        if (y1 == y2) {
            addGraphEdge(voxelIndex(x1, y1, z1), voxelIndex(x2, y2, z2));
            return;
        }

        if (y1 < y2) {
            addGraphEdge(voxelIndex(x1, y1, z1), voxelIndex(x1, y2, z1));
            addGraphEdge(voxelIndex(x1, y2, z1), voxelIndex(x2, y2, z2));
            return;
        }

        addGraphEdge(voxelIndex(x2, y2, z2), voxelIndex(x2, y1, z2));
        addGraphEdge(voxelIndex(x1, y1, z1), voxelIndex(x2, y1, z2));
    };

    for (int z = 0; z < depth; ++z) {
        for (int x = 0; x < width; ++x) {
            if (x < width - 1) {
                addEdge(x, z, x + 1, z);
            }
            if (z < depth - 1) {
                addEdge(x, z, x, z + 1);
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

    for (size_t i = 0; i < indices.size(); i += 3) {
        int v1 = indices[i];
        int v2 = indices[i + 1];
        int v3 = indices[i + 2];

        graph.addEdge(v1, v2);
        graph.addEdge(v2, v3);
        graph.addEdge(v3, v1);
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