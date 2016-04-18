//イベント処理
module kanity.event;

import kanity.render;
import derelict.sdl2.sdl;
import std.experimental.logger;

class Event{
private:
  bool running;

public:
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
