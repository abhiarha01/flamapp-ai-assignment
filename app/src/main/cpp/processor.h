#pragma once
#include <vector>
#include <opencv2/opencv.hpp>

namespace flamapp {

// Process an RGBA frame: grayscale + Canny; returns RGBA buffer
std::vector<uint8_t> process_rgba(const uint8_t* rgba, int width, int height);

// Optionally save to PNG at path (UTF-8)
bool save_png(const uint8_t* rgba, int width, int height, const char* path);

} // namespace flamapp
