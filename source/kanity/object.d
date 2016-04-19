module kanity.object;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;

abstract class DrawableObject{
private:
  float x,y,z; //ワールド座標系での値
  float u1,v1,u2,v2; //(u1,v1)-(u2,v2)までの範囲
  int draw_w, draw_h; //描画領域の幅、高さ
  int tex_w, tex_h; //テクスチャの幅、高さ
protected:
  SDL_Surface* surface; //テクスチャの元になるサーフェス

public:
  this(int drawArea_w,int drawArea_h){
    draw_w = drawArea_w; draw_h = drawArea_h;
  }

  void draw(){

  }
protected:
  @property{
    int drawX(){return cast(int)(x * draw_w);}
    float drawX(int x_){return x = x_ / draw_w;}

    int drawY(){return cast(int)(y * draw_h);}
    float drawY(int y_){return y = y_ / draw_h;}

    int priority(){return cast(int)(z * 256);} //描画優先度のZ座標に対する倍率は暫定
    float priority(int p_){return z = p_ / 256;}

    //サーフェスの描画に使う領域
    SDL_Rect rect(){
      SDL_Rect rect;
      with(rect){
        x = cast(int)(u1 * tex_w);
        y = cast(int)(v1 * tex_h);
        w = cast(int)((u2 - u1) * tex_w);
        h = cast(int)((v2 - v1) * tex_h);
      }
      return rect;
    }
    SDL_Rect rect(SDL_Rect rect){
      with(rect){
        u1 = x / tex_w;
        v1 = y / tex_h;
        u2 = (x + w) / tex_w;
        v2 = (y + h) / tex_h;
      }
      return rect;
    }
  }

  
}

class TestSP : DrawableObject{
  this(int drawArea_w,int drawArea_h){
    super(drawArea_w, drawArea_h);
  }
  ~this(){
  }
}
