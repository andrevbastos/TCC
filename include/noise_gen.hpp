#include <iostream>
#include <math.h>
#include <random>
#include <vector>
#include <fstream>
#include <filesystem>

typedef struct {
    float x, y;
} Vector2D;

typedef struct {
    int width, height;
    int wave = 100;
    float freq = 4.0f;
    float amp = 1.0f;
    float exp = 1.0f;
} NoiseConfig;

Vector2D randomGradient(int ix, int iy) {
    const unsigned w {8 * sizeof(unsigned)};
    const unsigned s {w / 2}; 
    unsigned a = ix, b = iy;
    a *= 3284157443;
 
    b ^= a << s | a >> w - s;
    b *= 1911520717;
 
    a ^= b << s | b >> w - s;
    a *= 2048419325;
    float random = a * (3.14159265 / ~(~0u >> 1));
    
    Vector2D v;
    v.x = sin(random);
    v.y = cos(random);
 
    return v;
}

float dotGridGradient(int ix, int iy, float x, float y) {
    auto gradient {randomGradient(ix, iy)};

    float dx {x - (float)ix};
    float dy {y - (float)iy};

    return (dx * gradient.x + dy * gradient.y);
}

float interpolate(float a0, float a1, float w) {
    return (a1 - a0) * (3.0f - w * 2.0f) * w * w + a0;
}

float perlin(float x, float y) {
    int x0 {(int)x};
    int x1 {x0 + 1};
    int y0 {(int)y};
    int y1 {y0 + 1};

    float sx {x - (float)x0};
    float sy {y - (float)y0};

    float n0 {dotGridGradient(x0, y0, x, y)};
    float n1 {dotGridGradient(x1, y0, x, y)};
    float ix0 {interpolate(n0, n1, sx)};

    n0 = dotGridGradient(x0, y1, x, y);
    n1 = dotGridGradient(x1, y1, x, y);
    float ix1 {interpolate(n0, n1, sx)};

    float result {interpolate(ix0, ix1, sy)};
    
    return result;
}

std::vector<float> generateNoiseMap(NoiseConfig config) {
    std::vector<float> noiseMap(config.width * config.height);

    for (int y{0}; y < config.height; ++y) {
        for (int x{0}; x < config.width; ++x) {
            int index {y * config.width + x};

            float val {0.0f};
            float freq {config.freq};
            float amp {config.amp};
            float ampSum = 0.0f;

            for (int i{0}; i < 3; i++) {
                val += perlin(x * freq / config.wave, y * freq / config.wave) * amp;
                ampSum += amp;
                amp /= 2;
                freq *= 2;
            }

            val /= ampSum;
            
            if (val > 1.0f) val = 1.0f;
            else if (val < -1.0f) val = -1.0f;
            
            val = (val + 1.0f) * 0.5f;
            val = pow(val, config.exp);
            noiseMap[index] = val;
        }
    }

    return noiseMap;
}

void saveNoiseAsPNG(const std::string& filename, const std::vector<float>& noiseMap, int width, int height) {
    std::vector<unsigned char> imageData(width * height);
    
    for (size_t i = 0; i < noiseMap.size(); ++i) {
        imageData[i] = static_cast<unsigned char>(noiseMap[i] * 255);
    }

    stbi_write_png(filename.c_str(), width, height, 1, imageData.data(), width);
}