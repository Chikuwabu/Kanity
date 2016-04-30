//イベント処理
module kanity.event;

import kanity.render;
import derelict.sdl2.sdl;
import std.experimental.logger;

class EventHandler(F)
{
    F[F] event;
    public void addEventHandler(F)(F func)
    {
        event[func] = func;
    }
    public void removeEventHandler(F)(F func)
    {
        event.remove(func);
    }
    public void opCall(Args...)(Args args)
    {
        foreach(e; event)
            e(args);
    }
}

alias ButtonEventFunction = void delegate(bool);
alias KeyEventFunction = void delegate(SDL_KeyboardEvent);
alias EventFunction = void delegate(SDL_Event);
class Event{
private:
    bool running;

public:
    auto leftButtonDownEvent = new EventHandler!ButtonEventFunction;
    auto rightButtonDownEvent = new EventHandler!ButtonEventFunction;
    auto upButtonDownEvent = new EventHandler!ButtonEventFunction;
    auto downButtonDownEvent = new EventHandler!ButtonEventFunction;
    auto keyDownEvent = new EventHandler!KeyEventFunction;
    auto eventHandler = new EventHandler!EventFunction;
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
                        keyDownEvent(event.key);
                        break;
                }
                break;
            case SDL_QUIT:
                this.stop;
                break;
            default:
                break;
        }
        eventHandler(event);
    }
    void stop(){
        running = false;
    }
}
