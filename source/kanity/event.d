//イベント処理
module kanity.event;

import kanity.imports;
import kanity.input;
import derelict.sdl2.sdl;
import std.experimental.logger;

class Event{
  private bool running;
  private Input input;

  this(){
  }

  void init(){
      running = true;
      input = new Input();
  }
  bool isRunning(){
      return running;
  }

  void process(){
    SDL_Event event;
    while(SDL_PollEvent(&event)){
      switch(event.type){
        //Inputに投げるイベント
        case SDL_KEYDOWN:
        case SDL_KEYUP:
          input.key(event.key);
          break;
        case SDL_JOYHATMOTION:
        case SDL_JOYBUTTONDOWN:
        case SDL_JOYBUTTONUP:
          input.button(event);
          break;
        case SDL_QUIT:
          this.stop;
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
