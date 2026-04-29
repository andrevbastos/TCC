#pragma once

#include <functional>
#include <thread>
#include <mutex>
#include <vector>
#include <queue>
#include <condition_variable>

class Monitor {
public:
    Monitor(std::shared_ptr<std::jthread> mainContextThread)
        : mainContextThread(mainContextThread) 
    {
        processingUnits = std::thread::hardware_concurrency() - 1;
        workerThreadCount = 0;
    }

    ~Monitor() {
        cv.notify_all();
        if (mainContextThread && mainContextThread->joinable()) {
            mainContextThread->join();
        }
    }

    void addTask(std::function<void()> task) {
        if (workerThreadCount < processingUnits) {
            std::jthread([this, task]() {
                task();
                {
                    std::lock_guard<std::mutex> lock(mtx);
                    workerThreadCount--;
                }
                cv.notify_one();
            });
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
    std::shared_ptr<std::jthread> mainContextThread;
    unsigned int processingUnits;
    unsigned int workerThreadCount;

    std::mutex mtx;
    std::condition_variable cv;
};