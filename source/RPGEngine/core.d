module RPGEngine.core;

import RPGEngine.render;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.experimental.logger;
//import std.string;

class engine{
  //コンストラクタとデコンストラクタ
  this(){
    info("Load a library \"SDL2\".");
    DerelictSDL2.load;
    info("Load a library \"SDL_Image\".");
    DerelictSDL2Image.load;

    if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) logf(LogLevel.fatal,"Failed initalization of \"SDL2\".\n%s", SDL_GetError());
    info("Success initalization of \"SDL2\".");
    if(IMG_Init(IMG_INIT_PNG) != IMG_INIT_PNG) logf(LogLevel.fatal,"Failed initalization of \"SDL_Image\".\n%s", IMG_GetError());
    info("Success initalization of \"SDL_Image\"");
    return;
  }
  ~this(){
    SDL_Quit();
    IMG_Quit();
  }

  //フィールド
  Renderer renderer;

  int run(string title, int width, int height){
    //初期化
    renderer = new Renderer(title, width, height);
    import core.thread;
    auto Trender = new Thread(&render);
    Trender.start;
    Trender.join;
    return 0;
  }

  void render(){
    renderer.run();
    return;
  }
}
