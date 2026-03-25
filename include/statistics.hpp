#include <iostream>
#include <map>
#include <vector>
#include <iomanip>
#include <fstream>

class Statistics {
public:
    Statistics(int max_entries) : max_entries(max_entries) {}
    ~Statistics() = default;

    void addEntry(const std::string& group, const std::string& metric, double value) {
        if (data[group].size() < max_entries) {
            data[group][metric].push_back(value);
        }
    }

    void printStatistics() const {
        const int columnWidth = 20;

        for (const auto& group : data) {
            std::cout << group.first << ":" << std::endl;

            const auto& metrics = group.second;
            if (metrics.empty()) continue;

            bool first = true;
            for (const auto& m : metrics) {
                if (!first) std::cout << ", ";
                std::cout << std::left << std::setw(columnWidth) << m.first;
                first = false;
            }
            std::cout << std::endl;

            size_t numRows = metrics.begin()->second.size();
            for (size_t i = 0; i < numRows; ++i) {
                first = true;
                for (const auto& m : metrics) {
                    if (!first) std::cout << ", ";
                    std::cout << std::left << std::setw(columnWidth) << m.second[i];
                    first = false;
                }
                std::cout << std::endl;
            }
            std::cout << std::string(columnWidth * metrics.size(), '-') << std::endl;
        }
    }

    void makeCSV(const std::string& filepath) const {
        for (const auto& group : data) {
            std::ofstream file(filepath + "/" + group.first + ".csv");

            if (!file.is_open()) {
                return;
            }

            const auto& metrics = group.second;
            if (metrics.empty()) continue;

            bool first = true;
            for (const auto& m : metrics) {
                if (!first) file << ",";
                file << m.first;
                first = false;
            }
            file << std::endl;

            size_t numRows = metrics.begin()->second.size();
            for (size_t i = 0; i < numRows; ++i) {
                first = true;
                for (const auto& m : metrics) {
                    if (!first) file << ",";
                    file << m.second[i];
                    first = false;
                }
                file << std::endl;
            }

            file.close();
        }
    }

private:
    std::map<std::string, std::map<std::string, std::vector<double>>> data;
    int max_entries = -1;
};