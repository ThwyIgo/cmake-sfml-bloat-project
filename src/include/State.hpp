#pragma once
#include <SFML/System.hpp>

class State {
  public:
    // The time the last frame took to be calculated
    static sf::Time deltaTime() noexcept;

    // update() should be called every frame
    static void update();

    State() = delete;

  private:
    static sf::Clock m_deltaClock;
    static sf::Time m_deltaTime;
};