//イベント処理
module kanity.event;

import kanity.render;
import derelict.sdl2.sdl;
import std.experimental.logger;

class EventHandler(F)
{
    F event;
    public void addEventHandler(F)(F func)
    {
        event = func;
    }
    public void opCall(Args...)(Args args)
    {
        if (event)
            event(args);
    }
}

alias ButtonEventFunction = void delegate(bool);
class Event{
private:
    bool running;

public:
    auto leftButtonDownEvent = new EventHandler!ButtonEventFunction;
    auto rightButtonDownEvent = new EventHandler!ButtonEventFunction;
    auto upButtonDownEvent = new EventHandler!ButtonEventFunction;
    auto downButtonDownEvent = new EventHandler!ButtonEventFunction;
    void init(){
        running = true;
    }
    bool isRunning()
    {
        return running;
    }

    void process(){
        SDL_Event event;
        SDL_PollEvent(&event);
        switch(event.type){
            case SDL_KEYDOWN:
                switch (event.key.keysym.sym) {
                    case SDLK_UP:
                        upButtonDownEvent(event.key.repeat == 0 ? false : true);
                        break;
                    case SDLK_RIGHT:
                        rightButtonDownEvent(event.key.repeat == 0 ? false : true);
                        break;
                    case SDLK_DOWN:
                        downButtonDownEvent(event.key.repeat == 0 ? false : true);
                        break;
                    case SDLK_LEFT:
                        leftButtonDownEvent(event.key.repeat == 0 ? false : true);
                        break;
                    default:
                        break;
                }
                break;
            case SDL_QUIT:
                this.stop;
                break;
            default:
                break;
        }
    }
    void stop(){
        running = false;
    }
}
