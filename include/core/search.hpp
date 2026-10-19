#pragma once

#include <algorithm>
#include <cstddef>
#include <functional>
#include <limits>
#include <queue>
#include <tuple>
#include <vector>
#include <graph/common/lw_graph.hpp>

namespace search {
    struct SearchResult {
        std::vector<std::size_t> path;
        double cost = 0.0;
        std::size_t expanded = 0;
        std::size_t generated = 0;
        std::size_t peakOpen = 0;
        std::size_t peakBytes = 0;
    };

    template <typename T>
    using Heuristic = std::function<double(const T&, const T&)>;

    // (prioridade, h, id): empates na prioridade são desfeitos pelo menor h.
    using OpenElement = std::tuple<double, double, std::size_t>;
    using OpenList = std::priority_queue<OpenElement, std::vector<OpenElement>, std::greater<OpenElement>>;

    inline constexpr double INF = std::numeric_limits<double>::infinity();

    inline std::vector<std::size_t> reconstructPath(
        const std::vector<std::size_t>& cameFrom,
        std::size_t start,
        std::size_t goal
    ) {
        std::vector<std::size_t> path;
        for (std::size_t current = goal; current != start; current = cameFrom[current]) {
            path.push_back(current);
        }
        path.push_back(start);
        std::reverse(path.begin(), path.end());
        return path;
    }

    // Memória auxiliar: gScore + cameFrom + closed por vértice, mais o pico da open list.
    inline std::size_t searchBytes(std::size_t numVertices, std::size_t peakOpen) {
        return numVertices * (sizeof(double) + sizeof(std::size_t) + sizeof(char))
            + peakOpen * sizeof(OpenElement);
    }

    template <typename T>
    SearchResult dijkstra(
        const common::lwGraph<T>& graph,
        std::size_t start,
        std::size_t goal
    ) {
        SearchResult result;
        const std::size_t numVertices = graph.getOrder();
        if (start >= numVertices || goal >= numVertices) return result;

        std::vector<double> gScore(numVertices, INF);
        std::vector<std::size_t> cameFrom(numVertices);
        std::vector<char> closed(numVertices, 0);
        OpenList open;

        gScore[start] = 0.0;
        cameFrom[start] = start;
        open.push({0.0, 0.0, start});
        result.generated = 1;
        result.peakOpen = 1;

        while (!open.empty()) {
            const auto [priority, h, current] = open.top();
            open.pop();

            if (closed[current]) continue;
            closed[current] = 1;
            ++result.expanded;

            if (current == goal) {
                result.path = reconstructPath(cameFrom, start, goal);
                result.cost = gScore[goal];
                break;
            }

            for (const auto& edge : graph.adj(current)) {
                const std::size_t neighbor = edge.target;
                if (closed[neighbor]) continue;

                const double tentativeG = gScore[current] + edge.weight;
                if (tentativeG >= gScore[neighbor]) continue;

                gScore[neighbor] = tentativeG;
                cameFrom[neighbor] = current;

                open.push({tentativeG, 0.0, neighbor});
                ++result.generated;
                result.peakOpen = std::max(result.peakOpen, open.size());
            }
        }

        result.peakBytes = searchBytes(numVertices, result.peakOpen);
        return result;
    }

    template <typename T>
    SearchResult aStar(
        const common::lwGraph<T>& graph,
        std::size_t start,
        std::size_t goal,
        Heuristic<T> heuristic
    ) {
        SearchResult result;
        const std::size_t numVertices = graph.getOrder();
        if (start >= numVertices || goal >= numVertices) return result;

        std::vector<double> gScore(numVertices, INF);
        std::vector<std::size_t> cameFrom(numVertices);
        std::vector<char> closed(numVertices, 0);
        OpenList open;

        const T& goalData = graph.getVertexData(goal);
        const double startH = heuristic(graph.getVertexData(start), goalData);

        gScore[start] = 0.0;
        cameFrom[start] = start;
        open.push({startH, startH, start});
        result.generated = 1;
        result.peakOpen = 1;

        while (!open.empty()) {
            const auto [priority, h, current] = open.top();
            open.pop();

            if (closed[current]) continue;
            closed[current] = 1;
            ++result.expanded;

            if (current == goal) {
                result.path = reconstructPath(cameFrom, start, goal);
                result.cost = gScore[goal];
                break;
            }

            for (const auto& edge : graph.adj(current)) {
                const std::size_t neighbor = edge.target;
                if (closed[neighbor]) continue;

                const double tentativeG = gScore[current] + edge.weight;
                if (tentativeG >= gScore[neighbor]) continue;

                gScore[neighbor] = tentativeG;
                cameFrom[neighbor] = current;

                const double neighborH = heuristic(graph.getVertexData(neighbor), goalData);
                open.push({tentativeG + neighborH, neighborH, neighbor});
                ++result.generated;
                result.peakOpen = std::max(result.peakOpen, open.size());
            }
        }

        result.peakBytes = searchBytes(numVertices, result.peakOpen);
        return result;
    }

    template <typename T>
    SearchResult greedyBestFirst(
        const common::lwGraph<T>& graph,
        std::size_t start,
        std::size_t goal,
        Heuristic<T> heuristic
    ) {
        SearchResult result;
        const std::size_t numVertices = graph.getOrder();
        if (start >= numVertices || goal >= numVertices) return result;

        std::vector<double> gScore(numVertices, INF);
        std::vector<std::size_t> cameFrom(numVertices);
        std::vector<char> closed(numVertices, 0);
        OpenList open;

        const T& goalData = graph.getVertexData(goal);
        const double startH = heuristic(graph.getVertexData(start), goalData);

        gScore[start] = 0.0;
        cameFrom[start] = start;
        open.push({startH, startH, start});
        result.generated = 1;
        result.peakOpen = 1;

        while (!open.empty()) {
            const auto [priority, h, current] = open.top();
            open.pop();

            if (closed[current]) continue;
            closed[current] = 1;
            ++result.expanded;

            if (current == goal) {
                result.path = reconstructPath(cameFrom, start, goal);
                result.cost = gScore[goal];
                break;
            }

            for (const auto& edge : graph.adj(current)) {
                const std::size_t neighbor = edge.target;
                if (closed[neighbor]) continue;

                const double tentativeG = gScore[current] + edge.weight;
                if (tentativeG >= gScore[neighbor]) continue;

                // A prioridade depende só de h, então o nó entra na open list uma única vez;
                // um g melhor apenas atualiza o pai, mantendo o custo real do caminho.
                const bool discovered = gScore[neighbor] != INF;
                gScore[neighbor] = tentativeG;
                cameFrom[neighbor] = current;
                if (discovered) continue;

                const double neighborH = heuristic(graph.getVertexData(neighbor), goalData);
                open.push({neighborH, neighborH, neighbor});
                ++result.generated;
                result.peakOpen = std::max(result.peakOpen, open.size());
            }
        }

        result.peakBytes = searchBytes(numVertices, result.peakOpen);
        return result;
    }

    template <typename T>
    SearchResult weightedAStar(
        const common::lwGraph<T>& graph,
        std::size_t start,
        std::size_t goal,
        Heuristic<T> heuristic,
        double weight
    ) {
        SearchResult result;
        const std::size_t numVertices = graph.getOrder();
        if (start >= numVertices || goal >= numVertices) return result;

        std::vector<double> gScore(numVertices, INF);
        std::vector<std::size_t> cameFrom(numVertices);
        std::vector<char> closed(numVertices, 0);
        OpenList open;

        const T& goalData = graph.getVertexData(goal);
        const double startH = heuristic(graph.getVertexData(start), goalData);

        gScore[start] = 0.0;
        cameFrom[start] = start;
        open.push({weight * startH, startH, start});
        result.generated = 1;
        result.peakOpen = 1;

        while (!open.empty()) {
            const auto [priority, h, current] = open.top();
            open.pop();

            if (closed[current]) continue;
            closed[current] = 1;
            ++result.expanded;

            if (current == goal) {
                result.path = reconstructPath(cameFrom, start, goal);
                result.cost = gScore[goal];
                break;
            }

            for (const auto& edge : graph.adj(current)) {
                const std::size_t neighbor = edge.target;
                if (closed[neighbor]) continue;

                const double tentativeG = gScore[current] + edge.weight;
                if (tentativeG >= gScore[neighbor]) continue;

                gScore[neighbor] = tentativeG;
                cameFrom[neighbor] = current;

                const double neighborH = heuristic(graph.getVertexData(neighbor), goalData);
                open.push({tentativeG + weight * neighborH, neighborH, neighbor});
                ++result.generated;
                result.peakOpen = std::max(result.peakOpen, open.size());
            }
        }

        result.peakBytes = searchBytes(numVertices, result.peakOpen);
        return result;
    }
}
