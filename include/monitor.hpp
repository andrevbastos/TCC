#pragma once

#include <functional>
#include <thread>
#include <mutex>
#include <vector>
#include <queue>
#include <condition_variable>
#include <array>

enum class Priority {
    High = 0,
    Medium = 1,
    Low = 2
};

class Monitor {
public:
    Monitor() {
        unsigned int processingUnits = std::thread::hardware_concurrency();
        if (processingUnits > 1) processingUnits--;

        for (unsigned int i = 0; i < processingUnits; ++i) {
            workers.emplace_back([this](std::stop_token st) {
                while (!st.stop_requested()) {
                    std::function<void()> task;
                    {
                        std::unique_lock<std::mutex> lock(mtx);

                        std::function<bool()> stopCon = [this] {
                            return !taskQueues[0].empty() || 
                                   !taskQueues[1].empty() || 
                                   !taskQueues[2].empty();
                        };

                        if (!cv.wait(lock, st, stopCon)) {
                            return;
                        }

                        for (int i = 0; i < 3; ++i) {
                            if (!taskQueues[i].empty()) {
                                task = std::move(taskQueues[i].front());
                                taskQueues[i].pop();
                                break;
                            }
                        }
                    }
                    if (task) {
                        task();
                    }
                }
            });
        }
    }

    ~Monitor() {
        cv.notify_all();
        for (auto& worker : workers) {
            worker.request_stop();
        }
    };

    void addTask(std::function<void()> task, Priority p = Priority::Medium) {
        {
            std::lock_guard<std::mutex> lock(mtx);
            taskQueues[static_cast<size_t>(p)].push(std::move(task));
        }
        cv.notify_one();
    }

private:
    std::vector<std::jthread> workers;
    std::array<std::queue<std::function<void()>>, 3> taskQueues;

    std::mutex mtx;
    std::condition_variable_any cv;
};