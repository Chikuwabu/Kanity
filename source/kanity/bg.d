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
  //情報
  uint chipSize;
  uint sizeWidth, sizeHeight;
  import kanity.sprite;
  AnimationData!int xAnim;
  AnimationData!int yAnim;

public:
  this(SDL_Surface* lmapChip){
    super();
    chipSize = *(cast(uint*)window.SDL_GetWindowData("bgChipSize"));
    sizeWidth = *(cast(uint*)window.SDL_GetWindowData("bgSizeWidth"));
    sizeHeight = *(cast(uint*)window.SDL_GetWindowData("bgSizeHeight"));

    mapChip = lmapChip;
    bgScreen = SDL_CreateRGBSurface(0, chipSize * sizeWidth, chipSize * sizeHeight, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    setTexture();
    xAnim.ptr = &bg.x;
    yAnim.ptr = &bg.y;
  }
  this(int x, int y, SDL_Surface* lmapChip){
    this(lmapChip);
    bg.x = x; bg.y = y;
    return;
  }
  this(int w, int h, int x, int y, SDL_Surface* lmapChip){
    this(x, y, lmapChip);
    drawWidth = w; drawHeight = h;
  }
  ~this(){
    bgScreen.SDL_FreeSurface;
  }
  bool updateFlag;
  //functions
  override public void draw(){
      xAnim.animation;
      yAnim.animation;
      if (xAnim.isStarted  || yAnim.isStarted)
      {
          updateFlag = true;
      }
      //toriaezu
      if(updateFlag)
      {
          setTexture();
          updateFlag = false;
      }
    //転送先座標の計算
    SDL_Rect rectS, rectD;
    with(rectS){
      x = 0; y = 0;
      w = drawWidth; h = drawHeight;
    }
    with(rectD){
      x = 0; y = 0;
      w = drawWidth; h = drawHeight;
    }
    if(bg.x < 0){
      rectS.w = drawWidth + bg.x;
      rectS.x = 0;
      rectD.w = rectS.w;
      rectD.x = -bg.x;
    }else if(0){
      rectS.w = drawWidth - bg.x;
      rectS.x = bg.x;
      rectD.w = rectS.w;
      rectD.x = 0;
    }else{
      rectS.w = drawWidth;
      rectS.x = bg.x;
      rectD.w = rectS.w;
      rectD.x = 0;
    }
    if(bg.y < 0){
      rectS.h = drawHeight + bg.y;
      rectS.y = 0;
      rectD.h = rectS.h;
      rectD.y = -bg.y;
    }else if(0){
      rectS.h = drawHeight - bg.y;
      rectS.y = bg.y;
      rectD.h = rectS.h;
      rectD.y = 0;
    }else{
      rectS.h = drawHeight;
      rectS.y = bg.y;
      rectD.h = rectS.h;
      rectD.y = 0;
    }
    this.texRect = rectS;
    this.drawRect = rectD;
    super.draw();
    return;
  }
  void scroll(int x, int y){
      updateFlag = true;
    bg.x += x; bg.y += y;
  }

  void scroll(int x, int y, int frame){
      xAnim.setAnimation(x, frame);
      yAnim.setAnimation(y, frame);
  }

private:
  void setTexture(){
    //転送
    SDL_Rect rectS, rectD;//source, destnation
    with(rectS){
      x = 0; y = 0;
      w = chipSize; h = chipSize;
    }
    with(rectD){
      x = 0; y = 0;
      w = chipSize; h = chipSize;
    }
    for(int x = 0; x < sizeWidth; x++){
      for(int y = 0; y < sizeHeight; y++){
        rectD.x = x * chipSize; rectD.y = y * chipSize;
        rectS.y = mapData[x][y] * chipSize;
        SDL_BlitSurface(mapChip, &rectS, bgScreen, &rectD);
      }
    }
    super.surface = bgScreen;
  }
}
