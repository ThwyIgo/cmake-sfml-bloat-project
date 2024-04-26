#define BOOST_TEST_MODULE State
#include <boost/test/included/unit_test.hpp>
#include <chrono>
#include <thread>

#include "State.hpp"

BOOST_AUTO_TEST_CASE(deltaTimeUpdate) {
    constexpr auto time = std::chrono::milliseconds(10);
    State::update();
    std::this_thread::sleep_for(time);
    State::update();

    BOOST_TEST(State::deltaTime().asMilliseconds() >= time.count());
}
