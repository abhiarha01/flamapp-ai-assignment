#include "processor.h"
#include <android/log.h>

#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, "flamapp", __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, "flamapp", __VA_ARGS__)

namespace flamapp {

static inline cv::Mat rgba_to_mat(const uint8_t* rgba, int width, int height) {
    cv::Mat mat_rgba(height, width, CV_8UC4, const_cast<uint8_t*>(rgba));
    return mat_rgba;
}

std::vector<uint8_t> process_rgba(const uint8_t* rgba, int width, int height) {
    cv::Mat src_rgba = rgba_to_mat(rgba, width, height);
    cv::Mat src_bgr, gray, edges, dst_rgba;

    cv::cvtColor(src_rgba, src_bgr, cv::COLOR_RGBA2BGR);
    cv::cvtColor(src_bgr, gray, cv::COLOR_BGR2GRAY);
    cv::Canny(gray, edges, 100, 200);

    // For visualization: put edges into all channels (white edges on black)
    cv::Mat edges_rgb;
    cv::cvtColor(edges, edges_rgb, cv::COLOR_GRAY2BGR);
    cv::cvtColor(edges_rgb, dst_rgba, cv::COLOR_BGR2RGBA);

    std::vector<uint8_t> out(dst_rgba.total() * dst_rgba.elemSize());
    memcpy(out.data(), dst_rgba.data, out.size());
    return out;
}

bool save_png(const uint8_t* rgba, int width, int height, const char* path) {
    try {
        cv::Mat rgba_mat(height, width, CV_8UC4, const_cast<uint8_t*>(rgba));
        cv::Mat bgr;
        cv::cvtColor(rgba_mat, bgr, cv::COLOR_RGBA2BGR);
        std::vector<int> params = {cv::IMWRITE_PNG_COMPRESSION, 3};
        bool ok = cv::imwrite(path, bgr, params);
        LOGI("Saved PNG to %s => %d", path, ok ? 1 : 0);
        return ok;
    } catch (const std::exception& e) {
        LOGE("save_png exception: %s", e.what());
        return false;
    }
}

} // namespace flamapp
