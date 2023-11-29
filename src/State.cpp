#include "State.hpp"

sf::Clock State::m_deltaClock;
sf::Time State::m_deltaTime;

void State::update() {
    m_deltaTime = m_deltaClock.restart();
}

sf::Time State::deltaTime() noexcept {
    return m_deltaTime;
}