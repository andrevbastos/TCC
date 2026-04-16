#include <map>
#include <vector>
#include <queue>
#include <unordered_map>
#include <functional>
#include <limits>
#include <graph/undirected/graph.hpp>

/*
unordered_map<Location, Location> jps(
   const Grid& grid,
   const Location& start, const Location& goal,
   heuristic_fn heuristic)
{

	PQLoc open_set;
	unordered_map<Location, Location> came_from {};
	unordered_map<Location, double> cost_so_far {};

	open_set.emplace(0, start);
	came_from[start] = start;
	cost_so_far[start] = 0;
	Location parent {NoneLoc};

	while(!open_set.empty()){
		const auto current {open_set.top().second};
		if(current == goal){
			break;
		}

		open_set.pop();
		if(current != start){
			parent = came_from[current];
		}

		for(const auto& next : successors(grid, current, parent, goal)){
			const auto new_cost = cost_so_far[current] + heuristic(current, next);
			auto existing_cost = std::numeric_limits<double>::max();
			if (cost_so_far.count(next)) {
				existing_cost = cost_so_far.at(next);
			}
			if(cost_so_far.find(next) == cost_so_far.end() || new_cost < existing_cost){
				cost_so_far[next] = new_cost;
				came_from[next] = current;
				open_set.emplace(new_cost + heuristic(next, goal), next);
			}
		}
	}
	return came_from;
}
*/

typedef std::pair<double, int> Element;
typedef std::priority_queue<Element, std::vector<Element>, std::greater<Element>> OSet;

std::vector<common::Node*> jumpPointSearch(common::Graph *graph, int startId, int endId, std::function<double(common::Node*, common::Node*)> heuristic)
{
    if (!graph) return {};
    common::Node* startNode = graph->getVertex(startId);
    common::Node* endNode = graph->getVertex(endId);
    if (!startNode || !endNode) return {};

    if (startId == endId) return {startNode};

    auto edgeWeights = graph->getWeights();

    OSet openSet;
    std::unordered_map<int, int> cameFrom;
    std::unordered_map<int, double> gScore;

    openSet.emplace(0.0, startId);
    cameFrom[startId] = startId;
    gScore[startId] = 0.0;

    std::vector<common::Node*> path;
    int parentId = -1;

    while (!openSet.empty()) {
        const auto currentId = openSet.top().second;
        const auto current = graph->getVertex(currentId);
        if (currentId == endId) {
            int nodeId = endId;
            while (nodeId != startId) {
                path.push_back(graph->getVertex(nodeId));
                nodeId = cameFrom[nodeId];
            }
            path.push_back(startNode);
            std::reverse(path.begin(), path.end());
            return path;
        }
        
        openSet.pop();
        if (currentId != startId) {
            parentId = cameFrom[currentId];
        }

        for (const auto& neighbor : current->adj()) {
            auto neighborId = neighbor->getId();
            const auto newCost = gScore[currentId] + heuristic(current, neighbor);
            auto existingCost = std::numeric_limits<double>::max();
            if (gScore.count(neighborId)) {
                existingCost = gScore.at(neighborId);
            }
            if (gScore.find(neighborId) == gScore.end() || newCost < existingCost) {
                gScore[neighborId] = newCost;
                cameFrom[neighborId] = currentId;
                openSet.emplace(newCost + heuristic(neighbor, endNode), neighborId);
            }
        }
    }
    return {};
}