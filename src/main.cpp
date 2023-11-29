#include "main.hpp"
#include "State.hpp"
#include "config.hpp"
#include "debug.hpp"

#include <SFML/Graphics.hpp>

int main(int argc, char* argv[]) {
    db_msg("info", SYSTEM_NAME, PROJECT_VERSION, DATA_PATH);

    sf::RenderWindow window({1600, 900}, "title", sf::Style::Default);

    while (window.isOpen()) {
        pollEvents(&window);
        update();
        render(&window);
    }
}

void pollEvents(sf::RenderWindow* window) {
    sf::Event ev;

    while (window->pollEvent(ev)) {
        switch (ev.type) {
            case sf::Event::Closed:
                window->close();
                break;
        }
    }
}

void update() {
    State::update();
}

void render(sf::RenderWindow* window) {
    window->clear();

    // Render

    window->display();
}