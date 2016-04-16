module RPGEngine.render;

import RPGEngine.BG;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.experimental.logger;
import std.string;

class Renderer{
  //フィールド
private:
  SDL_Window* window_;
  SDL_Renderer* renderer;
  string title; int width, height;

public:
  this(string title_, int width_, int height_){
    title = title_; width = width_; height = height_;
  }
  ~this(){
    window_.SDL_DestroyWindow;
    renderer.SDL_DestroyRenderer;
  }

  void run(){
    init();

    auto mapchip = IMG_Load("BGTest.png");
    auto tex = renderer.SDL_CreateTextureFromSurface(window_.SDL_GetWindowSurface);
    renderer.SDL_RenderCopy(tex, null, null);
    window_.SDL_ShowWindow;
    renderer.SDL_SetRenderDrawColor(255, 255, 255, 255);
    renderer.SDL_RenderClear;
    renderer.SDL_RenderPresent;

    auto bg1 = new BG(window_, 0, 0, mapchip);

    renderer.SDL_RenderClear;
    bg1.draw;
    renderer.SDL_RenderPresent;
    SDL_Delay(3000);
  }
  @property{
    public SDL_Window* window(){ return window_;}
  }
  //Utils
private:
  SDL_Window* CreateWindow(string title, int width, int height){
    return SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                              width, height, SDL_WINDOW_HIDDEN);
  }
  void init(){
    window_ = CreateWindow(title, width, height);
    if(window_ == null) logf(LogLevel.fatal, "Failed to create window.\n%s", SDL_GetError());
    info("Success to create window.");
    renderer = window_.SDL_CreateRenderer( -1, 0 );
    if(renderer == null) logf(LogLevel.fatal, "Failed to create renderer.\n%s", SDL_GetError());
    info("Success to create renderer.");

  }
}
