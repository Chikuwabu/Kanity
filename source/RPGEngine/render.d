module RPGEngine.render;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.experimental.logger;
import std.string;
import core.stdc.stdio;

class Renderer{
  //フィールド
  private SDL_Window* window;
  private SDL_Renderer* renderer;

  this(string title, int width, int height){
    window = CreateWindow(title, width, height);
    renderer = window.SDL_CreateRenderer( -1, 0 );
  }
  ~this(){
    window.SDL_DestroyWindow;
  }

  void run(){
    //window.SDL_ShowWindow;
    SDL_InitSubSystem(SDL_INIT_VIDEO);

    auto mapchip = IMG_Load("BGTest.png");
    auto tex = renderer.SDL_CreateTextureFromSurface(window.SDL_GetWindowSurface);
    renderer.SDL_RenderCopy(tex, null, null);
    window.SDL_ShowWindow;
    renderer.SDL_SetRenderDrawColor(255, 255, 255, 255);
    renderer.SDL_RenderClear;
    renderer.SDL_RenderPresent;

    auto bg = new BG(window, 0, 0, mapchip);

    renderer.SDL_RenderClear;
    bg.draw;
    renderer.SDL_RenderPresent;
    SDL_Delay(3000);
  }
  //Getter
  public SDL_Window* GetWindow(){
    return window;
  }
  //Utils
  private SDL_Window* CreateWindow(string title, int width, int height){
    return SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                              width, height, SDL_WINDOW_HIDDEN);
  }
}

class BG{
  private SDL_Window* window; //描画先ウィンドウ
  private SDL_Renderer* renderer;
  private int bg_x, bg_y;
  private SDL_Surface* mapChip;
  private int[64][64] mapData;//[x][y]
  private SDL_Surface* bgScreen;
  private SDL_Texture* tex;

  this(SDL_Window* lWindow, int x, int y, SDL_Surface* lmapChip){
    init(lWindow, x, y, lmapChip);
    setTexture();
    return;
  }
  ~this(){
    mapChip.SDL_FreeSurface;
    bgScreen.SDL_FreeSurface;
    tex.SDL_DestroyTexture;
  }
  //functions
  public void draw(){
    //転送先座標の計算
    SDL_Rect rectS, rectD;
    int window_w, window_h;
    window.SDL_GetWindowSize(&window_w, &window_h);

    with(rectS){
      x = 0; y = 0;
      w = window_w; h = window_h;
    }
    with(rectD){
      x = 0; y = 0;
      w = window_w; h = window_h;
    }
    if(bg_x < 0){
      rectS.w = window_w + bg_x;
      rectS.x = 0;
      rectD.w = rectS.w;
      rectD.x = -bg_x;
    }else if(16*64 - bg_x){
      rectS.w = 16*64 - bg_x;
      rectS.x = bg_x;
      rectD.w = rectS.w;
      rectD.x = 0;
    }else{
      rectS.w = window_w;
      rectS.x = bg_x;
      rectD.w = rectS.w;
      rectD.x = 0;
    }
    if(bg_y < 0){
      rectS.h = window_h + bg_y;
      rectS.y = 0;
      rectD.h = rectS.h;
      rectD.y = -bg_y;
    }else if(16*64 - bg_y){
      rectS.h = 16*64 - bg_y;
      rectS.y = bg_y;
      rectD.h = rectS.h;
      rectD.y = 0;
    }else{
      rectS.h = window_h;
      rectS.y = bg_y;
      rectD.h = rectS.h;
      rectD.y = 0;
    }
    renderer.SDL_RenderCopy(tex, &rectS, &rectD);
    return;
  }
  //Utils
  private void init(SDL_Window* lWindow, int x, int y, SDL_Surface* lmapChip){
    window = lWindow;
    renderer = window.SDL_GetRenderer;
    bg_x = x; bg_y = y;
    //Deep copy(mapChip)
    //IMG_Loadで取得したSurfaceのw,hを読むと落ちるからハードコーディングに甘んじる
    mapChip = SDL_CreateRGBSurface(0, 16, 16*256, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    SDL_BlitSurface(lmapChip, null, mapChip, null);
    tex = renderer.SDL_CreateTextureFromSurface(lmapChip);
    renderer.SDL_RenderCopy(tex, null, null);
    renderer.SDL_RenderPresent;
    bgScreen = window.SDL_GetWindowSurface;
    tex = renderer.SDL_CreateTextureFromSurface(bgScreen);
    return;
  }

  private void setTexture(){
    //転送
    SDL_Rect rectS, rectD;//source, destnation
    with(rectS){
      x = 0; y = 0*16;
      w = 16; h = 16;
    }
    with(rectD){
      x = 0; y = 0;
      w = 16; h = 16;
    }
    for(int x = 0; x < 64; x++){
      for(int y = 0; y < 64; y++){
        rectD.x = x*16; rectD.y = y*16;
        rectS.y = /+mapData[x][y]+/1 * 16;
        SDL_BlitSurface(mapChip, &rectS, bgScreen, &rectD);
      }
    }
    //サーフェスをテクスチャに変換
    tex.SDL_DestroyTexture;
    tex = renderer.SDL_CreateTextureFromSurface(bgScreen);
    return;
  }
}
