#pragma once

#include <functional>
#include <thread>
#include <mutex>
#include <vector>
#include <queue>
#include <condition_variable>

class Monitor {
public:
    // mainContextThread é a thread principal que executa o loop de renderização
    Monitor(std::shared_ptr<std::jthread> mainContextThread)
        : mainContextThread(mainContextThread) 
    {
        // Pega a quantidade de cores disponíveis e reserva uma para a thread principal
        processingUnits = std::thread::hardware_concurrency() - 1;
        // Inicialmente, não há threads de trabalho ativas
        workerThreadCount = 0;
    }

    // O destruidor garante que todas as threads sejam notificadas para encerrar quando o Monitor for destruído
    ~Monitor() {
        cv.notify_all();
    }

    // Adiciona uma tarefa para ser executada por uma thread de trabalho
    void addTask(std::function<void()> task) {
        // Lock para proteger o acesso ao contador de threads ativas e à fila de tarefas
        std::unique_lock<std::mutex> lock(mtx);

        // Se ainda há capacidade para criar uma nova thread de trabalho
        if (workerThreadCount < processingUnits) {
            // Incrementa o contador de threads ativas
            workerThreadCount++;

            // Cria uma nova thread de trabalho que executa a tarefa e, 
            // ao finalizar, decrementa o contador de threads ativas e 
            // notifica uma possível thread esperando
            workers.emplace_back([this, task]() {
                task();
                {
                    std::lock_guard<std::mutex> lock(mtx);
                    workerThreadCount--;
                }
                cv.notify_one();
            });

        } else {
            // Se o número máximo de threads de trabalho já está ativo, 
            // espera até que uma thread termine para adicionar a nova tarefa
            cv.wait(lock, [this]() { return workerThreadCount < processingUnits; });
            lock.unlock(); // Libera o lock antes da chamada recursiva
            addTask(task);
        }
    }

private:
    std::shared_ptr<std::jthread> mainContextThread;
    std::vector<std::jthread> workers;
    unsigned int processingUnits;
    unsigned int workerThreadCount;

    std::mutex mtx;
    std::condition_variable cv;
};