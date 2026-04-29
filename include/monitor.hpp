#pragma once

#include <functional>
#include <thread>
#include <mutex>
#include <vector>
#include <queue>
#include <condition_variable>

class Monitor {
public:
    Monitor(std::function<void()> mainContextFunction) {
        mainContextThread = std::jthread(mainContextFunction);
        processingUnits = std::thread::hardware_concurrency() - 1;
        workerThreadCount = 0;
    }

    ~Monitor() {
        cv.notify_all();
    }

    void addTask(std::function<void()> task) {
        if (workerThreadCount < processingUnits) {
            std::thread([this, task]() {
                task();
                {
                    std::lock_guard<std::mutex> lock(mtx);
                    workerThreadCount--;
                }
                cv.notify_one();
            }).detach();
            {
                std::lock_guard<std::mutex> lock(mtx);
                workerThreadCount++;
            }
        } else {
            std::unique_lock<std::mutex> lock(mtx);
            cv.wait(lock, [this]() { return workerThreadCount < processingUnits; });
            addTask(task);
        }
    }

private:
    std::jthread mainContextThread;
    unsigned int processingUnits;
    unsigned int workerThreadCount;

    std::mutex mtx;
    std::condition_variable cv;
};