module kanity.render;

import kanity.bg;
import kanity.sprite;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.experimental.logger;
import std.string;

class Renderer{
  //フィールド
private:
  SDL_Window* window_;
  SDL_Renderer* renderer;
  BG[] bgList;
  bool drawFlag;
  Sprite[] spriteList;

public:
  this(){
  }
  ~this(){
    window_.SDL_DestroyWindow;
    renderer.SDL_DestroyRenderer;
  }

  @property{
    public SDL_Window* window(){ return window_;}
  }
  void init(string title, int width, int height){
    window_ = createWindow(title, width, height);
    if(window_ == null) logf(LogLevel.fatal, "Failed to create window.\n%s", SDL_GetError());
    info("Success to create window.");
    renderer = window_.SDL_CreateRenderer( -1, 0 );
    if(renderer == null) logf(LogLevel.fatal, "Failed to create renderer.\n%s", SDL_GetError());
    info("Success to create renderer.");
    renderer.SDL_SetRenderDrawColor(255, 255, 255, 255);

    auto mapchip = IMG_Load("BGTest2.png");
    auto tex = renderer.SDL_CreateTextureFromSurface(window_.SDL_GetWindowSurface);
    renderer.SDL_RenderCopy(tex, null, null);
    window_.SDL_ShowWindow;

    auto bg1 = new BG(window_, 0, 0, mapchip);
    bgList = new BG[1];
    bgList[0] = bg1;

    spriteList = new Sprite[100];
    auto spchip = IMG_Load("SPTest.png");
    auto testtex = renderer.SDL_CreateTextureFromSurface(spchip);
    spriteList[0] = new Sprite(testtex);
    spriteList[0].move(13, 12);
    spriteList[0].move(130, 120, 120);
    spriteList[0].textureX = 0;
    spriteList[0].textureY = 0;
    spriteList[0].width = 20;
    spriteList[0].height = 16;

    drawFlag = true;
  }
  void render(){
    if(drawFlag){
      renderer.SDL_RenderClear;
      foreach(b; bgList)
      {
        b.draw();
      }
      foreach(s; spriteList)
      {
          if(s)
              s.draw(window, renderer);
      }
      renderer.SDL_RenderPresent;
    }
  }

  void draw(){
    drawFlag = true;
  }
  //Utils
private:
  SDL_Window* createWindow(string title, int width, int height){
    return SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                              width, height, SDL_WINDOW_HIDDEN);
  }
}
