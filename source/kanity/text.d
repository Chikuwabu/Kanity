module kanity.text;

import kanity.imports;
import kanity.object;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

class Text : DrawableObject{
private TTF_Font* font_;
private string text_ = "";
private SDL_Color color;
  this(TTF_Font* f){
    super();
    with(color){
      r = 255; g =255; b = 255; a = 255;
    }
    font_ = f;
    render();
  }
  private void render(){
    import std.string;
    if(text_ == "") return;
    
    auto sf = TTF_RenderUTF8_Solid(font_, text_.toStringz, color);
    scope(exit) sf.SDL_FreeSurface();
    this.surface = sf; //TODO:適当実装なのでなんとかしたい
    SDL_Rect rect;
    with(rect){
      x = 0; y = 0;
      w = sf.w; h = sf.h;
    }
    this.drawRect = rect;
    this.texRect = rect;
  }
  @property{
    TTF_Font* font(){return font_;}
    void font(TTF_Font* f){
      font_ = f;
      render();
    }
    int hinting(){
      return font_.TTF_GetFontHinting();
    }
    void hinting(int hint){
      font_.TTF_SetFontHinting(hint);
      render();
    }
    string text(){return text_;}
    void text(string t){
      text_ = t;
      render();
    }
  }
}
