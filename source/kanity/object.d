module kanity.object;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import std.experimental.logger;
import std.stdio;

abstract class DrawableObject{
private:
  float x1, y1, x2, y2; //(x1, y1)-(x2, y2)までの範囲を描画
  float z;//Z座標(描画優先度)
  float u1,v1,u2,v2; //(u1,v1)-(u2,v2)までの範囲
  float hx = 0.0f, hy = 0.0f; //描画時用の原点
  float gltexWidth, gltexHeight;
  SDL_Texture* texture_;
  float scale_ = 1.0f, scaleOrigin;
  SDL_Rect drawRect_, texRect_; //誤差対策
  int homeX_ = 0, homeY_ = 0;
protected:
  SDL_Window* window; //描画先のウインドウ
  SDL_Renderer* renderer; //描画に用いるレンダラ
  int drawWidth, drawHeight; //描画領域の幅、高さ
  int texWidth, texHeight; //テクスチャの幅、高さ
  DrawableObject next;

public:
  this(){
    window = SDL_GL_GetCurrentWindow();

    static import kanity.render;
    drawWidth = kanity.render.Renderer.getData("windowWidth").get!uint;
    drawHeight = kanity.render.Renderer.getData("windowHeight").get!uint;
    scaleOrigin = kanity.render.Renderer.getData("renderScale").get!float;

    renderer = window.SDL_GetRenderer();
    texture = renderer.SDL_CreateTexture(SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STATIC, 1, 1);

    this.priority = 0;
  }
  ~this(){
    texture.SDL_DestroyTexture;
  }

  void draw(){
    texture_.SDL_GL_BindTexture(&gltexWidth, &gltexHeight);
    glBegin(GL_QUADS);
      glTexCoord2f(u1 * gltexWidth, v1 * gltexHeight); glVertex3f(x1 - hx, y1 - hy, z);
      glTexCoord2f(u1 * gltexWidth, v2 * gltexHeight); glVertex3f(x1 - hx, y2 - hy, z);
      glTexCoord2f(u2 * gltexWidth, v2 * gltexHeight); glVertex3f(x2 - hx ,y2 - hy, z);
      glTexCoord2f(u2 * gltexWidth, v1 * gltexHeight); glVertex3f(x2 - hx, y1 - hy, z);
    glEnd();
    texture_.SDL_GL_UnbindTexture();
    glFlush();
  }

  void addObject(DrawableObject obj)
  {
      auto last = obj;
      while(last.next)
      {
          last = last.next;
      }
      last.next = next;
      next = last;
  }

  void move(int x, int y){
    auto rect = drawRect;
    rect.x += x; rect.y += y;
    drawRect = rect;
  }
  void setHome(int x, int y){
    homeX_ = x; homeY_ = y;
    reloadHome;
  }
private:
  void reloadHome(){
    hx = +cast(float)(homeX * (scaleOrigin * scale_) / drawWidth * 2);
    hy = -cast(float)(homeY * (scaleOrigin * scale_) / drawHeight * 2);
  }
  public:
  @property{
    int priority(){return cast(int)((1.0 - z) * 256);} //描画優先度のZ座標に対する倍率は暫定
    float priority(int p_){return z = 1.0 - (p_ / 256);}

    //描画される大きさ(倍率)
    float scale(){return scale_;}
    void scale(float s){
      SDL_Rect rect = this.drawRect;
      scale_ = s;
      this.drawRect = rect;
      reloadHome;
    }
    //描画先座標
    int posX(){ return drawRect.x; }
    int posY(){ return drawRect.y; }
    void posX(int n){ auto rect = drawRect; rect.x = n; drawRect = rect; }
    void posY(int n){ auto rect = drawRect; rect.y = n; drawRect = rect; }
    //描画原点
    int homeX(){ return homeX_; }
    int homeY(){ return homeY_; }
    void homeX(int n){ homeX_ = n; reloadHome; }
    void homeY(int n){ homeY_ = n; reloadHome; }
  }

  protected:
  @property{
    //描画先領域
    SDL_Rect drawRect(){ return drawRect_; }
    void drawRect(SDL_Rect rect){
      drawRect_ = rect;
      with(rect){
        //座標系の変換
        x1 = (cast(float)x / drawWidth * 2) - 1;
        y1 = 1 - (cast(float)y / drawHeight * 2);
        x2 = (cast(float)(x + w * (scaleOrigin * scale_)) / drawWidth * 2) - 1;
        y2 = 1 - (cast(float)(y + h * (scaleOrigin * scale_)) / drawHeight * 2);
      }
    }

    //サーフェスの描画に使う領域
    SDL_Rect texRect(){ return texRect_; }
    void texRect(SDL_Rect rect){
      texRect_ = rect;
      with(rect){
        u1 = cast(float)x / texWidth;
        v1 = cast(float)y / texHeight;
        u2 = cast(float)(x + w) / texWidth;
        v2 = cast(float)(y + h) / texHeight;
      }
    }
    SDL_Surface* surface(SDL_Surface* surface){
      texture.SDL_DestroyTexture;
      texture = renderer.SDL_CreateTextureFromSurface(surface);
      texWidth = surface.w; texHeight = surface.h;
      return surface;
    }
    SDL_Texture* texture(){return texture_;}
    SDL_Texture* texture(SDL_Texture* tex){
      uint f; int a;
      tex.SDL_QueryTexture(&f, &a, &texWidth, &texHeight);
      texture_ = tex;
      return tex;
    }
  }
}
