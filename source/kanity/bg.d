module kanity.bg;

import kanity.object;
import derelict.sdl2.sdl;
import std.experimental.logger;

class BG : DrawableObject{
private:
  SDL_Rect bg;
  SDL_Surface* mapChip;
  int[64][64] mapData;//[x][y]
  SDL_Surface* bgScreen;

public:
  this(int x, int y, SDL_Surface* lmapChip){
    super();
    bg.x = x; bg.y = y;
    mapChip = lmapChip;
    //TODO:ハードコーディングよくないので直す
    bgScreen = SDL_CreateRGBSurface(0, 16*64, 16*64, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    setTexture();
    return;
  }
  ~this(){
    bgScreen.SDL_FreeSurface;
  }
  //functions
  override public void draw(){
    //転送先座標の計算
    SDL_Rect rectS, rectD;
    with(rectS){
      x = 0; y = 0;
      w = draw_w; h = draw_h;
    }
    with(rectD){
      x = 0; y = 0;
      w = draw_w; h = draw_h;
    }
    if(bg.x < 0){
      rectS.w = draw_w + bg.x;
      rectS.x = 0;
      rectD.w = rectS.w;
      rectD.x = -bg.x;
    }else if(0){
      rectS.w = draw_w - bg.x;
      rectS.x = bg.x;
      rectD.w = rectS.w;
      rectD.x = 0;
    }else{
      rectS.w = draw_w;
      rectS.x = bg.x;
      rectD.w = rectS.w;
      rectD.x = 0;
    }
    if(bg.y < 0){
      rectS.h = draw_h + bg.y;
      rectS.y = 0;
      rectD.h = rectS.h;
      rectD.y = -bg.y;
    }else if(0){
      rectS.h = draw_h - bg.y;
      rectS.y = bg.y;
      rectD.h = rectS.h;
      rectD.y = 0;
    }else{
      rectS.h = draw_h;
      rectS.y = bg.y;
      rectD.h = rectS.h;
      rectD.y = 0;
    }
    with(rectS){
      w = w/2;
      h = h/2;
    }
    this.texRect = rectS;
    this.drawRect = rectD;
    super.draw();
    return;
  }
  void scroll(int x, int y){
    bg.x += x; bg.y += y;
  }

private:
  void setTexture(){
    //TODO:ハードコーディングが(ry
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
        rectD.x = x * 16; rectD.y = y * 16;
        rectS.y = mapData[x][y] * 16;
        SDL_BlitSurface(mapChip, &rectS, bgScreen, &rectD);
      }
    }
    super.surface = bgScreen;
  }
}
