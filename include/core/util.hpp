#pragma once

#include <iostream>
#include <set>
#include <tuple>
#include <algorithm>
#include <vector>
#include <memory>
#include <cmath>
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

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwPath(const common::lwGraph<Vertex3D>& graph, const std::vector<int>& path, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (size_t i = 0; i < path.size(); ++i) {
        int nodeId = path[i];
        
        const auto& data = graph.getVertexData(nodeId);
        
        // Swap Y and Z: data.x, data.z, data.y
        vertices.emplace_back(data.x, data.z, data.y, color.r, color.g, color.b, color.a);
        
        if (i < path.size() - 1) {
            indices.push_back(i);
            indices.push_back(i + 1);
        }
    }

    return {vertices, indices};
};

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromLwGraph(const common::lwGraph<Vertex3D>& graph, float maxZ, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    int numVertices {graph.getOrder()}; 

    for (int i = 0; i < numVertices; ++i) {
        const auto& data {graph.getVertexData(i)};
        
        float decay = std::max(0.5f, data.z / maxZ);
        Color vColor = color * decay;
        // Swap Y and Z: data.x, data.z, data.y
        vertices.emplace_back(data.x, data.z, data.y, vColor.r, vColor.g, vColor.b, color.a);
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

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromHeightmap(const char* imagePath, float intensity, Color color) {
    int width, height, channels;

    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    if (!data) {
        std::cerr << "Erro ao carregar a imagem: " << imagePath << std::endl;
        return {{}, {}};
    }

    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * intensity); 

            float decay = std::max(0.5f, data[y * width + x] / 255.0f);
            Color vColor = color * decay;

            // Swap Y and Z: x, z, y
            vertices.emplace_back(x, z, y, vColor.r, vColor.g, vColor.b, color.a);
        }
    }

    for (int y = 0; y < height - 1; ++y) {
        for (int x = 0; x < width - 1; ++x) {
            int topLeft = y * width + x;
            int topRight = y * width + (x + 1);
            int bottomLeft = (y + 1) * width + x;
            int bottomRight = (y + 1) * width + (x + 1);

            indices.push_back(topLeft);
            indices.push_back(bottomLeft);
            indices.push_back(topRight);

            indices.push_back(topRight);
            indices.push_back(bottomLeft);
            indices.push_back(bottomRight);
        }
    }

    stbi_image_free(data);
    return {vertices, indices};
};

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromNoise(const std::vector<float>& noise, const int width, const int height, float intensity, Color color) {
    std::vector<Vertex> vertices;
    std::vector<GLuint> indices;
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            float z = noise[currentId] * intensity;

            float decay = std::max(0.5f, noise[currentId]);
            Color vColor = color * decay;

            // Swap Y and Z: x, z, y
            vertices.emplace_back(x, z, y, vColor.r, vColor.g, vColor.b, color.a);
        }
    }

    for (int y = 0; y < height - 1; ++y) {
        for (int x = 0; x < width - 1; ++x) {
            int topLeft = y * width + x;
            int topRight = y * width + (x + 1);
            int bottomLeft = (y + 1) * width + x;
            int bottomRight = (y + 1) * width + (x + 1);

            indices.push_back(topLeft);
            indices.push_back(bottomLeft);
            indices.push_back(topRight);

            indices.push_back(topRight);
            indices.push_back(bottomLeft);
            indices.push_back(bottomRight);
        }
    }

    return {vertices, indices};
};

inline std::shared_ptr<common::lwGraph<Vertex3D>> createlwGraphFromNoise(const std::vector<float>& data, const int width, const int height, float heightLimit, int intensity) {
    auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(width * height);
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            float z = (data[currentId] * intensity); 

            graph->setVertex(currentId, {
                static_cast<float>(x), 
                static_cast<float>(y), 
                static_cast<float>(z)
            });
        }
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            const auto& currentData = graph->getVertexData(currentId);
            
            auto addEdgeWithCost = [&](int targetX, int targetY) {
                int targetId = targetY * width + targetX;
                const auto& targetData = graph->getVertexData(targetId);
                
                if (std::abs(targetData.z - currentData.z) >  heightLimit) return;

                float cost = std::sqrt(std::pow(currentData.x - targetData.x, 2) + std::pow(currentData.y - targetData.y, 2) + std::pow(currentData.z - targetData.z, 2));
                graph->addEdge(currentId, targetId, cost);
            };

            if (x + 1 < width) addEdgeWithCost(x + 1, y);
            if (y + 1 < height) addEdgeWithCost(x, y + 1);
            if (x + 1 < width && y + 1 < height) addEdgeWithCost(x + 1, y + 1);
            if (x - 1 >= 0 && y + 1 < height) addEdgeWithCost(x - 1, y + 1);
        }
    }

    return graph;
};

inline std::tuple<std::shared_ptr<common::lwGraph<Vertex3D>>, int, int> createLwGraphFromHeightmap(const char* imagePath, int intensity, float heightLimit) {
    int startId = -1, endId = -1;

    int width, height, channels;
    unsigned char* data = stbi_load(imagePath, &width, &height, &channels, 1);
    if (!data) {
        std::cerr << "Erro ao carregar a imagem: " << imagePath << std::endl;
        return {nullptr, -1, -1};
    }

    int numVertices = width * height;
    auto graph = std::make_shared<undirected::lwGraph<Vertex3D>>(numVertices);

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float z = (data[y * width + x] / 255.0f * intensity); 
            int currentId = y * width + x;

            graph->setVertex(currentId, {
                static_cast<float>(x), 
                static_cast<float>(y), 
                static_cast<float>(z)
            });
        }
    }

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int currentId = y * width + x;
            const auto& currentData = graph->getVertexData(currentId);
            
            if (currentData.z == 0.0) continue;

            auto addEdgeWithCost = [&](int targetX, int targetY) {
                int targetId = targetY * width + targetX;
                const auto& targetData = graph->getVertexData(targetId);
                
                if (targetData.z == 0.0 || std::abs(targetData.z - currentData.z) > heightLimit) return;

                float cost = std::sqrt(std::pow(currentData.x - targetData.x, 2) + std::pow(currentData.y - targetData.y, 2) + std::pow(currentData.z - targetData.z, 2));
                graph->addEdge(currentId, targetId, cost);
            };

            if (x + 1 < width) addEdgeWithCost(x + 1, y);
            if (y + 1 < height) addEdgeWithCost(x, y + 1);
            if (x + 1 < width && y + 1 < height) addEdgeWithCost(x + 1, y + 1);
            if (x - 1 >= 0 && y + 1 < height) addEdgeWithCost(x - 1, y + 1);

            if (startId == -1) startId = currentId;
            endId = currentId;
        }
    }

    stbi_image_free(data);  
    return {graph, startId, endId};
};

inline std::pair<std::vector<Vertex>, std::vector<GLuint>> createMeshDataFromVoxel(
    const NoiseConfig& noiseConfig, 
    float intensity, 
    Color color = {1.0f, 1.0f, 1.0f, 1.0f}
) {
    int width = noiseConfig.width;
    int depth = noiseConfig.height;
    int height = intensity;

	auto noise {generateNoiseMap(noiseConfig)};
    std::vector<uint> voxel{std::vector<uint>(height * width * depth, 0)};

	for (uint z = 0; z < depth; ++z) {
		for (uint x = 0; x < width; ++x) {
			uint index = (z * width) + x;
			int y = std::round(std::clamp(noise[index], 0.0f, 1.0f) * height);
			for (uint i = 0; i < y; ++i) {
				uint voxelIndex = x + (i * width) + (z * width * height);
				voxel[voxelIndex] = 1;
			}
		}
	}

	std::vector<Vertex> vertices;
	std::vector<GLuint> indices;

	for (uint z = 0; z < depth; ++z) {
		for (uint x = 0; x < width; ++x) {
			for (uint y = 0; y < height; ++y) {
				uint index = x + (y * width) + (z * width * height);
				if (voxel[index] == 1) {
					uint step{(uint)vertices.size()};

					// Left neighbour
					if (x == 0 || (x > 0 && voxel[index - 1] == 0)) {
						vertices.push_back(Vertex{-0.5f + x, +0.5f + y, +0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, -0.5f + y, +0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, -0.5f + y, -0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, +0.5f + y, -0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});

						indices.push_back(step + 0);
						indices.push_back(step + 1);
						indices.push_back(step + 3);
						indices.push_back(step + 1);
						indices.push_back(step + 2);
						indices.push_back(step + 3);

						step += 4;
					};

					// Right neighbour
					if (x == width - 1 || (x < width - 1 && voxel[index + 1] == 0)) {
						vertices.push_back(Vertex{+0.5f + x, -0.5f + y, +0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{+0.5f + x, -0.5f + y, -0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{+0.5f + x, +0.5f + y, -0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});
						vertices.push_back(Vertex{+0.5f + x, +0.5f + y, +0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});

						indices.push_back(step + 0);
						indices.push_back(step + 1);
						indices.push_back(step + 3);
						indices.push_back(step + 1);
						indices.push_back(step + 2);
						indices.push_back(step + 3);

						step += 4;
					};

					// Top neighbour
					if (y == height - 1 || (y < height - 1 && voxel[index + width] == 0)) {
						vertices.push_back(Vertex{+0.5f + x, +0.5f + y, +0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});
						vertices.push_back(Vertex{+0.5f + x, +0.5f + y, -0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, +0.5f + y, -0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, +0.5f + y, +0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});

						indices.push_back(step + 0);
						indices.push_back(step + 1);
						indices.push_back(step + 3);
						indices.push_back(step + 1);
						indices.push_back(step + 2);
						indices.push_back(step + 3);

						step += 4;
					};

					// Bottom neighbour
					if (y == 0 || (y > 0 && voxel[index - width] == 0)) {
						vertices.push_back(Vertex{+0.5f + x, -0.5f + y, +0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{+0.5f + x, -0.5f + y, -0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, -0.5f + y, -0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, -0.5f + y, +0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});

						indices.push_back(step + 0);
						indices.push_back(step + 1);
						indices.push_back(step + 3);
						indices.push_back(step + 1);
						indices.push_back(step + 2);
						indices.push_back(step + 3);

						step += 4;
					}

					// Front neighbour
					if (z == 0 || (z > 0 && voxel[index - (width * height)] == 0)) {
						vertices.push_back(Vertex{+0.5f + x, +0.5f + y, -0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});
						vertices.push_back(Vertex{+0.5f + x, -0.5f + y, -0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, -0.5f + y, -0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, +0.5f + y, -0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});

						indices.push_back(step + 0);
						indices.push_back(step + 1);
						indices.push_back(step + 3);
						indices.push_back(step + 1);
						indices.push_back(step + 2);
						indices.push_back(step + 3);

						step += 4;
					}

					// Back neighbour
					if (z == depth -1 || (z < depth - 1 && voxel[index + (width * height)] == 0)) {
						vertices.push_back(Vertex{+0.5f + x, +0.5f + y, +0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});
						vertices.push_back(Vertex{+0.5f + x, -0.5f + y, +0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, -0.5f + y, +0.5f + z, 0.6f, 0.3f, 0.0f, 1.0f});
						vertices.push_back(Vertex{-0.5f + x, +0.5f + y, +0.5f + z, 0.25f, 0.8, 0.3f, 1.0f});

						indices.push_back(step + 0);
						indices.push_back(step + 1);
						indices.push_back(step + 3);
						indices.push_back(step + 1);
						indices.push_back(step + 2);
						indices.push_back(step + 3);

						step += 4;
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

inline std::pair<std::pair<std::vector<Vertex>, std::vector<GLuint>>, std::pair<std::vector<Vertex>, std::vector<GLuint>>> createMeshDataFromMarchingCubes(
    const NoiseConfig& noiseConfig, 
    float intensity, 
    Color color = {1.0f, 1.0f, 1.0f, 1.0f}
) {
    int width = noiseConfig.width;
    int depth = noiseConfig.height;
    int height = intensity;

    std::vector<Vertex> corners {
        Vertex{0.0f, 0.0f, 0.0f},
        Vertex{1.0f, 0.0f, 0.0f},
        Vertex{0.0f, 1.0f, 0.0f},
        Vertex{1.0f, 1.0f, 0.0f},
        Vertex{0.0f, 0.0f, 1.0f},
        Vertex{1.0f, 0.0f, 1.0f},
        Vertex{0.0f, 1.0f, 1.0f},
        Vertex{1.0f, 1.0f, 1.0f}
    };

	std::vector<uint> voxel{std::vector<uint>(height * width * depth, 0)};
	std::vector<uint> cell{std::vector<uint>((width - 1) * (height - 1) * (depth - 1), 0)};

	auto noise {generateNoiseMap(noiseConfig)};

	for (uint z = 0; z < depth; ++z) {
		for (uint x = 0; x < width; ++x) {
			uint noiseIndex = (z * width) + x;
			uint y = (noise[noiseIndex] + 0.5f) * (height / 2.0f);
			for (uint i = 0; i < y; ++i) {
				uint voxelIndex = x + (i * width) + (z * width * height);
				voxel[voxelIndex] = 1;
			}
		}
	}

	std::vector<Vertex> vertices;
	std::vector<GLuint> indices;
	std::vector<Vertex> verticesLines;
	std::vector<GLuint> indicesLines;

	uint step = 0;
	for (uint z = 0; z < depth - 1; ++z) {
		for (uint y = 0; y < height - 1; ++y) {
			for (uint x = 0; x < width - 1; ++x) {
				uint voxelIndex = x + (y * width) + (z * width * height);
				uint cellIndex = x + (y * (width - 1)) + (z * (width - 1) * (height - 1));
				std::vector<uint> cellCorners = {
					voxelIndex,
					voxelIndex + 1,
					voxelIndex + width,
					voxelIndex + width + 1,
					voxelIndex + (width * height),
					voxelIndex + (width * height) + 1,
					voxelIndex + (width * height) + width,
					voxelIndex + (width * height) + width + 1
				};

				for (int i = 0; i < 8; ++i) {
					if (voxel[cellCorners[i]] == 1) {
						cell[cellIndex] |= (1 << i);
					}
				}

				uint caseIndex = cell[cellIndex];
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

						auto pos = corners[a] % corners[b];
						pos = pos + Vertex{(float)x, (float)y, (float)z};
						vertices.push_back(pos);
					}
					for (int i = 0; i < (triangleCount * 3); i++) {
						indices.push_back(vertexOffset + cellData.vertexIndex[i]);
					}
				}
			}
		}
	}

	for (int i = 0; i < vertices.size(); i++) {
		verticesLines.push_back(vertices[i] - Vertex{0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f});
	}

	for (int i = 0; i < indices.size(); i+=3) {
		auto a = indices[i];
		auto b = indices[i + 1];
		auto c = indices[i + 2];

		indicesLines.push_back(a);
		indicesLines.push_back(b);
		indicesLines.push_back(b);
		indicesLines.push_back(c);
		indicesLines.push_back(c);
		indicesLines.push_back(a);
	}

	if (!vertices.empty() && !indices.empty() && !verticesLines.empty() && !indicesLines.empty()) {
        return {{vertices, indices}, {verticesLines, indicesLines}};
    }
    return {{{}, {}}, {{}, {}}};
};