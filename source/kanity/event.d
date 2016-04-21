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
        event(args);
    }
}
alias ButtonEventFunction = void delegate();
class Event{
private:
    bool running;

public:
    auto leftButtonDownEvent = new EventHandler!ButtonEventFunction;
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
                        break;
                    case SDLK_RIGHT:
                        break;
                    case SDLK_DOWN:
                        break;
                    case SDLK_LEFT:
                        leftButtonDownEvent();
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