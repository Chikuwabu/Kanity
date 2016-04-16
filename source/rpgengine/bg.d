module rpgengine.bg;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.experimental.logger;

class BG{
private:
  SDL_Window* window; //描画先ウィンドウ
  SDL_Renderer* renderer;
  SDL_Rect bg;
  SDL_Surface* mapChip;
  int[64][64] mapData;//[x][y]
  SDL_Surface* bgScreen;
  SDL_Texture* tex;

public:
  this(SDL_Window* lWindow, int x, int y, SDL_Surface* lmapChip){
    init(lWindow, x, y, lmapChip);
    setTexture();
    //foreach()
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
    if(bg.x < 0){
      rectS.w = window_w + bg.x;
      rectS.x = 0;
      rectD.w = rectS.w;
      rectD.x = -bg.x;
    }else if(16*64 - bg.x < window_w){
      rectS.w = 16*64 - bg.x;
      rectS.x = bg.x;
      rectD.w = rectS.w;
      rectD.x = 0;
    }else{
      rectS.w = window_w;
      rectS.x = bg.x;
      rectD.w = rectS.w;
      rectD.x = 0;
    }
    if(bg.y < 0){
      rectS.h = window_h + bg.y;
      rectS.y = 0;
      rectD.h = rectS.h;
      rectD.y = -bg.y;
    }else if(16*64 - bg.y < window_h){
      rectS.h = 16*64 - bg.y;
      rectS.y = bg.y;
      rectD.h = rectS.h;
      rectD.y = 0;
    }else{
      rectS.h = window_h;
      rectS.y = bg.y;
      rectD.h = rectS.h;
      rectD.y = 0;
    }
    renderer.SDL_RenderCopy(tex, &rectS, &rectD);
    return;
  }
  void scroll(int x, int y){
    bg.x += x; bg.y += y;
  }
  //Utils
private:
  void init(SDL_Window* lWindow, int x, int y, SDL_Surface* lmapChip){
    window = lWindow;
    renderer = window.SDL_GetRenderer;
    bg.x = x; bg.y = y;
    //Deep copy(mapChip)
    mapChip = SDL_CreateRGBSurface(0, 16, 16*256, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    SDL_BlitSurface(lmapChip, null, mapChip, null);

    bgScreen = window.SDL_GetWindowSurface;
    tex = renderer.SDL_CreateTextureFromSurface(bgScreen);
    return;
  }

  void setTexture(){
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
        rectS.y = 0 * 16;

        SDL_BlitSurface(mapChip, &rectS, bgScreen, &rectD);
      }
    }
    //サーフェスをテクスチャに変換
    tex.SDL_DestroyTexture;
    tex = renderer.SDL_CreateTextureFromSurface(bgScreen);
    return;
  }
}
