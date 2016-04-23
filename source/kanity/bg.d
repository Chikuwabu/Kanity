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
    SDL_Rect rect;
    with(rect){
      x = 0; y =0;
      w = drawWidth; h = drawHeight;
    }
    this.drawRect = rect;
    this.texRect = rect;
  }
  this(int x, int y, Character chara){
    this(chara);
    //bg.x = x; bg.y = y;
    scroll(x, y);
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
    /*if(updateFlag){
        setTexture();
        updateFlag = false;
    }*/
    super.draw();
    return;
  }

  alias scroll = move;
  override void move(int x, int y){
    bg.x += x; bg.y += y;
    posX = bg.x; posY = bg.y;
  }

  void scroll(int x, int y, int frame){
      xAnim.setAnimation(x, frame);
      yAnim.setAnimation(y, frame);
  }
  @property{
    override int posX(){ return bg.x; }
    override int posY(){ return bg.y; }
    override void posX(int n){
      auto rectD = this.drawRect, rectT = this.texRect;
      if(n < 0){
        rectD.x = -n; rectD.w = drawWidth + n;
        rectT.x = 0;  rectT.w = drawWidth + n;
      }else if(chipSize * sizeWidth - n < drawWidth){
        rectD.x = 0; rectD.w = chipSize * sizeWidth - n;
        rectT.x = n; rectT.w = chipSize * sizeWidth - n;
      }else{
        rectD.x = 0; rectD.w = drawWidth;
        rectT.x = n; rectD.w = drawWidth;
      }
      drawRect = rectD; texRect = rectT;
    }
    override void posY(int n){
      auto rectD = this.drawRect, rectT = this.texRect;
      if(n < 0){
        rectD.y = -n; rectD.h = drawHeight + n;
        rectT.y = 0;  rectT.h = drawHeight + n;
      }else if(chipSize * sizeHeight - n < drawHeight){
        rectD.y = 0; rectD.h = chipSize * sizeHeight - n;
        rectT.y = n; rectT.h = chipSize * sizeHeight - n;
      }else{
        rectD.y = 0; rectD.h = drawHeight;
        rectT.y = n; rectD.h = drawHeight;
      }
      drawRect = rectD; texRect = rectT;
    }
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
