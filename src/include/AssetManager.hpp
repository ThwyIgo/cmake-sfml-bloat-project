#pragma once
#include "config.hpp"

#include <filesystem>
#include <unordered_map>

template <typename T>
class AssetManager {
    static std::unordered_map<std::filesystem::path, T> cache;

  public:
    AssetManager() = delete;

    // Load and get a shared SFML asset with T::loadFromFile()
    static T& get(std::filesystem::path filePath, std::filesystem::path BasePath = DATA_PATH) {
        std::filesystem::path file = BasePath / filePath;

        try {
            return cache.at(file);
        } catch (std::out_of_range&) {
            T& asset = cache[file];
            asset.loadFromFile(file.generic_string());
            return asset;
        }
    }

    // Free a shared SFML asset
    static void free(std::filesystem::path filePath, std::filesystem::path BasePath = DATA_PATH) {
        cache.erase(BasePath / filePath);
    }
};

template <typename T>
std::unordered_map<std::filesystem::path, T> AssetManager<T>::cache = {};
