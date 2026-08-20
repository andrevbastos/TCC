#pragma once

#include <ifcg/ifcg.hpp>
#include <ifcg/graphics/mesh.hpp>

inline Vertex getClosestVertex(const ifcg::Mesh& mesh) {
    double mouseX;
    double mouseY;

    auto renderer = ifcg::Engine::getRenderer();
    auto window = ifcg::Engine::getWindow();

    auto camera = renderer.getCamera();
    auto proj = camera.getProjectionMatrix();
    auto view = camera.getViewMatrix();

    glfwGetCursorPos(window.getGLFWwindow(), &mouseX, &mouseY);

    mouseX = (mouseX / window.getWidth()) * 2.0 - 1.0;
    mouseY = 1.0 - (mouseY / window.getHeight()) * 2.0;

    glm::vec4 ray_clip = glm::vec4(mouseX, mouseY, -1.0f, 1.0f);

    glm::mat4 invProjection = glm::inverse(proj);
    glm::vec4 ray_eye = invProjection * ray_clip;

    ray_eye = glm::vec4(ray_eye.x, ray_eye.y, -1.0f, 0.0f);

    glm::mat4 invView = glm::inverse(view);
    glm::vec4 ray_world = invView * ray_eye;

    glm::vec3 ray_direction = glm::normalize(glm::vec3(ray_world));
    glm::vec3 ray_origin = glm::vec3(invView[3]);

    float line_length = 100.0f;
    glm::vec3 ray_end = ray_origin + ray_direction * line_length;

    ray_direction = glm::normalize(ray_end - ray_origin);

    Vertex closestHitVertexPtr {0.0f, 0.0f};
    float minDistanceAlongRay = std::numeric_limits<float>::max();

    const float VERTEX_HIT_RADIUS = 0.5f; 

    for (auto v : mesh.getVertices()) {
        glm::vec4 localVertexPosHom = glm::vec4(v.x, v.y, v.z, 1.0f);
        glm::vec4 worldVertexPosHom = mesh.getModel() * localVertexPosHom; 
        glm::vec3 worldVertexPos = glm::vec3(worldVertexPosHom);
        
        glm::vec3 originToVertex = worldVertexPos - ray_origin;
        float t = glm::dot(originToVertex, ray_direction);
        if (t < 0.0f) {
            continue;
        }

        glm::vec3 closestPointOnRay = ray_origin + ray_direction * t;
        float distanceSq = glm::distance2(worldVertexPos, closestPointOnRay);

        if (distanceSq <= (VERTEX_HIT_RADIUS * VERTEX_HIT_RADIUS)) {
            if (t < minDistanceAlongRay) {
                minDistanceAlongRay = t;
                closestHitVertexPtr = v;
            }
        }
    }
    
    return closestHitVertexPtr;
}