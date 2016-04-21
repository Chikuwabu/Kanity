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
  float drawWidthOrigin, drawHeightOrigin;
  float gltexWidth, gltexHeight;
  SDL_Texture* texture_;
  float scale_;
protected:
  SDL_Window* window; //描画先のウインドウ
  SDL_Renderer* renderer; //描画に用いるレンダラ
  int drawWidth, drawHeight; //描画領域の幅、高さ
  int texWidth, texHeight; //テクスチャの幅、高さ

public:
  this(){
    window = SDL_GL_GetCurrentWindow();
    int w, h;
    window.SDL_GetWindowSize(&w, &h);
    drawWidthOrigin = w; drawHeightOrigin = h;
    renderScale = *(cast(float*)window.SDL_GetWindowData("renderScale"));

    renderer = window.SDL_GetRenderer();
    texture = renderer.SDL_CreateTexture(SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STATIC, 1, 1);

    this.priority = 256;
  }
  ~this(){
    texture.SDL_DestroyTexture;
  }

  void draw(){
    texture_.SDL_GL_BindTexture(&gltexWidth, &gltexHeight);
    glBegin(GL_QUADS);
      glTexCoord2f(u1 * gltexWidth, v1 * gltexHeight); glVertex3f(x1, y1, z);
      glTexCoord2f(u1 * gltexWidth, v2 * gltexHeight); glVertex3f(x1, y2, z);
      glTexCoord2f(u2 * gltexWidth, v2 * gltexHeight); glVertex3f(x2, y2, z);
      glTexCoord2f(u2 * gltexWidth, v1 * gltexHeight); glVertex3f(x2, y1, z);
    glEnd();
    texture_.SDL_GL_UnbindTexture();
    glFlush();
  }

  @property{
  public:
    int priority(){return cast(int)((1.0 - z) * 256);} //描画優先度のZ座標に対する倍率は暫定
    float priority(int p_){return z = 1.0 - (p_ / 256);}

    float renderScale(){return scale_;}
    float renderScale(float scale){
      scale_ = scale;
      drawWidth = cast(int)(drawWidthOrigin / scale_);
      drawHeight = cast(int)(drawHeightOrigin / scale_);
      return scale;
    }

  protected:
    //描画先領域
    SDL_Rect drawRect(){
      SDL_Rect rect;
      with(rect){
        x = cast(int)((1 + x1) * drawWidth / 2);
        y = cast(int)((1 - y1) * drawHeight / 2);
        w = cast(int)((1 + (x2 - x1)) * drawWidth / 2);
        h = cast(int)((1 - (y2 - y1)) * drawHeight);
      }
      return rect;
    }
    SDL_Rect drawRect(SDL_Rect rect){
      with(rect){
        //座標系の変換
        x1 = (cast(float)x / drawWidth * 2) - 1;
        y1 = 1 - (cast(float)y * 2 / drawHeight);
        x2 = (cast(float)(x + w) / drawWidth * 2) - 1;
        y2 = 1 - (cast(float)(y + h) / drawHeight * 2);
      }
      return rect;
    }

    //サーフェスの描画に使う領域
    SDL_Rect texRect(){
      SDL_Rect rect;
      with(rect){
        x = cast(int)(u1 * texWidth);
        y = cast(int)(v1 * texHeight);
        w = cast(int)((u2 - u1) * texWidth);
        h = cast(int)((v2 - v1) * texHeight);
      }
      return rect;
    }
    SDL_Rect texRect(SDL_Rect rect){
      with(rect){
        u1 = cast(float)x / texWidth;
        v1 = cast(float)y / texHeight;
        u2 = cast(float)(x + w) / texWidth;
        v2 = cast(float)(y + h) / texHeight;
      }
      return rect;
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
