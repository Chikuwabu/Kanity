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
  float draw_w, draw_h; //描画領域の幅、高さ
  float tex_w, tex_h; //テクスチャの幅、高さ
  GLuint glTexture;

public:
  this(int drawArea_w,int drawArea_h){
    draw_w = drawArea_w; draw_h = drawArea_h;
  }

  void draw(){
    glBindTexture(GL_TEXTURE_2D, glTexture);
    glBegin(GL_QUADS);
      glVertex3f(x1, y1, z);
      glVertex3f(x1, y2, z);
      glVertex3f(x2, y2, z);
      glVertex3f(x2, y1, z);

      glTexCoord2f(0,0);
      glTexCoord2f(0,1);
      glTexCoord2f(1,1);
      glTexCoord2f(1,0);
    glEnd();
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
      GLenum pixelFormat;

      //Surfaceのピクセルフォーマットを得る
      int bytesPerPixel = surface.format.BytesPerPixel;
      /+if(bytesPerPixel == 4){ //透明度情報を持つ
        if(surface.format.Rmask == 0x000000ff){ //色の配列
          pixelFormat = GL_RGBA;
        }else{
          pixelFormat = GL_BGRA;
        }
      }else if(bytesPerPixel == 3){ //透明度情報を持たない
        if(surface.format.Rmask == 0x000000ff){ //同上
          pixelFormat = GL_RGB;
        }else{
          pixelFormat = GL_BGR;
        }
      }else{
        //fatal("This is unsupported pixel format!");
        //TODO:SDL_ConvertPixelsを使ってなんとかする
        SDL_ConvertSurface(surface, SDL_PIXELFORMAT_RGBA8888.SDL_AllocFormat, 0);
        pixelFormat = GL_RGBA;
      }+/

      surface = SDL_ConvertSurfaceFormat(surface, SDL_PIXELFORMAT_RGBA8888, 0);
      SDL_GetError().puts();
      pixelFormat = GL_RGBA;
      //得た情報を使ってOpenGLのテクスチャを生成する
      //テクスチャ生成
      glGenTextures(1, &glTexture);
      //バインド
      glBindTexture(GL_TEXTURE_2D, glTexture);
      //テクスチャフィルタ
      //フィルタかけないほうがいいような気がする
      //サーフェスからテクスチャイメージを作成する
      glTexImage2D(GL_TEXTURE_2D, 0, bytesPerPixel, surface.w, surface.h, 0,
                  pixelFormat, GL_UNSIGNED_BYTE, surface.pixels);

      tex_w = surface.w; tex_h = surface.h;
      return surface;
    }
  }
}

class TestSP : DrawableObject{
public:
  this(int drawArea_w,int drawArea_h){
    super(drawArea_w, drawArea_h);
  }
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
