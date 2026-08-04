#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <memory>
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <unistd.h>
#include <arpa/inet.h>

#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>
#include "util.hpp"

int setupUDPSocket(int port) {
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) {
        std::cerr << "[UDP] Erro ao criar socket" << std::endl;
        return -1;
    }

    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0 || fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) {
        std::cerr << "[UDP] Erro ao configurar socket como O_NONBLOCK" << std::endl;
        close(fd);
        return -1;
    }

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(port);

    if (bind(fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        std::cerr << "[UDP] Erro no bind na porta " << port << std::endl;
        close(fd);
        return -1;
    }

    std::cout << "[UDP] Escutando comandos na porta " << port << "..." << std::endl;
    return fd;
}

int main() {
    const int port = 12345;
    int socket_fd = setupUDPSocket(port);
    if (socket_fd < 0) {
        return 1;
    }

    Engine::init(1200, 800, "Gerador de Terrenos Interativo - IFCG");
    Engine::setup3D();

    auto& renderer {Engine::getRenderer()};
    auto& input {Engine::getInputHandler()};
    GLuint shader {renderer.getShaderID()};

    auto& camera {renderer.getCamera()};
    camera.setPosition(glm::vec3(-50.0f, 150.0f, -50.0f));
    camera.setOrientation(glm::vec3(0.6f, -0.5f, 0.6f));
    renderer.setFarPlane(2000.0f);
    camera.setSpeed(1.0f);

    input.addKeyCallback(Key::SHIFT_L, KeyAction::HELD, [&camera]() {
        camera.setSpeed(3.0f);
    });

    input.addKeyCallback(Key::SHIFT_L, KeyAction::RELEASE, [&camera]() {
        camera.setSpeed(1.0f);
    });


    NoiseConfig config {
        .width = 256,
        .height = 256,
        .wave = 100,
        .freq = 4.0f,
        .amp = 1.0f,
        .exp = 1.0f,
        .seed = 42,
        .octaves = 3
    };
    float intensity = 100.0f;

    Color terrainColor = {0.3f, 0.6f, 0.3f, 1.0f};

    std::cout << "[Terrain] Gerando malha inicial de tamanho " << config.width << "x" << config.height << "..." << std::endl;
    std::vector<float> noiseMap = generateNoiseMap(config);
    saveNoiseAsPNG("./noise_preview.png", noiseMap, config.width, config.height);
    auto [vertices, indices] = createMeshDataFromNoise(noiseMap, config.width, config.height, intensity, terrainColor);
    
    std::shared_ptr<MeshBase> terrainMesh = std::make_shared<Mesh>(vertices, indices, shader, GL_TRIANGLES);
    renderer.addMesh(terrainMesh);

    bool needsUpdate = false;

    LoopConfig loopConfig {
        .loopBody = [&]() {
            char buffer[1024];
            sockaddr_in client_addr{};
            socklen_t addr_len = sizeof(client_addr);
            
            bool dataReceived = false;
            bool colorReceived = false;
            int new_w = config.width;
            int new_h = config.height;
            float new_wave = static_cast<float>(config.wave);
            float new_freq = config.freq;
            float new_amp = config.amp;
            float new_exp = config.exp;
            unsigned int new_seed = config.seed;
            unsigned int new_octaves = config.octaves;
            float new_intensity = intensity;
            
            float new_r = terrainColor.r;
            float new_g = terrainColor.g;
            float new_b = terrainColor.b;

            while (true) {
                ssize_t bytes = recvfrom(socket_fd, buffer, sizeof(buffer) - 1, 0, (struct sockaddr*)&client_addr, &addr_len);
                if (bytes <= 0) {
                    break;
                }
                
                buffer[bytes] = '\0';
                std::string msg(buffer);
                std::stringstream ss(msg);
                
                // Tenta ler com os 3 floats adicionais de cor (R, G, B)
                int temp_w, temp_h;
                float temp_wave, temp_freq, temp_amp, temp_exp, temp_intensity, temp_r, temp_g, temp_b;
                unsigned int temp_seed, temp_octaves;
                
                if (ss >> temp_w >> temp_h >> temp_wave >> temp_freq >> temp_amp >> temp_exp >> temp_seed >> temp_octaves >> temp_intensity >> temp_r >> temp_g >> temp_b) {
                    new_w = temp_w; new_h = temp_h; new_wave = temp_wave; new_freq = temp_freq;
                    new_amp = temp_amp; new_exp = temp_exp; new_seed = temp_seed; new_octaves = temp_octaves;
                    new_intensity = temp_intensity;
                    new_r = temp_r; new_g = temp_g; new_b = temp_b;
                    dataReceived = true;
                    colorReceived = true;
                }
                // Fallback: tenta ler os 9 parâmetros tradicionais de ruído
                else {
                    std::stringstream ss_fallback(msg);
                    if (ss_fallback >> temp_w >> temp_h >> temp_wave >> temp_freq >> temp_amp >> temp_exp >> temp_seed >> temp_octaves >> temp_intensity) {
                        new_w = temp_w; new_h = temp_h; new_wave = temp_wave; new_freq = temp_freq;
                        new_amp = temp_amp; new_exp = temp_exp; new_seed = temp_seed; new_octaves = temp_octaves;
                        new_intensity = temp_intensity;
                        dataReceived = true;
                    }
                }
            }

            if (dataReceived) {
                bool colorChanged = colorReceived && (terrainColor.r != new_r || terrainColor.g != new_g || terrainColor.b != new_b);
                
                if (config.width != new_w || config.height != new_h ||
                    config.wave != static_cast<int>(new_wave) || config.freq != new_freq ||
                    config.amp != new_amp || config.exp != new_exp ||
                    config.seed != new_seed || config.octaves != new_octaves ||
                    intensity != new_intensity || colorChanged) {
                    
                    config.width = new_w;
                    config.height = new_h;
                    config.wave = static_cast<int>(new_wave);
                    config.freq = new_freq;
                    config.amp = new_amp;
                    config.exp = new_exp;
                    config.seed = new_seed;
                    config.octaves = new_octaves;
                    intensity = new_intensity;
                    
                    if (colorReceived) {
                        terrainColor = {new_r, new_g, new_b, 1.0f};
                    }
                    
                    needsUpdate = true;
                }
            }

            if (needsUpdate) {
                std::vector<float> newNoiseMap = generateNoiseMap(config);
                saveNoiseAsPNG("./noise_preview.png", newNoiseMap, config.width, config.height);
                auto [newVertices, newIndices] = createMeshDataFromNoise(newNoiseMap, config.width, config.height, intensity, terrainColor);
                
                if (!newVertices.empty()) {
                    auto newMesh = std::make_shared<Mesh>(newVertices, newIndices, shader, GL_TRIANGLES);
                    renderer.removeMesh(terrainMesh);
                    renderer.addMesh(newMesh);
                    terrainMesh = newMesh;
                }
                
                needsUpdate = false;
            }
        },
        .onExit = [&]() {
            if (socket_fd >= 0) {
                close(socket_fd);
            }
            std::cout << "[Engine] Visualizador encerrado." << std::endl;
        }
    };

    Engine::loop(loopConfig);
    Engine::terminate();

    return 0;
}
