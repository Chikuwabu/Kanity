module kanity.character;

import derelict.sdl2.sdl;
import std.experimental.logger;

/*
Surfaceからキャラクターを生成し、便利に扱えるようにする
*/
//キャラクタ列生成の時、どちらの軸からスキャンするか(NONEはキャラクタ列を生成しない設定)
enum Character_ScanAxis{X, Y}
class Character{
private:
  SDL_Surface* surface_;
  string surfaceName_;
  SDL_Rect[int] characters_;
  SDL_Rect[string] charactersWithString;

public:
  this(SDL_Surface* sf){
      surface_ = sf;
      chipWidth = bgChipSize; chipHeight = bgChipSize;
      scanAxis = Character_ScanAxis.Y;
  }
  //BGのキャラクタの大きさで生成
  this(SDL_Surface* sf, string name){
    surfaceName_ = name;
      this(sf);
  }
  //キャラクタの幅の指定もできる
  //サーフェスを指定の設定で分割する
  uint chipWidth, chipHeight;
  Character_ScanAxis scanAxis;
  public void cut(int chipWidth, int chipHeight, Character_ScanAxis scanAxis)
  {
      this.chipWidth = chipWidth;
      this.chipHeight = chipHeight;
      this.scanAxis = scanAxis;
      cut();
  }
  public void cut(){
    int w, h;
    w = surface_.w / chipWidth; h = surface_.h / chipHeight;
    for(int x = 0; x < w; x++){
      for(int y = 0; y < h; y++){
        SDL_Rect rect;
        rect.x = x * chipWidth; rect.y = y * chipHeight;
        rect.w = chipWidth; rect.h = chipHeight;

        if(scanAxis == Character_ScanAxis.X){
          characters_[x + y * w] = rect;
        }else{
          characters_[y + x * h] = rect;
        }
      }
    }
  }
  //要素の取得
  auto get(uint a){
    if(a in characters_){
      return characters_[a];
    }else return cast(SDL_Rect)0; //TODO:例外投げる
  }
  auto get(string s){
    if(s in charactersWithString){
      return charactersWithString[s];
    }else return cast(SDL_Rect)0; //TODO:例外投げる
  }
  //要素の追加
  void add(int num, int x, int y){ add(num, x, y, bgChipSize, bgChipSize); }
  void add(int num, int x, int y, int w, int h){
    SDL_Rect rect;
    rect.x = x; rect.y = y; rect.w = w; rect.h = h;
    characters_[num] = rect;
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
    string surfaceName(){return surfaceName_;}
    SDL_Rect[int] characters(){return characters_;}
    void characters(SDL_Rect[int] c){characters_ = c;}
  }
  private uint bgChipSize(){
    import kanity.render;
    return Renderer.getData("bgChipSize").get!uint;
  }
}
