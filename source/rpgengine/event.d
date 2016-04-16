//イベント処理
module rpgengine.event;

import rpgengine.render;
import derelict.sdl2.sdl;
import std.experimental.logger;

class Event{
private:
  Renderer renderer;
  bool running;
public:
  this(Renderer renderer_){
    renderer = renderer_;
  }

  void run(){
    SDL_Event event;
    running = true;
    while(running){
      SDL_PollEvent(&event);
      switch(event.type){
        case SDL_QUIT:
          this.stop;
          renderer.stop;
          break;
        default:
          break;
      }
    }
  }
  void stop(){
    running = false;
  }
}
