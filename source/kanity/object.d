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
  float glTex_w, glTex_h;
protected:
  SDL_Renderer* renderer;
  SDL_Texture* texture;
  int draw_w, draw_h; //描画領域の幅、高さ
  int tex_w, tex_h; //テクスチャの幅、高さ

public:
  this(){
    SDL_Window* window = SDL_GL_GetCurrentWindow();
    int w,h;
    window.SDL_GetWindowSize(&w, &h);
    draw_w = w; draw_h = h;
    renderer = window.SDL_GetRenderer();
    texture = renderer.SDL_CreateTexture(SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STATIC, 1, 1);

    this.priority = 0;
  }
  ~this(){
    texture.SDL_DestroyTexture;
  }

  void draw(){
    texture.SDL_GL_BindTexture(&glTex_w, &glTex_h);
    glBegin(GL_QUADS);
      glTexCoord2f(u1 * glTex_w, v1 * glTex_h); glVertex3f(x1, y1, z);
      glTexCoord2f(u1 * glTex_w, v2 * glTex_h); glVertex3f(x1, y2, z);
      glTexCoord2f(u2 * glTex_w, v2 * glTex_h); glVertex3f(x2, y2, z);
      glTexCoord2f(u2 * glTex_w, v1 * glTex_h); glVertex3f(x2, y1, z);
    glEnd();
    texture.SDL_GL_UnbindTexture();
    glFlush();
  }
protected:
  @property{
    int priority(){return cast(int)(z * 256);} //描画優先度のZ座標に対する倍率は暫定
    float priority(int p_){return z = p_ / 256;}

    //描画先領域
    SDL_Rect drawRect(){
      SDL_Rect rect;
      with(rect){
        x = cast(int)((1 + x1) * draw_w / 2);
        y = cast(int)((1 - y1) * draw_h / 2);
        w = cast(int)((1 + (x2 - x1)) * draw_w / 2);
        h = cast(int)((1 - (y2 - y1)) * draw_h);
      }
      return rect;
    }
    SDL_Rect drawRect(SDL_Rect rect){
      with(rect){
        //座標系の変換
        x1 = (cast(float)x / draw_w * 2) - 1;
        y1 = 1 - (cast(float)y * 2 / draw_h);
        x2 = (cast(float)(x + w) / draw_w * 2) - 1;
        y2 = 1 - (cast(float)(y + h) / draw_h * 2);
      }
      return rect;
    }

    //サーフェスの描画に使う領域
    SDL_Rect texRect(){
      SDL_Rect rect;
      with(rect){
        x = cast(int)(u1 * tex_w);
        y = cast(int)(v1 * tex_h);
        w = cast(int)((u2 - u1) * tex_w);
        h = cast(int)((v2 - v1) * tex_h);
      }
      return rect;
    }
    SDL_Rect texRect(SDL_Rect rect){
      with(rect){
        u1 = cast(float)x / tex_w;
        v1 = cast(float)y / tex_h;
        u2 = cast(float)(x + w) / tex_w;
        v2 = cast(float)(y + h) / tex_h;
      }
      return rect;
    }
    SDL_Surface* surface(SDL_Surface* surface){
      texture.SDL_DestroyTexture;
      texture = renderer.SDL_CreateTextureFromSurface(surface);
      tex_w = surface.w; tex_h = surface.h;
      return surface;
    }
  }
}

class TestSP : DrawableObject{
public:
  ~this(){
  }
  @property{
    override SDL_Rect drawRect(){return super.drawRect;}
    override SDL_Rect drawRect(SDL_Rect rect){super.drawRect = rect; return rect;}
    override SDL_Rect texRect(){return super.texRect;}
    override SDL_Rect texRect(SDL_Rect rect){super.texRect = rect; return rect;}
    override int priority(){return super.priority;}
    override float priority(int p_){super.priority = p_; return p_;}
    override SDL_Surface* surface(SDL_Surface* surface){super.surface = surface; return surface;}
  }

}
