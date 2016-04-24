module kanity.character;

import derelict.sdl2.sdl;

/*
Surfaceからキャラクターを生成し、便利に扱えるようにする
*/
//キャラクタ列生成の時、どちらの軸からスキャンするか(NONEはキャラクタ列を生成しない設定)
enum CHARACTER_SCANAXIS{X, Y, NONE}
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
  this(SDL_Surface* sf, CHARACTER_SCANAXIS scan = CHARACTER_SCANAXIS.Y){ this(sf, bgChipSize, bgChipSize, scan); }
  //キャラクタの幅の指定もできる
  this(SDL_Surface* sf, uint chipWidth, uint chipHeight, CHARACTER_SCANAXIS scan = CHARACTER_SCANAXIS.Y){
    surface_ = sf;
    if(scan == CHARACTER_SCANAXIS.NONE) return;
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
  //要素の取得
  auto get(uint a){
    if(a < characters_.length){
      return characters_[a];
      }else return cast(SDL_Rect)0; //TODO:例外投げる
  }
  auto get(string s){
    if(s in charactersWithString){
      return charactersWithString[s];
    }else return cast(SDL_Rect)0; //TODO:例外投げる
  }
  //要素の追加
  int add(int x, int y){ return add(x, y, bgChipSize, bgChipSize); }
  int add(int x, int y, int w, int h){
    SDL_Rect[] rect = new SDL_Rect[1];
    rect[0].x = x; rect[0].y = y; rect[0].w = w; rect[0].h = h;
    characters_ ~= rect;
    return cast(int)characters_.length - 1;
  }
  void add(string s, int x, int y){ return add(s, x, y, bgChipSize, bgChipSize); }
  void add(string s, int x, int y, int w, int h){
    SDL_Rect rect;
    rect.x = x; rect.y = y; rect.w = w; rect.h = h;
    charactersWithString[s] = rect;
  }
  void remove(string s){
    if(s in charactersWithString){
      charactersWithString.remove(s);
    }//else TODO:例外投げる
  }

  @property{
    SDL_Surface* surface(){return surface_;}
    SDL_Rect[] characters(){return characters_;}
  }
  private uint bgChipSize(){
    static uint size; static bool flag;
    if(flag){
      size = *cast(uint*)kanity.render.Renderer.getData("bgChipSize");
      flag = true;
    }
    return size;
  }
}
