module kanity.character;

import derelict.sdl2.sdl;

/*
Surfaceからキャラクターを生成し、便利に扱えるようにする
*/
//キャラクタ列生成の時、どちらの軸からスキャンするか
enum CHARACTER_SCANAXIS{X,Y}
class Character{
private:
  SDL_Surface* surface_;
  SDL_Rect[] characters_;
  SDL_Rect[string] charactersWithString;

public:
  ~this(){
    surface.SDL_FreeSurface;
  }
  //Surfaceだけ渡された場合、BGのキャラクタの大きさで生成
  this(SDL_Surface* sf, CHARACTER_SCANAXIS scan = CHARACTER_SCANAXIS.Y){
    int chipSize = *(cast(uint*)(SDL_GL_GetCurrentWindow().SDL_GetWindowData("bgChipSize")));
    this(sf, chipSize, chipSize, scan);
  }
  //キャラクタの幅の指定もできる
  this(SDL_Surface* sf, uint chipWidth, uint chipHeight, CHARACTER_SCANAXIS scan = CHARACTER_SCANAXIS.Y){
    surface_ = sf;
    int w, h;
    w = sf.w / chipWidth; h = sf.h / chipHeight;
    characters_.length = w * h;
    for(int x = 0; x < w; x++){
      for(int y = 0; y < h; y++){
        SDL_Rect rect;
        rect.x = x * chipWidth; rect.y = y * chipHeight;
        rect.w = chipWidth; rect.h = chipHeight;

        if(scan == CHARACTER_SCANAXIS.X){
          characters_[x + y * w] = rect;
        }else{
          characters_[y + x * h] = rect;
        }
      }
    }
  }
  //パターンを指定することも可能
  this(SDL_Surface* sf, SDL_Rect[] rects){
    surface_ = sf;
    characters_ = rects.dup;
  }
  //文字列をキーとするパターンの連想配列も渡せる
  this(SDL_Surface* sf, SDL_Rect[string] rects){
    surface_ = sf;
    charactersWithString = rects.dup;
  }
  auto getWithNum(uint a){return characters_[a];}
  auto getWithString(string s){return charactersWithString[s];}

  @property{
    SDL_Surface* surface(){return surface_;}
    SDL_Rect[] characters(){return characters_;}
  }
}
