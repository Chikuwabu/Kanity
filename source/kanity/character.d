module kanity.character;

import derelict.sdl2.sdl;
import std.experimental.logger;

/*
Surfaceからキャラクターを生成し、便利に扱えるようにする
*/
//キャラクタ列生成の時、どちらの軸からスキャンするか(NONEはキャラクタ列を生成しない設定)
enum CHARACTER_SCANAXIS{X, Y}
class Character{
private:
    SDL_Surface* surface_;
    string surfaceName_;
    SDL_Rect[] characters_;
    SDL_Rect[string] charactersWithString;

public:
    this(SDL_Surface* sf){
        surface_ = sf;
        chipWidth = bgChipSize; chipHeight = bgChipSize;
    }
    this(SDL_Surface* sf, string name){
        this(sf);
        surfaceName_ = name;
    }
    //キャラクタの幅の指定もできる
    //サーフェスを指定の設定で分割する
    uint chipWidth, chipHeight;
    CHARACTER_SCANAXIS scanAxis;
    public void cut(uint chipWidth, uint chipHeight, CHARACTER_SCANAXIS scanAxis){
        this.chipWidth = chipWidth;
        this.chipHeight = chipHeight;
        this.scanAxis = scanAxis;
        cut();
    }
    public void cut(){
        int w, h;
        w = surface_.w / chipWidth; h = surface_.h / chipHeight;
        characters_.length = w * h;
        for(int x = 0; x < w; x++){
            for(int y = 0; y < h; y++){
                SDL_Rect rect;
                rect.x = x * chipWidth; rect.y = y * chipHeight;
                rect.w = chipWidth; rect.h = chipHeight;

                if(scanAxis == CHARACTER_SCANAXIS.X){
                    characters_[x + y * w] = rect;
                }else{
                    characters_[y + x * h] = rect;
                }
            }
        }
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
        SDL_Rect rect;
        rect.x = x; rect.y = y; rect.w = w; rect.h = h;
        characters_.length = characters_.length + 1;
        characters_[$-1] = rect;
        return cast(int)characters_.length -1;
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
        SDL_Surface* surface()
        {
            return surface_;
        }
        string surfaceName()
        {
            return surfaceName_;
        }
        SDL_Rect[] characters()
        {
            return characters_;
        }
        void characters(SDL_Rect[] hage)
        {
            characters_ = hage;
        }
    }
    private uint bgChipSize(){
        import kanity.render;
        return Renderer.getData("bgChipSize").get!uint;
    }
}
