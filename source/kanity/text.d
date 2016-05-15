module kanity.text;

import kanity.imports;
import kanity.object;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

class Text : DrawableObject{
private TTF_Font* font_;
public string fontName;
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
  this(TTF_Font* f, string name){
    this(f);
    fontName = name;
  }
  private void render(){
    import std.string, std.utf, std.array;
    if(text == "") return;

    auto tempText = text.split("\n").map!(a => cast(ushort*)(a.toUTF16z)).array;
    auto width = tempText.map!((a){
      int w, h;
      TTF_SizeUNICODE(font, a, &w, &h);
      return w;
    }).minCount!"a > b"()[0];
    auto height = tempText.length.to!int * font.TTF_FontHeight;

    SDL_Surface* tempSurface = SDL_CreateRGBSurface(0, width, height, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    scope(exit) tempSurface.SDL_FreeSurface();
    SDL_Surface* sf;
    scope(exit) sf.SDL_FreeSurface();
    foreach(int i, a; tempText){
      sf = font.TTF_RenderUNICODE_Solid(a, SDL_Color(255, 255, 255));
      SDL_Rect rect;
      with(rect){
        x = 0; y = i * font.TTF_FontHeight;
        y.log;
        w = sf.w; h = sf.h;
      }
      SDL_BlitSurface(sf, cast(SDL_Rect*)null, tempSurface, &rect);
    }

    this.surface = tempSurface;
    SDL_Rect rect;
    with(rect){
      x = 0; y = 0;
      w = tempSurface.w; h = tempSurface.h;
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
