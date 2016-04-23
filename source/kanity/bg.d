module kanity.bg;

import kanity.object;
import kanity.character;
import derelict.sdl2.sdl;
import std.experimental.logger;

class BG : DrawableObject{
private:
  SDL_Rect bg;
  Character character;
  int[] mapData;

  SDL_Surface* bgScreen;
  import kanity.animation;
  AnimationData!int xAnim;
  AnimationData!int yAnim;
public:
  //情報
  uint chipSize;
  uint sizeWidth, sizeHeight;

public:
  this(Character chara){
    super();
    chipSize = *(cast(uint*)window.SDL_GetWindowData("bgChipSize"));
    sizeWidth = *(cast(uint*)window.SDL_GetWindowData("bgSizeWidth"));
    sizeHeight = *(cast(uint*)window.SDL_GetWindowData("bgSizeHeight"));

    character = chara;
    mapData.length = sizeWidth * sizeHeight;
    bgScreen = SDL_CreateRGBSurface(0, chipSize * sizeWidth, chipSize * sizeHeight, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    setTexture();
  }
  this(int x, int y, Character chara){
    this(chara);
    bg.x = x; bg.y = y;
    return;
  }
  this(int w, int h, int x, int y, Character chara){
    this(x, y, chara);
    xAnim.ptr = &bg.x;
    yAnim.ptr = &bg.y;
  }
  ~this(){
    bgScreen.SDL_FreeSurface;
  }

  bool updateFlag;
  //functions
  override void draw(){
    xAnim.animation;
    yAnim.animation;
    if (xAnim.isStarted  || yAnim.isStarted){
        updateFlag = true;
    }
    //toriaezu
    if(updateFlag){
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
        SDL_BlitSurface(character.surface, &(character.characters[mapData[x * sizeHeight + y]]), bgScreen, &rectD);
      }
    }
    super.surface = bgScreen;
  }
}
